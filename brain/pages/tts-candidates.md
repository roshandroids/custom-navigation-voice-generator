---
id: tts-candidates
title: "TTS candidate engines (Piper, Kokoro, Qwen3-TTS, Chatterbox)"
category: concept
status: active
created: "2026-08-15T02:14:35"
updated: "2026-08-15T02:14:35"
---

<!-- compiled_truth -->
# TTS candidate engines

The benchmark currently targets four local/open-source TTS engines:

- **Piper** — fast local neural TTS (VITS), ONNX-based, per-language voice models. **Has identifiable Nepali voices** (`ne_NP-chitwan-medium`, `ne_NP-google-x_low`, `ne_NP-google-medium`).
- **Kokoro** — lightweight (82M) TTS via `kokoro-onnx`; Apache-2.0. No Nepali voice; English + other languages.
- **Qwen3-TTS** — large multilingual TTS (Alibaba); code/weights Apache-2.0 per HF card. Supports 10 languages — **Nepali NOT among them** (zh, en, ja, ko, de, fr, ru, pt, es, it).
- **Chatterbox** — Resemble AI, 0.5B Llama backbone; MIT. Supports 23 languages — **Nepali NOT among them**; Hindi single-language finetune exists (closest script-adjacent option).

The `dummy` adapter (silence) exists for pipeline testing and is always available.

Key point: **Piper is the first candidate intended for real-audio testing** because it is the only one with identifiable Nepali voices. This is a research finding, NOT a final engine-selection decision. See [[engine-selection-pending]], [[engine-licensing]].


## Timeline

- time: 2026-08-15T02:14:35
  kind: decision
  summary: "Created this page: TTS candidate engines (Piper, Kokoro, Qwen3-TTS, Chatterbox)"
  source: project brief
  affects: [tts-candidates]

- time: 2026-08-15T02:14:35
  kind: decision
  summary: captured candidate list
  source: project brief
  affects: [tts-candidates]
