# TTS Engines

Each subdirectory is a TTS engine adapter for the benchmark. Adapters implement
`benchmark.core.tts.TTSAdapter` and register themselves via `@register` (see
`benchmark/core/registry.py`). The runner is engine-agnostic — it only talks to the
`TTSAdapter` interface.

| Directory      | Engine                    | Interface        | Status                          |
| -------------- | ------------------------- | ---------------- | ------------------------------- |
| `dummy/`       | Dummy (silence)           | in-process       | always available (tests/wiring) |
| `piper/`       | Piper                     | subprocess CLI   | scaffold — needs `piper` install |
| `kokoro/`      | Kokoro (kokoro-onnx)      | in-process       | scaffold — needs `kokoro-onnx`  |
| `qwen3/`       | Qwen3-TTS                 | subprocess CLI   | scaffold — needs own env + CLI  |
| `chatterbox/`  | Chatterbox                | subprocess CLI   | scaffold — needs own env + CLI  |

## Adding a new engine

1. `mkdir benchmark/engines/<name>` with `adapter.py` + `__init__.py`.
2. Implement `TTSAdapter` (see `benchmark/engines/dummy/adapter.py` for the minimal
   reference) and decorate with `@register`.
3. Lazy-import heavy dependencies inside the adapter (or shell out to the engine's own
   environment) so importing `benchmark.engines` never fails.
4. Override `check_available()` when the engine has external requirements — returning a
   reason string skips the engine cleanly (recorded as `unavailable` in results).
5. `benchmark-run --list` to confirm registration; add tests.

Engine-specific install/run instructions: `docs/tts-evaluation.md`.
License research per engine: `docs/decisions/engine-licensing.md`.

> Isolation rule: an engine whose environment can't be satisfied must degrade to
> "unavailable", never break the whole benchmark.
