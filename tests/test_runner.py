"""Tests for the benchmark runner: paths, timing, serialization, error isolation."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from benchmark.core.corpus import Phrase
from benchmark.core.runner import (
    BenchmarkConfig,
    BenchmarkRunner,
    available_engine_names,
)

PHRASE = Phrase(
    id="speed_camera_001",
    category="enforcement",
    language="en",
    text="Speed camera ahead.",
)


@pytest.fixture
def runner(tmp_path: Path) -> BenchmarkRunner:
    config = BenchmarkConfig(
        engines=["dummy"],
        output_root=tmp_path / "output",
        results_dir=tmp_path / "results",
    )
    return BenchmarkRunner(config)


def test_output_path_generation(runner: BenchmarkRunner, tmp_path: Path):
    path = runner.output_path_for("dummy", "speed_camera_001")
    assert path == tmp_path / "output" / "dummy" / "speed_camera_001.wav"


def test_generate_writes_wav_and_result(runner: BenchmarkRunner):
    result = runner.generate("dummy", PHRASE)
    assert result.success is True
    assert result.engine == "dummy"
    assert result.phrase_id == "speed_camera_001"
    assert result.error_message is None
    assert result.duration_seconds >= 0
    assert Path(result.output_file).exists()
    assert result.audio is not None
    assert result.audio.sample_rate == 16000
    assert result.audio.channels == 1


def test_result_serialization_roundtrip(runner: BenchmarkRunner):
    result = runner.generate("dummy", PHRASE)
    payload = result.to_dict()
    assert payload["engine"] == "dummy"
    assert payload["phrase_id"] == "speed_camera_001"
    assert payload["success"] is True
    assert "started_at" in payload
    assert "duration_seconds" in payload
    # JSON-serializable end to end
    json.dumps(payload, ensure_ascii=False)


def test_run_engine_writes_json_and_csv(runner: BenchmarkRunner):
    runner.run_engine("dummy", [PHRASE])

    json_path = runner.results_file_for("dummy")
    assert json_path.exists()
    payload = json.loads(json_path.read_text(encoding="utf-8"))
    assert payload["engine"] == "dummy"
    assert payload["result_count"] == 1
    assert payload["results"][0]["phrase_id"] == "speed_camera_001"

    csv_path = runner.config.results_dir / "dummy.csv"
    assert csv_path.exists()
    content = csv_path.read_text(encoding="utf-8")
    assert "phrase_id" in content
    assert "speed_camera_001" in content


def test_failed_engine_isolated(tmp_path: Path):
    """A failing adapter must not raise; result records the error."""

    class FailingAdapter:
        name = "failing"
        model = "m"
        voice = "v"
        languages = ["en"]
        supports_devanagari = False

        def check_available(self):
            return None

        def prepare(self):
            return None

        def synthesize(self, text, output_path):
            raise RuntimeError("boom")

    from benchmark.core.registry import register

    register(FailingAdapter)
    try:
        config = BenchmarkConfig(
            engines=["dummy", "failing"],
            output_root=tmp_path / "output",
            results_dir=tmp_path / "results",
        )
        runner = BenchmarkRunner(config)

        results = runner.run_engine("failing", [PHRASE])
        assert len(results) == 1
        assert results[0].success is False
        assert "RuntimeError" in results[0].error_message
        assert not Path(results[0].output_file).exists()

        # The other engine still works in the same runner.
        ok = runner.run_engine("dummy", [PHRASE])
        assert ok[0].success is True
    finally:
        from benchmark.core.registry import _REGISTRY

        _REGISTRY.pop("failing", None)


def test_run_all_records_unavailable_engines(tmp_path: Path):
    config = BenchmarkConfig(
        engines=["dummy", "chatterbox"],  # chatterbox CLI not installed
        output_root=tmp_path / "output",
        results_dir=tmp_path / "results",
    )
    runner = BenchmarkRunner(config)
    by_engine = runner.run_all([PHRASE])

    assert "dummy" in by_engine and by_engine["dummy"][0].success is True
    assert "chatterbox" in by_engine and by_engine["chatterbox"] == []

    payload = json.loads(runner.results_file_for("chatterbox").read_text(encoding="utf-8"))
    assert payload["unavailable"] is True
    assert "reason" in payload


def test_reused_output_is_skipped_without_regenerating(runner: BenchmarkRunner, tmp_path: Path):
    first = runner.generate("dummy", PHRASE)
    wav = Path(first.output_file)
    mtime = wav.stat().st_mtime_ns
    assert first.extra.get("reused") is not True

    second = runner.generate("dummy", PHRASE)
    assert second.success is True
    assert second.extra.get("reused") is True
    assert wav.stat().st_mtime_ns == mtime, "existing WAV must not be rewritten"


def test_force_regenerates(runner: BenchmarkRunner):
    runner.generate("dummy", PHRASE)
    runner.config.force = True
    second = runner.generate("dummy", PHRASE)
    assert second.extra.get("reused") is not True


def test_summary_counts():
    from benchmark.core.tts import SynthesisResult

    ok = SynthesisResult(
        engine="dummy", model="m", voice="v", phrase_id="a", text="t",
        output_file="/tmp/a.wav", success=True, started_at="now", duration_seconds=0.5,
    )
    bad = SynthesisResult(
        engine="dummy", model="m", voice="v", phrase_id="b", text="t",
        output_file="/tmp/b.wav", success=False, started_at="now", duration_seconds=1.0,
        error_message="boom",
    )
    summary = BenchmarkRunner.summarize([ok, bad])
    assert summary.succeeded == 1
    assert summary.failed == 1
    assert summary.avg_duration_seconds == 0.5


def test_available_engine_names_matches_registry():
    from benchmark.core.registry import available_engines

    assert available_engine_names() == available_engines()


def test_text_selection_uses_latin_rendering_for_non_devanagari_engines():
    ne_phrase = Phrase(
        id="turn_left_001",
        category="directions",
        language="ne",
        text="देब्रे मोड्नुहोस्।",
        tts_text="Debre modnuhos.",
    )
    from benchmark.core.registry import create_engine

    # Piper has official ne_NP voices and accepts Devanagari: original text passes through.
    piper = create_engine("piper")
    assert BenchmarkRunner._select_text(piper, ne_phrase) == "देब्रे मोड्नुहोस्।"
    # Kokoro has no Nepali voice: receives the Latin rendering.
    kokoro = create_engine("kokoro")
    assert BenchmarkRunner._select_text(kokoro, ne_phrase) == "Debre modnuhos."
    dummy = create_engine("dummy")
    assert BenchmarkRunner._select_text(dummy, ne_phrase) == "देब्रे मोड्नुहोस्।"
