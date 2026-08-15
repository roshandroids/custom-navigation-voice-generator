---
id: waze-integration-deferred
title: "Waze integration deferred — manual recording workflow only"
category: decision
status: active
created: "2026-08-15T02:15:16"
updated: "2026-08-15T02:19:33"
---

<!-- compiled_truth -->
# Waze integration deferred

**Decision: Waze integration is deferred until after the MVP/TTS workflow works.**

- The initial product does **NOT** automatically modify Waze.
- The workflow is **manual recording**: generated voice plays (with a preparation delay) and the user manually records into Waze.
- **Do not assume undocumented Waze APIs or recording capabilities.**
- No Waze integration code exists yet, and none should be built during the current TTS benchmark milestone.

Related: [[tts-benchmark-milestone]], background.


## Timeline

- time: 2026-08-15T02:15:16
  kind: decision
  summary: "Created this page: Waze integration deferred — manual recording workflow only"
  source: project brief
  affects: [waze-integration-deferred]

- time: 2026-08-15T02:15:16
  kind: decision
  summary: captured decision
  source: project brief
  affects: [waze-integration-deferred]

- time: 2026-08-15T02:19:33
  kind: decision
  summary: fix root-page references to plain slugs
  source: lint-links
  affects: [waze-integration-deferred]
