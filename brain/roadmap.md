---
slug: roadmap
title: Roadmap
role: milestones
updated: "2026-08-15T02:13:45"
---

# Roadmap

## Milestones

```mermaid
gantt
  title Roadmap
  dateFormat YYYY-MM-DD
  section Milestone 1 (current)
  TTS research & benchmark foundation :m1, 2026-08-15, 2026-08-15
  section Milestone 2 (next)
  Install Piper + generate real Nepali WAVs :m2, after m1, 30d
  Run full benchmark across engines :after m2, 30d
  Human listening evaluation :after m2, 30d
  section Milestone 3 (deferred)
  TTS engine selection decision :after m2, 14d
  Flutter app development :after m3, 60d
  Waze recording workflow :after m4, 30d
  Voice pack export :after m5, 30d
```

## Status

- **Milestone 1 (current):** TTS research and benchmarking — foundation is complete (corpus, engine abstraction, runner, tests, docs). Real engine audio is the next step.
- Flutter, backend, and Waze integration are **intentionally deferred** until the TTS engine evaluation provides sufficient evidence.
