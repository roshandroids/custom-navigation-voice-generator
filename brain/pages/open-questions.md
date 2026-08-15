---
id: open-questions
title: "Unresolved technical questions & review-needed decisions"
category: project
status: active
created: "2026-08-15T02:19:06"
updated: "2026-08-15T02:19:06"
---

<!-- compiled_truth -->
# Unresolved technical questions & decisions needing review

Durable open questions (review before proceeding on related work):

1. **Which TTS engine wins for Nepali navigation speech?** — the benchmark's core question; undecided. Piper is the first candidate to test ([[piper-nepali-voices]]).
2. **Piper voice selection** — `ne_NP-chitwan-medium` vs `ne_NP-google-x_low`/`medium`; needs real-audio comparison.
3. **Piper upstream status** — `rhasspy/piper` archived (MIT); active dev in `OHF-Voice/piper1-gpl` (GPL). Which do we build on for a commercial app?
4. **Chatterbox watermarking** — every generated file carries Perth watermark; product/legal implications for voice-pack export.
5. **Kokoro CC BY training data** — possible attribution obligations for derivative redistribution.
6. **Qwen3-TTS and Chatterbox CLI flags** — unverified at scaffold time; need real installs to confirm adapter commands.
7. **Nepali quality for all engines** — no claims made until actual evaluation ([[engine-selection-pending]]).

Related: [[tts-candidates]], [[engine-licensing]].


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
