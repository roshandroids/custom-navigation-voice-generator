# Nepali Waze Voice-Pack Review — Independent Natural-Language Check

**Scope:** The 43 Nepali (`ne`) phrases in
[`benchmark/corpus/waze_voicepack.json`](../benchmark/corpus/waze_voicepack.json) —
the exact "Record your own voice" script from the Waze app's Nepali voice screen
(Start of drive, Distances, Instructions, Reports, Other). English phrases are the
fixed source meaning and are not re-judged here.

**Method:** Same as [`nepali-human-review-v2.md`](./nepali-human-review-v2.md) — every
phrase judged on natural spoken Nepali a driver/passenger would actually use, not
textbook grammar. These phrases were authored by me in the same session as this
review, so this is a self-critical second pass, not a rubber stamp — several issues
below are fixes to my own first draft. **REVISE items have already been applied** to
`waze_voicepack.json` and the affected audio has been regenerated; this document
records the reasoning.

---

## Overview

| ID | Waze group | Nepali text | Assessment |
| --- | --- | --- | --- |
| wz_start_allset_ne | Start of drive | भयो, जाऔं! | KEEP |
| wz_start_wereallset_ne | Start of drive | सबै तयार भयो, जाऔं! | KEEP |
| wz_start_startdriving_ne | Start of drive | गाडी बढाउनुहोस्। | REVISE (applied) |
| wz_start_getstarted_ne | Start of drive | अब सावधानीसाथ जाऔं! | KEEP |
| wz_start_hittheroad_ne | Start of drive | भयो, बाटो लागौं! | KEEP |
| wz_start_youready_ne | Start of drive | तयार हुनुभयो? म तयार छु! जाऔं! | KEEP |
| wz_start_readytoroll_ne | Start of drive | हामी तयार छौं, होसियारीसाथ जाऔं! | REVISE (applied) |
| wz_start_pleasantdrive_ne | Start of drive | तपाईंको यात्रा शुभ होस्! | KEEP |
| wz_start_herewego_ne | Start of drive | लौ, जाऔं! | KEEP |
| wz_dist_01mi_ne | Distances | पोइन्ट एक माइलपछि। | UNCERTAIN |
| wz_dist_qtrmi_ne | Distances | पाव माइलपछि। | KEEP |
| wz_dist_halfmi_ne | Distances | आधा माइलपछि। | KEEP |
| wz_dist_1mi_ne | Distances | एक माइलपछि। | KEEP |
| wz_dist_200m_ne | Distances | दुई सय मिटरपछि। | KEEP |
| wz_dist_400m_ne | Distances | चार सय मिटरपछि। | KEEP |
| wz_dist_800m_ne | Distances | आठ सय मिटरपछि। | KEEP |
| wz_dist_1km_ne | Distances | एक किलोमिटरपछि। | KEEP |
| wz_dist_15km_ne | Distances | डेढ किलोमिटरपछि। | KEEP |
| wz_instr_keepleft_ne | Instructions | देब्रेतिर लाग्नुहोस्। | KEEP |
| wz_instr_keepright_ne | Instructions | दायाँतिर लाग्नुहोस्। | KEEP |
| wz_instr_turnleft_ne | Instructions | देब्रे मोड्नुहोस्। | KEEP |
| wz_instr_turnright_ne | Instructions | दायाँ मोड्नुहोस्। | KEEP |
| wz_instr_exitleft_ne | Instructions | देब्रेबाट बाहिर निस्कनुहोस्। | KEEP |
| wz_instr_exitright_ne | Instructions | दायाँबाट बाहिर निस्कनुहोस्। | KEEP |
| wz_instr_continuestraight_ne | Instructions | सीधा जानुहोस्। | KEEP |
| wz_instr_uturn_ne | Instructions | यू-टर्न लिनुहोस्। | KEEP |
| wz_instr_atroundabout_ne | Instructions | राउन्डअबाउटमा। | KEEP |
| wz_instr_exit1_ne … exit7_ne | Instructions | पहिलो … सातौं बाटोबाट निस्कनुहोस्। | KEEP |
| wz_report_police_ne | Reports | अगाडि पुलिस छ। | KEEP |
| wz_report_crash_ne | Reports | अगाडि दुर्घटना छ। | KEEP |
| wz_report_hazard_ne | Reports | अगाडि खतरा छ। | KEEP |
| wz_report_heavytraffic_ne | Reports | बाटोमा धेरै ट्राफिक छ। | KEEP |
| wz_report_redlightcam_ne | Reports | अगाडि रातो बत्तीमा क्यामेरा छ। | KEEP |
| wz_report_speedcam_ne | Reports | अगाडि स्पिड क्यामेरा छ। | KEEP |
| wz_other_andthen_ne | Other | अनि | KEEP |
| wz_other_rerouting_ne | Other | नयाँ बाटो खोजिँदैछ। | REVISE (applied) |
| wz_other_arrived_ne | Other | तपाईं आइपुग्नुभयो। | KEEP |

---

## Phrases with findings

### wz_start_startdriving_ne — REVISE (applied)
**Was:** गाडी चलाउनुहोस्। ("drive the car")
**Now:** गाडी बढाउनुहोस्। ("move the car forward / get going")
**Why:** चलाउनुहोस् literally instructs "operate/drive the car" — reads like a stiff,
translated command, and it's stating the obvious to someone who is about to drive
anyway. बढाउनुहोस् is the natural cue Nepali speakers actually give to tell someone
to start moving a vehicle (a driver/conductor telling someone "गाडी बढाऊ").
**Confidence:** MEDIUM — both are understood; बढाउनुहोस् is the more natural kick-off cue.

### wz_start_readytoroll_ne — REVISE (applied)
**Was:** हामी तयार छौं, सावधानीसाथ चलाऔं! ("we're ready, let's drive carefully")
**Now:** हामी तयार छौं, होसियारीसाथ जाऔं! ("we're ready, let's go carefully")
**Why:** चलाउनु ("to drive/operate") is transitive — it wants a stated object
(गाडी चलाऔं, "let's drive the car"). Used alone as चलाऔं, it reads slightly
incomplete ("drive... what?"). जाऔं ("let's go") is the natural intransitive
cohortative Nepali speakers use for "let's get going" without needing an object.
**Confidence:** MEDIUM-HIGH.

### wz_dist_01mi_ne — UNCERTAIN
**Text:** पोइन्ट एक माइलपछि। ("point one mile[s] later")
**Why:** पोइन्ट (borrowed "point") is genuinely used for decimals in some spoken
contexts (exam scores, cricket stats), and माइल is accepted as a loanword elsewhere
in this file. But "0.1 miles" (~160m) as a distance marker has no real precedent in
Nepali speech at all — Nepal doesn't use miles, and no Nepali speaker has ever needed
to say a tenth-of-a-mile distance out loud. I can't honestly claim confidence this is
"what a Nepali speaker would say," because there is nothing to check it against.
**Confidence:** LOW — flagging rather than asserting naturalness I can't verify.

### wz_other_rerouting_ne — REVISE (applied)
**Was:** नयाँ बाटो खोज्दैछौं। ("we're searching for a new route")
**Now:** नयाँ बाटो खोजिँदैछ। ("a new route is being searched for")
**Why:** The English source "Rerouting" is a neutral, impersonal single-word status
announcement — not a personality/conversational line. छौं ("we") quietly injects a
companionable "we're in this together" tone that wasn't asked for. The corpus
principle is to add personality only where a phrase is *deliberately* conversational
(see `nepali-human-review-v2.md`'s note on discourse markers) — this isn't one of
those, so the impersonal/passive form matches the source's register better.
**Confidence:** MEDIUM.

### wz_dist_qtrmi_ne — KEEP (noted)
**Text:** पाव माइलपछि।
**Why:** पाव ("quarter") is a solid, everyday quantifier (पाव किलो, "quarter kilo")
that generalizes naturally to any unit — more confident than the 0.1-mile case above
because पाव is a broadly used pattern, not a novel one-off borrowing.
**Confidence:** MEDIUM (construction is natural; माइल itself is rare in Nepal, same
caveat as the rest of the distance-in-miles set).

### wz_instr_exitleft_ne / wz_instr_exitright_ne — KEEP (noted)
**Text:** देब्रेबाट/दायाँबाट बाहिर निस्कनुहोस्।
**Why:** बाहिर निस्कनु ("to come/go outside") is a completely standard Nepali
phrasal verb, not redundant — it correctly distinguishes "exit" from "turn"
(मोड्नुहोस्). No established idiom exists to check this against, though, since a
highway "exit lane to the left/right" (as opposed to a turn) is not a common concept
on Nepali roads.
**Confidence:** MEDIUM — sound construction, but genuinely novel territory.

### wz_report_redlightcam_ne — KEEP (already the fixed form)
**Text:** अगाडि रातो बत्तीमा क्यामेरा छ।
**Why:** This reuses the locative fix (रातो बत्तीमा, "at the red light") proposed
for `redlight_camera_002` in `nepali-human-review-v2.md`, instead of repeating the
रातो बत्ती क्यामेरा compound-noun calque. It's already the best version found so
far, not a new revision.
**Confidence:** MEDIUM — same caveat as before: red-light-camera enforcement isn't a
familiar concept for most Nepali drivers yet, so there's no deep idiom to confirm
against.

---

## Everything else: KEEP, high confidence

The remaining 33 phrases either reuse forms already validated in
`nepali-human-review-v2.md` (turn/keep/continue/U-turn, police/crash/traffic/speed-camera,
आइपुग्नुभयो for arrival) or are straightforward, unambiguous natural Nepali with no
register issue: the ordinal exit series (पहिलो…सातौं बाटोबाट निस्कनुहोस्), the सय/किलोमिटर
distance set (200m/400m/800m/1km — डेढ for 1.5km is a particularly strong natural
choice, avoiding a decimal calque), खतरा for hazard, and the casual Start-of-drive
lines (भयो/लौ/जाऔं family).

---

## Summary

| Result | Count |
| --- | --- |
| KEEP | 39 |
| REVISE (applied) | 3 |
| UNCERTAIN | 1 |

**Highest-risk phrase:** `wz_dist_01mi_ne` (LOW confidence) — "0.1 miles" has no
natural spoken precedent in Nepali at all; a native speaker should confirm पोइन्ट एक
माइल is actually said, or propose an alternative.

**Runner-up risk:** `wz_instr_exitleft_ne` / `wz_instr_exitright_ne` and
`wz_report_redlightcam_ne` — all MEDIUM confidence, sound constructions applied to
concepts (highway exit lanes, red-light cameras) that aren't yet common in everyday
Nepali driving, so there's less real-world idiom to check them against.

**Fixes applied this pass:**
1. `wz_start_startdriving_ne`: गाडी चलाउनुहोस् → गाडी बढाउनुहोस् (natural "get going" cue, not a literal "operate the car" command).
2. `wz_start_readytoroll_ne`: ...चलाऔं → ...जाऔं (transitive verb without an object read incomplete).
3. `wz_other_rerouting_ne`: ...खोज्दैछौं ("we") → ...खोजिँदैछ (impersonal, matching the neutral register of the English source status word).

Audio for these 3 phrases was regenerated across all 3 Nepali Piper voices after the
text fix (`benchmark/output/waze/piper/<voice>/wz_start_startdriving_ne.wav`, etc.).

**Translation principles reinforced from this pass:**
- Don't add unprompted personality/warmth (a "we" framing, extra politeness) to a
  phrase whose English source is a neutral system-status word — save that register
  shift for phrases that are deliberately conversational.
- Transitive verbs like चलाउनु ("to drive/operate something") read incomplete in
  Nepali without a stated object; prefer an intransitive cohortative (जाऔं) when the
  object would otherwise be implied/omitted.
- Be willing to say UNCERTAIN/LOW confidence when a phrase describes something with
  literally no precedent in everyday Nepali speech (e.g. a tenth of a mile) rather
  than asserting a confident-sounding construction has no real basis to check against.

*Reviewer note: as with `nepali-human-review-v2.md`, this is a self-review, not
native-speaker sign-off. All entries — especially the UNCERTAIN and MEDIUM-confidence
ones — should get a real native speaker's listen-through before this voice pack is recorded into Waze.*
