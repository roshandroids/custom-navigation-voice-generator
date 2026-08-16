# Nepali TTS Evaluation — MVP Corpus (2026-08-15)

Human listening evaluation for the **finalized 25-phrase Nepali product corpus**
(`benchmark/corpus/phrases.json`, all `ne` phrases, `review_status: approved`)
synthesized with the three official Nepali Piper voices.

- **Benchmark date:** 2026-08-15
- **Phrases:** 25 (all `ne` product phrases; `humor_002` `ne-en` technical test excluded)
- **Voices:** 3 — `ne_NP-chitwan-medium`, `ne_NP-google-medium`, `ne_NP-google-x_low`
- **Files:** 25 × 3 = 75 WAVs at `benchmark/output/piper/<voice>/<phrase_id>.wav`
- **Audio format:** mono 16-bit PCM WAV (chitwan/google-medium 22,050 Hz; google-x_low 16,000 Hz — rate fixed by each voice model config)
- **Methodology:** identical to the previous Piper experiment — one piper subprocess per phrase, per-phrase generation timing, per-phrase audio duration, all 25 phrases regenerated with `--force` against the finalized corpus text. Results JSON/CSV in the benchmark `results/` directory (runner format).

> **Do not select a voice automatically.** Generation speed, duration, RTF, CPU use, and
> phoneme warnings are recorded below for context only — voice selection requires human
> listening. Nothing in this document ranks the voices.

## How to evaluate

Listen to each WAV and score every row on a **1–5 scale** (1 = poor, 5 = excellent):

| Score | Meaning |
| ----- | ------- |
| 5 | Native-level, perfectly natural, instant understanding |
| 4 | Very good; minor imperfection, no confusion |
| 3 | Acceptable; understandable but noticeably imperfect |
| 2 | Poor; effort required to understand |
| 1 | Unusable |

- **Pronunciation:** Nepali phonemes, Devanagari rendering, borrowed English words
  (स्पिड, क्यामेरा, ट्राफिक, पुलिस, गोलचक्कर), number phrases.
- **Naturalness:** does it sound like a Nepali person speaking, or like a synthetic/translated voice?
- **Clarity:** can a driver act on it at speed without rewinding?
- **Intelligibility:** is every word recognizable?
- **Prosody:** stress, rhythm, intonation, sentence-final particles (छ। / छ है। / जाऊ। / जानुहोस्।).
- **Repetition Comfort:** would this still be tolerable after hearing it 20–50 times on one drive?
- **Overall:** your single judgment for the row.
- **Notes:** audible artifacts, mispronunciations, phoneme gaps, anything to revisit.

## Priority listening cases

These phrases carry the highest linguistic/content risk and **must** be listened to
carefully. Flag any audible issue in Notes.

| Phrase | Why it is a priority |
| ------ | -------------------- |
| redlight_camera_002 | Product decision wording ("अगाडिको रातो बत्तीमा क्यामेरा छ। रोकिनुहोस्।") — no settled spoken compound exists; pending possible native-speaker validation. |
| roundabout_002 | गोलचक्कर chosen over राउन्डअबाउट; verify the word and the "पहिलो निकास" ending render cleanly. |
| distance_200m_001 | "दुई सय मिटरपछि गोलचक्कर आउँछ।" — roundabout word + number + "आउँछ" sentence shape. |
| distance_100m_002 | "सय मिटरपछि..." — bare-hundred spoken form (no एक); verify it sounds like "saya", not "sayya" or mis-stressed. |
| long_001 | Long two-turn instruction; check rhythm, repetition ("देब्रे" twice + "मोड लिनुहोस्"), and whether a driver can follow it. |
| speed_camera_002 | Conversational register: "ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ।" — the most colloquial phrase; check the "ल"/"है" particles and casual "जाऊ" ending. |

### Borrowed words to check per voice

स्पिड (speed), क्यामेरा (camera), ट्राफिक (traffic), पुलिस (police), गोलचक्कर (roundabout).
Are they pronounced with Nepali phonology and immediately understandable? Do any revert to
English phonemes?

### Numbers to check per voice

सय (100), दुई सय (200), तीन सय (300), पाँच सय (500), एक किलोमिटर (1 km).
Are the numbers and unit (मिटर/किलोमिटर) clear at driving speed?

### Conversational speech

Especially **speed_camera_002**: does the relaxed register ("ल… छ है। अलि बिस्तारै जाऊ।")
sound like a real Nepali speaker or forced?

## Generation notes

- All 75 generations succeeded (25/25 per voice), 0 failures.
- `ne_NP-google-x_low` emitted `Missing phoneme from id map` warnings on **20** phrases
  (phonemes `ʰ` and `̃`). The same warning family was seen in the previous experiment on
  `ne_NP-google-medium`. These mark phonemes absent from the voice's id map — flag any
  audible artifact in the affected files during listening.

| Voice | Phrases with warnings |
| ----- | --------------------- |
| ne_NP-chitwan-medium | none |
| ne_NP-google-medium | none (this run) |
| ne_NP-google-x_low | turn_right_001, continue_straight_002, distance_100m_002, distance_500m_002, distance_1km_002, distance_200m_001, distance_300m_001, traffic_ahead_001, traffic_heavy_002, accident_ahead_002, construction_002, road_closed_002, speed_camera_001, speed_camera_002, redlight_camera_002, police_002, arrival_002, arrival_005, humor_001, long_001 |

## Performance (context only — not a selection criterion)

| Voice | Avg generation/phrase | Avg audio duration | Real-time factor | Sample rate | Channels | Bit depth |
| ----- | --------------------- | ------------------ | ---------------- | ----------- | -------- | --------- |
| ne_NP-chitwan-medium | 0.58 s | 2.27 s | 0.25 | 22,050 Hz | 1 | 16-bit PCM |
| ne_NP-google-medium | 0.74 s | 2.32 s | 0.32 | 22,050 Hz | 1 | 16-bit PCM |
| ne_NP-google-x_low | 0.69 s | 2.14 s | 0.32 | 16,000 Hz | 1 | 16-bit PCM |

## Evaluation table

Scores are **blank** — fill in during listening (1–5). All 25 phrases × 3 voices = 75 rows.

| Phrase ID | Voice | Pronunciation | Naturalness | Clarity | Intelligibility | Prosody | Repetition Comfort | Overall | Notes |
| --------- | ----- | ------------- | ----------- | ------- | --------------- | ------- | ------------------ | ------- | ----- |
| turn_left_001 | ne_NP-chitwan-medium | | | | | | | | |
| turn_right_001 | ne_NP-chitwan-medium | | | | | | | | |
| keep_left_002 | ne_NP-chitwan-medium | | | | | | | | |
| continue_straight_002 | ne_NP-chitwan-medium | | | | | | | | |
| uturn_002 | ne_NP-chitwan-medium | | | | | | | | |
| roundabout_002 ⚑ | ne_NP-chitwan-medium | | | | | | | | |
| exit_002 | ne_NP-chitwan-medium | | | | | | | | |
| distance_100m_002 ⚑ | ne_NP-chitwan-medium | | | | | | | | |
| distance_500m_002 | ne_NP-chitwan-medium | | | | | | | | |
| distance_1km_002 | ne_NP-chitwan-medium | | | | | | | | |
| distance_200m_001 ⚑ | ne_NP-chitwan-medium | | | | | | | | |
| distance_300m_001 | ne_NP-chitwan-medium | | | | | | | | |
| traffic_ahead_001 | ne_NP-chitwan-medium | | | | | | | | |
| traffic_heavy_002 | ne_NP-chitwan-medium | | | | | | | | |
| accident_ahead_002 | ne_NP-chitwan-medium | | | | | | | | |
| construction_002 | ne_NP-chitwan-medium | | | | | | | | |
| road_closed_002 | ne_NP-chitwan-medium | | | | | | | | |
| speed_camera_001 | ne_NP-chitwan-medium | | | | | | | | |
| speed_camera_002 ⚑ | ne_NP-chitwan-medium | | | | | | | | |
| redlight_camera_002 ⚑ | ne_NP-chitwan-medium | | | | | | | | |
| police_002 | ne_NP-chitwan-medium | | | | | | | | |
| arrival_002 | ne_NP-chitwan-medium | | | | | | | | |
| arrival_005 | ne_NP-chitwan-medium | | | | | | | | |
| humor_001 | ne_NP-chitwan-medium | | | | | | | | |
| long_001 ⚑ | ne_NP-chitwan-medium | | | | | | | | |
| turn_left_001 | ne_NP-google-medium | | | | | | | | |
| turn_right_001 | ne_NP-google-medium | | | | | | | | |
| keep_left_002 | ne_NP-google-medium | | | | | | | | |
| continue_straight_002 | ne_NP-google-medium | | | | | | | | |
| uturn_002 | ne_NP-google-medium | | | | | | | | |
| roundabout_002 ⚑ | ne_NP-google-medium | | | | | | | | |
| exit_002 | ne_NP-google-medium | | | | | | | | |
| distance_100m_002 ⚑ | ne_NP-google-medium | | | | | | | | |
| distance_500m_002 | ne_NP-google-medium | | | | | | | | |
| distance_1km_002 | ne_NP-google-medium | | | | | | | | |
| distance_200m_001 ⚑ | ne_NP-google-medium | | | | | | | | |
| distance_300m_001 | ne_NP-google-medium | | | | | | | | |
| traffic_ahead_001 | ne_NP-google-medium | | | | | | | | |
| traffic_heavy_002 | ne_NP-google-medium | | | | | | | | |
| accident_ahead_002 | ne_NP-google-medium | | | | | | | | |
| construction_002 | ne_NP-google-medium | | | | | | | | |
| road_closed_002 | ne_NP-google-medium | | | | | | | | |
| speed_camera_001 | ne_NP-google-medium | | | | | | | | |
| speed_camera_002 ⚑ | ne_NP-google-medium | | | | | | | | |
| redlight_camera_002 ⚑ | ne_NP-google-medium | | | | | | | | |
| police_002 | ne_NP-google-medium | | | | | | | | |
| arrival_002 | ne_NP-google-medium | | | | | | | | |
| arrival_005 | ne_NP-google-medium | | | | | | | | |
| humor_001 | ne_NP-google-medium | | | | | | | | |
| long_001 ⚑ | ne_NP-google-medium | | | | | | | | |
| turn_left_001 | ne_NP-google-x_low | | | | | | | | |
| turn_right_001 | ne_NP-google-x_low | | | | | | | | |
| keep_left_002 | ne_NP-google-x_low | | | | | | | | |
| continue_straight_002 | ne_NP-google-x_low | | | | | | | | |
| uturn_002 | ne_NP-google-x_low | | | | | | | | |
| roundabout_002 ⚑ | ne_NP-google-x_low | | | | | | | | |
| exit_002 | ne_NP-google-x_low | | | | | | | | |
| distance_100m_002 ⚑ | ne_NP-google-x_low | | | | | | | | |
| distance_500m_002 | ne_NP-google-x_low | | | | | | | | |
| distance_1km_002 | ne_NP-google-x_low | | | | | | | | |
| distance_200m_001 ⚑ | ne_NP-google-x_low | | | | | | | | |
| distance_300m_001 | ne_NP-google-x_low | | | | | | | | |
| traffic_ahead_001 | ne_NP-google-x_low | | | | | | | | |
| traffic_heavy_002 | ne_NP-google-x_low | | | | | | | | |
| accident_ahead_002 | ne_NP-google-x_low | | | | | | | | |
| construction_002 | ne_NP-google-x_low | | | | | | | | |
| road_closed_002 | ne_NP-google-x_low | | | | | | | | |
| speed_camera_001 | ne_NP-google-x_low | | | | | | | | |
| speed_camera_002 ⚑ | ne_NP-google-x_low | | | | | | | | |
| redlight_camera_002 ⚑ | ne_NP-google-x_low | | | | | | | | |
| police_002 | ne_NP-google-x_low | | | | | | | | |
| arrival_002 | ne_NP-google-x_low | | | | | | | | |
| arrival_005 | ne_NP-google-x_low | | | | | | | | |
| humor_001 | ne_NP-google-x_low | | | | | | | | |
| long_001 ⚑ | ne_NP-google-x_low | | | | | | | | |

⚑ = priority listening case (see table above).

## Reference

- Corpus: `benchmark/corpus/phrases.json` (25 `ne` phrases, finalized)
- Content decisions: `docs/decisions/nepali-content-final.md`
- Linguistic review: `docs/nepali-human-review-v2.md`
- General evaluation guide: `docs/tts-evaluation.md`
