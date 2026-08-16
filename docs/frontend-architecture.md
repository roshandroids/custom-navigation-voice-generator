# Frontend Architecture — Custom Navigation Voice Generator

The Flutter frontend lives in `frontend/`. It is the initial client of the
Custom Navigation Voice Generator product: a consumer app for creating
personalized navigation voice packs and recording them manually into Waze.

## 1. Feature structure

The codebase is organized **feature-first** — by business capability, not by
technical layer globally:

```
lib/
  app/                     # app shell: router, DI wiring
  core/                    # shared: Result/Failure, timing, design system
  features/
    voice_packs/           # packs: create, list, workspace, progress
    instructions/          # instruction editor, navigation, recording state source
    tts/                   # audio generation (mock boundary)
    suggestions/           # personalized suggestion generation (mock boundary)
    recording/             # recording workflow state machine + screen
    export/                # export domain contract + screen
```

Each feature follows the same internal layout when it has meaningful content:

```
  domain/       entities, value_objects, repositories (interfaces), use_cases
  data/         datasources/implementations, repositories (concrete), corpus
  presentation/ providers, notifiers, pages, widgets, state
```

Empty layers are not created. A feature only has a `data/` directory if it
has a data implementation today (e.g. export has a mock repository).

## 2. Clean Architecture boundaries

Dependency direction is strictly one-way:

```
Presentation  (widgets, notifiers, providers)
    ↓
Use cases     (application behavior)
    ↓
Domain        (entities, value objects, repository interfaces)
    ↑
Data          (repository implementations)
```

- **Presentation** renders state and dispatches user actions. It never calls
  repositories directly — it goes through notifiers → use cases.
- **Use cases** encode application behavior and depend only on domain
  repository interfaces.
- **Domain** is pure Dart. It does not import Flutter, Riverpod, Dio, HTTP
  clients, SharedPreferences, platform APIs, audio packages, or go_router.
- **Data** implements domain contracts and knows about infrastructure
  (in-memory stores, mocks; later HTTP).

## 3. Dependency direction

Concrete rules enforced by review (and kept simple — no framework):

- `domain/` files import only `core/` (Result/Failure) and other domain files.
- `data/` imports domain + its own infrastructure.
- `presentation/` imports domain, use cases (via providers), and core.
- Widgets never construct repositories or call use cases directly with
  manually wired dependencies — everything goes through Riverpod providers.

## 4. Riverpod role

Riverpod is used for:

- **DI**: repository providers (`lib/app/di/providers.dart`), use-case
  providers (`lib/app/di/use_case_providers.dart`), and presentation
  providers (`lib/app/di/presentation_providers.dart`).
- **State management**: notifiers (`HomeNotifier`, `WorkspaceNotifier`,
  `CreateVoicePackNotifier`, `InstructionEditorNotifier`,
  `RecordingNotifier`) expose immutable state; widgets `watch` them.
- **Async lookups**: `FutureProvider.family` for pack/progress/instructions
  reads that pages watch directly.

Dependency graph for audio generation (the canonical example):

```
AudioPlayer / Generate Audio button
    ↓
InstructionEditorNotifier
    ↓
GenerateInstructionAudio (use case)
    ↓
TtsRepository (domain interface)
    ↑
MockTtsRepository (data)
```

There is no service locator, no manually constructed dependency graphs in
widgets, and no Riverpod inside domain.

## 5. Repository contracts

Interfaces live in `domain/repositories/`:

| Contract | Purpose |
|---|---|
| `VoicePackRepository` | create / getById / getAll voice packs |
| `InstructionRepository` | instructions of a pack, custom text, audio attach, recorded flag, counts |
| `TtsRepository` | `generateAudio(TtsRequest) -> AudioAsset` |
| `SuggestionRepository` | `generate(SuggestionRequest) -> List<Suggestion>` |
| `ExportRepository` | `export(...) -> ExportBundle` |

The domain only knows these interfaces — never the concrete implementations.

## 6. Use cases

Meaningful application behavior lives in `domain/use_cases/`:

- `CreateVoicePack`, `GetVoicePack`, `GetVoicePacks`
- `GetInstructions`, `GetInstruction`
- `UpdateInstructionText`, `MarkInstructionRecorded`
- `GetVoicePackProgress`
- `GetNextInstruction`, `GetPreviousInstruction`
- `GenerateInstructionAudio`
- `GenerateInstructionSuggestions`
- `ExportVoicePack`

Use cases are plain classes with `execute(...) -> Future<Result<T>>`. They do
not extend a generic `BaseUseCase` — each has an explicit, meaningful type.

## 7. TDD approach

Development follows RED → GREEN → REFACTOR, phase by phase:

1. **Domain tests** — entities, value objects, progress rules, the recording
   state machine (all transitions + invalid transition prevention).
2. **Use-case tests** — each use case against fake repositories (success and
   failure paths).
3. **Repository tests** — in-memory/mock implementations.
4. **Notifier tests** — presentation state transitions with fake repositories
   and fake ticker/scheduler (deterministic countdown).
5. **Widget tests** — design-system widgets, recording controls, routing.

The test pyramid prioritizes domain and use-case behavior over widget tests.

## 8. Mock TTS boundary

`MockTtsRepository` simulates generation with a small delay and returns
`AudioAsset` metadata (duration derived from word count). The domain does not
know Piper exists; `TtsRequest` carries only `text`, `language`, and `voice`.

## 9. Future HTTP/FastAPI migration

Replacing the mock with a real engine only touches:

1. Add `HttpTtsRepository implements TtsRepository` (calls FastAPI → Piper).
2. Change the `ttsRepositoryProvider` override in `lib/app/di/providers.dart`.

Screens, widgets, domain entities, use cases, and business rules do not
change. The same applies to `SuggestionRepository` (mock → model service) and
`ExportRepository` (mock → real ZIP/files).

## 10. Recording workflow state machine

The recording machine is a domain value object (`recording_state.dart`) with
explicit phases:

```
idle ──beginPreparation──▶ preparing ──tick×3──▶ playing
  ▲                          │                    │
  │                          └──startPlayback──▶ playing
  │ reset                                            │ completePlayback
  │                                                  ▼
  └────────────────────────────── recorded ◀── completed
```

- Every transition returns a new state (immutable) or an
  `InvalidTransitionFailure` — invalid transitions (e.g. `recorded → recorded`)
  are prevented.
- The countdown is **visual only** and driven through a `CountdownTicker`
  abstraction (`core/timing/`); playback completion goes through a
  `PlaybackScheduler`. Widgets and notifiers never use `Timer.periodic`
  directly, so tests inject fakes and drive ticks deterministically.

## 11. Routing

go_router is configured in `lib/app/router/app_router.dart` (the app layer —
feature code never owns the router):

| Route | Screen |
|---|---|
| `/` | Home |
| `/create` | Create Voice Pack |
| `/pack/:id` | Voice pack workspace |
| `/pack/:id/instruction/:instructionId` | Instruction editor |
| `/pack/:id/record/:instructionId` | Recording mode |
| `/pack/:id/export` | Export |

Invalid ids resolve to error states in the pages; unknown paths hit the
router error page.

## 12. Testing strategy

- **Domain**: entity lifecycle, value-object validation, progress math, the
  full recording transition table (including every invalid transition).
- **Use cases**: success + failure per use case against hand-written fakes.
- **Data**: in-memory repository behavior (seed, find, mutate, count).
- **Notifiers**: home/create/workspace/editor/recording state transitions;
  recording uses fake ticker + fake playback scheduler for determinism.
- **Widgets**: design-system primitives, recording controls by phase.
- **Routing**: full-app smoke tests through the real router (brand renders,
  create reachable, invalid path error page, seed pack workspace reachable).

Tests use simple hand-written fakes at architectural boundaries — no mocking
framework is introduced.
