---
id: voice-pack-single-language
title: "Voice packs are single-language — no mixed-language instructions"
category: decision
status: active
created: "2026-08-15T03:07:06"
updated: "2026-08-15T03:10:42"
---

<!-- compiled_truth -->
# Voice packs are single-language

**Authoritative requirement (clarified 2026-08-15):** a generated voice pack has ONE language. All instructions in that voice pack are synthesized using the appropriate voice for that language.

```
English Voice Pack
  → English instruction
  → English TTS voice
  → English audio

Nepali Voice Pack
  → Nepali instruction
  → Nepali TTS voice
  → Nepali audio
```

**Explicit non-requirements:**
- Mixed Nepali-English speech inside a single instruction is NOT an MVP requirement.
- The TTS engine must NOT be asked to pronounce English words using a Nepali voice.
- No stitching of Nepali and English voices; no voice switching; no multilingual segment detection; no automatic language detection (as product architecture).

**Consequences:**
- The hybrid experiment ([[hybrid-tts-experiment]]) is experimental/historical only — not part of MVP.
- Piper stays a candidate: the "English words via Nepali voice are hard to understand" finding is no longer relevant. The real question: can Piper provide a good standalone Nepali voice AND a good standalone English voice?
- Benchmark metadata should identify language + voice per generation (a light VoiceProfile concept: language + tts_voice) without building a final domain model yet.

Related: [[hybrid-tts-experiment]], [[piper-nepali-voices]], [[tts-benchmark-milestone]].


## Timeline

- time: 2026-08-15T03:07:06
  kind: decision
  summary: "Created this page: Voice packs are single-language — no mixed-language instructions"
  source: product requirement clarification 2026-08-15
  affects: [voice-pack-single-language]

- time: 2026-08-15T03:10:42
  kind: decision
  summary: authoritative product requirement
  source: product requirement clarification 2026-08-15
  affects: [voice-pack-single-language]
