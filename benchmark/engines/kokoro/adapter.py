"""Kokoro TTS adapter (kokoro-onnx).

In-process adapter using the ``kokoro_onnx`` Python package. Official voices are
English (with additional languages in newer releases); Nepali is NOT currently
supported — the corpus renders Nepali phrases in Latin script for this engine,
which is a compromise to evaluate, not a Nepali capability claim.
"""

from __future__ import annotations

import wave
from pathlib import Path

from benchmark.core.audio import inspect_wav, resample_wav_file
from benchmark.core.registry import register
from benchmark.core.tts import AudioInfo, TTSAdapter

KOKORO_DEFAULT_SAMPLE_RATE = 24000


@register
class KokoroAdapter(TTSAdapter):
    """Kokoro: lightweight high-quality TTS via kokoro_onnx (in-process)."""

    name = "kokoro"
    model = "kokoro-v1.0 (onnx)"
    voice = "af_heart"
    languages = ["en"]  # Nepali NOT supported — see adapter docstring
    supports_devanagari = False
    requires_gpu = False
    notes = (
        "Requires `pip install kokoro-onnx` plus the model files (kokoro-v1.0.onnx, "
        "voices-v1.0.bin), downloaded via `python -m kokoro_onnx.download`. Runs in "
        "this venv. Voices are language-specific; af_* are English. No Nepali voice "
        "exists at the time of writing."
    )

    def __init__(
        self,
        voice: str | None = None,
        model_id: str = "kokoro-v1.0",
        language_id: str = "a",
        target_sample_rate: int = 16000,
        **kwargs,
    ):
        if voice is not None:
            self.voice = voice
        self.model_id = model_id
        self.language_id = language_id
        self.target_sample_rate = target_sample_rate
        self._pipe = None

    def check_available(self) -> str | None:
        try:
            import kokoro_onnx  # noqa: F401
        except ImportError:
            return "kokoro-onnx not installed in this venv (`pip install kokoro-onnx`)"
        return None

    def prepare(self) -> None:
        """Download the model/voice files on first use (idempotent)."""
        import subprocess
        import sys

        subprocess.run(
            [sys.executable, "-m", "kokoro_onnx.download"],
            check=False,
        )

    def _get_pipeline(self):
        if self._pipe is None:
            from kokoro_onnx import KokoroPipeline

            self._pipe = KokoroPipeline(
                language_id=self.language_id,
                model_id=self.model_id,
            )
        return self._pipe

    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        samples, sample_rate = self._get_pipeline().create(text, voice=self.voice)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        raw_path = output_path.with_suffix(".raw.wav")
        _write_float32_wav(raw_path, samples, sample_rate)

        if self.target_sample_rate and sample_rate != self.target_sample_rate:
            try:
                resample_wav_file(raw_path, output_path, self.target_sample_rate, 1)
                raw_path.unlink(missing_ok=True)
            except RuntimeError:
                # No ffmpeg: keep native rate, record it in metadata.
                raw_path.replace(output_path)
        else:
            raw_path.replace(output_path)
        return inspect_wav(output_path)


def _write_float32_wav(path: Path, samples, sample_rate: int) -> None:
    """Write float32 samples (-1..1) as 16-bit PCM mono WAV without numpy in core."""
    import struct

    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        frames = bytearray()
        for value in samples:
            clipped = max(-1.0, min(1.0, float(value)))
            frames += struct.pack("<h", int(clipped * 32767))
        w.writeframes(bytes(frames))
