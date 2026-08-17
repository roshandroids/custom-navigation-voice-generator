"""Tests for the FastAPI routes (server.app)."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from server.app import app


@pytest.fixture
def client(app_cache_dir, stub_piper) -> TestClient:  # noqa: ARG001 (stub ensures hermetic piper)
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
