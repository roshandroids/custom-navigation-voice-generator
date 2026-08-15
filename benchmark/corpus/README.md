# Phrase Corpus

This directory holds the **standardized navigation phrase corpus** used by every TTS
engine in the benchmark. All engines synthesize the exact same phrases, which is what
makes engine comparisons meaningful.

## Files

| File          | Purpose                                                                 |
| ------------- | ----------------------------------------------------------------------- |
| `phrases.json`| The main 50-phrase corpus (Nepali/English/mixed).                        |
| `phrases_en.json` | English-only 47-phrase corpus — natural English phrasing, same categories, plus personality-style phrases. Used for standalone English voice evaluation (voice packs are single-language). |
| `hybrid_phrases.json` | **Experimental** — explicit-segment mixed Nepali/English phrases from the hybrid experiment. Historical evidence only; NOT part of the MVP (voice packs are single-language). |
| `schema.json` | (referenced by `$schema`) The JSON schema the corpus validates against. |

## Corpus schema

Each phrase is an object with the following fields:

| Field                 | Required | Description                                                                   |
| --------------------- | -------- | ----------------------------------------------------------------------------- |
| `id`                  | yes      | Stable, unique, machine-readable ID (e.g. `speed_camera_001`). **Never change an ID once a benchmark has run** — results and output files reference it. |
| `category`            | yes      | One of: `directions`, `distances`, `traffic`, `enforcement`, `arrival`, `language_tests`. |
| `language`            | yes      | `ne` (Nepali), `en` (English), or `ne-en` (mixed).                              |
| `text`                | yes      | The exact phrase to synthesize (UTF-8, Devanagari script where Nepali).        |
| `tts_text`            | no       | Latin-script rendering for engines that cannot process Devanagari. `null`/absent when the text is already Latin. |
| `expected_pronunciation` | no    | Informal pronunciation guidance for human evaluators. Benchmark material, not product copy. |
| `tags`                | no       | Free-form tags: `short`, `number`, `mixed`, `english_word`, `humor`, `conversational`, `long`, `devanagari_number`. |

Additional metadata (e.g. `description`, TTS-specific hint fields) can be added later
without breaking existing entries — extra fields are ignored by the validator as long as
the required fields are valid.

## Rules enforced by validation (`corpus-validate`, `benchmark.core.corpus`)

1. The file must be valid JSON and match the schema.
2. IDs must be unique (duplicate detection).
3. IDs must match `^[a-z0-9_]+$`.
4. `language` must be `ne`, `en`, or `ne-en`.
5. `category` must be one of the known categories.
6. If `language` is `ne` or `ne-en` and the text contains Devanagari characters, a
   `tts_text` Latin rendering should be provided.
7. Text must be non-empty and not contain control characters.

## Adding a phrase

Use the helper script (also validates and deduplicates):

```bash
python -m tools.add_phrase --text "अगाडि ढिलो गाडी छ।" \
    --category traffic --language ne --tags slow_traffic
```

Or edit `phrases.json` directly and run `corpus-validate` (or
`python -m benchmark.scripts.validate_corpus`). Bump `version` in the file when the
corpus content changes.

> IDs are stable by contract: renaming or deleting an ID after results exist will orphan
> previously generated audio and metadata. Add new phrases with new IDs instead.
