"""Hybrid Nepali/English TTS experiment.

Generates three versions of each hybrid-corpus phrase for listening comparison:

- Version A: whole phrase spoken by the Nepali Piper voice (status quo).
- Version B: Nepali voice for Nepali segments + English voice for English
  segments, concatenated (per-segment WAVs kept).
- Version C (optional): the English segment re-spoken by the Nepali voice using
  the phonetic Nepali spelling from ``version_c`` in the corpus.

Segments are EXPLICITLY defined in benchmark/corpus/hybrid_phrases.json — no
automatic language detection. Pure-Python resampling + concatenation (no ffmpeg).

Output layout:
    benchmark/output/hybrid/<phrase_id>/
        001-ne.wav, 002-en.wav, ...     (per-segment, Version B)
        version_a.wav  version_b.wav  version_c.wav
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

from benchmark.core.audio import concatenate_wavs, inspect_wav
from benchmark.engines.piper.adapter import PiperAdapter

REPO_ROOT = Path(__file__).resolve().parents[2]
HYBRID_CORPUS = REPO_ROOT / "benchmark" / "corpus" / "hybrid_phrases.json"
OUTPUT_ROOT = REPO_ROOT / "benchmark" / "output" / "hybrid"

VALID_LANGUAGES = {"ne", "en"}


class HybridCorpusError(Exception):
    """Raised when the hybrid corpus is malformed."""


def load_hybrid_corpus(path: Path = HYBRID_CORPUS) -> dict:
    """Load and validate the hybrid corpus; returns the parsed data."""
    if not path.exists():
        raise HybridCorpusError(f"hybrid corpus not found: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))

    phrases = data.get("phrases")
    if not isinstance(phrases, list) or not phrases:
        raise HybridCorpusError("corpus must contain a non-empty 'phrases' array")

    seen: set[str] = set()
    for p in phrases:
        pid = p.get("id")
        if not isinstance(pid, str) or not pid:
            raise HybridCorpusError(f"phrase missing id: {p}")
        if pid in seen:
            raise HybridCorpusError(f"duplicate phrase id: {pid}")
        seen.add(pid)

        segs = p.get("segments")
        if not isinstance(segs, list) or not segs:
            raise HybridCorpusError(f"phrase {pid}: 'segments' must be a non-empty list")
        for i, seg in enumerate(segs, 1):
            lang = seg.get("language")
            text = seg.get("text")
            if lang not in VALID_LANGUAGES:
                raise HybridCorpusError(
                    f"phrase {pid} segment {i}: invalid language {lang!r} (ne or en)"
                )
            if not isinstance(text, str) or not text.strip():
                raise HybridCorpusError(f"phrase {pid} segment {i}: non-empty text required")

        vc = p.get("version_c")
        if vc is not None and (vc.get("language") not in VALID_LANGUAGES
                               or not isinstance(vc.get("text"), str) or not vc["text"].strip()):
            raise HybridCorpusError(f"phrase {pid}: version_c must be {VALID_LANGUAGES} + text")

    return data


def synthesize_segment(adapter: PiperAdapter, text: str, out_path: Path) -> float:
    """Synthesize one segment with the given adapter; returns generation seconds."""
    t0 = time.monotonic()
    adapter.synthesize(text, out_path)
    return time.monotonic() - t0


def make_adapter(voice: str) -> PiperAdapter:
    """Create a PiperAdapter bound to a specific voice (bypasses env var)."""
    adapter = PiperAdapter(voice=voice)
    reason = adapter.check_available()
    if reason is not None:
        raise HybridCorpusError(f"piper unavailable for {voice}: {reason}")
    return adapter


def run_experiment(corpus_path: Path = HYBRID_CORPUS, output_root: Path = OUTPUT_ROOT) -> dict:
    """Run the hybrid experiment; returns a summary dict."""
    data = load_hybrid_corpus(corpus_path)
    vc = data.get("voice_config", {})
    ne_voice = vc.get("ne", "ne_NP-chitwan-medium")
    en_voice = vc.get("en", "en_US-joe-medium")
    target_rate = int(vc.get("output_sample_rate", 22050))

    ne_adapter = make_adapter(ne_voice)
    en_adapter = make_adapter(en_voice)

    summary = {"phrases": []}
    for phrase in data["phrases"]:
        pid = phrase["id"]
        phrase_dir = output_root / pid
        phrase_dir.mkdir(parents=True, exist_ok=True)
        entry: dict = {
            "id": pid,
            "text": phrase.get("text", ""),
            "segments": [],
            "versions": {},
            "timings": {},
        }

        # Version B: synthesize each segment with its language voice.
        seg_paths: list[Path] = []
        b_generation = 0.0
        for i, seg in enumerate(phrase["segments"], 1):
            lang = seg["language"]
            adapter = ne_adapter if lang == "ne" else en_adapter
            seg_path = phrase_dir / f"{i:03d}-{lang}.wav"
            elapsed = synthesize_segment(adapter, seg["text"], seg_path)
            b_generation += elapsed
            seg_paths.append(seg_path)
            entry["segments"].append(
                {
                    "index": i,
                    "language": lang,
                    "text": seg["text"],
                    "generation_seconds": round(elapsed, 4),
                    "file": str(seg_path.relative_to(REPO_ROOT)),
                    "audio": inspect_wav(seg_path).to_dict(),
                }
            )

        t0 = time.monotonic()
        final_b = phrase_dir / "version_b.wav"
        b_duration, _ = concatenate_wavs(seg_paths, final_b, target_rate)
        stitch_time = time.monotonic() - t0
        entry["timings"]["version_b_stitch_seconds"] = round(stitch_time, 4)

        # Version A: whole phrase in the Nepali voice.
        t0 = time.monotonic()
        version_a = phrase_dir / "version_a.wav"
        ne_adapter.synthesize(phrase["text"], version_a)
        a_generation = time.monotonic() - t0
        a_info = inspect_wav(version_a)
        entry["versions"]["a"] = {
            "file": str(version_a.relative_to(REPO_ROOT)),
            "generation_seconds": round(a_generation, 4),
            "audio": a_info.to_dict(),
        }

        # Version B final metadata.
        b_info = inspect_wav(final_b)
        entry["versions"]["b"] = {
            "file": str(final_b.relative_to(REPO_ROOT)),
            "generation_seconds": round(b_generation, 4),
            "stitch_seconds": round(stitch_time, 4),
            "audio": b_info.to_dict(),
        }

        # Version C (optional): phonetic Nepali spelling, Nepali voice.
        vc_entry = phrase.get("version_c")
        if vc_entry:
            t0 = time.monotonic()
            version_c = phrase_dir / "version_c.wav"
            ne_adapter.synthesize(vc_entry["text"], version_c)
            c_generation = time.monotonic() - t0
            c_info = inspect_wav(version_c)
            entry["versions"]["c"] = {
                "file": str(version_c.relative_to(REPO_ROOT)),
                "generation_seconds": round(c_generation, 4),
                "audio": c_info.to_dict(),
            }
        else:
            entry["versions"]["c"] = None

        c_gen = entry["versions"]["c"]["generation_seconds"] if entry["versions"]["c"] else 0.0
        entry["timings"]["total_tts_seconds"] = round(
            a_generation + b_generation + c_gen, 4
        )
        summary["phrases"].append(entry)
        print(
            f"[{pid}] A={a_info.duration_seconds:.2f}s B={b_duration:.2f}s "
            f"(gen {b_generation:.2f}s + stitch {stitch_time:.2f}s)"
        )

    # Write a machine-readable summary.
    summary["voice_config"] = vc
    summary["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%S")
    out_file = output_root / "summary.json"
    out_file.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nSummary: {out_file}")
    return summary


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run the hybrid Nepali/English TTS experiment.")
    parser.add_argument("--corpus", default=str(HYBRID_CORPUS))
    parser.add_argument("--output", default=str(OUTPUT_ROOT))
    args = parser.parse_args(argv)

    try:
        run_experiment(Path(args.corpus), Path(args.output))
    except (HybridCorpusError, Exception) as exc:  # noqa: BLE001 - report and exit
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
