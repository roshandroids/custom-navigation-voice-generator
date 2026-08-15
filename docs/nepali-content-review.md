# Nepali Content Review — Native-Conversational Review Record

**Status: REVIEWED BY CODE AGENT — NOT native-human-approved.**
The purpose of this pass was to identify and fix obvious unnatural phrasing and to
prepare a clean corpus for human/native-speaker approval. The statuses below are the
reviewer's best-judgment assessment; a native speaker must confirm before TTS
regeneration is treated as final.

Scope: the 26 Nepali-language phrases (`ne` + the single `ne-en` test phrase) in
`benchmark/corpus/phrases.json`. English phrases and `benchmark/corpus/phrases_en.json`
are untouched. **No TTS audio was regenerated.**

Criteria applied per phrase (from [[nepali-content-principle]]):
natural spoken Nepali, natural vocabulary/structure/endings, driving context,
conciseness, immediate comprehension, repetition tolerance, personality fit,
and exact navigation-meaning preservation.

---

## Review table

| ID | Situation | Current Script | Status | Review Notes |
| --- | --- | --- | --- | --- |
| turn_left_001 | Turn left | देब्रे मोड्नुहोस्। | approved | Canonical spoken Nepali; short, unambiguous, fine on repeat. |
| turn_right_001 | Turn right | दायाँ मोड्नुहोस्। | approved | Same as above. |
| keep_left_002 | Keep left | देब्रेतिर लाग्नुहोस्। | approved | Corrected this pass from देब्रे बस्नुहोस् (बस्नुहोस् primarily reads "sit"). देब्रेतिर लाग्नुहोस् = "head/take toward the left", the natural keep-left expression. |
| continue_straight_002 | Continue straight | सीधा जानुहोस्। | approved | Natural spoken imperative. |
| uturn_002 | Make a U-turn | यू-टर्न लिनुहोस्। | approved | यू-टर्न is the universally used loanword; लिनुहोस् is the natural verb (take a U-turn). |
| roundabout_002 | At the roundabout, take the first exit | राउन्डअबाउटमा पहिलो निकास लिनुहोस्। | needs-review | राउन्डअबाउट loanword natural; **निकास for "exit" needs native confirmation** — निकास is formal; a native may prefer "बाटो छोड्नुहोस्" (leave the road) or an exit-loanword. Grammar is fine. |
| exit_002 | Take the next exit | अगाडिको निकास लिनुहोस्। | needs-review | Corrected this pass from अगाडिको निकासबाट बाहिर निस्कनुहोस् (redundant "exit out from the exit"). Now concise and parallel to roundabout_002; **निकास wording still needs native confirmation.** |
| distance_100m_002 | In 100 meters, turn left | एक सय मिटरपछि देब्रे मोड्नुहोस्। | approved | Natural spoken distance phrasing (एक सय मिटरपछि). |
| distance_500m_002 | In 500 meters, keep right | पाँच सय मिटरपछि दायाँतिर लाग्नुहोस्। | approved | Corrected this pass twice: first to मोड्नुहोस् (turn), then to दायाँतिर लाग्नुहोस् (keep right) to **preserve the keep-right meaning** and match keep_left_002 (देब्रेतिर लाग्नुहोस्). Natural spoken "keep right" phrasing. |
| distance_1km_002 | In 1 kilometer, turn right | एक किलोमिटरपछि दायाँ मोड्नुहोस्। | approved | Natural spoken distance + turn. |
| distance_200m_001 | After 200 meters, roundabout | दुई सय मिटरपछि राउन्डअबाउट आउँछ। | approved | Natural; "roundabout comes" is idiomatic. |
| distance_300m_001 | After 300 meters, go straight | तीन सय मिटरपछि सीधा जानुहोस्। | approved | Natural. |
| traffic_ahead_001 | Traffic ahead | अगाडि ट्राफिक जाम छ। | approved | ट्राफिक जाम is the everyday spoken term. |
| traffic_heavy_002 | Heavy traffic on your route | बाटोमा धेरै ट्राफिक छ। | approved | Natural spoken construction. |
| accident_ahead_002 | Accident ahead | अगाडि दुर्घटना छ। | approved | दुर्घटना is the standard spoken word for accident; natural and clear. |
| construction_002 | Road construction ahead | अगाडि बाटो बनिरहेको छ। | approved | Corrected this pass from अगाडि सडक मर्मत भइरहेको छ (सडक मर्मत is sign/formal language, not speech). "The road is being built ahead" is what a driver says. |
| road_closed_002 | Road closed | बाटो बन्द छ। | approved | Short, natural, universally understood. |
| speed_camera_001 | Speed camera ahead (simple) | अगाडि स्पिड क्यामेरा छ। | approved | स्पिड क्यामेरा is the natural spoken loanword; simple/neutral as required. |
| speed_camera_002 | Speed camera ahead (normal) | ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ। | needs-review | Personality variant — **needs human ear.** Fillers ल/है are natural here but only a native listener can judge whether the pacing works repeatedly. Meaning (warning + slow down) is preserved. |
| redlight_camera_002 | Red-light camera ahead | अगाडि रातो बत्ती क्यामेरा छ। रोकिनुहोस्। | needs-review | Corrected this pass from the awkward descriptive clause रातो बत्ती भएको क्यामेरा to a **loan-compound calque** रातो बत्ती क्यामेरा (following स्पिड क्यामेरा). This is a coinage — **needs native confirmation.** |
| police_002 | Police ahead | अगाडि पुलिस छ। | approved | पुलिस is the everyday spoken word (प्रहरी is formal). Natural. |
| arrival_002 | You have arrived | तपाईं गन्तव्यमा आइपुग्नुभयो। | needs-review | Corrected this pass from पुग्नुभयो to आइपुग्नुभयो (warmer "arrive here"). Still a slightly formal/GPS register — **native ear needed** to decide between this and a more casual "पुग्यौं / आइपुग्यौं" style. |
| arrival_005 | Destination is on the left | तपाईंको गन्तव्य देब्रेतिर छ। | needs-review | गन्तव्य is formal-ish for everyday speech; **native confirmation needed** whether "तपाईंको गन्तव्य देब्रेतिर छ" is natural or whether a plainer phrasing (e.g. देब्रेतिर पुग्नुहुन्छ) is preferred. |
| humor_001 | This road again? (savage/humor) | फेरि यही बाटो? पक्का? लौ, ठीकै छ, जाऔँ। | needs-review | Light, repeatable, not insulting — but **joke-naturalness needs native confirmation**; the "पक्का?" double-check may feel scripted to some ears. |
| humor_002 | Keep right, exit ahead (TTS language test) | Keep right है, अगाडि exit आउँदैछ। | needs-review | **Deliberate ne-en language-test phrase** (Latin English through Nepali voice) — kept intentionally to document the TTS limitation. Not product copy. |
| long_001 | Long two-turn instruction | अबको दोस्रो गल्लीबाट देब्रे मोड्नुहोस् र सीधै जानुहोस्। त्यसपछि पहिलो देब्रे मोड लिनुहोस्। | needs-review | Corrected this pass: removed the देब्रे/बायाँ inconsistency (both mean "left") and the repetitious फेरि मोड्नुहोस्. **Naturalness of the long-form flow needs native confirmation.** |

---

## Summary

- **Phrases reviewed:** 26
- **Approved (ready for TTS pending native confirmation):** 17
- **Still needs-review:** 9
  - Vocabulary-uncertain: `roundabout_002`, `exit_002`, `redlight_camera_002`, `arrival_002`, `arrival_005`
  - Personality/naturalness-uncertain: `speed_camera_002`, `humor_001`, `long_001`
  - Deliberate language test (not product copy): `humor_002`

> **Important limitation:** this review was performed by a code agent applying the
> content principles. It is NOT native-human approval. The 17 "approved" phrases are
> standard, widely-attested spoken Nepali constructions, but a native speaker should
> still spot-check the full list before TTS regeneration — and the 9 flagged phrases
> must be resolved by a native speaker.
