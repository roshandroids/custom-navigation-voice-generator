---
id: piper-performance-baseline
title: "Piper M1 CPU performance baseline (2026-08-15)"
category: reference
status: active
created: "2026-08-15T02:34:54"
updated: "2026-08-15T02:35:33"
---

<!-- compiled_truth -->
# Piper M1 CPU performance baseline

Measured 2026-08-15 on Apple M1 (8 cores, 16 GB RAM, CPU inference), piper-tts 1.6.1 (GPL-3.0 OHF-Voice fork), 50-phrase benchmark corpus. One piper subprocess per phrase.

| Voice | avg gen/phrase | avg audio dur | real-time factor (gen/audio) |
|---|---|---|---|
| ne_NP-chitwan-medium | 0.57 s | 2.04 s | 0.32 |
| ne_NP-google-medium | 0.73 s | 2.04 s | 0.43 |
| ne_NP-google-x_low | 0.69 s | 1.92 s | 0.44 |

- All three voices: 50/50 phrases succeeded (150/150 total), 0 failures.
- **Real-time factor < 1.0 for all voices** — faster than real time on M1 CPU.
- Wall-clock for a full 50-phrase voice run: ~34 s (includes ~50 process startups; ~0.5-0.6 s cold startup each).
- Peak RSS: ~234 MB per piper process.
- Audio format: mono 16-bit PCM WAV; chitwan + google-medium at 22,050 Hz, google-x_low at 16,000 Hz (voice config determines rate).
- Note: piper CLI has **no sample-rate flag** — output rate is fixed by the voice model config.

Caveat: generation time per phrase includes subprocess startup; a long-running server process would amortize it. See [[piper-nepali-voices]].


## Timeline

- time: 2026-08-15T02:34:54
  kind: decision
  summary: "Created this page: Piper M1 CPU performance baseline (2026-08-15)"
  source: piper experiment 2026-08-15
  affects: [piper-performance-baseline]

- time: 2026-08-15T02:35:33
  kind: decision
  summary: performance baseline from experiment
  source: piper experiment 2026-08-15
  affects: [piper-performance-baseline]
