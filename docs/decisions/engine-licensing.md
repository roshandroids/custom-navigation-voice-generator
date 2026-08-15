# Engine Licensing — Research Record

**Status: research notes, not legal advice.**
This document records *source URLs* and *license facts we could verify* for each
candidate engine. It deliberately separates **source code license**, **model/weights
license**, **voice license**, and **dataset restrictions**, because "open source
repository" does not imply "commercially usable model". Where we could not verify
something, it is explicitly marked **UNKNOWN — REQUIRES VERIFICATION**. Nothing here
is a legal conclusion; verify with the license texts (links included) before any
commercial use.

Research date: 2026-08-15.

---

## Piper

> **Update (2026-08-15, verified at experiment time):** the current `pip install
> piper-tts` package (v1.6.1) is **GPL-3.0-or-later** and points to the
> `OHF-Voice/piper1-gpl` fork. The MIT `rhasspy/piper` repo is archived. The earlier
> note "the pip package is the MIT version" is **outdated** — see the reversal below.

| Item                | Finding | Source |
| ------------------- | ------- | ------ |
| Source code license | **GPL-3.0-or-later** for the maintained package (piper-tts 1.6.1 → `OHF-Voice/piper1-gpl`). Original `rhasspy/piper` is **MIT** but **archived** (Oct 2025). | PyPI `piper-tts` 1.6.1 metadata (License: GPL-3.0-or-later, Home-page: github.com/OHF-voice/piper1-gpl); https://github.com/OHF-Voice/piper1-gpl |
| Repository status   | `rhasspy/piper` archived (read-only). Active maintenance in `OHF-Voice/piper1-gpl` (GPL-3.0), which is looking for maintainers. | https://github.com/OHF-Voice/piper1-gpl |
| Model/weights license | Voice models on `huggingface.co/rhasspy/piper-voices` (repo license: **MIT**) — **per-voice** licensing lives in each voice's MODEL_CARD. Piper itself imposes no additional voice restrictions. | https://huggingface.co/rhasspy/piper-voices |
| Voice license (ne_NP-chitwan-medium) | **Dataset CC0** (from OHF-Voice/voice-datasets). Trained by finetuning U.S. English lessac voice. Model card lists no additional voice-level license beyond CC0 dataset. **Interpretation of CC0 for commercial use is a legal question — not concluded here.** | https://huggingface.co/rhasspy/piper-voices/blob/main/ne/ne_NP/chitwan/medium/MODEL_CARD |
| Voice license (ne_NP-google-medium) | **Dataset CC-BY-SA-4.0** (OpenSLR 43). 18 speakers, 22,050 Hz. Finetuned from U.S. English lessac. **CC-BY-SA is share-alike — implications for derivative/commercial use require legal review. Not concluded here.** | https://huggingface.co/rhasspy/piper-voices/blob/main/ne/ne_NP/google/medium/MODEL_CARD |
| Voice license (ne_NP-google-x_low) | **Dataset CC-BY-SA-4.0** (OpenSLR 43). 18 speakers, 16,000 Hz. Trained from scratch. **Share-alike — same review note as google-medium.** | https://huggingface.co/rhasspy/piper-voices/blob/main/ne/ne_NP/google/x_low/MODEL_CARD |
| Dataset restrictions | chitwan: **CC0** dataset. google-medium / google-x_low: **CC-BY-SA-4.0** dataset (share-alike). | per-voice MODEL_CARDs (above) |
| Commercial use       | GPL-3.0 code: copyleft obligations for distribution. Voice models: chitwan **CC0** dataset; google voices **CC-BY-SA-4.0** dataset (share-alike). **No legal conclusion.** | — |
| Attribution          | GPL requires preserving license notices. Voice-level attribution per MODEL_CARD (chitwan: CC0). | — |

**Reversal (2026-08-15):** the claim "the `pip install piper-tts` package is the MIT
version" is **no longer true** — current PyPI piper-tts 1.6.1 is GPL-3.0-or-later from
the OHF-Voice fork. This changes the licensing picture for any distributed product that
embeds/redistributes the Piper code (GPL copyleft). For internal benchmarking use this
has no immediate practical effect; for product distribution a review is required.

---

## Kokoro

| Item                | Finding | Source |
| ------------------- | ------- | ------ |
| Source code license | **Apache-2.0** (hexgrad/kokoro `LICENSE`) | https://github.com/hexgrad/kokoro/blob/main/LICENSE |
| Model/weights license | **Apache-2.0** (HF model card `License: apache-2.0`; card explicitly welcomes commercial deployment) | https://huggingface.co/hexgrad/Kokoro-82M |
| Voice license        | Voices ship inside `voices-v1.0.bin` with the model — covered by the Apache-2.0 model license. Individual voice provenance (trained on CC BY audio — see below) may still matter. | https://huggingface.co/hexgrad/Kokoro-82M/VOICES.md |
| Dataset restrictions | Model card discloses **CC BY** audio in training data (Koniwa <1h CC BY 3.0; SIWIS <11h CC BY 4.0) and states the rest is permissive/non-copyrighted. CC BY in training data may imply attribution obligations for derivative redistribution — legal review advised. | https://huggingface.co/hexgrad/Kokoro-82M (Creative Commons Attribution section) |
| Commercial use       | Apache-2.0: permitted, with attribution/notice obligations. | — |
| Attribution          | Apache-2.0 requires license notice; CC BY data attribution may also apply. | — |

---

## Qwen3-TTS

| Item                | Finding | Source |
| ------------------- | ------- | ------ |
| Source code license | **Apache-2.0** (QwenLM/Qwen3-TTS `LICENSE`, © 2026 Alibaba Cloud) | https://github.com/QwenLM/Qwen3-TTS/blob/main/LICENSE |
| Model/weights license | **Apache-2.0** (HF model card `License: apache-2.0` for `Qwen3-TTS-12Hz-1.7B-Base`) | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base |
| Voice license        | Voice *cloning/design* is a model capability; no separate voice files. Prebuilt speaker identities (Vivian, Ryan, …) come with the model. **UNKNOWN — REQUIRES VERIFICATION** whether cloned voices carry additional restrictions. | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base |
| Dataset restrictions | **UNKNOWN — REQUIRES VERIFICATION** (training-data license details not recorded here). | — |
| Commercial use       | Apache-2.0 per model card. Note the model card lists **10 languages only** — Nepali is NOT among them; use is technically permitted but quality for Nepali is unproven. | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base |
| Attribution          | Apache-2.0 requires license notice for code and model use. | — |

---

## Chatterbox

| Item                | Finding | Source |
| ------------------- | ------- | ------ |
| Source code license | **MIT** (resemble-ai/chatterbox `LICENSE`, © 2025 Resemble AI) | https://github.com/resemble-ai/chatterbox/blob/master/LICENSE |
| Model/weights license | **MIT** (HF model card `License: mit`; Resemble page confirms "MIT-licensed") | https://huggingface.co/ResembleAI/chatterbox; https://www.resemble.ai/learn/models/chatterbox |
| Voice license        | Voice cloning is a model capability (reference audio prompt); no separate voice files. **UNKNOWN — REQUIRES VERIFICATION** for cloned-voice use. | — |
| Dataset restrictions | Model card: "Prompts are sourced from freely available data on the internet." **UNKNOWN — REQUIRES VERIFICATION** (no detailed dataset license breakdown found). | https://huggingface.co/ResembleAI/chatterbox |
| Commercial use       | MIT: permitted. **Caveat: every generated file is watermarked** with Resemble's Perth watermarker — product and legal implications for a voice-pack export feature. | https://huggingface.co/ResembleAI/chatterbox |
| Attribution          | MIT requires license notice for code. | — |

---

## Cross-engine summary

| Engine      | Code | Weights | Nepali? | Watch items |
| ----------- | ---- | ------- | ------- | ----------- |
| Piper       | **GPL-3.0** (maintained); MIT (archived) | per-voice | ✅ official voices | GPL-3.0 code copyleft; chitwan CC0; google voices UNKNOWN |
| Kokoro      | Apache-2.0 | Apache-2.0 | ❌ | CC BY training data attribution |
| Qwen3-TTS   | Apache-2.0 | Apache-2.0 | ❌ (10 langs) | Nepali unproven; voice-clone terms UNKNOWN |
| Chatterbox  | MIT | MIT | ❌ (23 langs, no Nepali) | Perth watermark on output; Hindi finetune exists |

## Decisions needed from a human (no conclusions drawn here)

1. Does the product need **commercial use** of the winning engine? (MIT/Apache-2.0
   code + weights are permissive; Piper voice models and Kokoro's CC BY data need
   per-item review.)
2. Piper: MIT-archived vs GPL-active fork — which do we build on?
3. Chatterbox's built-in watermarking vs. clean audio for a voice-pack product.
4. Voice-cloning terms for Qwen3-TTS and Chatterbox (if voice cloning becomes a feature).

## Verification checklist (re-run before relying on any license)

- [ ] Re-fetch each linked LICENSE file (licenses can change).
- [ ] For Piper: check the MODEL_CARD of every voice we actually ship.
- [ ] For Qwen3-TTS: confirm the weights license on the exact model artifact
      (HF card said apache-2.0; verify at download time).
- [ ] For Kokoro: obtain legal view on CC BY training-data attribution.
- [ ] For Chatterbox: confirm watermarking terms and dataset licensing.
