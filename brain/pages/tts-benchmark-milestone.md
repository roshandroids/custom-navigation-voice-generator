---
id: tts-benchmark-milestone
title: "Current milestone is TTS research and benchmarking — not Flutter"
category: decision
status: active
created: "2026-08-15T02:14:28"
updated: "2026-08-15T02:19:33"
---

<!-- compiled_truth -->
# Current milestone: TTS research and benchmarking

The project's current milestone is **TTS research and benchmarking** — determining which local/open-source TTS engine produces high-quality Nepali navigation speech.

- The first product workflow to validate: navigation situation → standard instruction → custom instruction → TTS → preview → recording mode → preparation delay → generated voice plays → user manually records into Waze.
- The initial product does **NOT** automatically modify Waze.
- **Flutter application development is NOT the current milestone.** Flutter is the intended frontend technology, but development is deliberately deferred until the TTS engine evaluation provides sufficient evidence.
- No production backend, Firebase, Supabase, auth, database, or cloud infrastructure at this stage.

Blast radius: guards against scope creep — all implementation work must stay within the TTS benchmark until evaluation completes. See background, roadmap.


## Timeline

- time: 2026-08-15T02:14:28
  kind: decision
  summary: "Created this page: Current milestone is TTS research and benchmarking — not Flutter"
  source: "project task brief, README"
  affects: [tts-benchmark-milestone]

- time: 2026-08-15T02:14:28
  kind: decision
  summary: captured from project brief and README
  source: project brief
  affects: [tts-benchmark-milestone]

- time: 2026-08-15T02:19:33
  kind: decision
  summary: fix root-page references to plain slugs
  source: lint-links
  affects: [tts-benchmark-milestone]
