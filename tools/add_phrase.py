"""Add a phrase to the corpus with a stable, auto-generated ID.

Generates the next ID in the format ``<slug>_NNN`` based on the category,
appends the phrase, validates the corpus, and writes the file back.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

from benchmark.core.corpus import CorpusError, load_corpus

CORPUS_PATH = Path(__file__).resolve().parents[1] / "benchmark" / "corpus" / "phrases.json"


def next_id(phrase_id_base: str, existing: list[str]) -> str:
    prefix = re.sub(r"[^a-z0-9_]", "_", phrase_id_base.lower()).strip("_") or "phrase"
    candidates = {p for p in existing if p.startswith(prefix + "_")}
    numbers = [
        int(p.rsplit("_", 1)[1])
        for p in candidates
        if p.rsplit("_", 1)[1].isdigit()
    ]
    n = (max(numbers) + 1) if numbers else 1
    return f"{prefix}_{n:03d}"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Add a phrase to the benchmark corpus.")
    parser.add_argument("--text", required=True, help="Phrase text (UTF-8).")
    parser.add_argument("--category", required=True,
                        help="One of: directions, distances, traffic, enforcement, "
                             "arrival, language_tests")
    parser.add_argument("--language", required=True, choices=["ne", "en", "ne-en"])
    parser.add_argument("--tts-text", default=None,
                        help="Latin-script rendering for engines without Devanagari support.")
    parser.add_argument("--tags", nargs="*", default=[])
    parser.add_argument("--id", default=None, help="Explicit ID (default: auto-generated).")
    args = parser.parse_args(argv)

    data = json.loads(CORPUS_PATH.read_text(encoding="utf-8"))
    existing = [p["id"] for p in data["phrases"]]

    if args.id:
        if args.id in existing:
            print(f"ERROR: id {args.id!r} already exists")
            return 1
        phrase_id = args.id
    else:
        phrase_id = next_id(args.category, existing)

    entry = {
        "id": phrase_id,
        "category": args.category,
        "language": args.language,
        "text": args.text,
        "tts_text": args.tts_text,
        "tags": args.tags,
    }

    # Validate the whole corpus (existing entries + the new one) BEFORE writing.
    try:
        from benchmark.core.corpus import _validate_entry

        _validate_entry(entry, len(data["phrases"]))
    except CorpusError as exc:
        print(f"ERROR: new phrase invalid: {exc}")
        return 1

    CORPUS_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # Final validation of the written file.
    try:
        load_corpus(CORPUS_PATH)
    except CorpusError as exc:
        print(f"ERROR: written corpus failed validation: {exc}")
        return 1

    print(f"Added {phrase_id}: {args.text}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
