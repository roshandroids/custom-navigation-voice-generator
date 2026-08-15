# English Voice Evaluation Sheet — Standalone English TTS Benchmark

**Status: HUMAN EVALUATION PENDING.** Scores below are **blank by design** — the
human listener fills them in. Do not invent scores.

## How to evaluate

Listen to the generated WAVs and score each row. Suggested scale: **1 (poor) – 5 (excellent)**.

Audio locations (one WAV per phrase per voice):

- `benchmark/output/piper/en_US-joe-medium/<phrase_id>.wav`
- `benchmark/output/piper/en_US-kristin-medium/<phrase_id>.wav`
- `benchmark/output/piper/en_US-ljspeech-medium/<phrase_id>.wav`

Corpus: `benchmark/corpus/phrases_en.json` (47 natural English navigation phrases;
no mechanical translation of the Nepali corpus). Each phrase was synthesized as a
single English TTS request — no hybrid segmentation, no voice stitching.

**The key question:** does the English voice sound natural and clear enough to serve
as a navigation voice? Pay particular attention to:

- pronunciation and accent
- numbers, distances, abbreviations ("U-turn", "exit 42")
- sentence endings and prosody
- speed / pacing (can a driver act on it at speed?)
- clarity in a car environment
- conversational personality (simple → normal → firm → savage)

| Column | What to score |
| --- | --- |
| Naturalness | Sounds human, not robotic |
| Pronunciation | Words, numbers, abbreviations pronounced correctly |
| Clarity | Understandable at driving speed, in car noise |
| Navigation Suitability | Would you trust this voice to guide you? |
| Personality | Does the intended voice-pack personality come through? |


---

## en_US-joe-medium

Male, CC0 dataset (OHF-Voice/voice-datasets), 22,050 Hz — BASELINE

| Voice | Phrase ID | Naturalness | Pronunciation | Clarity | Navigation Suitability | Personality | Notes |
| ----- | --------- | ----------- | ------------- | ------- | ---------------------- | ----------- | ----- |
| en_US-joe-medium | en_turn_left_001 | | | | | | |
| en_US-joe-medium | en_turn_right_001 | | | | | | |
| en_US-joe-medium | en_keep_left_001 | | | | | | |
| en_US-joe-medium | en_keep_right_001 | | | | | | |
| en_US-joe-medium | en_continue_straight_001 | | | | | | |
| en_US-joe-medium | en_uturn_001 | | | | | | |
| en_US-joe-medium | en_uturn_002 | | | | | | |
| en_US-joe-medium | en_roundabout_001 | | | | | | |
| en_US-joe-medium | en_roundabout_002 | | | | | | |
| en_US-joe-medium | en_roundabout_003 | | | | | | |
| en_US-joe-medium | en_exit_001 | | | | | | |
| en_US-joe-medium | en_exit_002 | | | | | | |
| en_US-joe-medium | en_exit_003 | | | | | | |
| en_US-joe-medium | en_distance_100m_001 | | | | | | |
| en_US-joe-medium | en_distance_500m_001 | | | | | | |
| en_US-joe-medium | en_distance_1km_001 | | | | | | |
| en_US-joe-medium | en_distance_2km_001 | | | | | | |
| en_US-joe-medium | en_distance_intersection_001 | | | | | | |
| en_US-joe-medium | en_distance_short_001 | | | | | | |
| en_US-joe-medium | en_traffic_ahead_001 | | | | | | |
| en_US-joe-medium | en_traffic_heavy_001 | | | | | | |
| en_US-joe-medium | en_traffic_heavy_002 | | | | | | |
| en_US-joe-medium | en_accident_ahead_001 | | | | | | |
| en_US-joe-medium | en_hazard_ahead_001 | | | | | | |
| en_US-joe-medium | en_construction_001 | | | | | | |
| en_US-joe-medium | en_road_closed_001 | | | | | | |
| en_US-joe-medium | en_speed_camera_001 | | | | | | |
| en_US-joe-medium | en_speed_camera_002 | | | | | | |
| en_US-joe-medium | en_speed_camera_003 | | | | | | |
| en_US-joe-medium | en_speed_camera_004 | | | | | | |
| en_US-joe-medium | en_redlight_camera_001 | | | | | | |
| en_US-joe-medium | en_redlight_camera_002 | | | | | | |
| en_US-joe-medium | en_police_001 | | | | | | |
| en_US-joe-medium | en_police_002 | | | | | | |
| en_US-joe-medium | en_arrival_001 | | | | | | |
| en_US-joe-medium | en_arrival_002 | | | | | | |
| en_US-joe-medium | en_arrival_003 | | | | | | |
| en_US-joe-medium | en_arrival_004 | | | | | | |
| en_US-joe-medium | en_personality_simple_001 | | | | | | |
| en_US-joe-medium | en_personality_normal_001 | | | | | | |
| en_US-joe-medium | en_personality_normal_002 | | | | | | |
| en_US-joe-medium | en_personality_firm_001 | | | | | | |
| en_US-joe-medium | en_personality_firm_002 | | | | | | |
| en_US-joe-medium | en_personality_savage_001 | | | | | | |
| en_US-joe-medium | en_personality_savage_002 | | | | | | |
| en_US-joe-medium | en_long_001 | | | | | | |
| en_US-joe-medium | en_long_002 | | | | | | |

---

## en_US-kristin-medium

Female, public domain dataset (LibriVox), 22,050 Hz

| Voice | Phrase ID | Naturalness | Pronunciation | Clarity | Navigation Suitability | Personality | Notes |
| ----- | --------- | ----------- | ------------- | ------- | ---------------------- | ----------- | ----- |
| en_US-kristin-medium | en_turn_left_001 | | | | | | |
| en_US-kristin-medium | en_turn_right_001 | | | | | | |
| en_US-kristin-medium | en_keep_left_001 | | | | | | |
| en_US-kristin-medium | en_keep_right_001 | | | | | | |
| en_US-kristin-medium | en_continue_straight_001 | | | | | | |
| en_US-kristin-medium | en_uturn_001 | | | | | | |
| en_US-kristin-medium | en_uturn_002 | | | | | | |
| en_US-kristin-medium | en_roundabout_001 | | | | | | |
| en_US-kristin-medium | en_roundabout_002 | | | | | | |
| en_US-kristin-medium | en_roundabout_003 | | | | | | |
| en_US-kristin-medium | en_exit_001 | | | | | | |
| en_US-kristin-medium | en_exit_002 | | | | | | |
| en_US-kristin-medium | en_exit_003 | | | | | | |
| en_US-kristin-medium | en_distance_100m_001 | | | | | | |
| en_US-kristin-medium | en_distance_500m_001 | | | | | | |
| en_US-kristin-medium | en_distance_1km_001 | | | | | | |
| en_US-kristin-medium | en_distance_2km_001 | | | | | | |
| en_US-kristin-medium | en_distance_intersection_001 | | | | | | |
| en_US-kristin-medium | en_distance_short_001 | | | | | | |
| en_US-kristin-medium | en_traffic_ahead_001 | | | | | | |
| en_US-kristin-medium | en_traffic_heavy_001 | | | | | | |
| en_US-kristin-medium | en_traffic_heavy_002 | | | | | | |
| en_US-kristin-medium | en_accident_ahead_001 | | | | | | |
| en_US-kristin-medium | en_hazard_ahead_001 | | | | | | |
| en_US-kristin-medium | en_construction_001 | | | | | | |
| en_US-kristin-medium | en_road_closed_001 | | | | | | |
| en_US-kristin-medium | en_speed_camera_001 | | | | | | |
| en_US-kristin-medium | en_speed_camera_002 | | | | | | |
| en_US-kristin-medium | en_speed_camera_003 | | | | | | |
| en_US-kristin-medium | en_speed_camera_004 | | | | | | |
| en_US-kristin-medium | en_redlight_camera_001 | | | | | | |
| en_US-kristin-medium | en_redlight_camera_002 | | | | | | |
| en_US-kristin-medium | en_police_001 | | | | | | |
| en_US-kristin-medium | en_police_002 | | | | | | |
| en_US-kristin-medium | en_arrival_001 | | | | | | |
| en_US-kristin-medium | en_arrival_002 | | | | | | |
| en_US-kristin-medium | en_arrival_003 | | | | | | |
| en_US-kristin-medium | en_arrival_004 | | | | | | |
| en_US-kristin-medium | en_personality_simple_001 | | | | | | |
| en_US-kristin-medium | en_personality_normal_001 | | | | | | |
| en_US-kristin-medium | en_personality_normal_002 | | | | | | |
| en_US-kristin-medium | en_personality_firm_001 | | | | | | |
| en_US-kristin-medium | en_personality_firm_002 | | | | | | |
| en_US-kristin-medium | en_personality_savage_001 | | | | | | |
| en_US-kristin-medium | en_personality_savage_002 | | | | | | |
| en_US-kristin-medium | en_long_001 | | | | | | |
| en_US-kristin-medium | en_long_002 | | | | | | |

---

## en_US-ljspeech-medium

Female, public domain dataset (LJSpeech), 22,050 Hz

| Voice | Phrase ID | Naturalness | Pronunciation | Clarity | Navigation Suitability | Personality | Notes |
| ----- | --------- | ----------- | ------------- | ------- | ---------------------- | ----------- | ----- |
| en_US-ljspeech-medium | en_turn_left_001 | | | | | | |
| en_US-ljspeech-medium | en_turn_right_001 | | | | | | |
| en_US-ljspeech-medium | en_keep_left_001 | | | | | | |
| en_US-ljspeech-medium | en_keep_right_001 | | | | | | |
| en_US-ljspeech-medium | en_continue_straight_001 | | | | | | |
| en_US-ljspeech-medium | en_uturn_001 | | | | | | |
| en_US-ljspeech-medium | en_uturn_002 | | | | | | |
| en_US-ljspeech-medium | en_roundabout_001 | | | | | | |
| en_US-ljspeech-medium | en_roundabout_002 | | | | | | |
| en_US-ljspeech-medium | en_roundabout_003 | | | | | | |
| en_US-ljspeech-medium | en_exit_001 | | | | | | |
| en_US-ljspeech-medium | en_exit_002 | | | | | | |
| en_US-ljspeech-medium | en_exit_003 | | | | | | |
| en_US-ljspeech-medium | en_distance_100m_001 | | | | | | |
| en_US-ljspeech-medium | en_distance_500m_001 | | | | | | |
| en_US-ljspeech-medium | en_distance_1km_001 | | | | | | |
| en_US-ljspeech-medium | en_distance_2km_001 | | | | | | |
| en_US-ljspeech-medium | en_distance_intersection_001 | | | | | | |
| en_US-ljspeech-medium | en_distance_short_001 | | | | | | |
| en_US-ljspeech-medium | en_traffic_ahead_001 | | | | | | |
| en_US-ljspeech-medium | en_traffic_heavy_001 | | | | | | |
| en_US-ljspeech-medium | en_traffic_heavy_002 | | | | | | |
| en_US-ljspeech-medium | en_accident_ahead_001 | | | | | | |
| en_US-ljspeech-medium | en_hazard_ahead_001 | | | | | | |
| en_US-ljspeech-medium | en_construction_001 | | | | | | |
| en_US-ljspeech-medium | en_road_closed_001 | | | | | | |
| en_US-ljspeech-medium | en_speed_camera_001 | | | | | | |
| en_US-ljspeech-medium | en_speed_camera_002 | | | | | | |
| en_US-ljspeech-medium | en_speed_camera_003 | | | | | | |
| en_US-ljspeech-medium | en_speed_camera_004 | | | | | | |
| en_US-ljspeech-medium | en_redlight_camera_001 | | | | | | |
| en_US-ljspeech-medium | en_redlight_camera_002 | | | | | | |
| en_US-ljspeech-medium | en_police_001 | | | | | | |
| en_US-ljspeech-medium | en_police_002 | | | | | | |
| en_US-ljspeech-medium | en_arrival_001 | | | | | | |
| en_US-ljspeech-medium | en_arrival_002 | | | | | | |
| en_US-ljspeech-medium | en_arrival_003 | | | | | | |
| en_US-ljspeech-medium | en_arrival_004 | | | | | | |
| en_US-ljspeech-medium | en_personality_simple_001 | | | | | | |
| en_US-ljspeech-medium | en_personality_normal_001 | | | | | | |
| en_US-ljspeech-medium | en_personality_normal_002 | | | | | | |
| en_US-ljspeech-medium | en_personality_firm_001 | | | | | | |
| en_US-ljspeech-medium | en_personality_firm_002 | | | | | | |
| en_US-ljspeech-medium | en_personality_savage_001 | | | | | | |
| en_US-ljspeech-medium | en_personality_savage_002 | | | | | | |
| en_US-ljspeech-medium | en_long_001 | | | | | | |
| en_US-ljspeech-medium | en_long_002 | | | | | | |
