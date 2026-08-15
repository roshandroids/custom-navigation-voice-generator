"""Tests for engine registration and adapter behavior."""

from __future__ import annotations

from benchmark.core.registry import (
    available_engines,
    clear_registry,
    create_engine,
    get_registry,
    register,
)
from benchmark.core.tts import TTSAdapter


def test_all_candidate_engines_registered():
    names = available_engines()
    for expected in ("dummy", "piper", "kokoro", "qwen3", "chatterbox"):
        assert expected in names, f"{expected} should be registered"


def test_create_unknown_engine_raises():
    saved = get_registry()
    clear_registry()
    try:
        import pytest

        with pytest.raises(KeyError):
            create_engine("does_not_exist")
    finally:
        for cls in saved.values():
            register(cls)


def test_engine_spec_reflects_availability():
    from benchmark.core.registry import create_engine

    dummy = create_engine("dummy")
    spec = dummy.spec()
    assert spec.supported is True
    assert dummy.check_available() is None

    for name in ("piper", "kokoro", "qwen3", "chatterbox"):
        adapter = create_engine(name)
        spec = adapter.spec()
        assert spec.name == name
        assert isinstance(spec.languages, list)


def test_all_adapters_are_tts_adapters():
    for name in available_engines():
        adapter = create_engine(name)
        assert isinstance(adapter, TTSAdapter)
        assert adapter.name == name
        assert hasattr(adapter, "synthesize")


def test_register_rejects_duplicate():
    class DuplicateAdapter(TTSAdapter):
        name = "dummy"
        model = "x"
        voice = "y"
        languages = ["en"]

        def synthesize(self, text, output_path):
            raise NotImplementedError

    import pytest

    with pytest.raises(ValueError, match="duplicate engine"):
        register(DuplicateAdapter)
