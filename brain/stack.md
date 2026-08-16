---
slug: stack
title: Tech stack
role: tech-stack choices
updated: "2026-08-15T23:24:37"
---

# Tech stack

## Technology choices

| domain | candidates | decision | rationale |
|---|---|---|---|
| Benchmark language | — | **Python 3.10+ (3.12 used)** | The open-source TTS ecosystem (Piper, Kokoro, Qwen3-TTS, Chatterbox) is primarily Python-oriented. |
| Benchmark core | — | **Pure stdlib, zero runtime deps** | Keep the runner simple and reproducible; pytest/ruff are dev-only. |
| Package/deps | — | **pip + pyproject.toml (editable install)** | Standard, minimal; `.venv` per project. |
| Testing | — | **pytest** | Standard for Python; tests cover corpus, registry, runner. |
| Linting/format | — | **ruff** | Single fast tool for lint + format. |
| TTS engines | Piper, Kokoro, Qwen3-TTS, Chatterbox | **All four scaffolded; none selected yet** | The benchmark's job is to decide; an engine may be marked unavailable without breaking runs. |
| Audio | — | **WAV, 16 kHz mono PCM target** | Standardized for fair comparison; ffmpeg optional for resampling engine-native output. |
| Frontend | — | **Flutter (frontend/)** | Frontend MVP built: feature-first Clean Architecture + Riverpod + go_router; TTS behind `TtsRepository` (mock now, FastAPI/Piper later). |
| Frontend state/DI | — | **Riverpod** | Notifiers + immutable state; no service locator; domain stays pure Dart. |
| Frontend routing | — | **go_router** | Routes defined in the app layer. |
| Backend (future) | — | **Python/FastAPI TTS service (possible)** | Not built now; no production backend yet. |

## Decision mindmap

```mermaid
graph LR
  D[Benchmark language] --> C1[Python]
  C1 --> P[Python 3.12, stdlib core]
  D2[TTS engines] --> C2[Piper]
  D2 --> C3[Kokoro]
  D2 --> C4[Qwen3-TTS]
  D2 --> C5[Chatterbox]
  C2 --> P2[Benchmark decides - none selected]
  C3 --> P2
  C4 --> P2
  C5 --> P2
  F[Flutter frontend] --> FR[Riverpod + go_router]
  F --> TTSB[TtsRepository]
  TTSB --> M[MockTtsRepository now]
  TTSB --> H[HttpTtsRepository -> FastAPI -> Piper later]
```

## Open items

- **Which TTS engine wins for Nepali** — the benchmark's core question; no decision yet.
- **Piper voice selection** (`ne_NP-chitwan` vs `ne_NP-google`) — to be tested.
- Engine-specific CLI flags for Qwen3-TTS and Chatterbox — unverified at scaffold time.
- Backend TTS service (FastAPI) remains future; frontend integration point is `TtsRepository`.
