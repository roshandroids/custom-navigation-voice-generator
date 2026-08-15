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

| Item                | Finding | Source |
| ------------------- | ------- | ------ |
| Source code license | **MIT** (rhasspy/piper `LICENSE.md`, © 2022 Michael Hansen) | https://github.com/rhasspy/piper/blob/master/LICENSE.md |
| Repository status   | **Archived** (read-only since Oct 2025). Dev moved to `OHF-Voice/piper1-gpl` — a **GPL** fork. | https://github.com/rhasspy/piper |
| Model/weights license | **Per-voice MODEL_CARD.** Piper's README states Piper is intended for TTS research and imposes no additional restrictions on voice models; each voice's licensing lives in its own MODEL_CARD file. Individual voices may carry their own licenses (e.g. dataset-derived restrictions). | https://github.com/Bigbynth/piper-tts (MODEL_CARD note); https://github.com/rhasspy/piper#voices |
| Voice license        | Same as above — per-voice, must be checked for the specific voice (e.g. `ne_NP-chitwan-medium`). **UNKNOWN — REQUIRES VERIFICATION** per voice. | https://huggingface.co/rhasspy/piper-voices |
| Dataset restrictions | Voices trained on various datasets (e.g. Common Voice, LJSpeech, MLS); restrictions, if any, follow each voice's MODEL_CARD. **UNKNOWN — REQUIRES VERIFICATION** per voice. | — |
| Commercial use       | MIT code: permitted. GPL fork: copyleft implications. Voice models: depends on each MODEL_CARD. | — |
| Attribution          | MIT requires license notice for code. Voice-level attribution per MODEL_CARD. | — |

**Notes:**
- The `pip install piper-tts` package (used by this repo's adapter) is the MIT version.
- If the project later adopts the actively-developed piper1-gpl fork, the GPL license
  has real implications for a commercial app — decision required.

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
| Piper       | MIT (archived); GPL fork | per-voice | ✅ official voices | per-voice MODEL_CARDs; archived upstream |
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
