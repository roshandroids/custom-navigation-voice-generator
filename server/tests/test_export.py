"""Tests for the export bundle builder (server.export)."""

from __future__ import annotations

import zipfile
from pathlib import Path

from server import cache as cache_mod
from server.export import _prepend_silence, build_bundle
from server.tests.conftest import write_tiny_wav


def _seed_cache(cache_dir: Path, text: str, voice: str, seconds: float = 0.5) -> Path:
    path = cache_mod.cache_path(cache_dir, text, voice)
    write_tiny_wav(path, seconds=seconds, sample_rate=22050)
    return path


def _pack_and_instructions(cache_dir: Path) -> tuple[dict, list[dict]]:
    clip_a = _seed_cache(cache_dir, "turn left", "joe")
    clip_b = _seed_cache(cache_dir, "speed camera", "joe")
    asset_a = f"/v1/audio/{clip_a.stem}.wav"
    asset_b = f"/v1/audio/{clip_b.stem}.wav"
    return {"id": "pack-1", "name": "My Pack"}, [
        {"id": "i1", "audioUrl": asset_a},
        {"id": "i2", "audioUrl": asset_b},
        {"id": "i3", "audioUrl": None},  # no audio -> skipped
    ]


def test_build_bundle_zips_clean_and_recording(tmp_path: Path):
    cache_dir = tmp_path / "cache"
    pack, instructions = _pack_and_instructions(cache_dir)
    output_root = tmp_path / "out"

    bundle = build_bundle(pack, instructions, cache_dir=cache_dir, output_root=output_root)

    assert bundle["packName"] == "My Pack"
    assert bundle["fileCount"] == 2  # two instructions have audio
    zip_path = output_root / "pack-1.zip"
    assert zip_path.exists()
    with zipfile.ZipFile(zip_path) as zf:
        names = zf.namelist()
        assert len(names) == 4  # 2 clean + 2 recording
        assert "clean/pack-1__i1.wav" in names
        assert "recording/pack-1__i1.wav" in names
        assert all(n.startswith(("clean/", "recording/")) for n in names)
        assert zf.testzip() is None


def test_recording_clip_has_prepended_silence(tmp_path: Path):
    cache_dir = tmp_path / "cache"
    clip = _seed_cache(cache_dir, "turn left", "joe", seconds=0.5)
    rec = _prepend_silence(clip, silence_seconds=2.0)
    # 44-byte RIFF header + (0.5s clean + 2s silence) @ 22050 Hz mono PCM16.
    assert len(rec) == 44 + int(2.5 * 22050 * 2)


def test_build_bundle_excludes_clean_only_when_requested(tmp_path: Path):
    cache_dir = tmp_path / "cache"
    pack, instructions = _pack_and_instructions(cache_dir)
    output_root = tmp_path / "out"

    bundle = build_bundle(
        pack,
        instructions,
        cache_dir=cache_dir,
        output_root=output_root,
        include_clean=False,
        include_recording=True,
    )
    assert bundle["fileCount"] == 2
    with zipfile.ZipFile(output_root / "pack-1.zip") as zf:
        assert all(n.startswith("recording/") for n in zf.namelist())


def test_build_bundle_skips_missing_clips(tmp_path: Path):
    cache_dir = tmp_path / "cache"
    pack = {"id": "pack-1", "name": "P"}
    # audioUrl whose cache file does not exist.
    instructions = [{"id": "i1", "audioUrl": "/v1/audio/nope.wav"}]
    output_root = tmp_path / "out"

    bundle = build_bundle(pack, instructions, cache_dir=cache_dir, output_root=output_root)
    assert bundle["fileCount"] == 0
    assert bundle["totalBytes"] == 0
