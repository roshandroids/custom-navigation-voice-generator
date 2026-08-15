"""Tests for the hybrid Nepali/English TTS experiment."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from benchmark.core.audio import (
    concatenate_wavs,
    inspect_wav,
    read_pcm16_mono,
    resample_linear,
    write_pcm16_mono,
    write_silence_wav,
)
from benchmark.scripts.run_hybrid import (
    HybridCorpusError,
    load_hybrid_corpus,
)

REPO_ROOT = Path(__file__).resolve().parents[1]
HYBRID_CORPUS = REPO_ROOT / "benchmark" / "corpus" / "hybrid_phrases.json"


def _write_corpus(tmp_path: Path, phrases: list[dict]) -> Path:
    path = tmp_path / "hybrid.json"
    path.write_text(
        json.dumps({"version": 1, "voice_config": {"ne": "ne_x", "en": "en_x",
                                                  "output_sample_rate": 22050},
                    "phrases": phrases}, ensure_ascii=False),
        encoding="utf-8",
    )
    return path


# ---------------------------------------------------------------------------
# Segment schema validation
# ---------------------------------------------------------------------------


def test_valid_hybrid_corpus_loads():
    data = load_hybrid_corpus(HYBRID_CORPUS)
    phrases = data["phrases"]
    assert len(phrases) >= 10
    ids = [p["id"] for p in phrases]
    assert len(set(ids)) == len(ids), "IDs must be unique"
    for p in phrases:
        assert p["segments"], f"{p['id']} must have segments"
        for seg in p["segments"]:
            assert seg["language"] in ("ne", "en")
            assert seg["text"].strip()


def test_hybrid_corpus_has_explicit_segments():
    """Segments must be explicitly defined (no auto language detection)."""
    data = load_hybrid_corpus(HYBRID_CORPUS)
    for p in data["phrases"]:
        # Every segment carries its language explicitly.
        assert all("language" in seg and "text" in seg for seg in p["segments"])


def test_invalid_language_rejected(tmp_path):
    path = _write_corpus(tmp_path, [
        {"id": "h_001", "segments": [{"language": "fr", "text": "bonjour"}]}
    ])
    with pytest.raises(HybridCorpusError, match="invalid language"):
        load_hybrid_corpus(path)


def test_empty_segments_rejected(tmp_path):
    path = _write_corpus(tmp_path, [{"id": "h_001", "segments": []}])
    with pytest.raises(HybridCorpusError, match="segments"):
        load_hybrid_corpus(path)


def test_empty_segment_text_rejected(tmp_path):
    path = _write_corpus(tmp_path, [
        {"id": "h_001", "segments": [{"language": "ne", "text": "  "}]}
    ])
    with pytest.raises(HybridCorpusError, match="text"):
        load_hybrid_corpus(path)


def test_duplicate_ids_rejected(tmp_path):
    path = _write_corpus(tmp_path, [
        {"id": "h_001", "segments": [{"language": "ne", "text": "a"}]},
        {"id": "h_001", "segments": [{"language": "en", "text": "b"}]},
    ])
    with pytest.raises(HybridCorpusError, match="duplicate"):
        load_hybrid_corpus(path)


def test_missing_file_raises(tmp_path):
    with pytest.raises(HybridCorpusError, match="not found"):
        load_hybrid_corpus(tmp_path / "nope.json")


# ---------------------------------------------------------------------------
# Segment ordering
# ---------------------------------------------------------------------------


def test_segment_order_preserved():
    data = load_hybrid_corpus(HYBRID_CORPUS)
    # Every phrase's full text should be reconstructable from segments in order.
    for p in data["phrases"]:
        # The stored `text` may differ in spacing; verify every segment's words
        # appear in the phrase text in order.
        pos = 0
        for seg in p["segments"]:
            idx = p["text"].find(seg["text"][:5], pos)
            assert idx != -1, f"segment text {seg['text']!r} not in order in {p['text']!r}"
            pos = idx + 1


# ---------------------------------------------------------------------------
# Audio format normalization
# ---------------------------------------------------------------------------


def test_resample_linear_keeps_length_proportional():
    samples = [0] * 1000
    out = resample_linear(samples, 1000, 2000)
    assert len(out) == 2000
    out2 = resample_linear(samples, 2000, 1000)
    assert len(out2) == 500


def test_resample_linear_identity():
    samples = [100, 200, -300, 400]
    assert resample_linear(samples, 16000, 16000) == samples


def test_read_pcm16_mono_roundtrip(tmp_path):
    path = tmp_path / "tone.wav"
    samples = [i % 1000 - 500 for i in range(4410)]
    write_pcm16_mono(path, samples, 44100)
    out, rate = read_pcm16_mono(path)
    assert rate == 44100
    assert out == samples


def test_write_silence_wav_is_valid(tmp_path):
    path = write_silence_wav(tmp_path / "silence.wav", 0.5, 16000)
    info = inspect_wav(path)
    assert info.sample_rate == 16000
    assert info.channels == 1
    assert info.duration_seconds == pytest.approx(0.5, abs=0.01)


# ---------------------------------------------------------------------------
# Audio concatenation
# ---------------------------------------------------------------------------


def test_concatenate_same_rate(tmp_path):
    a = write_silence_wav(tmp_path / "a.wav", 0.5, 22050)
    b = write_silence_wav(tmp_path / "b.wav", 0.25, 22050)
    out = tmp_path / "out.wav"
    dur, sr = concatenate_wavs([a, b], out, 22050)
    assert sr == 22050
    assert dur == pytest.approx(0.75, abs=0.01)


def test_concatenate_mixed_rates(tmp_path):
    """Segments at different sample rates must be resampled before stitching."""
    a = write_silence_wav(tmp_path / "a.wav", 1.0, 22050)
    b = write_silence_wav(tmp_path / "b.wav", 1.0, 16000)
    out = tmp_path / "out.wav"
    dur, sr = concatenate_wavs([a, b], out, 22050)
    assert sr == 22050
    # 1s + 1s = 2s at 22050
    assert dur == pytest.approx(2.0, abs=0.02)
    info = inspect_wav(out)
    assert info.channels == 1
    assert info.sample_width_bytes == 2


def test_concatenate_preserves_content_amplitude(tmp_path):
    """Stitched output must retain non-silent content (no dropped audio)."""
    import math

    tone = [int(8000 * math.sin(2 * math.pi * 440 * i / 22050)) for i in range(22050)]
    t = write_pcm16_mono(tmp_path / "tone.wav", tone, 22050)
    s = write_silence_wav(tmp_path / "silence.wav", 0.5, 22050)
    out = tmp_path / "out.wav"
    concatenate_wavs([t, s], out, 22050)
    samples, _ = read_pcm16_mono(out)
    # First second should have tone content.
    first_sec = samples[:22050]
    assert max(abs(x) for x in first_sec) > 5000


# ---------------------------------------------------------------------------
# Failure handling
# ---------------------------------------------------------------------------


def test_concatenate_missing_file_raises(tmp_path):
    with pytest.raises(FileNotFoundError):
        concatenate_wavs([tmp_path / "missing.wav"], tmp_path / "out.wav", 22050)


def test_inspect_wav_rejects_garbage(tmp_path):
    import wave

    bad = tmp_path / "bad.wav"
    bad.write_bytes(b"not a wav file at all")
    with pytest.raises(wave.Error):
        inspect_wav(bad)
