"""Validate the benchmark corpus (schema, duplicates, metadata rules).

Exit code 0 = valid, 1 = invalid.
"""

from __future__ import annotations

import argparse
import sys

from benchmark.core.corpus import CORPUS_PATH, CorpusError, corpus_stats, load_corpus


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate the benchmark phrase corpus.")
    parser.add_argument("--corpus", default=str(CORPUS_PATH))
    args = parser.parse_args(argv)

    try:
        phrases = load_corpus(args.corpus)
    except CorpusError as exc:
        print(f"INVALID: {exc}")
        return 1

    stats = corpus_stats(phrases)
    print(f"OK: {stats['total']} phrases")
    print(f"  categories: {stats['categories']}")
    print(f"  languages:  {stats['languages']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
