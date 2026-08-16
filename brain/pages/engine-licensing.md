---
id: engine-licensing
title: TTS engine licensing research record
category: reference
status: active
created: "2026-08-15T02:15:34"
updated: "2026-08-15T11:23:44"
---

<!-- compiled_truth -->
# TTS engine licensing research record

Full record: `docs/decisions/engine-licensing.md` (research notes, not legal advice). Verified findings (2026-08-15):

- **Piper** — the maintained `piper-tts` PyPI package (v1.6.1) is **GPL-3.0-or-later** from `OHF-Voice/piper1-gpl`; original `rhasspy/piper` is MIT but **archived**. Voice models (huggingface.co/rhasspy/piper-voices, repo MIT, per-voice MODEL_CARDs):
  - `ne_NP-chitwan-medium`: dataset **CC0** — most permissive of the three.
  - `ne_NP-google-medium` / `ne_NP-google-x_low`: dataset **CC-BY-SA-4.0** (OpenSLR 43) — **share-alike**, legal review needed before derivative/commercial use.
  - **English voices actually tested** ([[piper-english-benchmark]]): `en_US-joe-medium` (baseline) dataset **CC0**; `en_US-kristin-medium` and `en_US-ljspeech-medium` datasets **public domain** — all three permissive, no commercial-use restriction recorded on their model cards.
  - **No legal conclusions drawn.**
- **Kokoro** — code Apache-2.0; weights Apache-2.0 (HF card). Training data includes CC BY audio (Koniwa, SIWIS) — attribution obligations may apply.
- **Qwen3-TTS** — code Apache-2.0; weights Apache-2.0 per HF card. 10 supported languages, no Nepali.
- **Chatterbox** — code MIT; weights MIT (HF card). Every generated file watermarked (Perth). 23 languages, no Nepali (Hindi finetune exists).

Related: [[tts-candidates]], [[piper-nepali-voices]], [[piper-english-benchmark]].


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

- time: 2026-08-15T02:35:33
  kind: reversal
  summary: "Verified 2026-08-15: pip install piper-tts (v1.6.1) is GPL-3.0-or-later from OHF-Voice/piper1-gpl, NOT the MIT rhasspy/piper. Voice licenses verified: chitwan CC0 dataset, google-medium & google-x_low CC-BY-SA-4.0 (OpenSLR 43)."
  source: "piper experiment 2026-08-15 (PyPI metadata + MODEL_CARDs)"
  affects: [engine-licensing, tts-candidates]

- time: 2026-08-15T02:36:14
  kind: decision
  summary: "Piper licensing verified by experiment; reversal recorded"
  source: piper experiment 2026-08-15
  affects: [engine-licensing]

- time: 2026-08-15T02:59:28
  kind: evidence
  summary: "en_US-joe-medium verified: CC0 dataset (OHF-Voice/voice-datasets), 22,050 Hz, finetuned from lessac — selected for hybrid experiment. en_US-ryan-medium (CC BY-NC-SA, non-commercial) and en_US-lessac-medium (research-only license) rejected for commercial suitability."
  source: hybrid experiment 2026-08-15
  affects: [engine-licensing, hybrid-tts-experiment]

- time: 2026-08-15T11:23:44
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: brain update-truth
  affects: [engine-licensing]
