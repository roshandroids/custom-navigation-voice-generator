"""Dummy adapter: no dependencies, always available.

Writes a short silent WAV so the full pipeline (registry -> runner -> output ->
results) can be exercised end-to-end without installing any TTS engine. Also the
reference implementation for writing a new adapter.
"""

from __future__ import annotations

from pathlib import Path

from benchmark.core.audio import write_silence_wav
from benchmark.core.registry import register
from benchmark.core.tts import AudioInfo, TTSAdapter


@register
class DummyAdapter(TTSAdapter):
    """Dummy engine: generates a fixed-length silent WAV (no real speech)."""

    name = "dummy"
    model = "dummy-v1"
    voice = "silence"
    languages = ["ne", "en", "ne-en"]
    supports_devanagari = True
    requires_gpu = False
    notes = (
        "Fake engine used for pipeline testing and as a wiring reference. "
        "It writes silence; it does not produce speech."
    )

    def __init__(self, duration: float = 1.0, sample_rate: int = 16000, **kwargs):
        self.duration = duration
        self.sample_rate = sample_rate

    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        write_silence_wav(output_path, duration_seconds=self.duration, sample_rate=self.sample_rate)
        return AudioInfo(
            duration_seconds=self.duration,
            sample_rate=self.sample_rate,
            channels=1,
            sample_width_bytes=2,
        )
