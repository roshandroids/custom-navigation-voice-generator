"""Assemble an export bundle (ZIP) for a voice pack.

For each instruction with a generated audio clip (a cached ``/v1/audio`` url),
we package two variants:
- ``clean/``     — the WAV as synthesized (voice only);
- ``recording/`` — the same WAV with a 3 s leading silence prepended, ready for
  manual recording into Waze (the preparation delay belongs to this variant
  only, per the audio-standard decision — clean clips get no silence).

The result is written under ``benchmark/output/export/<packId>.zip`` and we
return the summary fields the frontend ``ExportBundle`` expects: pack name,
file count, and total byte counts. Instructions without a generated clip are
skipped. Each variant reports its own file count and byte total; the combined
``fileCount`` is the larger of the two and ``totalBytes`` the sum.
"""

from __future__ import annotations

import os
import tempfile
import zipfile
from pathlib import Path

from benchmark.core.audio import read_pcm16_mono, write_pcm16_mono
from server import cache as cache_mod

EXPORT_DIR = (
    Path(__file__).resolve().parents[1] / "benchmark" / "output" / "export"
)

SILENCE_SECONDS = 3.0


def _audio_asset_id(audio_url: str) -> str:
    return audio_url.rstrip("/").rsplit("/", 1)[-1].removesuffix(".wav")


def _prepend_silence(clean_wav: Path, silence_seconds: float) -> bytes:
    """Return the clean WAV with ``silence_seconds`` of leading silence."""
    samples, rate = read_pcm16_mono(clean_wav)
    combined = [0] * int(silence_seconds * rate) + samples
    fd, tmp = tempfile.mkstemp(suffix=".wav")
    os.close(fd)
    path = Path(tmp)
    try:
        write_pcm16_mono(path, combined, rate)
        return path.read_bytes()
    finally:
        path.unlink(missing_ok=True)


def build_bundle(
    pack: dict,
    instructions: list[dict],
    *,
    cache_dir: Path,
    output_root: Path,
    include_clean: bool = True,
    include_recording: bool = True,
    silence_seconds: float = SILENCE_SECONDS,
) -> dict:
    """Build a ZIP of the pack's generated clips and summarize it."""
    pack_id = pack["id"]
    output_root.mkdir(parents=True, exist_ok=True)
    zip_path = output_root / f"{pack_id}.zip"

    clean_names: list[str] = []
    recording_names: list[str] = []
    clean_bytes_total = 0
    recording_bytes_total = 0

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for instr in instructions:
            audio_url = instr.get("audioUrl")
            if not audio_url:
                continue
            clip = cache_mod.lookup(cache_dir, _audio_asset_id(audio_url))
            if clip is None:
                continue

            base = f"{pack_id}__{instr['id']}"
            if include_clean:
                clean_name = f"clean/{base}.wav"
                zf.write(clip, clean_name)
                clean_bytes_total += clip.stat().st_size
                clean_names.append(clean_name)
            if include_recording:
                rec = _prepend_silence(clip, silence_seconds)
                rec_name = f"recording/{base}.wav"
                zf.writestr(zipfile.ZipInfo(rec_name), rec)
                recording_bytes_total += len(rec)
                recording_names.append(rec_name)

    return {
        "packName": pack.get("name", pack_id),
        "fileCount": max(len(clean_names), len(recording_names)),
        "totalBytes": clean_bytes_total + recording_bytes_total,
        "zip": str(zip_path),
    }
