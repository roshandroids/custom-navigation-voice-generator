"""Chatterbox TTS adapter.

Chatterbox (Resemble AI) is Python/PyTorch based. Like Qwen3-TTS it can require
a dedicated environment, so this adapter shells out to a CLI. The exact CLI
command is UNVERIFIED at scaffold time — adjust CHATTERBOX_CMD (or the code
below) to match the installed Chatterbox version.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

from benchmark.core.audio import inspect_wav
from benchmark.core.registry import register
from benchmark.core.tts import AudioInfo, TTSAdapter


def _find_cmd() -> str | None:
    env = os.environ.get("CHATTERBOX_CMD")
    if env and shutil.which(env):
        return env
    return shutil.which("chatterbox-tts")


@register
class ChatterboxAdapter(TTSAdapter):
    """Chatterbox: Resemble AI's conversational TTS, run via CLI (subprocess)."""

    name = "chatterbox"
    model = "chatterbox (default checkpoint)"
    voice = "default"
    languages = ["en"]  # Nepali unsupported/unknown — must be verified
    supports_devanagari = False
    requires_gpu = False  # CPU inference possible — verify
    notes = (
        "Requires its own env with `pip install chatterbox-tts` (PyTorch) and model "
        "download on first run. Adapter shells out to the `chatterbox-tts` CLI "
        "(override with CHATTERBOX_CMD). CLI flags and Nepali support are UNVERIFIED "
        "at scaffold time."
    )

    def __init__(self, voice: str | None = None, **kwargs):
        if voice is not None:
            self.voice = voice

    def check_available(self) -> str | None:
        if _find_cmd() is None:
            return (
                "chatterbox-tts CLI not found (install Chatterbox in its own env and "
                "set CHATTERBOX_CMD, or add it to PATH)"
            )
        return None

    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        cmd = [
            _find_cmd(),
            "--text", text,
            "--output", str(output_path),
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
        if proc.returncode != 0:
            raise RuntimeError(
                f"chatterbox exited {proc.returncode}: {proc.stderr.strip()[:500]}"
            )
        return inspect_wav(output_path)
