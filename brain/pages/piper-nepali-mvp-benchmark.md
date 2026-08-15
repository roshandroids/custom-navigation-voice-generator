---
id: piper-nepali-mvp-benchmark
title: "Piper Nepali MVP benchmark run (2026-08-15)"
category: reference
status: active
tags: [benchmark, piper, nepali]
created: "2026-08-15T14:46:23"
updated: "2026-08-15T14:46:32"
---

<!-- compiled_truth -->
# Piper Nepali MVP benchmark run (2026-08-15)

Generated audio for the finalized 25-phrase Nepali product corpus (all `ne` phrases in
`benchmark/corpus/phrases.json`, `review_status: approved`) with the three official
Nepali Piper voices. `humor_002` (`ne-en`) excluded — it is a deliberate TTS language
test, not product copy.

## Facts

- **Benchmark date:** 2026-08-15
- **Voices tested:** ne_NP-chitwan-medium, ne_NP-google-medium, ne_NP-google-x_low
- **Generations:** 75/75 succeeded (25 phrases × 3 voices), 0 failures
- **Audio format:** mono 16-bit PCM WAV; chitwan + google-medium at 22,050 Hz,
  google-x_low at 16,000 Hz (rate fixed by voice model config, piper CLI has no rate flag)
- **Performance (context only — NOT a selection criterion):**
  | Voice | avg gen/phrase | avg audio dur | RTF |
  |---|---|---|---|
  | ne_NP-chitwan-medium | 0.58 s | 2.27 s | 0.25 |
  | ne_NP-google-medium | 0.74 s | 2.32 s | 0.32 |
  | ne_NP-google-x_low | 0.69 s | 2.14 s | 0.32 |
- **Warnings:** ne_NP-google-x_low emitted `Missing phoneme from id map` warnings
  (phonemes ʰ and ̃) on 20 of 25 phrases. Same warning family previously seen on
  ne_NP-google-medium in the first Piper experiment. chitwan-medium: no warnings this run.
- **Human evaluation status:** pending — scores live in `docs/tts-evaluation-ne.md`
  (75 blank rows, 1–5 scale, priority flags on redlight_camera_002, roundabout_002,
  distance_200m_001, distance_100m_002, long_001, speed_camera_002).

## Status

**No voice has been selected.** Voice selection requires human listening; automated
metrics (RTF, duration, warnings) do not decide. See [[engine-selection-pending]] and
[[piper-performance-baseline]] (the earlier 50-phrase baseline).


## Timeline

- time: 2026-08-15T14:46:23
  kind: decision
  summary: "Created this page: Piper Nepali MVP benchmark run (2026-08-15)"
  source: nepali benchmark generation task 2026-08-15
  affects: [piper-nepali-mvp-benchmark]

- time: 2026-08-15T14:46:32
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: brain update-truth
  affects: [piper-nepali-mvp-benchmark]
