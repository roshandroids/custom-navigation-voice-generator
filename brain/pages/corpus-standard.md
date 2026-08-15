---
id: corpus-standard
title: "Standardized navigation phrase corpus (50 phrases, stable IDs)"
category: concept
status: active
created: "2026-08-15T02:15:41"
updated: "2026-08-15T12:26:04"
---

<!-- compiled_truth -->
# Standardized navigation phrase corpus (50 phrases, stable IDs)

The corpus (`benchmark/corpus/phrases.json`) is the single source of truth for benchmark phrases — every engine synthesizes the same phrases, which is what makes comparisons meaningful.

- **50 phrases**, stable IDs (e.g. `speed_camera_001`), categories: directions, distances, traffic, enforcement, arrival, language_tests.
- Languages: `ne` (Nepali), `en` (English), `ne-en` (mixed). **25 ne / 24 en / 1 ne-en** (v2, 2026-08-15 — Nepali content rewritten as native conversational Nepali per [[nepali-content-principle]]).
- Each entry: id, category, language, text, optional `tts_text` (Latin rendering for engines without Devanagari support), `expected_pronunciation`, `tags`, optional `review_status` (draft / needs-review / approved).
- **IDs are stable by contract** — renaming/deleting an ID after results exist orphans generated audio and metadata. Add new phrases with new IDs.
- All rewritten Nepali phrases are marked `review_status: needs-review` — native-speaker review required before approval.
- Validation rules enforced: unique IDs, `^[a-z0-9_]+$`, valid language/category, Devanagari text requires `tts_text`.
- Adding a phrase: `corpus-add-phrase` CLI (auto-generates next ID, validates before writing) or edit + `corpus-validate`.
- The English corpus is separate: `benchmark/corpus/phrases_en.json` (47 phrases) — natural English evaluated with English voices.

Related: [[nepali-content-principle]], [[voice-pack-single-language]].


## Timeline

- time: 2026-08-15T02:15:41
  kind: decision
  summary: "Created this page: Standardized navigation phrase corpus (50 phrases, stable IDs)"
  source: repo benchmark/corpus
  affects: [corpus-standard]

- time: 2026-08-15T02:15:42
  kind: decision
  summary: captured corpus design
  source: repo benchmark/corpus
  affects: [corpus-standard]

- time: 2026-08-15T12:26:04
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: brain update-truth
  affects: [corpus-standard]
