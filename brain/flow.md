---
slug: flow
title: Key flows
role: key flows
updated: "2026-08-15T02:08:41"
---

# Key flows

## End-to-end path of a typical request

```mermaid
sequenceDiagram
  participant U as User (CLI)
  participant R as BenchmarkRunner
  participant E as TTS Adapter
  participant F as Filesystem
  U->>R: benchmark-run --engines piper
  R->>R: load + validate corpus
  R->>E: check_available()
  alt unavailable
    E-->>R: reason string
    R->>F: results/<engine>.json {"unavailable": true}
  else available
    R->>E: prepare() (model download, one-time)
    loop each phrase
      R->>E: synthesize(text, output_path)
      E-->>R: AudioInfo
      R->>F: benchmark/output/<engine>/<phrase_id>.wav
    end
    R->>F: results/<engine>.json + .csv
  end
  R-->>U: per-engine summary (ok/failed, avg duration)
```

## Other important flows

- **Corpus validation** (`corpus-validate`): load → validate schema/IDs/duplicates → report stats.
- **Add a phrase** (`corpus-add-phrase`): generate next stable ID, validate before writing, append to `phrases.json`.
- **Human listening evaluation (future)**: generated WAV → human scores (naturalness, pronunciation, navigation clarity) → appended to result format.
- **Future product workflow** (after engine selection): navigation situation → standard instruction → custom instruction → TTS → preview → recording mode → preparation delay → generated voice plays → user manually records into Waze.
