# Nepali Navigation Phrases — Independent Natural-Language Review (v2)

Independent verification of the 25 Nepali (`ne`) product phrases from
`benchmark/corpus/phrases.json`, focused on **natural spoken Nepali** — what a Nepali
driver would actually say and understand while driving — not grammatical correctness,
formal register, or literal translation.

Scope and constraints:

- All 25 `ne`-language phrases reviewed. `humor_002` (the deliberate `ne-en` TTS
  language test) is excluded. English phrases are untouched.
- `benchmark/corpus/phrases.json` was **not modified**.
- No TTS audio was generated; no Piper/benchmark/engine configuration changed.
- No personality metadata was invented. Conversational phrases are judged only on
  whether the language itself sounds like something a real Nepali person would say.
- Assessment values: **KEEP** (already natural), **REVISE** (a more natural form is
  proposed), **UNCERTAIN** (cannot confidently choose between forms). Confidence is
  stated per phrase and is deliberately conservative: this document is a strong
  proposal for a native speaker to verify, not a final approval.

## Overview

| ID | Category | Current script | Assessment |
| --- | --- | --- | --- |
| turn_left_001 | directions | देब्रे मोड्नुहोस्। | KEEP |
| turn_right_001 | directions | दायाँ मोड्नुहोस्। | KEEP |
| keep_left_002 | directions | देब्रेतिर लाग्नुहोस्। | KEEP |
| continue_straight_002 | directions | सीधा जानुहोस्। | KEEP |
| uturn_002 | directions | यू-टर्न लिनुहोस्। | KEEP |
| roundabout_002 | directions | राउन्डअबाउटमा पहिलो निकास लिनुहोस्। | REVISE |
| exit_002 | directions | अगाडिको निकास लिनुहोस्। | REVISE |
| distance_100m_002 | distances | एक सय मिटरपछि देब्रे मोड्नुहोस्। | REVISE |
| distance_500m_002 | distances | पाँच सय मिटरपछि दायाँतिर लाग्नुहोस्। | KEEP |
| distance_1km_002 | distances | एक किलोमिटरपछि दायाँ मोड्नुहोस्। | KEEP |
| distance_200m_001 | distances | दुई सय मिटरपछि राउन्डअबाउट आउँछ। | REVISE |
| distance_300m_001 | distances | तीन सय मिटरपछि सीधा जानुहोस्। | KEEP |
| traffic_ahead_001 | traffic | अगाडि ट्राफिक जाम छ। | KEEP |
| traffic_heavy_002 | traffic | बाटोमा धेरै ट्राफिक छ। | KEEP |
| accident_ahead_002 | traffic | अगाडि दुर्घटना छ। | KEEP |
| construction_002 | traffic | अगाडि बाटो बनिरहेको छ। | KEEP |
| road_closed_002 | traffic | बाटो बन्द छ। | KEEP |
| speed_camera_001 | enforcement | अगाडि स्पिड क्यामेरा छ। | KEEP |
| speed_camera_002 | enforcement | ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ। | KEEP |
| redlight_camera_002 | enforcement | अगाडि रातो बत्ती क्यामेरा छ। रोकिनुहोस्। | UNCERTAIN |
| police_002 | enforcement | अगाडि पुलिस छ। | KEEP |
| arrival_002 | arrival | तपाईं गन्तव्यमा आइपुग्नुभयो। | KEEP |
| arrival_005 | arrival | तपाईंको गन्तव्य देब्रेतिर छ। | KEEP |
| humor_001 | language_tests | फेरि यही बाटो? पक्का? लौ, ठीकै छ, जाऔँ। | KEEP |
| long_001 | language_tests | अबको दोस्रो गल्लीबाट देब्रे मोड्नुहोस् र सीधै जानुहोस्। त्यसपछि पहिलो देब्रे मोड लिनुहोस्। | KEEP |

---

## turn_left_001

**Category:** directions
**Original/current text:** देब्रे मोड्नुहोस्।
**Assessment:** KEEP
**Why:**
This is exactly how a Nepali speaker tells a driver to turn left — short, direct, in the
standard polite imperative, with zero translation residue. "मोड्नु" (to turn) with
"देब्रे" (left) is the everyday form, not textbook Nepali. The variant "देब्रेतिर
मोड्नुहोस्" is equally natural and marginally more explicit; for a short prompt that a
driver will hear dozens of times, the shorter current form is the better navigation
choice. Driving meaning: *turn left* — exact, and correctly distinct from "keep left".
**Proposed natural Nepali:**
> देब्रे मोड्नुहोस्।
**English meaning:**
> Turn left.
**TTS notes:**
Simple two-word prompt. "देब्रे" = de-bre; "मोड्नुहोस्" = mod-nu-hos. No tricky clusters.
**Confidence:** HIGH

---

## turn_right_001

**Category:** directions
**Original/current text:** दायाँ मोड्नुहोस्।
**Assessment:** KEEP
**Why:**
Same reasoning as turn_left_001 — natural spoken imperative, correct driving meaning
(*turn right*), no formality or translation feel. Keep.
**Proposed natural Nepali:**
> दायाँ मोड्नुहोस्।
**English meaning:**
> Turn right.
**TTS notes:**
"दायाँ" = da-yā; "मोड्नुहोस्" = mod-nu-hos. Clean.
**Confidence:** HIGH

---

## keep_left_002

**Category:** directions
**Original/current text:** देब्रेतिर लाग्नुहोस्।
**Assessment:** KEEP
**Why:**
"लाग्नुहोस्" (proceed / head toward) is the natural spoken verb for "keep left" at a
fork, lane split, or divergence — it conveys *continuing on the left* rather than making
a turn. "देब्रेतिर" (toward the left) is the everyday locative. This is exactly what a
Nepali co-driver says, and it preserves the driving distinction the task flagged: this is
*keep/bear left*, not *turn left*. Natural and correct.
**Proposed natural Nepali:**
> देब्रेतिर लाग्नुहोस्।
**English meaning:**
> Keep left / bear left.
**TTS notes:**
"देब्रेतिर" = de-bre-ti-ra (four syllables, no issues).
**Confidence:** HIGH

---

## continue_straight_002

**Category:** directions
**Original/current text:** सीधा जानुहोस्।
**Assessment:** KEEP
**Why:**
"सीधा जानुहोस्" is the plain, universally used way to say "go straight" in spoken
Nepali — in casual directions and in navigation alike. "सोझै जानुहोस्" is a natural
synonym; "सीधा" is the more standard navigation choice. Meaning: *continue straight* —
exact.
**Proposed natural Nepali:**
> सीधा जानुहोस्।
**English meaning:**
> Go straight / continue straight.
**TTS notes:**
"सीधा" = sī-dha (aspirated dh). Simple.
**Confidence:** HIGH

---

## uturn_002

**Category:** directions
**Original/current text:** यू-टर्न लिनुहोस्।
**Assessment:** KEEP
**Why:**
"यू-टर्न" is the everyday Nepali term, spoken as "yu-turn", and "लिनुहोस्" (take) with
it follows the same natural pattern as "मोड लिनुहोस्" (take the turn). "यू-टर्न
गर्नुहोस्" (do a U-turn) is equally natural — both verb forms are heard in real speech,
so this is a coin-flip between two natural forms rather than a correctness issue.
"लिनुहोस्" is kept here because it matches the exit phrasing used elsewhere in the
corpus. Meaning: *make a U-turn* — exact.
**Proposed natural Nepali:**
> यू-टर्न लिनुहोस्।
**English meaning:**
> Make a U-turn.
**TTS notes:**
"यू" is the English letter U in Devanagari — confirm the Nepali voice renders it "yu"
rather than "yū-ū". "टर्न" = ṭar-n (retroflex). If the hyphen causes tokenization
issues, "यू टर्न" or "युटर्न" are spelling variants of the same sound.
**Confidence:** MEDIUM (word choice is natural; "take" vs "do" is a stylistic coin-flip)

---

## roundabout_002

**Category:** directions
**Original/current text:** राउन्डअबाउटमा पहिलो निकास लिनुहोस्।
**Assessment:** REVISE
**Why:**
Grammatical and understandable, and राउन्डअबाउट is heard in urban, English-mixed
speech — but **गोलचक्कर** is the established everyday Nepali word for a roundabout
(used across Nepal, e.g. "कलंकी गोलचक्कर") and is instantly natural for the general
driving audience. "निकास" (exit) is understood and appears on Nepali road signage, so it
is acceptable here; "पहिलो निकास लिनुहोस्" is a clear instruction. This is a
naturalness preference plus a real TTS advantage, not a correctness fix: गोलचक्कर avoids
forcing English phonology ("ra-un-da-ba-uṭ") through the Nepali voice. If the team
deliberately targets a younger urban audience, the current loanword form remains
acceptable — flagging that this word choice affects both roundabout phrases
(see distance_200m_001) and should be decided once.
**Proposed natural Nepali:**
> गोलचक्करमा पहिलो निकास लिनुहोस्।
**English meaning:**
> At the roundabout, take the first exit.
**TTS notes:**
"गोलचक्कर" = gol-chak-kar — straightforward Devanagari, native phonology. Preferable to
"राउन्डअबाउट", which the Nepali voice must render with English phonemes.
**Confidence:** MEDIUM

---

## exit_002

**Category:** directions
**Original/current text:** अगाडिको निकास लिनुहोस्।
**Assessment:** REVISE
**Why:**
"अगाडिको" primarily means "the one in front / up ahead" (e.g. "अगाडिको कार" = the car
ahead). It is understandable here, but for English "take the **next** exit" the natural
spoken word is "अर्को" (next/another): "अर्को निकास लिनुहोस्।" That matches the source
meaning more exactly and is what a Nepali driver expects to hear. "निकास" stays —
understood from signage and kept consistent with roundabout_002. The current form is
acceptable; the proposed form is the more natural "next".
**Proposed natural Nepali:**
> अर्को निकास लिनुहोस्।
**English meaning:**
> Take the next exit.
**TTS notes:**
"अर्को" = ar-ko. Short and clean.
**Confidence:** MEDIUM

---

## distance_100m_002

**Category:** distances
**Original/current text:** एक सय मिटरपछि देब्रे मोड्नुहोस्।
**Assessment:** REVISE
**Why:**
"एक सय" is not wrong, but spoken Nepali says "सय" alone for a hundred in everyday
contexts ("सय रुपैयाँ" = a hundred rupees). "सय मिटरपछि देब्रे मोड्नुहोस्" is the more
natural spoken form and one syllable shorter for TTS. This is a spoken-register
preference, not a grammar fix. Note: the multi-hundred forms (दुई सय, तीन सय, पाँच सय)
are already correct and natural — only the "एक सय" form wants the colloquial
simplification. Meaning: *after 100 meters, turn left* — unchanged.
**Proposed natural Nepali:**
> सय मिटरपछि देब्रे मोड्नुहोस्।
**English meaning:**
> In 100 meters, turn left.
**TTS notes:**
"सय मिटरपछि" = sa-ya me-ṭar-pa-chhi. One fewer syllable than "एक सय".
**Confidence:** MEDIUM

---

## distance_500m_002

**Category:** distances
**Original/current text:** पाँच सय मिटरपछि दायाँतिर लाग्नुहोस्।
**Assessment:** KEEP
**Why:**
"पाँच सय मिटरपछि" is the natural spoken number form (the "एक" is only dropped for a
bare hundred), and "दायाँतिर लाग्नुहोस्" mirrors keep_left_002 — natural for "keep
right". Meaning: *after 500 meters, keep right* — exact, and correctly distinct from
"turn right".
**Proposed natural Nepali:**
> पाँच सय मिटरपछि दायाँतिर लाग्नुहोस्।
**English meaning:**
> In 500 meters, keep right.
**TTS notes:**
"पाँच सय" = pā~ch sa-ya (nasalized pāch). Clean.
**Confidence:** HIGH

---

## distance_1km_002

**Category:** distances
**Original/current text:** एक किलोमिटरपछि दायाँ मोड्नुहोस्।
**Assessment:** KEEP
**Why:**
For exactly one kilometer, "एक किलोमिटर" is the correct and natural spoken form (unlike
a bare hundred, you cannot drop "एक" here). The full "किलोमिटर" is clearer than the
casual "केएम" and better for TTS. "दायाँ मोड्नुहोस्" is natural. Meaning: *after 1
kilometer, turn right* — exact.
**Proposed natural Nepali:**
> एक किलोमिटरपछि दायाँ मोड्नुहोस्।
**English meaning:**
> In 1 kilometer, turn right.
**TTS notes:**
"किलोमिटर" is long — verify fluency. Do not substitute "केएम" (casual) in product copy.
**Confidence:** HIGH

---

## distance_200m_001

**Category:** distances
**Original/current text:** दुई सय मिटरपछि राउन्डअबाउट आउँछ।
**Assessment:** REVISE
**Why:**
"दुई सय मिटरपछि ... आउँछ" is a very natural spoken construction — "आउँछ" ("comes / is
coming") is exactly how Nepalis announce an approaching junction. The only question is
राउन्डअबाउट vs गोलचक्कर, with the same reasoning as roundabout_002: गोलचक्कर is the
established everyday word and renders natively in the Nepali voice. The two roundabout
phrases should be consistent, whichever word is chosen.
**Proposed natural Nepali:**
> दुई सय मिटरपछि गोलचक्कर आउँछ।
**English meaning:**
> After 200 meters, there's a roundabout.
**TTS notes:**
"आउँछ" = ā-u~-chha (nasalized). Clean once the loanword is replaced.
**Confidence:** MEDIUM

---

## distance_300m_001

**Category:** distances
**Original/current text:** तीन सय मिटरपछि सीधा जानुहोस्।
**Assessment:** KEEP
**Why:**
Natural spoken number form and natural instruction, same pattern as the other distance
phrases. Meaning: *after 300 meters, go straight* — exact.
**Proposed natural Nepali:**
> तीन सय मिटरपछि सीधा जानुहोस्।
**English meaning:**
> In 300 meters, go straight.
**TTS notes:**
Clean; "तीन सय" = tīn sa-ya.
**Confidence:** HIGH

---

## traffic_ahead_001

**Category:** traffic
**Original/current text:** अगाडि ट्राफिक जाम छ।
**Assessment:** KEEP
**Why:**
"ट्राफिक जाम" is the everyday term ("जाम" alone is also common: "अगाडि जाम छ"), and
"अगाडि X छ" is the natural spoken warning template. This sounds like a real person
warning a driver, not a GPS translation. Meaning: *traffic jam ahead* — exact.
**Proposed natural Nepali:**
> अगाडि ट्राफिक जाम छ।
**English meaning:**
> There's a traffic jam ahead.
**TTS notes:**
"ट्राफिक" = ṭrā-phik (retroflex ṭ + r cluster — standard Devanagari, fine for Nepali TTS).
**Confidence:** HIGH

---

## traffic_heavy_002

**Category:** traffic
**Original/current text:** बाटोमा धेरै ट्राफिक छ।
**Assessment:** KEEP
**Why:**
"बाटोमा धेरै ट्राफिक छ" is exactly how Nepalis describe heavy traffic in daily speech
("आज बाटोमा धेरै ट्राफिक छ"). "बाटो" (the road / your route) covers the English "on
your route" naturally. No translation feel.
**Proposed natural Nepali:**
> बाटोमा धेरै ट्राफिक छ।
**English meaning:**
> There's a lot of traffic on the road (your route).
**TTS notes:**
"धेरै" = dhe-rai. Clean.
**Confidence:** HIGH

---

## accident_ahead_002

**Category:** traffic
**Original/current text:** अगाडि दुर्घटना छ।
**Assessment:** KEEP
**Why:**
"दुर्घटना" is the standard spoken word for accident (not bookish), and "अगाडि दुर्घटना
छ" is a natural warning. "अगाडि दुर्घटना भएको छ" (an accident has happened ahead) is
equally natural but longer; the current short form is better for a warning. Meaning:
*accident ahead* — exact.
**Proposed natural Nepali:**
> अगाडि दुर्घटना छ।
**English meaning:**
> There's an accident ahead.
**TTS notes:**
"दुर्घटना" = dur-gha-ṭa-nā. Fine.
**Confidence:** HIGH

---

## construction_002

**Category:** traffic
**Original/current text:** अगाडि बाटो बनिरहेको छ।
**Assessment:** KEEP
**Why:**
"बाटो बनिरहेको छ" ("the road is being built") is precisely how Nepalis colloquially
describe road works — completely natural, zero formality. The formal alternative
"निर्माण भइरहेको छ" would be wrong for this product. Meaning: *road construction ahead*
— exact.
**Proposed natural Nepali:**
> अगाडि बाटो बनिरहेको छ।
**English meaning:**
> The road is under construction ahead.
**TTS notes:**
"बनिरहेको" = ba-ni-ra-he-ko. Fine.
**Confidence:** HIGH

---

## road_closed_002

**Category:** traffic
**Original/current text:** बाटो बन्द छ।
**Assessment:** KEEP
**Why:**
"बाटो बन्द छ" is the everyday phrase for a closed road. Short, clear, natural, and
repeatable.
**Proposed natural Nepali:**
> बाटो बन्द छ।
**English meaning:**
> The road is closed.
**TTS notes:**
Simple; "बन्द" = ban-da.
**Confidence:** HIGH

---

## speed_camera_001

**Category:** enforcement
**Original/current text:** अगाडि स्पिड क्यामेरा छ।
**Assessment:** KEEP
**Why:**
"स्पिड क्यामेरा" is the established spoken term in Nepal — this is what drivers say and
hear; a "pure Nepali" substitute would sound artificial, not more natural. "अगाडि X छ"
is the natural warning template. Meaning: *speed camera ahead* — exact.
**Proposed natural Nepali:**
> अगाडि स्पिड क्यामेरा छ।
**English meaning:**
> There's a speed camera ahead.
**TTS notes:**
Borrowed words in Devanagari are standard practice here and render acceptably; no change.
**Confidence:** HIGH

---

## speed_camera_002

**Category:** enforcement
**Original/current text:** ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ।
**Assessment:** KEEP
**Why:**
This is genuinely conversational Nepali: "ल" as a spoken discourse opener, "छ है" for an
emphatic friendly warning, "अलि बिस्तारै जाऊ" (go a bit slowly) in the familiar
(timi-)register — exactly how a Nepali friend warns the driver. The register is
consistent throughout, and the personality reads as "friendly passenger", not a
performer. One caveat: "जाऊ" is familiar-register; if the product voice is meant to be
neutral-respectful to all users, "अलि बिस्तारै जानुहोस्" would be the polite variant —
but that would flatten this phrase's personality, so this is a product-tone decision,
not a language correction. Meaning: *speed camera ahead, slow down* — exact.
**Proposed natural Nepali:**
> ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ।
**English meaning:**
> Hey, there's a speed camera ahead — go a bit slowly.
**TTS notes:**
Ensure the voice keeps the pause between the two sentences (full stop handling). "है" is
a short emphatic particle (hai); "जाऊ" = jā-ū.
**Confidence:** MEDIUM (language is natural; appropriateness depends on chosen product
personality)

---

## redlight_camera_002

**Category:** enforcement
**Original/current text:** अगाडि रातो बत्ती क्यामेरा छ। रोकिनुहोस्।
**Assessment:** UNCERTAIN
**Why:**
"रातो बत्ती क्यामेरा" as a bare compound is a calque of English "red-light camera".
"रातो बत्ती" (traffic light) is everyday Nepali and "क्यामेरा" is a natural loan, but
the compound itself is not established speech — and the concept is new to Nepal (red-light
cameras appeared recently and are rare), so there is no settled natural phrasing yet. A
native speaker would more likely describe the situation: "अगाडिको रातो बत्तीमा क्यामेरा
छ" (there's a camera at the red light ahead), or "अगाडि रातो बत्तीमा क्यामेरा छ,
रोकिनुहोस्।" Both preserve the meaning (a camera at the upcoming red light). I am
confident the current compound is off, but not confident enough to declare the single
best replacement — **this needs native confirmation**. Note "रोकिनुहोस्" (stop) is fine
only because a red light is actually ahead; as a camera warning it means "be ready to
stop", which matches the intended meaning.
**Proposed natural Nepali:**
> अगाडिको रातो बत्तीमा क्यामेरा छ। रोकिनुहोस्।
**English meaning:**
> There's a camera at the red light ahead. Stop.
**TTS notes:**
"रातो बत्ती" is clean Devanagari; removing the calque also removes any ambiguity in the
voice's rendering of the stacked compound.
**Confidence:** LOW

---

## police_002

**Category:** enforcement
**Original/current text:** अगाडि पुलिस छ।
**Assessment:** KEEP
**Why:**
पुलिस is the everyday spoken word; प्रहरी is the formal/news register and would sound
like a government announcement, not a driving warning. "अगाडि पुलिस छ" is exactly how a
Nepali warns a driver. Meaning: *police ahead* — exact.
**Proposed natural Nepali:**
> अगाडि पुलिस छ।
**English meaning:**
> There are police ahead.
**TTS notes:**
"पुलिस" = pu-lis. Clean.
**Confidence:** HIGH

---

## arrival_002

**Category:** arrival
**Original/current text:** तपाईं गन्तव्यमा आइपुग्नुभयो।
**Assessment:** KEEP
**Why:**
"आइपुग्नु" (arrive here) is the warm, spoken verb — more natural than bare
"पुग्नुभयो". The sentence is polite (तपाईं + -नुभयो) but not stiff; this is the right
register for a navigation assistant at arrival. गन्तव्य is the standard navigation word
(understood by all), even though everyday speech would more often just say "तपाईं
आइपुग्नुभयो" — but the nav context needs गन्तव्य for clarity, and the full form is
natural. A shorter spoken variant "गन्तव्यमा आइपुग्नुभयो।" (subject dropped, very
common in spoken Nepali) is also fine if a shorter prompt is preferred. Meaning: *you
have arrived at your destination* — exact.
**Proposed natural Nepali:**
> तपाईं गन्तव्यमा आइपुग्नुभयो।
**English meaning:**
> You have arrived at your destination.
**TTS notes:**
"आइपुग्नुभयो" = ā-i-pug-nu-bha-yo — long word; verify fluency at natural pace.
**Confidence:** MEDIUM (natural and appropriate; mildly formal register is by design at
arrival)

---

## arrival_005

**Category:** arrival
**Original/current text:** तपाईंको गन्तव्य देब्रेतिर छ।
**Assessment:** KEEP
**Why:**
Natural spoken structure. "देब्रेतिर छ" (is toward the left) is how a Nepali describes
location. The alternative "देब्रेतिर पर्छ" (lies toward the left) is equally natural
with a slightly more descriptive flavor — both are fine, and the current "छ" is shorter,
which suits a navigation prompt. Meaning: *your destination is on the left* — exact.
**Proposed natural Nepali:**
> तपाईंको गन्तव्य देब्रेतिर छ।
**English meaning:**
> Your destination is on the left.
**TTS notes:**
"तपाईंको" = ta-pā-i~-ko. Fine.
**Confidence:** MEDIUM (both "छ" and "पर्छ" are natural; current is the shorter choice)

---

## humor_001

**Category:** language_tests
**Original/current text:** फेरि यही बाटो? पक्का? लौ, ठीकै छ, जाऔँ।
**Assessment:** KEEP
**Why:**
Reads as authentic spoken Nepali humor: "फेरि यही बाटो?" (this road again?) with
"पक्का?" (are you sure?) as a comic double-take, then "लौ, ठीकै छ, जाऔँ" (well, fine,
let's go). "लौ" is the right interjection here (not "ल"), and "जाऔँ" is the correct
inclusive "let's go". Nothing textbook or translated — a real Nepali passenger would say
this. Repetition tolerance is not a concern since this is a humor/test phrase, not a
frequent prompt. Meaning matches the humorous intent.
**Proposed natural Nepali:**
> फेरि यही बाटो? पक्का? लौ, ठीकै छ, जाऔँ।
**English meaning:**
> This road again? Really? Fine, let's go.
**TTS notes:**
"जाऔँ" is nasalized (jā-u~) — verify the voice renders the chandrabindu; "पक्का" =
pak-kā.
**Confidence:** MEDIUM (structure is clearly natural; humor register is subjective and
worth a native listen)

---

## long_001

**Category:** language_tests
**Original/current text:** अबको दोस्रो गल्लीबाट देब्रे मोड्नुहोस् र सीधै जानुहोस्। त्यसपछि पहिलो देब्रे मोड लिनुहोस्।
**Assessment:** KEEP
**Why:**
The structure is natural spoken Nepali: "अबको दोस्रो गल्लीबाट" ("from the second lane
from here") uses गल्ली the way Kathmandu drivers do for side streets; "देब्रे मोड्नुहोस्
र सीधै जानुहोस्" is natural (सीधै is the colloquial emphatic of सीधा); "त्यसपछि पहिलो
देब्रे मोड लिनुहोस्" uses the natural "मोड लिनुहोस्" (take the turn). The navigation
sequence — second lane, left, go straight, then first left — is preserved exactly. The
repeated देब्रे/मोड is what real speech does; it is not a problem. Optional tweak: "र" →
"अनि" ("...मोड्नुहोस्, अनि सीधै जानुहोस्") is marginally more conversational, but the
current form is already natural, so no change is proposed.
**Proposed natural Nepali:**
> अबको दोस्रो गल्लीबाट देब्रे मोड्नुहोस् र सीधै जानुहोस्। त्यसपछि पहिलो देब्रे मोड लिनुहोस्।
**English meaning:**
> Turn left from the second lane from here and go straight. Then take the first left turn.
**TTS notes:**
Long sentence — check pause placement at the full stop. "गल्लीबाट" = gal-lī-bāṭ;
"सीधै" = sī-dhai. Worth an audio listen given the sequence length.
**Confidence:** MEDIUM (natural; the complex sequence should be human-listened in audio)

---

# Final Summary

## Result counts

| Result | Count |
| --- | --- |
| KEEP | 20 |
| REVISE | 4 |
| UNCERTAIN | 1 |

Total reviewed: 25 (all `ne` phrases; `humor_002` excluded as the `ne-en` TTS test).

## Highest-risk phrases

Phrases where native-language confidence is lowest — these most need a native speaker's
ear:

- **redlight_camera_002** (LOW) — the "रातो बत्ती क्यामेरा" compound is a calque and
  the concept is new to Nepal; no settled natural phrasing exists.
- **roundabout_002** (MEDIUM) — राउन्डअबाउट vs गोलचक्कर; the choice affects
  distance_200m_001 too and should be decided once.
- **exit_002** (MEDIUM) — अगाडिको vs अर्को for "next exit".
- **arrival_002** (MEDIUM) — arrival register; आइपुग्नुभयो is warm but the sentence is
  on the polite side by design.
- **humor_001** (MEDIUM) — humor register is inherently subjective.
- **long_001** (MEDIUM) — long multi-turn sequence; needs an audio listen.
- **uturn_002** (MEDIUM) — लिनुहोस् vs गर्नुहोस् are both natural; pick one.

## Major changes recommended

1. **redlight_camera_002** — drop the "रातो बत्ती क्यामेरा" calque for a natural
   locative: "अगाडिको रातो बत्तीमा क्यामेरा छ।" (native confirmation still required).
2. **roundabout_002 and distance_200m_001** — prefer गोलचक्कर over राउन्डअबाउट: it is
   the established everyday Nepali word and avoids forcing English phonology through the
   Nepali voice. Keep both phrases consistent.
3. **exit_002** — "अगाडिको निकास" → "अर्को निकास" to match "take the *next* exit"
   exactly.
4. **distance_100m_002** — "एक सय मिटरपछि" → "सय मिटरपछि" (spoken number form; the
   multi-hundred forms are already correct).

## Phrases where current wording was retained

turn_left_001, turn_right_001, keep_left_002, continue_straight_002, uturn_002,
distance_500m_002, distance_1km_002, distance_300m_001, traffic_ahead_001,
traffic_heavy_002, accident_ahead_002, construction_002, road_closed_002,
speed_camera_001, speed_camera_002, police_002, arrival_002, arrival_005, humor_001,
long_001. These read as natural spoken Nepali with the correct driving meaning; several
have equal-naturalness alternatives that were judged not worth the churn.

## Translation principles discovered

Reusable principles for future Nepali navigation phrases:

- **Spoken before formal.** Prefer the everyday verb and construction ("बाटो बनिरहेको
  छ", "अगाडि X छ") over formal equivalents ("निर्माण भइरहेको छ"). Formal is a defect
  here, not a virtue.
- **"अगाडि X छ" is the natural warning template.** "अगाडि स्पिड क्यामेरा छ",
  "अगाडि दुर्घटना छ", "अगाडि ट्राफिक जाम छ" all follow it and all sound native.
- **Borrowed words are fine when they are the established spoken term** — स्पिड
  क्यामेरा, ट्राफिक, पुलिस. Do not force "pure Nepali" substitutes (प्रहरी, निर्माण)
  that sound like news language. Judge each loanword on actual usage.
- **...but calques of new concepts are risky.** A borrowed compound for a concept that
  barely exists in Nepal (रातो बत्ती क्यामेरा) has no natural footing — prefer a
  descriptive locative ("रातो बत्तीमा क्यामेरा छ"). Borrowing is fine; compounding a
  calque is not automatically fine.
- **Established Nepali words beat fresh English loans when both are in use** —
  गोलचक्कर over राउन्डअबाउट, with a TTS bonus: native phonology in the Nepali voice.
- **Spoken number forms:** a bare hundred is "सय" (सय मिटरपछि); multiples keep the
  multiplier (दुई/तीन/पाँच सय); "एक" is required for एक किलोमिटर.
- **Distinguish the maneuvers.** मोड्नुहोस् = turn; लाग्नुहोस् (X-तिर) = keep/bear;
  सीधा जानुहोस् = go straight; मोड/निकास लिनुहोस् = take the turn/exit. These are
  distinct driving meanings — naturalness rewording must never blur them.
- **Register is a product decision, not a language fix.** The polite -नुहोस्
  imperative is the right default for a navigation assistant; timi-forms (जाऊ, जाऔँ,
  छ है) belong only in explicitly conversational/personality phrases, and must be
  consistent within the phrase.
- **Don't add flavor particles mechanically.** ल, है, नि, भाइ are natural only where a
  real speaker would use them; adding them everywhere is the fast path to artificial
  "chummy" copy.
- **Short is better for repetition.** When two forms are equally natural, take the
  shorter one for prompts heard 20–50 times per drive (छ over पर्छ, सय over एक सय).
- **Naturalness rewording must preserve navigation meaning exactly.** Every proposed
  change above keeps the route information identical.
