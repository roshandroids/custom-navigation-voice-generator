"""FastAPI app: router and routes for the TTS service.

Endpoints:
- ``GET   /v1/voices``            — available voices, piper health, language groups
- ``POST  /v1/synthesize``        — synthesize text, return WAV bytes (+ metadata headers)
- ``GET   /v1/audio/{asset}.wav`` — stream a previously synthesized (cached) WAV
- ``GET/POST /v1/voice-packs``    — list / create voice packs
- ``GET /v1/voice-packs/{id}`` + ``/instructions`` + ``/progress`` — pack detail
- ``PATCH .../instructions/{i}``, ``PUT .../audio`` — update instruction state
- ``POST /v1/voice-packs/{id}/export`` — build an export ZIP bundle
- ``POST /v1/suggestions``        — generate personalized instruction alternatives
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse, Response
from pydantic import BaseModel, ConfigDict

from server import cache as cache_mod
from server import export as export_mod
from server import store as store_mod
from server import suggestions as suggestions_mod
from server import tts as tts_mod
from server.voices import (
    LANGUAGE_BY_VOICE,
    SUPPORTED_LANGUAGES,
    VOICE_MAP,
    available_voices,
    default_voice_for,
    piper_ok,
    resolve_voice,
    validate_language,
)

app = FastAPI(title="Custom Navigation Voice TTS", version="0.1.0")

# Cache + store paths are overridable (tests point at tmp dirs).
_CACHE_DIR: Path = cache_mod.CACHE_DIR
_STORE_PATH: Path = store_mod.STORE_PATH
_EXPORT_DIR: Path = export_mod.EXPORT_DIR
# Store created lazily on first use so importing the app never touches the
# real store file; tests replace _STORE with a tmp-backed instance.
_STORE: store_mod.AppStore | None = None


class SynthesizeRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    text: str
    voice: str | None = None
    language: str | None = None


class CreateVoicePackRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str
    language: str
    voice: str
    personality: str


class PatchInstructionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    customText: str | None = None
    isRecorded: bool | None = None


class AttachAudioRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    audioUrl: str


class SuggestionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    situation: str
    standardText: str
    personality: str
    language: str


class ExportRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    includeCleanAudio: bool = True
    includeRecordingAudio: bool = True


@app.get("/v1/voices")
def voices() -> dict[str, Any]:
    """Report which voices work end to end (cli + model file present)."""
    avail = available_voices()
    languages: dict[str, list[str]] = {}
    for lang in SUPPORTED_LANGUAGES:
        languages[lang] = [
            vid for vid in avail if LANGUAGE_BY_VOICE.get(vid) == lang
        ]
    return {
        "available": avail,
        "voices": {vid: resolve_voice(vid) for vid in sorted(VOICE_MAP)},
        "languages": languages,
        "piper_ok": piper_ok(),
    }


@app.post("/v1/synthesize", response_class=Response)
def synthesize(req: SynthesizeRequest) -> Response:
    """Synthesize ``text`` and return an ``audio/wav`` payload.

    Headers:
    - ``X-Audio-Duration``  ms
    - ``X-Audio-Sample-Rate``
    - ``X-Audio-Voice``     the short voice id used
    - ``X-Audio-Url``       path to stream this clip via ``GET /v1/audio/...``
    """
    text = req.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="text must not be empty")

    # Resolve voice (explicit, else language default).
    voice = req.voice or (default_voice_for(req.language) if req.language else None)
    if voice is None:
        raise HTTPException(status_code=400, detail="voice or language is required")
    try:
        resolve_voice(voice)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    if req.language:
        try:
            validate_language(voice, req.language)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc

    try:
        outcome = tts_mod.synthesize(text, voice, cache_dir=_CACHE_DIR)
    except tts_mod.SynthesisError as exc:
        return JSONResponse(status_code=500, content={"detail": str(exc)})

    return Response(
        content=outcome.wav_bytes,
        media_type="audio/wav",
        headers={
            "X-Audio-Duration": str(outcome.duration_ms),
            "X-Audio-Sample-Rate": str(outcome.sample_rate),
            "X-Audio-Voice": outcome.voice,
            "X-Audio-Url": f"/v1/audio/{outcome.asset_id}.wav",
        },
    )


@app.get("/v1/audio/{asset_id}.wav")
def stream_audio(asset_id: str) -> FileResponse:
    """Stream a cached WAV by its asset id (see ``X-Audio-Url``)."""
    path = cache_mod.lookup(_CACHE_DIR, asset_id)
    if path is None:
        raise HTTPException(status_code=404, detail="audio not found")
    return FileResponse(path, media_type="audio/wav")


def _store() -> store_mod.AppStore:
    global _STORE
    if _STORE is None:
        _STORE = store_mod.AppStore(_STORE_PATH)
    return _STORE


def _not_found(exc: store_mod.StoreError) -> HTTPException:
    return HTTPException(status_code=404, detail=str(exc))


@app.get("/v1/voice-packs")
def list_voice_packs() -> list[dict[str, Any]]:
    return _store().get_packs()


@app.post("/v1/voice-packs", status_code=201)
def create_voice_pack(req: CreateVoicePackRequest) -> dict[str, Any]:
    name = req.name.strip()
    if not name:
        raise HTTPException(status_code=400, detail="name must not be empty")
    try:
        resolve_voice(req.voice)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    try:
        validate_language(req.voice, req.language)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    try:
        return _store().create_pack(name, req.language, req.voice, req.personality)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.get("/v1/voice-packs/{pack_id}")
def get_voice_pack(pack_id: str) -> dict[str, Any]:
    try:
        return _store().get_pack(pack_id)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.get("/v1/voice-packs/{pack_id}/instructions")
def list_instructions(pack_id: str) -> list[dict[str, Any]]:
    try:
        return _store().get_instructions(pack_id)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.get("/v1/voice-packs/{pack_id}/instructions/{instr_id}")
def get_instruction(pack_id: str, instr_id: str) -> dict[str, Any]:
    try:
        return _store().get_instruction(pack_id, instr_id)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.patch("/v1/voice-packs/{pack_id}/instructions/{instr_id}")
def patch_instruction(
    pack_id: str, instr_id: str, req: PatchInstructionRequest
) -> dict[str, Any]:
    try:
        return _store().update_instruction(
            pack_id,
            instr_id,
            custom_text=req.customText,
            is_recorded=req.isRecorded,
        )
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.put("/v1/voice-packs/{pack_id}/instructions/{instr_id}/audio")
def attach_audio(pack_id: str, instr_id: str, req: AttachAudioRequest) -> dict[str, Any]:
    try:
        return _store().attach_audio(pack_id, instr_id, req.audioUrl)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.get("/v1/voice-packs/{pack_id}/progress")
def pack_progress(pack_id: str) -> dict[str, int]:
    try:
        return _store().progress(pack_id)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc


@app.post("/v1/suggestions")
def generate_suggestions(req: SuggestionRequest) -> list[dict[str, Any]]:
    try:
        return suggestions_mod.generate(
            situation=req.situation,
            standard_text=req.standardText,
            personality=req.personality,
            language=req.language,
        )
    except suggestions_mod.SuggestionError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@app.post("/v1/voice-packs/{pack_id}/export")
def export_pack(pack_id: str, req: ExportRequest) -> dict[str, Any]:
    try:
        pack = _store().get_pack(pack_id)
        instructions = _store().get_instructions(pack_id)
    except store_mod.StoreError as exc:
        raise _not_found(exc) from exc
    bundle = export_mod.build_bundle(
        pack,
        instructions,
        cache_dir=_CACHE_DIR,
        output_root=_EXPORT_DIR,
        include_clean=req.includeCleanAudio,
        include_recording=req.includeRecordingAudio,
    )
    return bundle
