# Architecture

This document describes the technical architecture of the TTS benchmark prototype.

## Goals

- Run multiple TTS engines against an identical, standardized phrase corpus.
- Keep engine implementations swappable without touching core logic.
- Isolate failures (one broken engine never blocks the others).
- Produce structured, machine-readable evaluation data.
- Stay simple enough that any single adapter can be replaced.

## Module map

```
benchmark/
├── corpus/
│   └── phrases.json          # the standardized phrase corpus (stable IDs)
├── core/
│   ├── corpus.py             # load/validate corpus; Phrase dataclass
│   ├── tts.py                # TTSAdapter ABC, AudioInfo, SynthesisResult, EngineSpec
│   ├── registry.py           # engine name -> adapter class registry
│   ├── runner.py             # BenchmarkRunner, BenchmarkConfig, RunSummary
│   └── audio.py              # WAV metadata inspection, silence writer, ffmpeg resample
├── engines/
│   ├── __init__.py           # imports all adapters (registration side effect)
│   ├── dummy/                # silence generator — always available (reference adapter)
│   ├── piper/                # subprocess wrapper around `piper` CLI
│   ├── kokoro/               # in-process wrapper around `kokoro_onnx`
│   ├── qwen3/                # subprocess wrapper around `qwen3-tts` CLI
│   └── chatterbox/           # subprocess wrapper around `chatterbox-tts` CLI
├── scripts/
│   ├── run_benchmark.py      # CLI entry point (benchmark-run)
│   └── validate_corpus.py    # corpus validation (corpus-validate)
├── output/                   # generated WAVs, one dir per engine (gitignored)
└── results/                  # per-engine JSON + CSV (gitignored)
```

## Engine abstraction

```python
class TTSAdapter(ABC):
    name: str                       # registry key, == engine directory name
    model: str                      # model identifier
    voice: str                      # voice identifier
    languages: list[str]            # corpus languages the engine accepts
    supports_devanagari: bool       # can consume Devanagari script directly
    requires_gpu: bool

    def synthesize(self, text: str, output_path: Path) -> AudioInfo: ...
    def check_available(self) -> str | None: ...   # None == runnable
    def prepare(self) -> None: ...                  # optional one-time setup hook
```

The runner depends only on this interface plus the registry. Engines with heavy or
conflicting dependencies (Qwen3-TTS, Chatterbox) shell out to their own CLI/environment,
and report unavailability via `check_available()` when not installed — so the benchmark
still runs (and records the skip) without them.

## Data flow

```
corpus-load → BenchmarkRunner.run_all(phrases)
                per engine:
                  check_available?  ──no──▶ results/<engine>.json {"unavailable": true, reason}
                  │ yes
                  prepare()                  (model download, one-time)
                  per phrase:
                    synthesize(text, out) ──▶ timing + error capture
                  write results/<engine>.json + results/<engine>.csv
```

Every `SynthesisResult` records engine, model, voice, phrase ID, text, timestamps,
generation duration, audio metadata (duration/sample rate/channels), success flag and
error message. Existing WAV files are reused unless `--force` is passed.

## Text selection

The runner passes `Phrase.text` to adapters with `supports_devanagari=True`; adapters
without Devanagari support receive `Phrase.tts_text` (the Latin-script rendering) when
available. This lets English-only engines run the full corpus without pretending they
speak Nepali — the metadata always records exactly which text was synthesized.

## Isolation & error handling

- Adapter exceptions are converted into failed `SynthesisResult`s; the runner never raises.
- `check_available()` failures produce a skip record instead of a crash.
- Unknown engine names on the CLI exit with code 2 *before* any synthesis.

## Assumptions & decisions

- **Python 3.10+** (3.12 used here) — all four candidate engines are Python-based.
- **Standardized audio**: 16 kHz mono PCM WAV target. Engines outputting other rates are
  resampled via ffmpeg when present; otherwise native rate is kept and recorded.
- **No artificial silence** is added by the benchmark. The 3-second recording delay
  belongs to the future recording workflow, not here.
- **Sequential generation** for now — correctness first; parallelization is a later
  optimization.
- **Timing** measures wall-clock time (model + I/O + process), not pure model time.
- The corpus is the single source of truth for phrases; adapters never hard-code text.
