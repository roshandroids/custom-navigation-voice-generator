"""Suggestion generator for personalized instruction alternatives.

A direct port of the frontend ``MockSuggestionRepository`` template pool so the
server reproduces exactly the two suggestions the MVP app shows today: one
``standardText + <personality suffix>`` and one ``situation — standardText``,
with the personality suffix chosen per personality × language.

This is a curated template, not a learned model; it can be replaced by a
corpus-driven generator once the TTS engine/voice evaluation selected one.
"""

from __future__ import annotations

from typing import Any

# personality values mirror the frontend ``Personality`` enum.
VALID_PERSONALITIES = ("simple", "normal", "firm", "savage")
VALID_LANGUAGES = ("ne", "en")

_PERSONALITY_SUFFIX: dict[str, dict[str, str]] = {
    "simple": {"ne": "भो, अब देब्रे।", "en": "Okay, left it is."},
    "normal": {"ne": "कृपया देब्रेतिर लाग्नुहोस्।", "en": "Please keep left."},
    "firm": {"ne": "ल, अब देब्रे मोड्नुहोस्।", "en": "Now turn left, watch your speed."},
    "savage": {"ne": "फेरि देब्रे? ल, जाऔँ।", "en": "Left again? Fine, let's go."},
}


class SuggestionError(Exception):
    """Invalid request to the suggestion generator."""


def generate(
    *, situation: str, standard_text: str, personality: str, language: str
) -> list[dict[str, Any]]:
    """Return the two suggestion objects for a request."""
    if personality not in VALID_PERSONALITIES:
        raise SuggestionError(f"unknown personality: {personality!r}")
    if language not in VALID_LANGUAGES:
        raise SuggestionError(f"unsupported language: {language!r}")
    if not standard_text.strip():
        raise SuggestionError("standardText must not be empty")

    trimmed = standard_text.strip()
    suffix = _PERSONALITY_SUFFIX[personality][language]

    return [
        {
            "text": f"{trimmed} {suffix}",
            "personality": personality,
            "language": language,
        },
        {
            "text": f"{situation.strip()} — {trimmed}",
            "personality": personality,
            "language": language,
        },
    ]
