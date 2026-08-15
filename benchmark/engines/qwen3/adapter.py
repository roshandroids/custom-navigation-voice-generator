"""Qwen3-TTS adapter.

Qwen3-TTS has heavier, version-sensitive requirements (PyTorch, its own model
download, and in some setups its own Python environment). This adapter isolates
those requirements by shelling out to a ``qwen3-tts`` CLI. If that CLI is not
installed, the engine is reported unavailable and the rest of the benchmark
still runs.

The exact CLI flags are documented as needing verification — they are read from
the Qwen3-TTS installation and may change between versions.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

from benchmark.core.audio import inspect_wav
from benchmark.core.registry import register
from benchmark.core.tts import AudioInfo, TTSAdapter


def _find_cli() -> str | None:
    env = os.environ.get("QWEN3_TTS_BIN")
    if env and shutil.which(env):
        return env
    return shutil.which("qwen3-tts")


@register
class Qwen3Adapter(TTSAdapter):
    """Qwen3-TTS: Alibaba's large TTS model, run via the qwen3-tts CLI (subprocess)."""

    name = "qwen3"
    model = "Qwen3-TTS (default checkpoint)"
    voice = "default"
    languages = ["ne", "en", "ne-en"]  # multilingual model — Nepali needs verification
    supports_devanagari = True  # model handles Devanagari input — must be verified
    requires_gpu = False  # can run on CPU at reduced speed — verify
    notes = (
        "Requires a separate Python env with `pip install qwen3-tts` (PyTorch) and "
        "the model checkpoint. The adapter shells out to the `qwen3-tts` CLI; set "
        "QWEN3_TTS_BIN if the CLI lives outside this venv. CLI flags and Nepali "
        "quality are UNVERIFIED at scaffold time."
    )

    def __init__(self, voice: str | None = None, speed: float = 1.0, **kwargs):
        if voice is not None:
            self.voice = voice
        self.speed = speed

    def check_available(self) -> str | None:
        if _find_cli() is None:
            return (
                "qwen3-tts CLI not found (install Qwen3-TTS in its own env and "
                "set QWEN3_TTS_BIN, or add it to PATH)"
            )
        return None

    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        cmd = [
            _find_cli(),
            "--text", text,
            "--output", str(output_path),
            "--voice", self.voice,
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
        if proc.returncode != 0:
            raise RuntimeError(
                f"qwen3-tts exited {proc.returncode}: {proc.stderr.strip()[:500]}"
            )
        return inspect_wav(output_path)
