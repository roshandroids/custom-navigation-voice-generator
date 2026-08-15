# TTS Evaluation Guide

How to install and run each candidate engine, and what the results mean.

## Setup prerequisites

- Python 3.10+ (3.12 recommended): `brew install python@3.12`
- Optional: `ffmpeg` (used to normalize non-standard engine output to the target
  16 kHz mono format): `brew install ffmpeg`
- Project venv: `python3.12 -m venv .venv && .venv/bin/pip install -e ".[dev]"`

## Engine matrix (as of 2026-08-15)

| Engine      | Code license | Weights license        | Nepali voices?                    | Extra env needed |
| ----------- | ------------ | ---------------------- | --------------------------------- | ---------------- |
| Piper       | MIT (archived repo) / GPL fork | per-voice MODEL_CARD | **YES** (`ne_NP` chitwan, google) | none (pip package) |
| Kokoro      | Apache-2.0   | Apache-2.0             | **NO** (English + other langs)    | none (pip package) |
| Qwen3-TTS   | Apache-2.0   | Apache-2.0 (per HF card) | NO (10 langs, no Nepali)        | separate Python env recommended |
| Chatterbox  | MIT          | MIT                    | NO (23 langs, no Nepali; Hindi finetune exists) | separate Python env recommended |

License details, caveats, and verification status: `docs/decisions/engine-licensing.md`.

> **Important:** "has Nepali voices" and "sounds good in Nepali" are different claims.
> The benchmark exists to test the latter. Nothing in this repo asserts Nepali quality
> until evaluation data says so.

---

## Piper

Fast local neural TTS (VITS), ONNX-based, per-language voice models.

**Install:**

```bash
.venv/bin/pip install piper-tts
```

The first synthesis auto-downloads the voice model
(`ne_NP-chitwan-medium` by default) from Hugging Face.

**Run:**

```bash
.venv/bin/benchmark-run --engines piper
```

**Voices** (official Nepali, from `rhasspy/piper` VOICES.md):
- `ne_NP-chitwan-medium`
- `ne_NP-google-x_low`, `ne_NP-google-medium`

Compare voices: `PIPER_VOICE=ne_NP-google-medium .venv/bin/benchmark-run --engines piper --force`

**Notes:**
- `rhasspy/piper` was archived Oct 2025; active development moved to
  `OHF-Voice/piper1-gpl` (GPL). The MIT-licensed version still works and is what
  `pip install piper-tts` provides. Review licensing before any commercial use.
- Voice-specific licensing lives in each voice's MODEL_CARD; Piper itself imposes no
  additional voice restrictions (per its README) — verify per-voice before shipping.

---

## Kokoro

Lightweight (82M) Apache-2.0 TTS via `kokoro-onnx` (ONNX Runtime, in-process).

**Install:**

```bash
.venv/bin/pip install kokoro-onnx
.venv/bin/python -m kokoro_onnx.download   # downloads model + voices files
```

Requires the model files (`kokoro-v1.0.onnx`, `voices-v1.0.bin`) in the working
directory or `~/.cache`. Output is 24 kHz; the adapter resamples to 16 kHz via ffmpeg
if available.

**Run:**

```bash
.venv/bin/benchmark-run --engines kokoro
```

**Notes:**
- No Nepali voice. `supports_devanagari=False`, so Nepali phrases are synthesized from
  their Latin `tts_text` — a compromise to evaluate, not a capability claim.
- Voices are language-tagged (`af_*`, `am_*`, …); the default is `af_heart` (English).
  Only English phrases should be considered representative of Kokoro's real quality.
- Model card notes some training data was CC BY-licensed (attribution requirements for
  derivative redistribution — see licensing doc).

---

## Qwen3-TTS

Large multilingual TTS from Alibaba (Qwen). Code and (per HF card) weights are
Apache-2.0. **Nepali is not among the 10 supported languages**
(zh, en, ja, ko, de, fr, ru, pt, es, it) — treat Nepali output as unverified.

**Install (isolated env recommended — PyTorch deps):**

```bash
python3.12 -m venv .venv-qwen3
.venv-qwen3/bin/pip install -U qwen-tts
# model weights auto-download on first run; FlashAttention 2 recommended on GPU
```

**Run:** the adapter shells out to a `qwen3-tts` CLI. The exact CLI name/flags are
**UNVERIFIED** at scaffold time — check the installed package's CLI
(`.venv-qwen3/bin/qwen3-tts --help`) and align
`benchmark/engines/qwen3/adapter.py` (or set `QWEN3_TTS_BIN` / `QWEN3_TTS_ARGS`).

```bash
.venv/bin/benchmark-run --engines qwen3
```

**Notes:**
- Requires a GPU for reasonable speed (CPU inference is possible but slow).
- Voice clone/design models exist; the scaffold uses the default voice. Language and
  speaker selection are future adapter parameters.

---

## Chatterbox

Resemble AI's open TTS (0.5B Llama backbone). Code and weights MIT.

**Languages:** 23 — **Nepali is not among them** (Arabic, Danish, German, Greek,
English, Spanish, Finnish, French, Hebrew, Hindi, Italian, Japanese, Korean, Malay,
Dutch, Norwegian, Polish, Portuguese, Russian, Swedish, Swahili, Turkish, Chinese).
A Hindi single-language finetune exists — the closest script-adjacent option for
evaluation.

**Install (isolated env recommended — PyTorch deps):**

```bash
python3.12 -m venv .venv-chatterbox
.venv-chatterbox/bin/pip install chatterbox-tts
```

**Run:** the adapter shells out to a `chatterbox-tts` CLI. The exact CLI name/flags are
**UNVERIFIED** at scaffold time — align `benchmark/engines/chatterbox/adapter.py`
(or set `CHATTERBOX_CMD`) with the installed package.

```bash
.venv/bin/benchmark-run --engines chatterbox
```

**Notes:**
- **Every generated file is watermarked** with Resemble's Perth watermarker. This has
  product implications (voice-pack export) and possibly legal ones — flag for review.
- `supports_devanagari=False`; Nepali phrases use Latin `tts_text`.
- Voice cloning uses a reference audio prompt — a future adapter parameter.

---

## Dummy

No dependencies, always available. Writes silent WAVs to exercise the full pipeline
and the test suite. Not a real TTS.

---

## Running the benchmark

```bash
.venv/bin/benchmark-run                    # all engines
.venv/bin/benchmark-run --engines piper kokoro
.venv/bin/benchmark-run --force            # regenerate existing WAVs
.venv/bin/benchmark-run --list             # engine availability
```

Outputs:
- WAVs: `benchmark/output/<engine>/<phrase_id>.wav`
- Metadata: `benchmark/results/<engine>.json` + `<engine>.csv`

## What the metadata captures (per phrase)

engine, model, voice, phrase_id, text (exactly what was synthesized), output_file,
success, started_at, duration_seconds (wall-clock generation), audio.duration_seconds,
audio.sample_rate, audio.channels, error_message.

## Human evaluation sheet

Generated audio to review: `benchmark/output/piper/<voice>/<phrase_id>.wav` (one WAV per
phrase per voice). Listen and score each row manually. Scores are **blank** — fill them
in during listening evaluation. Suggested scale: 1 (poor) – 5 (excellent). Focus
especially on Nepali pronunciation, mixed Nepali/English switching, numbers/units, and
navigation clarity at driving speed. Do not alter the corpus to hide problems — the
problems are part of the benchmark.

| Voice | Phrase ID | Naturalness | Pronunciation | Navigation Clarity | Notes |
| ----- | --------- | ----------- | ------------- | ------------------ | ----- |
| ne_NP-chitwan-medium | turn_left_001 | | | | |
| ne_NP-chitwan-medium | turn_right_001 | | | | |
| ne_NP-chitwan-medium | keep_left_002 | | | | |
| ne_NP-chitwan-medium | continue_straight_002 | | | | |
| ne_NP-chitwan-medium | uturn_002 | | | | |
| ne_NP-chitwan-medium | roundabout_002 | | | | |
| ne_NP-chitwan-medium | exit_002 | | | | |
| ne_NP-chitwan-medium | distance_100m_002 | | | | |
| ne_NP-chitwan-medium | distance_500m_002 | | | | |
| ne_NP-chitwan-medium | distance_1km_002 | | | | |
| ne_NP-chitwan-medium | distance_200m_001 | | | | |
| ne_NP-chitwan-medium | distance_300m_001 | | | | |
| ne_NP-chitwan-medium | traffic_ahead_001 | | | | |
| ne_NP-chitwan-medium | traffic_heavy_002 | | | | |
| ne_NP-chitwan-medium | accident_ahead_002 | | | | |
| ne_NP-chitwan-medium | construction_002 | | | | |
| ne_NP-chitwan-medium | road_closed_002 | | | | |
| ne_NP-chitwan-medium | speed_camera_001 | | | | |
| ne_NP-chitwan-medium | speed_camera_002 | | | | |
| ne_NP-chitwan-medium | redlight_camera_002 | | | | |
| ne_NP-chitwan-medium | police_002 | | | | |
| ne_NP-chitwan-medium | arrival_002 | | | | |
| ne_NP-chitwan-medium | arrival_005 | | | | |
| ne_NP-chitwan-medium | humor_001 | | | | |
| ne_NP-chitwan-medium | humor_002 | | | | |
| ne_NP-chitwan-medium | long_001 | | | | |
| ne_NP-google-medium | speed_camera_001 | | | | |
| ne_NP-google-medium | speed_camera_002 | | | | |
| ne_NP-google-medium | traffic_ahead_001 | | | | |
| ne_NP-google-medium | distance_500m_002 | | | | |
| ne_NP-google-medium | humor_002 | | | | |
| ne_NP-google-medium | turn_left_001 | | | | |
| ne_NP-google-medium | roundabout_002 | | | | |
| ne_NP-google-medium | uturn_002 | | | | |
| ne_NP-google-medium | long_001 | | | | |
| ne_NP-google-x_low | speed_camera_001 | | | | |
| ne_NP-google-x_low | speed_camera_002 | | | | |
| ne_NP-google-x_low | traffic_ahead_001 | | | | |
| ne_NP-google-x_low | distance_500m_002 | | | | |
| ne_NP-google-x_low | humor_002 | | | | |
| ne_NP-google-x_low | turn_left_001 | | | | |
| ne_NP-google-x_low | roundabout_002 | | | | |
| ne_NP-google-x_low | uturn_002 | | | | |
| ne_NP-google-x_low | long_001 | | | | |

> **Note:** `ne_NP-google-medium` emitted `Missing phoneme from id map: ʰ` warnings on
> some phrases during generation — flag any audible artifacts for those files during
> listening.

---

## Hybrid Nepali/English experiment (2026-08-15)

**Question:** Can separate Nepali (ne_NP-chitwan-medium) and English (en_US-joe-medium)
Piper voices, stitched together, produce a more understandable mixed-language
navigation voice than the Nepali voice alone?

**Files to listen to** — `benchmark/output/hybrid/<phrase_id>/`:

- `version_a.wav` — whole phrase, Nepali voice only (status quo)
- `version_b.wav` — Nepali voice for Nepali segments + English voice for English segments (stitched)
- `version_c.wav` — whole phrase, Nepali voice, English words in phonetic Nepali spelling

**Key question:** does the hybrid (B) make English significantly easier to understand
while remaining natural enough for navigation? Scores are **blank** — fill in during
listening (1 = poor, 5 = excellent).

| Phrase | Version A | Version B | Version C | English Clarity | Naturalness | Navigation Suitability | Notes |
| ------ | --------- | --------- | --------- | --------------- | ----------- | ---------------------- | ----- |
| hybrid_001 (ल भाइ, अगाडि speed camera छ। अब बिस्तारै।) | | | | | | | |
| hybrid_002 (अगाडि red light camera छ है।) | | | | | | | |
| hybrid_003 (Keep right है, अगाडि exit आउँदैछ।) | | | | | | | |
| hybrid_004 (500 meters पछि keep left गर्नुहोस्।) | | | | | | | |
| hybrid_005 (अगाडि traffic छ, अलि बिस्तारै जाऊ।) | | | | | | | |
| hybrid_006 (U-turn लिनुपर्ने छ।) | | | | | | | |
| hybrid_007 (Exit अगाडि नै छ।) | | | | | | | |
| hybrid_008 (आज police अगाडि छन् है।) | | | | | | | |
| hybrid_009 (Waze ले route change गरेको छ।) | | | | | | | |
| hybrid_010 (Speed घटाऊ, अगाडि camera छ।) | | | | | | | |

**Listen for:** English pronunciation in A vs B, voice-switch naturalness, unnatural
pauses, robotic delivery, number/unit handling (500 meters), and whether the hybrid
sounds like a coherent navigation voice or a jarring alternation.

---

## Evaluation dimensions (future work)

- **Naturalness** (human listening)
- **Pronunciation** — Nepali words, English words inside Nepali, Devanagari digits
- **Navigation clarity** — can a driver act on it at speed?
- **Generation speed** (already recorded)
- **Audio duration** (already recorded)
- **Resource requirements** (model size, RAM, GPU) — to be added

These will be added to the result format as human evaluation scores.
