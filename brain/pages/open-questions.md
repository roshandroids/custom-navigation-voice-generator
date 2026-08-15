---
id: open-questions
title: "Unresolved technical questions & review-needed decisions"
category: project
status: active
created: "2026-08-15T02:19:06"
updated: "2026-08-15T03:15:36"
---

<!-- compiled_truth -->
# Unresolved technical questions & decisions needing review

Durable open questions (review before proceeding on related work):

1. **Which TTS engine wins for Nepali navigation speech?** — the benchmark's core question; undecided. Piper is verified working (Nepali + English voices) and is the baseline; quality is pending human listening evaluation.
2. **Can Piper independently provide a good standalone Nepali voice AND a good standalone English voice?** — the current evaluation question (single-language voice packs, [[voice-pack-single-language]]). Nepali voices verified; English voices (joe/kristin/ljspeech) generated — human listening pending.
3. **English voice selection** — `en_US-joe-medium` (CC0) baseline; `en_US-kristin-medium` / `en_US-ljspeech-medium` (public domain) candidates. Quality pending listening; licensing favors all three.
4. **Piper upstream status / license** — maintained package is GPL-3.0 (OHF-Voice fork); MIT rhasspy/piper archived. GPL implications for distributed products need review.
5. **Kokoro CC BY training data** — possible attribution obligations for derivative redistribution.
6. **Qwen3-TTS and Chatterbox CLI flags** — unverified at scaffold time; need real installs to confirm adapter commands.
7. **Hybrid stitching** — NO LONGER a product question (single-language voice packs); the experiment is historical evidence only.

Related: [[tts-candidates]], [[engine-licensing]], [[voice-pack-single-language]].


## Timeline

- time: 2026-08-15T02:19:06
  kind: decision
  summary: "Created this page: Unresolved technical questions & review-needed decisions"
  source: "initial setup + research"
  affects: [open-questions]

- time: 2026-08-15T02:19:06
  kind: decision
  summary: captured unresolved items
  source: "initial setup + research"
  affects: [open-questions]

- time: 2026-08-15T02:36:45
  kind: decision
  summary: Piper experiment resolved several open questions
  source: piper experiment 2026-08-15
  affects: [open-questions]

- time: 2026-08-15T03:15:36
  kind: decision
  summary: "English evaluation in progress; hybrid no longer a product question"
  source: product requirement clarification 2026-08-15
  affects: [open-questions]
