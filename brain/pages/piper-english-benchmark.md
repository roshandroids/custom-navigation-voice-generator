---
id: piper-english-benchmark
title: "Piper English voice benchmark results (2026-08-15)"
category: reference
status: active
tags: [piper, english, benchmark]
created: "2026-08-15T11:23:16"
updated: "2026-08-15T11:23:34"
---

<!-- compiled_truth -->
# Piper English voice benchmark results

Standalone English evaluation measured 2026-08-15 on Apple M1 (CPU), piper-tts 1.6.1 (GPL-3.0 OHF-Voice fork), 47-phrase English corpus (`benchmark/corpus/phrases_en.json`). One piper subprocess per phrase; each phrase generated as a single English TTS request — no hybrid segmentation, no voice stitching.

| Voice | Dataset license | Gender | Sample rate | Channels | Generated | Failed | Avg gen/phrase | Avg audio dur | Real-time factor |
|---|---|---|---|---|---|---|---|---|---|
| en_US-joe-medium (BASELINE) | CC0 | male | 22,050 Hz | mono | 47/47 | 0 | 0.74 s | 1.99 s | 0.37 |
| en_US-kristin-medium | public domain (LibriVox) | female | 22,050 Hz | mono | 47/47 | 0 | 0.80 s | 2.32 s | 0.35 |
| en_US-ljspeech-medium | public domain (LJSpeech) | female | 22,050 Hz | mono | 47/47 | 0 | 0.81 s | 2.20 s | 0.37 |

- **141/141 generations succeeded, 0 failures** across the three English voices.
- Audio format: mono 16-bit PCM WAV, 22,050 Hz (voice model config determines rate — piper CLI has no sample-rate flag).
- Real-time factor < 1.0 for all English voices — faster than real time on M1 CPU.
- joe baseline: full 47-phrase run ~35 s wall clock (includes per-phrase subprocess startup); audio duration range 0.64–6.41 s.
- Licensing (all three): model repo MIT; voices CC0 / public domain — permissive. Piper code package remains GPL-3.0 (see [[engine-licensing]]).
- **Human evaluation pending** — scores must come from the user listening to `benchmark/output/piper/<voice>/<phrase_id>.wav` (sheet: `docs/tts-evaluation-en.md`). No voice is selected until the user reviews the audio.

Related: [[piper-performance-baseline]], [[piper-nepali-voices]], [[voice-pack-single-language]], [[engine-licensing]].


## Timeline

- time: 2026-08-15T11:23:16
  kind: decision
  summary: "Created this page: Piper English voice benchmark results (2026-08-15)"
  source: english benchmark run 2026-08-15
  affects: [piper-english-benchmark]

- time: 2026-08-15T11:23:34
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: brain update-truth
  affects: [piper-english-benchmark]
