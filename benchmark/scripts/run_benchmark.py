"""Run the TTS benchmark: synthesize the corpus with one or more engines.

Examples
--------
# List available engines
benchmark-run --list

# Run every available engine (skips unsupported ones, records why)
benchmark-run

# Run specific engines
benchmark-run --engines piper kokoro

# Force regeneration (overwrite existing WAVs)
benchmark-run --force
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from benchmark import engines  # noqa: F401  (import registers all adapters)
from benchmark.core.corpus import CORPUS_PATH, corpus_stats, load_corpus
from benchmark.core.registry import available_engines, create_engine
from benchmark.core.runner import BenchmarkConfig, BenchmarkRunner

REPO_ROOT = Path(__file__).resolve().parents[2]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="benchmark-run",
        description="Synthesize the navigation phrase corpus with one or more TTS engines.",
    )
    parser.add_argument(
        "--engines", nargs="*", default=None,
        help="Engines to run (default: all registered engines). Use --list to see them.",
    )
    parser.add_argument(
        "--list", action="store_true",
        help="List registered engines and exit.",
    )
    parser.add_argument(
        "--corpus", default=str(CORPUS_PATH),
        help="Path to phrases.json (default: bundled corpus).",
    )
    parser.add_argument(
        "--output", default=str(REPO_ROOT / "benchmark" / "output"),
        help="Root directory for generated WAV files.",
    )
    parser.add_argument(
        "--results", default=str(REPO_ROOT / "benchmark" / "results"),
        help="Directory for benchmark result files (JSON + CSV).",
    )
    parser.add_argument(
        "--sample-rate", type=int, default=16000,
        help="Target sample rate for generated audio (default 16000).",
    )
    parser.add_argument(
        "--force", action="store_true",
        help="Regenerate audio even if a WAV already exists.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    if args.list:
        print("Registered engines:")
        for name in available_engines():
            adapter = create_engine(name)
            reason = adapter.check_available()
            status = "available" if reason is None else f"UNAVAILABLE: {reason}"
            print(f"  {name:<12} {status}")
        return 0

    phrases = load_corpus(args.corpus)
    stats = corpus_stats(phrases)
    print(f"Corpus: {stats['total']} phrases "
          f"(categories: {stats['categories']}, languages: {stats['languages']})")

    engines_to_run = args.engines if args.engines else available_engines()
    unknown = [e for e in engines_to_run if e not in available_engines()]
    if unknown:
        print(f"ERROR: unknown engine(s): {unknown}. Registered: {available_engines()}")
        return 2

    config = BenchmarkConfig(
        engines=engines_to_run,
        phrases=phrases,
        output_root=Path(args.output),
        results_dir=Path(args.results),
        sample_rate=args.sample_rate,
        force=args.force,
    )
    runner = BenchmarkRunner(config)

    print(f"Engines to run: {engines_to_run}")
    by_engine = runner.run_all(phrases)

    for name, results in by_engine.items():
        if not results:
            reason_file = runner.results_file_for(name)
            print(f"[{name}] skipped (see {reason_file})")
            continue
        summary = runner.summarize(results)
        print(
            f"[{name}] {summary.succeeded}/{summary.total} ok, "
            f"{summary.failed} failed, "
            f"avg {summary.avg_duration_seconds}s per phrase"
        )
    print(f"Results written to {config.results_dir}")
    print(f"Audio written to {config.output_root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
