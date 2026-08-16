"""Audio utilities: WAV metadata inspection and standardized format helpers."""

from __future__ import annotations

import struct
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


def read_pcm16_mono(path: Path) -> tuple[list[int], int]:
    """Read a WAV as mono 16-bit PCM samples + its sample rate.

    Converts to mono (averages channels) if the file has more than one channel.
    Raises ``wave.Error`` / ``ValueError`` for unsupported formats.
    """
    with wave.open(str(path), "rb") as w:
        channels = w.getnchannels()
        sample_width = w.getsampwidth()
        sample_rate = w.getframerate()
        raw = w.readframes(w.getnframes())
    if sample_width != 2:
        raise ValueError(f"unsupported sample width {sample_width} (need 16-bit PCM)")
    n_frames = len(raw) // (2 * channels)
    samples = [0] * n_frames
    for i in range(n_frames):
        total = 0
        for c in range(channels):
            offset = (i * channels + c) * 2
            total += struct.unpack_from("<h", raw, offset)[0]
        samples[i] = total // channels
    return samples, sample_rate


def resample_linear(samples: list[int], src_rate: int, dst_rate: int) -> list[int]:
    """Linearly resample mono PCM16 samples to a new sample rate (pure Python).

    Suitable for short TTS segments; linear interpolation is adequate for
    voice-concatenation purposes (no anti-aliasing filter). Keeps the result
    within int16 range.
    """
    if src_rate == dst_rate:
        return samples
    if src_rate <= 0 or dst_rate <= 0:
        raise ValueError("sample rates must be positive")
    n_out = int(len(samples) * dst_rate / src_rate)
    ratio = src_rate / dst_rate
    out = [0] * n_out
    for i in range(n_out):
        pos = i * ratio
        idx = int(pos)
        frac = pos - idx
        if idx + 1 < len(samples):
            out[i] = int(samples[idx] * (1 - frac) + samples[idx + 1] * frac)
        else:
            out[i] = samples[idx]
    return out


def write_pcm16_mono(path: Path, samples: list[int], sample_rate: int) -> Path:
    """Write mono 16-bit PCM samples to a WAV file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        frames = bytearray()
        for s in samples:
            clipped = max(-32768, min(32767, s))
            frames += struct.pack("<h", clipped)
        w.writeframes(bytes(frames))
    return path


def concatenate_wavs(
    inputs: list[Path],
    output: Path,
    target_rate: int,
) -> tuple[float, int]:
    """Concatenate WAV files into one mono 16-bit PCM WAV at ``target_rate``.

    Each input is read as mono PCM16 and linearly resampled to ``target_rate``
    before concatenation, so mixed sample rates stitch cleanly. Returns
    ``(duration_seconds, sample_rate)`` of the output.
    """
    out_samples: list[int] = []
    for src in inputs:
        samples, rate = read_pcm16_mono(src)
        out_samples.extend(resample_linear(samples, rate, target_rate))
    write_pcm16_mono(output, out_samples, target_rate)
    duration = len(out_samples) / target_rate if target_rate else 0.0
    return round(duration, 4), target_rate


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
