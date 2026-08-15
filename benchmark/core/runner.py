"""Benchmark runner: drives adapters over the corpus and writes results.

The runner knows only about :class:`TTSAdapter` and the registry — never about a
specific engine. It provides per-engine error isolation (one broken engine does not
stop the others) and per-phrase timing.
"""

from __future__ import annotations

import csv
import json
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from benchmark.core.audio import inspect_wav
from benchmark.core.corpus import Phrase
from benchmark.core.registry import available_engines, create_engine
from benchmark.core.tts import SynthesisResult, now_utc_iso

#: Standardized sample rate applied to generated WAVs (mono PCM).
STANDARD_SAMPLE_RATE = 16000


@dataclass
class BenchmarkConfig:
    """Configuration for a benchmark run."""

    engines: list[str] = field(default_factory=list)
    phrases: list[Phrase] | None = None
    output_root: Path = Path("benchmark/output")
    results_dir: Path = Path("benchmark/results")
    sample_rate: int = STANDARD_SAMPLE_RATE
    force: bool = False

    def engine_dirs(self) -> dict[str, Path]:
        return {name: self.output_root / name for name in self.engines}


@dataclass
class RunSummary:
    """Aggregate numbers for one engine after a run."""

    engine: str
    total: int
    succeeded: int
    failed: int
    total_duration_seconds: float
    avg_duration_seconds: float


class BenchmarkRunner:
    """Executes a set of engines over a set of phrases."""

    def __init__(self, config: BenchmarkConfig):
        self.config = config
        self.engines = [create_engine(name) for name in config.engines]

    # -- path helpers --------------------------------------------------------

    def output_dir_for(self, engine_name: str) -> Path:
        return self.config.output_root / engine_name

    def output_path_for(self, engine_name: str, phrase_id: str) -> Path:
        return self.output_dir_for(engine_name) / f"{phrase_id}.wav"

    def results_file_for(self, engine_name: str) -> Path:
        return self.config.results_dir / f"{engine_name}.json"

    # -- generation ----------------------------------------------------------

    def generate(self, engine_name: str, phrase: Phrase) -> SynthesisResult:
        """Run one engine on one phrase, with timing + error capture.

        Never raises: every outcome is a ``SynthesisResult`` with ``success`` set.
        """
        adapter = next(e for e in self.engines if e.name == engine_name)
        output_path = self.output_path_for(engine_name, phrase.id)
        text = self._select_text(adapter, phrase)

        if not self.config.force and output_path.exists():
            # Reuse previously generated audio; still record a result for it.
            started = now_utc_iso()
            audio = inspect_wav(output_path)
            return SynthesisResult(
                engine=engine_name,
                model=adapter.model,
                voice=adapter.voice,
                phrase_id=phrase.id,
                text=text,
                output_file=str(output_path),
                success=True,
                started_at=started,
                duration_seconds=0.0,
                audio=audio,
                extra={"reused": True},
            )

        started = now_utc_iso()
        t0 = time.monotonic()
        try:
            output_path.parent.mkdir(parents=True, exist_ok=True)
            audio = adapter.synthesize(text, output_path)
            elapsed = time.monotonic() - t0
            if not output_path.exists():
                raise RuntimeError("adapter reported success but no WAV file was written")
            if audio is None:
                audio = inspect_wav(output_path)
            return SynthesisResult(
                engine=engine_name,
                model=adapter.model,
                voice=adapter.voice,
                phrase_id=phrase.id,
                text=text,
                output_file=str(output_path),
                success=True,
                started_at=started,
                duration_seconds=round(elapsed, 4),
                audio=audio,
            )
        except Exception as exc:  # noqa: BLE001 - intentional: isolate engine failures
            elapsed = time.monotonic() - t0
            return SynthesisResult(
                engine=engine_name,
                model=adapter.model,
                voice=adapter.voice,
                phrase_id=phrase.id,
                text=text,
                output_file=str(output_path),
                success=False,
                started_at=started,
                duration_seconds=round(elapsed, 4),
                error_message=f"{type(exc).__name__}: {exc}",
            )

    def run_engine(self, engine_name: str, phrases: list[Phrase]) -> list[SynthesisResult]:
        """Run one engine over all phrases; returns one result per phrase."""
        adapter = next(e for e in self.engines if e.name == engine_name)
        adapter.prepare()  # one-time setup (model download) before the run
        results = [self.generate(engine_name, phrase) for phrase in phrases]
        self._write_results(engine_name, results)
        return results

    def run_all(self, phrases: list[Phrase]) -> dict[str, list[SynthesisResult]]:
        """Run all configured engines over the corpus.

        Failed/unsupported engines are recorded (empty result list) without
        breaking the rest of the run.
        """
        by_engine: dict[str, list[SynthesisResult]] = {}
        for engine in self.engines:
            reason = engine.check_available()
            if reason is not None:
                results = []
                self._write_unavailable(engine.name, reason)
            else:
                results = self.run_engine(engine.name, phrases)
            by_engine[engine.name] = results
        return by_engine

    # -- result serialization -------------------------------------------------

    def _write_results(self, engine_name: str, results: list[SynthesisResult]) -> None:
        self.config.results_dir.mkdir(parents=True, exist_ok=True)
        payload = {
            "engine": engine_name,
            "run_started_at": now_utc_iso(),
            "sample_rate": self.config.sample_rate,
            "result_count": len(results),
            "results": [r.to_dict() for r in results],
        }
        path = self.results_file_for(engine_name)
        path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
        self._write_results_csv(engine_name, results)

    def _write_unavailable(self, engine_name: str, reason: str) -> None:
        self.config.results_dir.mkdir(parents=True, exist_ok=True)
        payload = {
            "engine": engine_name,
            "run_started_at": now_utc_iso(),
            "sample_rate": self.config.sample_rate,
            "result_count": 0,
            "unavailable": True,
            "reason": reason,
            "results": [],
        }
        (self.results_file_for(engine_name)).write_text(
            json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
        )

    def _write_results_csv(self, engine_name: str, results: list[SynthesisResult]) -> None:
        if not results:
            return
        rows = []
        for r in results:
            rows.append(
                {
                    "engine": r.engine,
                    "model": r.model,
                    "voice": r.voice,
                    "phrase_id": r.phrase_id,
                    "text": r.text,
                    "success": r.success,
                    "started_at": r.started_at,
                    "generation_duration_seconds": r.duration_seconds,
                    "output_duration_seconds": r.audio.duration_seconds if r.audio else None,
                    "sample_rate": r.audio.sample_rate if r.audio else None,
                    "channels": r.audio.channels if r.audio else None,
                    "output_file": r.output_file,
                    "error_message": r.error_message,
                }
            )
        path = self.config.results_dir / f"{engine_name}.csv"
        with path.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
            writer.writeheader()
            writer.writerows(rows)

    # -- helpers ---------------------------------------------------------------

    @staticmethod
    def _select_text(adapter: Any, phrase: Phrase) -> str:
        if not adapter.supports_devanagari and phrase.tts_text is not None:
            return phrase.tts_text
        return phrase.text

    @staticmethod
    def summarize(results: list[SynthesisResult]) -> RunSummary:
        succeeded = [r for r in results if r.success]
        total = sum(r.duration_seconds for r in succeeded)
        n = len(succeeded)
        return RunSummary(
            engine=results[0].engine if results else "?",
            total=len(results),
            succeeded=len(succeeded),
            failed=len(results) - len(succeeded),
            total_duration_seconds=round(total, 4),
            avg_duration_seconds=round(total / n, 4) if n else 0.0,
        )


def available_engine_names() -> list[str]:
    """Registered engine names (see ``benchmark.engines`` package import)."""
    return available_engines()
