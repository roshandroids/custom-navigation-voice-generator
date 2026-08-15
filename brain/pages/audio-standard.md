---
id: audio-standard
title: "Standardized audio: WAV, 16 kHz mono PCM, no artificial silence"
category: decision
status: active
created: "2026-08-15T02:16:52"
updated: "2026-08-15T02:16:52"
---

<!-- compiled_truth -->
# Standardized audio for the benchmark

**Decision: standardize generated audio** as much as reasonably possible:

- **WAV** format
- **Consistent sample rate** (target 16 kHz)
- **Mono** where supported/appropriate
- **PCM** audio
- **No artificial silence added by the benchmark** unless the engine itself requires it

**Important:** the **3-second recording preparation delay belongs to the later recording workflow**, NOT the benchmark. The benchmark evaluates clean TTS output.

Rationale: consistent audio makes engine comparisons (and later human listening evaluation) fair. Adapters may resample engine-native output via ffmpeg when available; otherwise native rate is kept and recorded in metadata.

Related: [[corpus-standard]], [[tts-benchmark-milestone]].


## Timeline

- time: 2026-08-15T02:16:52
  kind: decision
  summary: "Created this page: Standardized audio: WAV, 16 kHz mono PCM, no artificial silence"
  source: project brief
  affects: [audio-standard]

- time: 2026-08-15T02:16:52
  kind: decision
  summary: captured audio requirements
  source: project brief
  affects: [audio-standard]
