---
id: hybrid-tts-experiment
title: "Hybrid Nepali+English TTS experiment (2026-08-15)"
category: project
status: active
created: "2026-08-15T02:57:58"
updated: "2026-08-15T12:26:08"
---

<!-- compiled_truth -->
# Hybrid Nepali+English TTS experiment

**Status: EXPERIMENTAL — NOT part of MVP, NOT part of current architecture. Kept as historical evidence only.**

**Product requirement (clarified 2026-08-15):** voice packs are single-language. The product does NOT need mixed-language speech within a single instruction. The TTS engine must NOT be asked to pronounce English words using a Nepali voice, and there is no requirement to stitch Nepali and English voices together.

**Historical experiment record (2026-08-15):**
- Motivation (no longer a product direction): English words through the Nepali voice were hard to understand; tested stitching Nepali voice (ne segments) + English voice (en segments).
- Nepali voice: `ne_NP-chitwan-medium`; English voice: `en_US-joe-medium` (both 22,050 Hz, CC0).
- 10 explicit-segment phrases in `benchmark/corpus/hybrid_phrases.json`; 3 versions per phrase (A: Nepali-only, B: stitched, C: phonetic transliteration).
- Findings (experimental, superseded by the clarified requirement): 10/10 generated, click-free stitching, pure-Python resampling.

**Why it no longer matters for the product:** mixed Nepali-English speech inside a single instruction is NOT an MVP requirement. The English-in-Nepali-voice question is irrelevant to the core product, which uses one language per voice pack. The relevant question is now: can Piper provide a good standalone Nepali voice AND a good standalone English voice?

Related: [[voice-pack-single-language]], [[piper-nepali-voices]], [[engine-licensing]].


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

- time: 2026-08-15T03:07:02
  kind: decision
  summary: "requirement clarified: single-language voice packs; hybrid is experimental/not-MVP"
  source: product requirement clarification 2026-08-15
  affects: [hybrid-tts-experiment]

- time: 2026-08-15T12:26:08
  kind: decision
  summary: "Corpus rewrite (2026-08-15): product Nepali phrases no longer contain Latin English; humor_002 kept as the only deliberate ne-en language-test phrase. Hybrid remains experimental/historical — not MVP."
  affects: [voice-pack-single-language, nepali-content-principle]
