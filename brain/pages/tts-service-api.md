---
id: tts-service-api
title: "TTS service: subprocess FastAPI + dual audio delivery"
category: decision
status: active
tags: [backend, api, integration]
created: "2026-08-21T00:31:27"
updated: "2026-08-21T00:37:10"
---

<!-- compiled_truth -->
# TTS service: subprocess-based FastAPI with dual audio delivery

**Decision (2026-08): bridge the benchmark Piper pipeline into the Flutter app with a small FastAPI service that drives Piper via the existing subprocess adapter.**

What was built:
- `server/` FastAPI package. `POST /v1/synthesize` returns raw WAV bytes (download path) plus `X-Audio-Duration` / `X-Audio-Sample-Rate` / `X-Audio-Url` headers; `GET /v1/audio/{asset}.wav` streams the same clip (stream path); `GET /v1/voices` reports availability + piper health. Content-addressed cache under `benchmark/output/server_cache/` (gitignored).
- Frontend `HttpTtsRepository` is now the DI default (`ttsRepositoryProvider` in `lib/app/di/providers.dart`); `AudioAsset` carries both optional `bytes` and `uri`; `AudioPlayer` plays real audio via `audioplayers`.

Key decisions and rationale:
- **Subprocess via PiperAdapter, not in-process PiperVoice.** Reuses `benchmark/engines/piper/adapter.py` and keeps a clean CLI boundary — the service never imports the GPL-3.0 piper Python API. Fine for local MVP QPS; slower per request (subprocess spawn), accepted.
- **piper is NOT a declared dependency** (GPL-3.0, see [[engine-licensing]]). Service runs against a manually-installed `piper-tts` or `PIPER_BIN`.
- **Dual delivery** (both download-bytes and stream-from-URL) chosen over a single mode; both are surfaced on `AudioAsset`.
- **HTTP is the default** wiring (not a flag). `MockTtsRepository` remains for tests/offline.

This does NOT select an engine or voice — that still requires the pending human evaluation (see [[engine-selection-pending]], [[open-questions]]).


## Timeline

- time: 2026-08-21T00:31:27
  kind: decision
  summary: "Created this page: TTS service: subprocess FastAPI + dual audio delivery"
  source: "task: wire real TTS into the frontend"
  affects: [tts-service-api]

- time: 2026-08-21T00:37:10
  kind: decision
  summary: "Documented the built TTS service: subprocess FastAPI + dual delivery + HTTP default"
  source: "task: wire real TTS into the frontend"
  affects: [tts-service-api]
