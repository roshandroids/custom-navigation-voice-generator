"""Tests for the voice registry (server.voices)."""

from __future__ import annotations

import pytest

from server.voices import (
    LANGUAGE_BY_VOICE,
    LANGUAGE_DEFAULT_VOICE,
    VOICE_MAP,
    default_voice_for,
    resolve_voice,
    validate_language,
)


def test_voice_map_covers_frontend_catalog():
    """Every frontend VoiceCatalog id resolves to a full Piper voice name."""
    expected = {
        "chitwan": "ne_NP-chitwan-medium",
        "google-medium": "ne_NP-google-medium",
        "google-x-low": "ne_NP-google-x_low",
        "joe": "en_US-joe-medium",
        "kristin": "en_US-kristin-medium",
        "ljspeech": "en_US-ljspeech-medium",
    }
    assert VOICE_MAP == expected


def test_resolve_voice_known():
    assert resolve_voice("chitwan") == "ne_NP-chitwan-medium"


def test_resolve_voice_unknown_raises():
    with pytest.raises(ValueError):
        resolve_voice("does-not-exist")


def test_default_voice_per_language():
    assert default_voice_for("ne") == "chitwan"
    assert default_voice_for("en") == "joe"
    with pytest.raises(ValueError):
        default_voice_for("fr")


def test_validate_language_ok():
    validate_language("chitwan", "ne")
    validate_language("ljspeech", "en")


def test_validate_language_mismatch_raises():
    with pytest.raises(ValueError):
        validate_language("chitwan", "en")
    with pytest.raises(ValueError):
        validate_language("joe", "ne")


def test_validate_language_unsupported():
    with pytest.raises(ValueError):
        validate_language("chitwan", "fr")


def test_every_voice_has_a_language():
    assert set(LANGUAGE_BY_VOICE) == set(VOICE_MAP)
    assert set(LANGUAGE_DEFAULT_VOICE.values()) == {"chitwan", "joe"}
