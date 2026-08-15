---
id: flutter-deferred
title: Flutter frontend deferred until TTS evaluation
category: decision
status: active
created: "2026-08-15T02:15:22"
updated: "2026-08-15T02:19:33"
---

<!-- compiled_truth -->
# Flutter frontend deferred

**Decision: Flutter is the intended frontend technology, but Flutter development is intentionally deferred** until the TTS engine evaluation provides sufficient evidence.

- Do NOT build the Flutter application during the current TTS benchmark milestone.
- Rationale: the product experience depends on TTS quality for Nepali speech; building the app before engine selection would freeze the TTS choice without data.
- This is a deferral, not a reversal — Flutter remains the intended frontend for the eventual app.

Related: [[tts-benchmark-milestone]], [[tts-candidates]], background.


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
