# Hybrid Nepali + English TTS Experiment

**Date:** 2026-08-15
**Status:** experiment — results pending human listening evaluation
**Scope:** test whether stitching a Nepali Piper voice (Nepali segments) with an
English Piper voice (English segments) yields acceptable mixed-language navigation
speech. This is an experiment only — no final architecture decision.

## Motivation

The Piper Nepali benchmark (see `piper-nepali-voices` in BRAIN) confirmed Piper
produces good Nepali speech, but English words spoken through the Nepali voice are
difficult to understand (accent/pronunciation). This experiment tests a two-voice
stitching approach:

```
Nepali text → Piper Nepali voice ─┐
                                  ├→ audio stitching → single WAV
English text → Piper English voice ┘
```

## Voices

| Role | Voice | Sample rate | Dataset license | Source |
| ---- | ----- | ----------- | --------------- | ------ |
| Nepali | `ne_NP-chitwan-medium` | 22,050 Hz | CC0 | huggingface.co/rhasspy/piper-voices |
| English | `en_US-joe-medium` | 22,050 Hz | **CC0** | huggingface.co/rhasspy/piper-voices |

**Why `en_US-joe-medium`:** the only English voice with a clearly permissive (CC0)
dataset license, matching the chitwan Nepali voice. Other natural English voices were
rejected for licensing: `en_US-ryan-medium` (CC BY-NC-SA 4.0, non-commercial),
`en_US-lessac-medium` (Lessac/Blizzard 2013 — research-only license, explicitly excludes
commercial voice synthesis products). Joe is finetuned from lessac, male, natural —
suitable navigation-assistant style. `piper-tts` code itself remains GPL-3.0-or-later
(OHF-Voice fork) — see `docs/decisions/engine-licensing.md`.

## Corpus

`benchmark/corpus/hybrid_phrases.json` — 10 phrases, stored **separately** from the
main 50-phrase benchmark corpus. Segments are **explicitly defined** (no automatic
language detection):

```json
{
  "id": "hybrid_001",
  "text": "ल भाइ, अगाडि speed camera छ। अब बिस्तारै।",
  "segments": [
    { "language": "ne", "text": "ल भाइ, अगाडि" },
    { "language": "en", "text": "speed camera" },
    { "language": "ne", "text": "छ। अब बिस्तारै।" }
  ],
  "version_c": { "language": "ne", "text": "ल भाइ, अगाडि स्पिड क्यामेरा छ। अब बिस्तारै।" }
}
```

`version_c` is the full phrase with English words transliterated into phonetic Nepali,
spoken entirely by the Nepali voice.

## Three versions per phrase

- **Version A** — whole phrase, Nepali voice only (status quo from the main benchmark).
- **Version B** — Nepali voice for `ne` segments, English voice for `en` segments,
  concatenated. Per-segment WAVs are kept.
- **Version C** — whole phrase (phonetic `version_c` text), Nepali voice only.

Output layout (`benchmark/output/hybrid/<phrase_id>/`, gitignored):

```
001-ne.wav 002-en.wav ...   # per-segment (Version B)
version_a.wav version_b.wav version_c.wav
```

## Method

- **Generation:** reuse the existing `PiperAdapter` (piper-tts 1.6.1, GPL-3.0 fork),
  one subprocess per segment.
- **Normalization:** all segments read as mono 16-bit PCM and linearly resampled to a
  common output rate (22,050 Hz) in pure Python — **no ffmpeg required**.
- **Stitching:** simple concatenation (no crossfade, no mastering — deliberately).
  Voice transitions are evaluated as-is.
- **Click avoidance:** no artificial silence is inserted; concatenation is sample-level
  so boundaries are clean (verified: max consecutive-sample delta ≈ 13k, below the
  ~30k pop threshold).
- No preparation/post silence, no recording workflow, no Waze integration.

## Performance (M1 CPU, 2026-08-15)

| Measure | Value |
| ------- | ----- |
| Nepali segment generation | ~0.3–0.6 s per segment |
| English segment generation | ~0.4–0.7 s per segment |
| Total TTS per phrase (A+B+C) | ~1.2–2.5 s |
| Stitching (10-segment phrases) | ~0.02–0.04 s per phrase |
| Final audio duration (Version B) | ~1.8–4.5 s |

Full per-phrase timings: `benchmark/output/hybrid/summary.json`.

## Human evaluation

See the evaluation table in `docs/tts-evaluation.md` ("Hybrid Nepali/English
experiment"). Scores are blank — listening is pending. The key question:

> Does the hybrid version make English significantly easier to understand while
> remaining natural enough to use as a navigation voice?

## Files

- `benchmark/corpus/hybrid_phrases.json` — hybrid corpus (committed)
- `benchmark/scripts/run_hybrid.py` — experiment runner (committed)
- `tests/test_hybrid.py` — schema/stitching/normalization tests (committed)
- `benchmark/output/hybrid/` — generated WAVs + summary.json (gitignored)
- `benchmark/engines/piper/models/en_US-joe-medium.onnx` (+ .json) — English voice (gitignored)

## Reproduce

```bash
.venv/bin/python -m benchmark.scripts.run_hybrid
```

## Next steps (NOT part of this experiment)

Automatic language detection, multilingual architecture, Flutter, FastAPI — all
deferred until the listening evaluation of this experiment is reviewed.
