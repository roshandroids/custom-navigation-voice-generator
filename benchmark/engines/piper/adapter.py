"""Piper TTS adapter.

Runs the ``piper`` CLI as a subprocess. Official Nepali voices exist
(``ne_NP-chitwan-medium``, ``ne_NP-google-medium``, ``ne_NP-google-x_low``)
and are the default; override via ``--voice`` (or PIPER_VOICE env var).

Voice models are looked up in ``benchmark/engines/piper/models/``
(``<voice>.onnx`` + ``<voice>.onnx.json``, downloaded from
huggingface.co/rhasspy/piper-voices) via the CLI ``--data-dir`` flag.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

from benchmark.core.audio import inspect_wav
from benchmark.core.registry import register
from benchmark.core.tts import AudioInfo, TTSAdapter

MODELS_DIR = Path(__file__).resolve().parent / "models"


def _find_piper() -> str | None:
    env = os.environ.get("PIPER_BIN")
    if env and shutil.which(env):
        return env
    found = shutil.which("piper")
    if found:
        return found
    # Fall back to the same venv's bin directory (console-script venvs are not
    # always on PATH when invoked via `python -m` or another console script).
    import sys

    venv_bin = Path(sys.prefix) / "bin" / "piper"
    if venv_bin.exists():
        return str(venv_bin)
    return None


def _voice_model_path(voice: str) -> Path | None:
    """Resolve a voice name to a local .onnx model path (data-dir lookup)."""
    candidate = MODELS_DIR / f"{voice}.onnx"
    return candidate if candidate.exists() else None


@register
class PiperAdapter(TTSAdapter):
    """Piper: fast local neural TTS via the piper CLI (subprocess)."""

    name = "piper"
    model = "piper (onnx voice model)"
    voice = "ne_NP-chitwan-medium"
    languages = ["ne", "en", "ne-en"]  # official ne_NP voices exist (see notes)
    supports_devanagari = True  # ne_NP voices accept Devanagari input — verified
    requires_gpu = False
    notes = (
        "Requires the `piper` CLI (pip install piper-tts) and local voice models in "
        "benchmark/engines/piper/models/. Official Nepali voices: "
        "ne_NP-chitwan-medium, ne_NP-google-medium, ne_NP-google-x_low "
        "(huggingface.co/rhasspy/piper-voices). NOTE: piper-tts is now the GPL-3.0 "
        "OHF-Voice/piper1-gpl fork (rhasspy/piper is archived) — licensing: "
        "docs/decisions/engine-licensing.md."
    )

    def __init__(self, voice: str | None = None, sample_rate: int | None = None, **kwargs):
        voice = voice or os.environ.get("PIPER_VOICE")
        if voice is not None:
            self.voice = voice
        # piper's CLI has no sample-rate flag; the voice model config determines
        # the output rate (chitwan/google-medium: 22050 Hz, google-x_low: 16000 Hz).
        # We record the actual rate from the generated WAV via inspect_wav.
        self.sample_rate = sample_rate

    def check_available(self) -> str | None:
        if _find_piper() is None:
            return (
                "piper CLI not found on PATH (install with `pip install piper-tts` "
                "or set PIPER_BIN)"
            )
        if _voice_model_path(self.voice) is None:
            return (
                f"voice model not found: {self.voice!r} "
                f"(expected {MODELS_DIR / (self.voice + '.onnx')})"
            )
        return None

    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        model_path = _voice_model_path(self.voice)
        if model_path is None:
            expected = MODELS_DIR / (self.voice + ".onnx")
            raise RuntimeError(f"voice model not found: {self.voice!r} (expected {expected})")
        cmd = [
            _find_piper(),
            "--model", str(model_path),
            "--output_file", str(output_path),
            "--data-dir", str(MODELS_DIR),
        ]
        proc = subprocess.run(
            cmd, input=text, capture_output=True, text=True, timeout=300
        )
        if proc.returncode != 0:
            raise RuntimeError(
                f"piper exited {proc.returncode}: {proc.stderr.strip()[:500]}"
            )
        return inspect_wav(output_path)
