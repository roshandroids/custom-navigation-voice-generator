---
id: piper-nepali-voices
title: "Research finding: Piper has identifiable Nepali voices — first candidate for real-audio testing"
category: decision
status: active
created: "2026-08-15T02:14:41"
updated: "2026-08-15T02:34:54"
---

<!-- compiled_truth -->
# Verified: Piper has working Nepali voices

**Verified by experiment (2026-08-15) on Apple M1 (CPU):** Piper successfully generates Nepali speech from Devanagari text with all three official ne_NP voices:

- `ne_NP-chitwan-medium` — 22,050 Hz, 1 speaker, dataset CC0
- `ne_NP-google-medium` — 22,050 Hz, 18 speakers, dataset CC-BY-SA-4.0
- `ne_NP-google-x_low` — 16,000 Hz, 18 speakers, dataset CC-BY-SA-4.0

Result: 50/50 benchmark phrases succeeded per voice (150/150 total) with Devanagari input preserved — **no Latin-script fallback needed for Piper**.

This is a **capability verification, NOT a final engine-selection decision** — speech quality, pronunciation, and navigation clarity are still unproven until human listening evaluation. See [[tts-candidates]], [[engine-selection-pending]], [[piper-performance-baseline]].

Blast radius: Piper is confirmed as the working baseline for the benchmark; the remaining question is quality, not viability.


## Timeline

- time: 2026-08-15T02:14:41
  kind: decision
  summary: "Created this page: Research finding: Piper has identifiable Nepali voices — first candidate for real-audio testing"
  source: "web research 2026-08-15 (rhasspy/piper VOICES.md)"
  affects: [piper-nepali-voices]

- time: 2026-08-15T02:14:41
  kind: decision
  summary: verified from rhasspy/piper VOICES.md
  source: web research 2026-08-15
  affects: [piper-nepali-voices]

- time: 2026-08-15T02:34:32
  kind: evidence
  summary: "VERIFIED 2026-08-15: all three ne_NP voices (chitwan-medium, google-medium, google-x_low) download, load, and synthesize Devanagari text into valid WAVs on M1 CPU. 50/50 phrases succeeded per voice. Piper runs the full benchmark."
  source: piper experiment 2026-08-15
  affects: [piper-nepali-voices, tts-candidates]

- time: 2026-08-15T02:34:54
  kind: decision
  summary: "voice availability verified by experiment; research finding upgraded to verified"
  source: piper experiment 2026-08-15
  affects: [piper-nepali-voices]
