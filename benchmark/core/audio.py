"""Audio utilities: WAV metadata inspection and standardized format helpers."""

from __future__ import annotations

import wave
from pathlib import Path

from benchmark.core.tts import AudioInfo


def inspect_wav(path: Path) -> AudioInfo:
    """Read metadata from a WAV file.

    Raises ``wave.Error`` if the file is not a readable WAV; returns an
    :class:`AudioInfo` with ``duration_seconds``, ``sample_rate``, ``channels``
    and ``sample_width_bytes`` filled in.
    """
    with wave.open(str(path), "rb") as w:
        sample_rate = w.getframerate()
        channels = w.getnchannels()
        sample_width = w.getsampwidth()
        frames = w.getnframes()
    duration = frames / sample_rate if sample_rate else 0.0
    return AudioInfo(
        duration_seconds=round(duration, 4),
        sample_rate=sample_rate,
        channels=channels,
        sample_width_bytes=sample_width,
    )


def write_silence_wav(path: Path, duration_seconds: float, sample_rate: int = 16000) -> Path:
    """Write a silent WAV file (used by the dummy engine and tests).

    Pure-stdlib PCM16 mono output.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    n_frames = int(duration_seconds * sample_rate)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        w.writeframes(b"\x00\x00" * n_frames)
    return path


def resample_wav_file(
    src: Path,
    dst: Path,
    target_rate: int,
    target_channels: int = 1,
) -> Path:
    """Resample/convert a WAV using ``ffmpeg`` (required on PATH).

    Raises ``RuntimeError`` if ffmpeg is missing or fails. Used by adapters whose
    engines output at a non-standard rate or in another container, so the corpus is
    evaluated at a consistent ``target_rate`` mono.
    """
    cmd = [
        "ffmpeg", "-y", "-i", str(src),
        "-ar", str(target_rate),
        "-ac", str(target_channels),
        "-c:a", "pcm_s16le",
        str(dst),
    ]
    import subprocess

    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"ffmpeg failed for {src.name}: {proc.stderr.strip()}")
    return dst
