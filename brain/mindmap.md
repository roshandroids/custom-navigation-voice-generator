---
slug: mindmap
title: Feature mindmap
role: feature mindmap
updated: "2026-08-15T02:19:48"
---

# Feature mindmap

## Feature mindmap

```mermaid
mindmap
  root((Custom Navigation Voice Generator))
    TTS Benchmark (current)
      Corpus
        Directions
        Distances
        Traffic
        Enforcement
        Arrival
        Language tests
      Engines
        Piper
        Kokoro
        Qwen3-TTS
        Chatterbox
        Dummy
      Core
        Runner
        Registry
        Adapters
      Results
        WAV output
        JSON/CSV metadata
        Human evaluation (future)
    Future Product (deferred)
      Custom instruction editor
      TTS preview
      Recording workflow
        Preparation delay
      Waze manual recording
      Voice pack export
    App (deferred)
      Flutter frontend
      Python/FastAPI TTS service (possible)
```

## Scope guardrail

Only the **TTS Benchmark** branch exists today. Flutter app, backend, and Waze integration are intentionally deferred (see background and [[tts-benchmark-milestone]]).
