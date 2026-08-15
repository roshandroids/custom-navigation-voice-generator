---
id: engine-licensing
title: TTS engine licensing research record
category: reference
status: active
created: "2026-08-15T02:15:34"
updated: "2026-08-15T02:15:35"
---

<!-- compiled_truth -->
# TTS engine licensing research

Full record: `docs/decisions/engine-licensing.md` (research notes, not legal advice). Summary of verified findings (2026-08-15):

- **Piper** — source code **MIT** (rhasspy/piper), but the repo is **archived** (Oct 2025); development moved to `OHF-Voice/piper1-gpl` (**GPL** fork). Voice models: per-voice MODEL_CARD licensing; Piper imposes no additional restrictions. **Per-voice licensing requires verification.**
- **Kokoro** — code **Apache-2.0**; weights **Apache-2.0** (HF card). Training data includes **CC BY** audio (Koniwa, SIWIS) — attribution obligations for derivatives may apply.
- **Qwen3-TTS** — code **Apache-2.0**; weights **Apache-2.0** per HF card. 10 supported languages, **no Nepali**.
- **Chatterbox** — code **MIT**; weights **MIT** (HF card). **Every generated file is watermarked** with Resemble's Perth watermarker — product/legal implications for voice-pack export. 23 languages, **no Nepali** (Hindi finetune exists).

**Do not invent license information.** Items not verified are marked UNKNOWN — REQUIRES VERIFICATION in the doc. No legal conclusions drawn.

Related: [[tts-candidates]], [[piper-nepali-voices]].


## Timeline

- time: 2026-08-15T02:15:34
  kind: decision
  summary: "Created this page: TTS engine licensing research record"
  source: web research 2026-08-15
  affects: [engine-licensing]

- time: 2026-08-15T02:15:35
  kind: decision
  summary: captured licensing research summary
  source: web research 2026-08-15
  affects: [engine-licensing]
