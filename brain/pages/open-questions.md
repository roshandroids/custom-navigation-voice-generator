---
id: open-questions
title: "Unresolved technical questions & review-needed decisions"
category: project
status: active
created: "2026-08-15T02:19:06"
updated: "2026-08-15T02:36:45"
---

<!-- compiled_truth -->
# Unresolved technical questions & decisions needing review

Durable open questions (review before proceeding on related work):

1. **Which TTS engine wins for Nepali navigation speech?** — the benchmark's core question; undecided. **Piper is verified working** (all 3 ne_NP voices) and is the baseline ([[piper-nepali-voices]]); quality is now the open question pending human listening evaluation.
2. **Piper voice selection** — `ne_NP-chitwan-medium` (CC0) vs `ne_NP-google-medium`/`x_low` (CC-BY-SA-4.0). Quality comparison pending human listening; licensing strongly favors chitwan for a commercial product.
3. **Piper upstream status / license** — maintained package is **GPL-3.0** (OHF-Voice fork); MIT rhasspy/piper archived. GPL implications for distributed products need review.
4. **Chatterbox watermarking** — every generated file carries Perth watermark; product/legal implications for voice-pack export.
5. **Kokoro CC BY training data** — possible attribution obligations for derivative redistribution.
6. **Qwen3-TTS and Chatterbox CLI flags** — unverified at scaffold time; need real installs to confirm adapter commands.
7. **Nepali quality for all engines** — no quality claims made until human listening evaluation ([[engine-selection-pending]]). Piper capability is verified; quality is not.

Related: [[tts-candidates]], [[engine-licensing]], [[piper-performance-baseline]].


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
