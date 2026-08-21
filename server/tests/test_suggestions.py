"""Tests for the suggestion generator (server.suggestions)."""

from __future__ import annotations

import pytest

from server.suggestions import SuggestionError, generate


def test_returns_two_suggestions_matching_frontend_templates():
    out = generate(
        situation="बायाँ मोड",
        standard_text="देब्रे मोड्नुहोस्।",
        personality="savage",
        language="ne",
    )
    assert len(out) == 2
    assert out[0]["text"] == "देब्रे मोड्नुहोस्। फेरि देब्रे? ल, जाऔँ।"
    assert out[1]["text"] == "बायाँ मोड — देब्रे मोड्नुहोस्।"
    for s in out:
        assert s["personality"] == "savage"
        assert s["language"] == "ne"


@pytest.mark.parametrize(
    ("personality", "language", "suffix"),
    [
        ("simple", "ne", "भो, अब देब्रे।"),
        ("simple", "en", "Okay, left it is."),
        ("normal", "ne", "कृपया देब्रेतिर लाग्नुहोस्।"),
        ("normal", "en", "Please keep left."),
        ("firm", "ne", "ल, अब देब्रे मोड्नुहोस्।"),
        ("firm", "en", "Now turn left, watch your speed."),
        ("savage", "en", "Left again? Fine, let's go."),
    ],
)
def test_standard_plus_personality_suffix(personality, language, suffix):
    out = generate(
        situation="x", standard_text="Turn left.", personality=personality, language=language
    )
    assert out[0]["text"] == f"Turn left. {suffix}"


def test_rejects_unknown_personality():
    with pytest.raises(SuggestionError):
        generate(situation="x", standard_text="y", personality="angry", language="en")


def test_rejects_unsupported_language():
    with pytest.raises(SuggestionError):
        generate(situation="x", standard_text="y", personality="simple", language="fr")


def test_rejects_empty_standard_text():
    with pytest.raises(SuggestionError):
        generate(situation="x", standard_text="   ", personality="simple", language="en")
