# Decision: Final Nepali Navigation Content (MVP)

**Status:** Decided (project-level approval)
**Date:** 2026-08-15
**Applies to:** `benchmark/corpus/phrases.json` — 25 Nepali (`ne`) product phrases

## 1. Final language decision

The 25 Nepali product phrases in the corpus are frozen as the MVP copy. Five phrases
were changed to the wording below; all other `ne` phrases keep the wording marked KEEP
in `docs/nepali-human-review-v2.md`. All finalized product phrases are marked
`review_status: approved`. `humor_002` remains `needs-review` as the deliberate `ne-en`
technical TTS test, not product copy.

Final wording changes applied:

| ID | Final text |
| --- | --- |
| roundabout_002 | गोलचक्करमा पहिलो निकास लिनुहोस्। |
| exit_002 | अर्को निकास लिनुहोस्। |
| distance_100m_002 | सय मिटरपछि देब्रे मोड्नुहोस्। |
| distance_200m_001 | दुई सय मिटरपछि गोलचक्कर आउँछ। |
| redlight_camera_002 | अगाडिको रातो बत्तीमा क्यामेरा छ। रोकिनुहोस्। |

## 2. Spoken Nepali over formal/literal translation

Navigation copy is written as **native conversational Nepali** — what a Nepali person
would actually say to a driver — not as a literal or formal translation of the English.
Grammatical correctness is necessary but not sufficient: textbook, news-register, or
GPS-announcement style ("तपाईंको यात्रा सुरु हुँदैछ") fails on first listen. The
principle: forget the English sentence, then ask how a Nepali speaker would naturally
say it. Full rationale: `docs/nepali-human-review-v2.md` and the project brain
(`nepali-content-principle`).

## 3. Borrowed terms are retained

स्पिड क्यामेरा, ट्राफिक, पुलिस are the established spoken words in Nepali driving
contexts. Forcing pure-Nepali substitutes (प्रहरी, निर्माण) would sound like news or
government language, not a friendly driving assistant. Borrowed English-origin words are
kept where real speakers use them, written in Devanagari.

## 4. गोलचक्कर over राउन्डअबाउट

गोलचक्कर is the established everyday Nepali word for a roundabout (e.g. कलंकी
गोलचक्कर), understood by the general driving audience, and renders with native
phonology in the Nepali TTS voice. राउन्डअबाउट would force English phonemes
("ra-un-da-ba-uṭ") through the Nepali voice. Applied to both roundabout phrases
(roundabout_002, distance_200m_001) so the two stay consistent.

## 5. निकास: retained in "पहिलो निकास", "अर्को निकास" for the generic next exit

निकास (exit) is understood and appears on Nepali road signage, so it is retained in the
roundabout instruction. For the generic "take the next exit" phrase, अर्को निकास is used
because अर्को ("next/another") is the natural spoken word — अगाडिको primarily means "the
one up ahead/in front" and is the wrong flavor for "next".

## 6. Red-light camera uses descriptive wording

"रातो बत्ती क्यामेरा" is an unnatural calque of English "red-light camera", and the
concept is new to Nepal, so there is no settled spoken compound. The phrase instead
describes the situation naturally: "अगाडिको रातो बत्तीमा क्यामेरा छ। रोकिनुहोस्।"
(there is a camera at the red light ahead — stop). This is a product decision based on
the linguistic review; it may receive future native-speaker validation (recorded in the
phrase's `review_note`).

## 7. "सय मिटर" for 100 meters

Spoken Nepali says a bare hundred as सय ("सय रुपैयाँ"), not एक सय. The multi-hundred
forms keep the multiplier (दुई सय, तीन सय, पाँच सय). "एक" is required for एक
किलोमिटर (exactly one kilometer), so only the 100-meter phrase changes.

## 8. Scope of this approval

This is **project-level language approval** based on the internal linguistic review —
it is not certified linguistic approval by a professional Nepali linguist or native
review panel. The red-light-camera phrase in particular is flagged for potential future
native-speaker validation.

## Reference

- `docs/nepali-human-review.md` — review template (v1)
- `docs/nepali-human-review-v2.md` — independent natural-language review (v2), source of
  the final wording decisions
