"""Synthesis handler: drives Piper through the benchmark PiperAdapter.

Synthesizes text+voice to a temp WAV (the adapter's file-based contract),
then stores it in the cache and returns the raw bytes plus metadata. The
caller (FastAPI route) turns the result into an HTTP response.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from benchmark.core.audio import inspect_wav
from server import cache as cache_mod
from server.voices import make_adapter


class SynthesisError(Exception):
    """Raised when Piper fails to synthesize the requested audio."""


@dataclass(frozen=True)
class SynthesisOutcome:
    """A successful synthesis: bytes + metadata for the HTTP response."""

    wav_bytes: bytes
    duration_ms: int
    sample_rate: int
    asset_id: str
    voice: str


def synthesize(
    text: str,
    voice: str,
    cache_dir: Path | None = None,
) -> SynthesisOutcome:
    """Synthesize ``text`` with the Piper voice and return the WAV payload.

    Raises ``SynthesisError`` on Piper/adapter failure. ``voice`` is a short
    frontend voice id (see ``server.voices``).
    """
    if not text.strip():
        raise SynthesisError("text must not be empty")

    target = cache_dir or cache_mod.CACHE_DIR
    wav_path: Path = cache_mod.cache_path(target, text.strip(), voice)
    if not wav_path.is_file():
        adapter = make_adapter(voice)
        try:
            adapter.synthesize(text.strip(), wav_path)
        except Exception as exc:  # adapter raises RuntimeError/OSError/etc.
            # Never leave a partial file behind.
            wav_path.unlink(missing_ok=True)
            raise SynthesisError(f"piper failed for voice {voice!r}: {exc}") from exc

    audio = inspect_wav(wav_path)
    wav_bytes = wav_path.read_bytes()
    return SynthesisOutcome(
        wav_bytes=wav_bytes,
        duration_ms=round((audio.duration_seconds or 0.0) * 1000),
        sample_rate=audio.sample_rate or 0,
        asset_id=cache_mod.asset_id(text.strip(), voice),
        voice=voice,
    )
