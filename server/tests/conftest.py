"""Shared fixtures for server tests.

Adds the repo root to sys.path (same pattern as tests/conftest.py) and exposes
helpers to stub the Piper adapter so the tests never shell out to a real piper.
"""

from __future__ import annotations

import sys
import wave
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT))


def write_tiny_wav(path: Path, seconds: float = 0.5, sample_rate: int = 22050) -> Path:
    """Write a minimal mono 16-bit PCM WAV (silence) for fixture audio."""
    path.parent.mkdir(parents=True, exist_ok=True)
    n_frames = int(seconds * sample_rate)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        w.writeframes(b"\x00\x00" * n_frames)
    return path


class FakePiperAdapter:
    """Drop-in stub for server.voices.make_adapter -> PiperAdapter.synthesize."""

    def __init__(self, output_bytes: bytes):
        self.output_bytes = output_bytes
        self.called_with: list[tuple[str, Path]] = []

    def synthesize(self, text: str, output_path: Path) -> None:
        self.called_with.append((text, output_path))
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_bytes(self.output_bytes)


class FailingPiperAdapter(FakePiperAdapter):
    def synthesize(self, text: str, output_path: Path):  # noqa: ARG002
        raise RuntimeError("simulated piper failure")


@pytest.fixture
def tiny_wav_bytes(tmp_path: Path) -> bytes:
    return write_tiny_wav(tmp_path / "fixture.wav").read_bytes()


@pytest.fixture
def stub_piper(monkeypatch: pytest.MonkeyPatch, tiny_wav_bytes: bytes):
    """Replace server.voices.make_adapter with a stub returning a tiny WAV.

    Returns a callable ``set_fail`` to make the next synthesis raise instead.
    """
    import server.tts as tts_mod
    import server.voices as voices_mod

    state = {"fail": False}

    def fake_make_adapter(voice: str):
        if state["fail"]:
            return FailingPiperAdapter(tiny_wav_bytes)
        return FakePiperAdapter(tiny_wav_bytes)

    monkeypatch.setattr(voices_mod, "make_adapter", fake_make_adapter)
    # tts_mod calls make_adapter via server.voices.make_adapter.
    monkeypatch.setattr(tts_mod, "make_adapter", fake_make_adapter)
    return state


@pytest.fixture
def app_cache_dir(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    """Point the FastAPI app's cache dir at a temp directory."""
    import server.app as app_mod

    cache_dir = tmp_path / "server_cache"
    cache_dir.mkdir(parents=True, exist_ok=True)
    monkeypatch.setattr(app_mod, "_CACHE_DIR", cache_dir)
    return cache_dir
