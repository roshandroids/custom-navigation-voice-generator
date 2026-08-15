"""Piper TTS adapter.

Runs the ``piper`` CLI as a subprocess. Official Nepali voices exist
(``ne_NP/chitwan``, ``ne_NP/google``) and are the default; override via
``--voice`` (or PIPER_VOICE env var) to compare others.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

from benchmark.core.audio import inspect_wav
from benchmark.core.registry import register
from benchmark.core.tts import AudioInfo, TTSAdapter


def _find_piper() -> str | None:
    env = os.environ.get("PIPER_BIN")
    if env and shutil.which(env):
        return env
    return shutil.which("piper")


@register
class PiperAdapter(TTSAdapter):
    """Piper: fast local neural TTS via the piper CLI (subprocess)."""

    name = "piper"
    model = "piper (onnx voice model)"
    voice = "ne_NP-chitwan-medium"
    languages = ["ne", "en", "ne-en"]  # official ne_NP voices exist (see notes)
    supports_devanagari = True  # ne_NP voices accept Devanagari input — verify quality
    requires_gpu = False
    notes = (
        "Requires the `piper` CLI (pip install piper-tts) and a voice .onnx model "
        "(auto-downloaded on first run). Official Nepali voices: ne_NP-chitwan-medium, "
        "ne_NP-google-x_low, ne_NP-google-medium (see rhasspy/piper VOICES.md). "
        "Override via the --voice CLI flag. NOTE: rhasspy/piper is archived (Oct 2025); "
        "active development moved to OHF-Voice/piper1-gpl (GPL) — licensing: "
        "docs/decisions/engine-licensing.md."
    )

    def __init__(self, voice: str | None = None, sample_rate: int = 16000, **kwargs):
        voice = voice or os.environ.get("PIPER_VOICE")
        if voice is not None:
            self.voice = voice
        self.sample_rate = sample_rate

    def check_available(self) -> str | None:
        if _find_piper() is None:
            return (
                "piper CLI not found on PATH (install with `pip install piper-tts` "
                "or set PIPER_BIN)"
            )
        return None

    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        cmd = [
            _find_piper(),
            "--model", self.voice,
            "--output_file", str(output_path),
            "--sample_rate", str(self.sample_rate),
        ]
        proc = subprocess.run(
            cmd, input=text, capture_output=True, text=True, timeout=300
        )
        if proc.returncode != 0:
            raise RuntimeError(
                f"piper exited {proc.returncode}: {proc.stderr.strip()[:500]}"
            )
        return inspect_wav(output_path)
