---
id: hybrid-tts-experiment
title: "Hybrid Nepali+English TTS experiment (2026-08-15)"
category: project
status: active
created: "2026-08-15T02:57:58"
updated: "2026-08-15T02:59:23"
---

<!-- compiled_truth -->
# Hybrid Nepali+English TTS experiment

**Status: experimental — pending human listening evaluation. Not a final architecture decision.**

**Motivation:** Piper Nepali voices produce good Nepali speech, but English words through the Nepali voice are hard to understand. Test: stitch Nepali Piper voice (ne segments) + English Piper voice (en segments).

**Setup:**
- Nepali voice: `ne_NP-chitwan-medium` (22,050 Hz, CC0)
- English voice: `en_US-joe-medium` (22,050 Hz, CC0) — selected as the only English voice with a permissive (CC0) license; ryan (CC BY-NC-SA, non-commercial) and lessac (research-only license) rejected
- 10 explicit-segment hybrid phrases in `benchmark/corpus/hybrid_phrases.json` (separate from the main 50-phrase corpus)
- 3 versions per phrase: A (Nepali voice whole phrase), B (stitched hybrid), C (phonetic Nepali transliteration, Nepali voice)
- Pure-Python resampling + concatenation at 22,050 Hz — no ffmpeg required

**Findings (experimental):**
- All 10 phrases generated; 0 failures (segments + A/B/C versions).
- Stitching is click-free (max consecutive-sample delta ~13k, below pop threshold).
- Sample-rate normalization works (22050↔16000 verified in tests) though both selected voices are 22,050 Hz.
- Performance: segment gen ~0.3-0.7 s, stitch ~0.02-0.04 s per phrase, on M1 CPU.

**Open question (the experiment's purpose):** does Version B (hybrid) make English significantly easier to understand while staying natural enough for navigation? **Awaiting human listening** — see evaluation table in docs/tts-evaluation.md.

Related: [[piper-nepali-voices]], [[engine-licensing]], [[tts-candidates]].


## Timeline

- time: 2026-08-15T02:57:58
  kind: decision
  summary: "Created this page: Hybrid Nepali+English TTS experiment (2026-08-15)"
  source: hybrid experiment 2026-08-15
  affects: [hybrid-tts-experiment]

- time: 2026-08-15T02:59:23
  kind: decision
  summary: "hybrid experiment findings (experimental, pending listening)"
  source: hybrid experiment 2026-08-15
  affects: [hybrid-tts-experiment]
