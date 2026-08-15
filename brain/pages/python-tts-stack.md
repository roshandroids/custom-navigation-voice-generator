---
id: python-tts-stack
title: Python is the TTS experimentation environment
category: decision
status: active
created: "2026-08-15T02:15:10"
updated: "2026-08-15T02:19:33"
---

<!-- compiled_truth -->
# Python is the TTS experimentation environment

**Decision: Python is the preferred environment for TTS experimentation**, because the relevant open-source TTS ecosystem (Piper, Kokoro, Qwen3-TTS, Chatterbox) is primarily Python-oriented.

- Benchmark implemented in Python 3.10+ (3.12 used), core is pure stdlib.
- A **future Python/FastAPI TTS service is possible**, but **no production backend is being built yet**.
- This does not decide the future app stack (Flutter remains the intended frontend).

Related: [[tts-benchmark-milestone]], stack.


## Timeline

- time: 2026-08-15T02:15:10
  kind: decision
  summary: "Created this page: Python is the TTS experimentation environment"
  source: project brief
  affects: [python-tts-stack]

- time: 2026-08-15T02:15:10
  kind: decision
  summary: captured decision
  source: project brief
  affects: [python-tts-stack]

- time: 2026-08-15T02:19:33
  kind: decision
  summary: fix root-page references to plain slugs
  source: lint-links
  affects: [python-tts-stack]
