"""Tests for the FastAPI routes (server.app)."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from server.app import app


@pytest.fixture
def client(app_cache_dir, app_store, stub_piper) -> TestClient:  # noqa: ARG001 (fixtures wired via monkeypatch)
    return TestClient(app)


def test_get_voices_shape(client):
    resp = client.get("/v1/voices")
    assert resp.status_code == 200
    body = resp.json()
    assert "available" in body
    assert "voices" in body
    assert "languages" in body
    assert "piper_ok" in body
    # Every catalog voice is listed in the maps.
    assert set(body["voices"]) == {
        "chitwan",
        "google-medium",
        "google-x-low",
        "joe",
        "kristin",
        "ljspeech",
    }


def test_synthesize_returns_wav_bytes_and_headers(client, app_cache_dir):
    resp = client.post(
        "/v1/synthesize",
        json={"text": "देब्रे मोड्नुहोस्।", "voice": "chitwan", "language": "ne"},
    )
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "audio/wav"
    assert resp.headers["x-audio-duration"] == "500"  # fixture 0.5s
    assert resp.headers["x-audio-sample-rate"] == "22050"
    assert resp.headers["x-audio-voice"] == "chitwan"
    body = resp.content
    assert body.startswith(b"RIFF")


def test_synthesize_defaults_voice_from_language(client):
    # language "ne" -> default voice "chitwan".
    resp = client.post(
        "/v1/synthesize", json={"text": "देब्रे मोड्नुहोस्।", "language": "ne"}
    )
    assert resp.status_code == 200
    assert resp.headers["x-audio-voice"] == "chitwan"


def test_synthesize_language_mismatch_400(client):
    resp = client.post(
        "/v1/synthesize",
        json={"text": "Turn left", "voice": "chitwan", "language": "en"},
    )
    assert resp.status_code == 400


def test_synthesize_empty_text_400(client):
    resp = client.post(
        "/v1/synthesize", json={"text": "   ", "language": "ne"}
    )
    assert resp.status_code == 400


def test_synthesize_unknown_voice_400(client):
    resp = client.post(
        "/v1/synthesize", json={"text": "hi", "voice": "nope", "language": "en"}
    )
    assert resp.status_code == 400


def test_synthesize_missing_voice_and_language_400(client):
    resp = client.post("/v1/synthesize", json={"text": "hi"})
    assert resp.status_code == 400


def test_synthesize_piper_failure_500(client, stub_piper):
    stub_piper["fail"] = True
    resp = client.post(
        "/v1/synthesize", json={"text": "hi", "voice": "joe", "language": "en"}
    )
    assert resp.status_code == 500
    assert "detail" in resp.json()


def test_stream_audio_serves_cached_wav(client, app_cache_dir):
    synth = client.post(
        "/v1/synthesize", json={"text": "hi", "voice": "joe", "language": "en"}
    )
    assert synth.status_code == 200
    asset_id = synth.headers["x-audio-url"].split("/")[-1].removesuffix(".wav")

    stream = client.get(f"/v1/audio/{asset_id}.wav")
    assert stream.status_code == 200
    assert stream.headers["content-type"] == "audio/wav"
    assert stream.content.startswith(b"RIFF")


def test_stream_audio_unknown_404(client):
    resp = client.get("/v1/audio/nope.wav")
    assert resp.status_code == 404


# -- voice packs ---------------------------------------------------------


def test_list_voice_packs_seeded(client):
    resp = client.get("/v1/voice-packs")
    assert resp.status_code == 200
    ids = {p["id"] for p in resp.json()}
    assert {"seed-ne", "seed-en"} <= ids


def test_get_voice_pack(client):
    resp = client.get("/v1/voice-packs/seed-en")
    assert resp.status_code == 200
    assert resp.json()["id"] == "seed-en"


def test_get_voice_pack_404(client):
    assert client.get("/v1/voice-packs/nope").status_code == 404


def test_create_voice_pack(client):
    resp = client.post(
        "/v1/voice-packs",
        json={"name": "My Pack", "language": "ne", "voice": "chitwan", "personality": "firm"},
    )
    assert resp.status_code == 201
    pack = resp.json()
    assert pack["id"].startswith("pack-")
    assert pack["name"] == "My Pack"
    # New pack carries canonical Nepali instructions.
    instrs = client.get(f"/v1/voice-packs/{pack['id']}/instructions").json()
    assert len(instrs) == 23


def test_create_voice_pack_rejects_voice_language_mismatch(client):
    resp = client.post(
        "/v1/voice-packs",
        json={"name": "Bad", "language": "en", "voice": "chitwan", "personality": "firm"},
    )
    assert resp.status_code == 400


# -- instructions --------------------------------------------------------


def test_list_instructions_for_pack(client):
    resp = client.get("/v1/voice-packs/seed-en/instructions")
    assert resp.status_code == 200
    assert len(resp.json()) == 22


def test_get_instruction_404(client):
    assert client.get("/v1/voice-packs/seed-ne/instructions/nope").status_code == 404


def test_patch_instruction_updates_custom_text_and_recorded(client):
    resp = client.patch(
        "/v1/voice-packs/seed-ne/instructions/turn_left_001",
        json={"customText": "मेरो आफ्नै।", "isRecorded": True},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["customText"] == "मेरो आफ्नै।"
    assert body["isRecorded"] is True
    assert client.get("/v1/voice-packs/seed-ne/progress").json() == {
        "recorded": 1,
        "total": 23,
    }


def test_attach_audio_then_export(client):
    # Synthesize a clip into the cache, then attach its url to an instruction.
    synth = client.post(
        "/v1/synthesize", json={"text": "turn left", "voice": "joe", "language": "en"}
    )
    assert synth.status_code == 200
    audio_url = synth.headers["x-audio-url"]

    attached = client.put(
        "/v1/voice-packs/seed-en/instructions/en_turn_left_001/audio",
        json={"audioUrl": audio_url},
    )
    assert attached.status_code == 200
    assert attached.json()["audioUrl"] == audio_url

    exported = client.post(
        "/v1/voice-packs/seed-en/export",
        json={"includeCleanAudio": True, "includeRecordingAudio": True},
    )
    assert exported.status_code == 200
    bundle = exported.json()
    assert bundle["packName"] == "English Daily"
    assert bundle["fileCount"] == 1  # only the attached instruction has audio


def test_export_unknown_pack_404(client):
    assert client.post("/v1/voice-packs/nope/export", json={}).status_code == 404


# -- suggestions ---------------------------------------------------------


def test_suggestions_returns_two(client):
    resp = client.post(
        "/v1/suggestions",
        json={
            "situation": "बायाँ मोड",
            "standardText": "देब्रे मोड्नुहोस्।",
            "personality": "savage",
            "language": "ne",
        },
    )
    assert resp.status_code == 200
    body = resp.json()
    assert len(body) == 2
    assert body[0]["text"].startswith("देब्रे मोड्नुहोस्।")
    assert body[0]["personality"] == "savage"
    assert body[1]["text"].startswith("बायाँ मोड")


def test_suggestions_invalid_language_400(client):
    resp = client.post(
        "/v1/suggestions",
        json={"situation": "x", "standardText": "y", "personality": "simple", "language": "fr"},
    )
    assert resp.status_code == 400
