"""Phrase corpus loading and validation for the TTS benchmark."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path

CORPUS_PATH = Path(__file__).resolve().parents[1] / "corpus" / "phrases.json"

VALID_LANGUAGES = {"ne", "en", "ne-en"}
VALID_CATEGORIES = {
    "directions",
    "distances",
    "traffic",
    "enforcement",
    "arrival",
    "language_tests",
    "start_of_drive",
    "other",
}
ID_PATTERN = re.compile(r"^[a-z0-9_]+$")

# Devanagari Unicode block: U+0900–U+097F plus a few extension points.
DEVANAGARI_RE = re.compile(r"[\u0900-\u097F\uA8E0-\uA8FF]")


class CorpusError(Exception):
    """Raised when the corpus file is missing, malformed, or invalid."""


@dataclass(frozen=True)
class Phrase:
    """A single benchmark phrase with a stable ID."""

    id: str
    category: str
    language: str
    text: str
    tts_text: str | None = None
    expected_pronunciation: str | None = None
    description: str | None = None
    tags: tuple[str, ...] = field(default_factory=tuple)
    extra: dict = field(default_factory=dict)

    def text_for_tts(self) -> str:
        """Return the text the engine should synthesize.

        Engines that declare ``supports_devanagari=False`` receive ``tts_text``
        (a Latin rendering) when available; otherwise the original ``text`` is used.
        """
        return self.text


def _validate_entry(entry: dict, index: int) -> Phrase:
    missing = [k for k in ("id", "category", "language", "text") if k not in entry]
    if missing:
        raise CorpusError(f"phrase #{index}: missing required field(s): {', '.join(missing)}")

    phrase_id = entry["id"]
    if not isinstance(phrase_id, str) or not ID_PATTERN.match(phrase_id):
        pattern = ID_PATTERN.pattern
        raise CorpusError(f"phrase #{index}: invalid id {phrase_id!r} (must match {pattern})")

    if entry["language"] not in VALID_LANGUAGES:
        raise CorpusError(
            f"phrase {phrase_id!r}: invalid language {entry['language']!r} "
            f"(expected one of {sorted(VALID_LANGUAGES)})"
        )

    if entry["category"] not in VALID_CATEGORIES:
        raise CorpusError(
            f"phrase {phrase_id!r}: invalid category {entry['category']!r} "
            f"(expected one of {sorted(VALID_CATEGORIES)})"
        )

    text = entry["text"]
    if not isinstance(text, str) or not text.strip():
        raise CorpusError(f"phrase {phrase_id!r}: text must be a non-empty string")

    if any(ord(ch) < 32 and ch not in "\n\t" for ch in text):
        raise CorpusError(f"phrase {phrase_id!r}: text contains control characters")

    lang = entry["language"]
    if lang in ("ne", "ne-en") and DEVANAGARI_RE.search(text) and not entry.get("tts_text"):
        raise CorpusError(
            f"phrase {phrase_id!r}: Devanagari text without a 'tts_text' Latin rendering "
            "(needed by engines that cannot process Devanagari)"
        )

    allowed = {"id", "category", "language", "text", "tts_text",
               "expected_pronunciation", "description", "tags"}
    extra = {k: v for k, v in entry.items() if k not in allowed}

    tags = tuple(entry["tags"]) if isinstance(entry.get("tags"), list) else ()
    if any(not isinstance(t, str) for t in tags):
        raise CorpusError(f"phrase {phrase_id!r}: tags must be strings")

    return Phrase(
        id=phrase_id,
        category=entry["category"],
        language=lang,
        text=text,
        tts_text=entry.get("tts_text"),
        expected_pronunciation=entry.get("expected_pronunciation"),
        description=entry.get("description"),
        tags=tags,
        extra=extra,
    )


def load_corpus(path: str | Path = CORPUS_PATH) -> list[Phrase]:
    """Load and validate the corpus from ``path``.

    Raises ``CorpusError`` on any structural problem, including duplicate IDs.
    Returns phrases in file order.
    """
    corpus_path = Path(path)
    if not corpus_path.exists():
        raise CorpusError(f"corpus file not found: {corpus_path}")

    try:
        data = json.loads(corpus_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise CorpusError(f"corpus file is not valid JSON: {exc}") from exc

    if not isinstance(data, dict) or "phrases" not in data:
        raise CorpusError("corpus must be a JSON object with a 'phrases' array")

    phrases = [ _validate_entry(e, i) for i, e in enumerate(data["phrases"]) ]

    seen: dict[str, int] = {}
    for phrase in phrases:
        if phrase.id in seen:
            raise CorpusError(
                f"duplicate phrase id {phrase.id!r} (first at index {seen[phrase.id]})"
            )
        seen[phrase.id] = 1

    return phrases


def corpus_stats(phrases: list[Phrase]) -> dict:
    """Return simple summary statistics about a loaded corpus (for logs/CLI)."""
    categories: dict[str, int] = {}
    languages: dict[str, int] = {}
    for p in phrases:
        categories[p.category] = categories.get(p.category, 0) + 1
        languages[p.language] = languages.get(p.language, 0) + 1
    return {
        "total": len(phrases),
        "categories": categories,
        "languages": languages,
    }
