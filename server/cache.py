"""Content-addressed on-disk WAV cache for the TTS service.

Generated audio is stored under ``<cache_dir>/<sha256(text + voice)>.wav`` so
repeated requests for the same text+voice reuse the file (the stream-from-URL
path stays cheap and idempotent). The cache directory defaults to
``benchmark/output/server_cache/`` (gitignored build output).
"""

from __future__ import annotations

import hashlib
from pathlib import Path

CACHE_DIR = (
    Path(__file__).resolve().parents[1] / "benchmark" / "output" / "server_cache"
)


def asset_id(text: str, voice: str) -> str:
    """Content hash used as the cache filename stem and stream asset id."""
    digest = hashlib.sha256(f"{voice}\0{text}".encode()).hexdigest()
    return f"{voice}__{digest}"


def cache_path(cache_dir: Path, text: str, voice: str) -> Path:
    """Path of the cached WAV for text+voice (parent dir created)."""
    path = cache_dir / f"{asset_id(text, voice)}.wav"
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def lookup(cache_dir: Path, asset_id: str) -> Path | None:
    """Resolve an asset id to a cached WAV file, if present."""
    candidate = cache_dir / f"{asset_id}.wav"
    return candidate if candidate.is_file() else None
