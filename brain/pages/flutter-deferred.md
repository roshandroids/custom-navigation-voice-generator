---
id: flutter-deferred
title: Flutter frontend deferred until TTS evaluation
category: decision
status: active
created: "2026-08-15T02:15:22"
updated: "2026-08-15T23:21:16"
---

<!-- compiled_truth -->
# Flutter frontend MVP underway

**Update (2026-08-15): the Flutter frontend is no longer deferred.** A frontend MVP lives in `frontend/` and follows:

- Feature-first Clean Architecture (presentation → use cases → domain ← data)
- Riverpod for DI + state management, go_router for navigation
- Repository abstractions in domain; implementations in data
- TTS behind `TtsRepository` — current `MockTtsRepository`, future `HttpTtsRepository` → FastAPI → Piper
- TDD (domain → use cases → data → notifiers → widgets → routing)
- No Python/FastAPI/Piper dependency in the frontend; mock repositories are seeded from the finalized corpora

The TTS engine evaluation (benchmark) still decides the real engine; the frontend does not freeze that choice because TTS sits behind a repository boundary.

Related: [[flutter-frontend-architecture]], [[tts-benchmark-milestone]], [[voice-pack-single-language]], [[audio-standard]].


## Timeline

- time: 2026-08-15T02:15:22
  kind: decision
  summary: "Created this page: Flutter frontend deferred until TTS evaluation"
  source: project brief
  affects: [flutter-deferred]

- time: 2026-08-15T02:15:22
  kind: decision
  summary: captured decision
  source: project brief
  affects: [flutter-deferred]

- time: 2026-08-15T02:19:33
  kind: decision
  summary: fix root-page references to plain slugs
  source: lint-links
  affects: [flutter-deferred]

- time: 2026-08-15T23:21:16
  kind: decision
  summary: "Flutter frontend MVP is now being built; deferral is lifted for the frontend"
  source: "task: Flutter frontend MVP"
  affects: [flutter-deferred]
