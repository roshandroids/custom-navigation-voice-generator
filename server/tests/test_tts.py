"""Tests for the synthesis handler (server.tts)."""

from __future__ import annotations

import pytest

from server.tts import SynthesisError, synthesize


def test_synthesize_returns_wav_bytes_and_metadata(stub_piper, tmp_path):
    outcome = synthesize("देब्रे मोड्नुहोस्।", "chitwan", cache_dir=tmp_path / "cache")

    assert outcome.wav_bytes.startswith(b"RIFF")
    assert outcome.duration_ms == 500  # fixture: 0.5s @ 22050 Hz
    assert outcome.sample_rate == 22050
    assert outcome.voice == "chitwan"
    assert outcome.asset_id.endswith(".wav") is False  # asset id is voice__hash
    assert outcome.asset_id.startswith("chitwan__")


def test_synthesize_caches_by_text_and_voice(stub_piper, tmp_path):
    cache_dir = tmp_path / "cache"
    first = synthesize("अगाडि ट्राफिक छ।", "chitwan", cache_dir=cache_dir)
    second = synthesize("अगाडि ट्राफिक छ।", "chitwan", cache_dir=cache_dir)

    assert first.asset_id == second.asset_id
    # Cache hit: the fake adapter should only have been called once.
    cached_files = list(cache_dir.glob("*.wav"))
    assert len(cached_files) == 1


def test_synthesize_empty_text_raises(stub_piper, tmp_path):
    with pytest.raises(SynthesisError):
        synthesize("   ", "chitwan", cache_dir=tmp_path / "cache")


def test_synthesize_failure_cleans_partial_file(stub_piper, tmp_path):
    stub_piper["fail"] = True
    cache_dir = tmp_path / "cache"
    with pytest.raises(SynthesisError):
        synthesize("some text", "chitwan", cache_dir=cache_dir)
    assert list(cache_dir.glob("*.wav")) == []
