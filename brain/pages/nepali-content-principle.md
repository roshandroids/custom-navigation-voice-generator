---
id: nepali-content-principle
title: "Nepali navigation content is native conversational Nepali, not translated English"
category: decision
status: active
tags: [corpus, content, nepali]
created: "2026-08-15T12:23:46"
updated: "2026-08-15T12:31:50"
---

<!-- compiled_truth -->
# Nepali navigation content is native conversational Nepali

**Authoritative content principle (2026-08-15):** Nepali navigation scripts are authored as **native conversational Nepali** — the way a Nepali person would naturally say the instruction to a friend in the car — NOT translated literally from English.

```
Navigation meaning
      ↓
Forget the English sentence
      ↓
How would a Nepali person naturally say this?
      ↓
Natural spoken Nepali
```

## The three problems this resolves (from the Nepali TTS evaluation)

1. **English inside Nepali TTS** — Latin-script English (speed camera, keep right, exit, traffic) sent to a Nepali Piper voice is pronounced with a Nepali accent and hard to understand. This is NOT a Piper bug to solve: the product does not require a Nepali voice to speak English. The Nepali voice pack must not depend on English pronunciation.
2. **Grammatically correct but unnatural** — literal translations, textbook/formal Nepali, GPS-announcement style. Grammatical correctness is necessary but NOT sufficient; "technically correct but nobody talks like that" must be rewritten.
3. **Inappropriate personality scripts** — exaggerated, joke-heavy, slang-heavy, or repetitive scripts are not suitable for daily driving. Personality must stay useful, natural, and repeatable ("funny friend", not "comedian performing every 20 seconds").

## Rules

- Nepali TTS input is primarily Devanagari; **no unnecessary Latin-script English** is sent to the Nepali voice.
- **Borrowed English-origin words are allowed** when genuinely natural in spoken Nepali, written in Devanagari: स्पिड, क्यामेरा, ट्राफिक, पुलिस, रुट. Do not force unnatural pure-Nepali translations, and do not transliterate every English word automatically.
- **Personality principle:** personality modifies wording and delivery while **preserving the navigation meaning** and remaining pleasant on repeated daily listening. The warning must stay obvious in every personality.
- **TTS principle:** the Nepali voice is not responsible for native English pronunciation — English is handled by the English voice pack ([[voice-pack-single-language]]).
- Numbers/distances are written as natural spoken Nepali (एक सय मिटरपछि, पाँच सय मिटरपछि, एक किलोमिटरपछि), not "100 meters पछि".
- Deliberate TTS edge-case tests (Latin English, digits, hard words) live only in the `language_tests` category and do not dictate product-script wording.
- All rewritten phrases carry `review_status: needs-review` in the corpus — native-speaker review is required before approval.

Related: [[voice-pack-single-language]], [[corpus-standard]], [[hybrid-tts-experiment]], [[piper-nepali-voices]].


## Timeline

- time: 2026-08-15T12:23:46
  kind: decision
  summary: "Created this page: Nepali navigation content is native conversational Nepali, not translated English"
  source: Nepali corpus content rewrite 2026-08-15
  affects: [nepali-content-principle]

- time: 2026-08-15T12:25:56
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: brain update-truth
  affects: [nepali-content-principle]

- time: 2026-08-15T12:31:50
  kind: decision
  summary: "Native-conversational review (2026-08-15): 26 phrases reviewed, 17 approved (standard spoken constructions), 9 flagged needs-review (निकास/exit vocabulary, रातो बत्ती क्यामेरा calque, arrival register, personality/long-form). Review record: docs/nepali-content-review.md. Not native-human approval."
  source: Nepali content review pass 2026-08-15
  affects: [corpus-standard]
