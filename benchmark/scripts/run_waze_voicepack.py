"""Generate audio for the Waze custom voice-pack script.

Reads benchmark/corpus/waze_voicepack.json (the exact "Record your own voice"
phrase list from Waze's Nepali voice screen, both English and natural-spoken-Nepali
text - see docs/nepali-waze-voicepack-review.md for the translation review) and
synthesizes each phrase with the correct language's Piper voices:

- ``ne`` phrases -> the official Nepali voices (ne_NP-*)
- ``en`` phrases -> the English voices (en_US-*)

Unlike ``benchmark-run``, which runs every phrase in a corpus through whichever
voice is selected regardless of the phrase's own language, this script always
routes each phrase to a voice that can actually speak its language - so an
English "Turn left" is never sent through a Nepali voice model, and vice versa.

Output layout matches the main runner:
    benchmark/output/waze/piper/<voice>/<phrase_id>.wav
    benchmark/results/waze/piper-<voice>.json + .csv
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from benchmark import engines  # noqa: F401  (import registers all adapters)
from benchmark.core.corpus import CorpusError, Phrase, load_corpus
from benchmark.core.runner import BenchmarkConfig, BenchmarkRunner

REPO_ROOT = Path(__file__).resolve().parents[2]
WAZE_CORPUS = REPO_ROOT / "benchmark" / "corpus" / "waze_voicepack.json"
OUTPUT_ROOT = REPO_ROOT / "benchmark" / "output" / "waze"
RESULTS_DIR = REPO_ROOT / "benchmark" / "results" / "waze"

NE_VOICES = ["ne_NP-chitwan-medium", "ne_NP-google-medium", "ne_NP-google-x_low"]
EN_VOICES = ["en_US-joe-medium", "en_US-kristin-medium", "en_US-ljspeech-medium"]


def _run_language(
    phrases: list[Phrase],
    voices: list[str],
    output_root: Path,
    results_dir: Path,
    force: bool,
) -> None:
    if not phrases:
        return
    import os

    for voice in voices:
        os.environ["PIPER_VOICE"] = voice
        config = BenchmarkConfig(
            engines=["piper"],
            phrases=phrases,
            output_root=output_root,
            results_dir=results_dir,
            force=force,
            subdirs={"piper": voice},
        )
        runner = BenchmarkRunner(config)
        by_engine = runner.run_all(phrases)
        results = by_engine.get("piper", [])
        if not results:
            print(f"  piper/{voice}: skipped (see {runner.results_file_for('piper')})")
            continue
        summary = runner.summarize(results)
        print(
            f"  piper/{voice}: {summary.succeeded}/{summary.total} ok, "
            f"{summary.failed} failed, avg {summary.avg_duration_seconds}s per phrase"
        )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Synthesize the Waze voice-pack corpus with language-correct Piper voices."
    )
    parser.add_argument("--corpus", default=str(WAZE_CORPUS))
    parser.add_argument("--output", default=str(OUTPUT_ROOT))
    parser.add_argument("--results", default=str(RESULTS_DIR))
    parser.add_argument("--ne-voices", nargs="*", default=NE_VOICES)
    parser.add_argument("--en-voices", nargs="*", default=EN_VOICES)
    parser.add_argument("--force", action="store_true", help="Regenerate even if a WAV exists.")
    args = parser.parse_args(argv)

    try:
        phrases = load_corpus(args.corpus)
    except CorpusError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    ne_phrases = [p for p in phrases if p.language == "ne"]
    en_phrases = [p for p in phrases if p.language == "en"]
    print(f"Corpus: {len(phrases)} phrases ({len(ne_phrases)} ne, {len(en_phrases)} en)")

    output_root = Path(args.output)
    results_dir = Path(args.results)

    if args.ne_voices:
        print("Nepali phrases:")
        _run_language(ne_phrases, args.ne_voices, output_root, results_dir, args.force)
    if args.en_voices:
        print("English phrases:")
        _run_language(en_phrases, args.en_voices, output_root, results_dir, args.force)

    print(f"\nResults written to {results_dir}")
    print(f"Audio written to {output_root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
