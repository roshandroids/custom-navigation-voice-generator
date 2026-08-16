"""TTS engine adapter abstraction.

Every engine in the benchmark implements :class:`TTSAdapter`. The benchmark runner
depends only on this interface, so adding a new engine never touches core logic.
"""

from __future__ import annotations

import json
from abc import ABC, abstractmethod
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class AudioInfo:
    """Metadata about a generated WAV file."""

    duration_seconds: float | None = None
    sample_rate: int | None = None
    channels: int | None = None
    sample_width_bytes: int | None = None
    format: str = "wav"
    codec: str = "pcm"

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class SynthesisResult:
    """Outcome of a single text -> WAV generation attempt."""

    engine: str
    model: str
    voice: str
    phrase_id: str
    text: str
    output_file: str | None
    success: bool
    started_at: str
    duration_seconds: float
    audio: AudioInfo | None = None
    error_message: str | None = None
    extra: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        d["audio"] = d.get("audio")  # AudioInfo already dataclass-as-dict via asdict
        return d

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)


@dataclass
class EngineSpec:
    """Static description of an engine adapter (used for registration/docs)."""

    name: str
    description: str
    languages: list[str]
    supports_devanagari: bool
    requires_gpu: bool
    setup_docs: str | None = None
    supported: bool = True
    notes: str | None = None


def now_utc_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


# ---------------------------------------------------------------------------
# Adapter interface
# ---------------------------------------------------------------------------


class TTSAdapter(ABC):
    """Interface every benchmark engine adapter implements.

    Subclasses provide :meth:`synthesize`, which writes a WAV file to
    ``output_path`` and returns an :class:`AudioInfo`. The runner wraps calls to
    :meth:`synthesize` with timing and error capture, so adapters do **not** handle
    their own exceptions.
    """

    #: Public engine name (directory name under ``benchmark/engines/``).
    name: str

    #: Model identifier, e.g. the checkpoint/onnx file name used.
    model: str

    #: Voice identifier (language model in Piper terms, voice in Kokoro terms).
    voice: str

    #: Which corpus languages this engine accepts as-is.
    languages: list[str]

    #: Whether this engine can consume Devanagari script text directly.
    supports_devanagari: bool = False

    #: Whether a GPU is required to run this engine at all.
    requires_gpu: bool = False

    #: Free-form setup/run notes surfaced to the user and docs.
    notes: str | None = None

    @abstractmethod
    def synthesize(self, text: str, output_path: Path) -> AudioInfo:
        """Synthesize ``text`` to a WAV file at ``output_path``.

        Must create a valid WAV file. Return :class:`AudioInfo` describing it
        (fields left ``None`` are recorded as unknown). Raise on failure; the runner
        converts exceptions into failed results.
        """

    def check_available(self) -> str | None:
        """Return None if the engine can run, else a short reason it cannot.

        The default implementation assumes the engine is available. Adapters that
        depend on external processes or uninstalled packages should override this.
        """
        return None

    def spec(self) -> EngineSpec:
        return EngineSpec(
            name=self.name,
            description=self.__doc__ or "",
            languages=list(self.languages),
            supports_devanagari=self.supports_devanagari,
            requires_gpu=self.requires_gpu,
            setup_docs=self.notes,
            supported=self.check_available() is None,
            notes=self.notes,
        )

    def prepare(self) -> None:
        """Optional one-time setup hook (model download, etc.), called once per run."""
        return None
