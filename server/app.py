"""FastAPI app: router and routes for the TTS service.

Endpoints:
- ``GET  /v1/voices``            — available voices, piper health, language groups
- ``POST /v1/synthesize``        — synthesize text, return WAV bytes (+ metadata headers)
- ``GET  /v1/audio/{asset}.wav`` — stream a previously synthesized (cached) WAV
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse, Response
from pydantic import BaseModel, ConfigDict

from server import cache as cache_mod
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

# Cache directory is overridable (tests point at a tmp dir).
_CACHE_DIR: Path = cache_mod.CACHE_DIR


class SynthesizeRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    text: str
    voice: str | None = None
    language: str | None = None


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
