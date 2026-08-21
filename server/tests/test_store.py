"""Tests for the JSON-file-backed store (server.store)."""

from __future__ import annotations

from pathlib import Path

import pytest

from server.store import AppStore, StoreError


@pytest.fixture
def store_path(tmp_path: Path) -> Path:
    return tmp_path / "store.json"


def test_seeds_two_packs_with_instructions(store_path: Path):
    store = AppStore(store_path)
    packs = store.get_packs()
    assert {p["id"] for p in packs} == {"seed-ne", "seed-en"}

    ne = store.get_instructions("seed-ne")
    en = store.get_instructions("seed-en")
    assert len(ne) == 23
    assert len(en) == 22
    # First entries match the canonical corpus text + curated situation.
    assert ne[0]["id"] == "turn_left_001"
    assert ne[0]["situation"] == "बायाँ मोड"
    assert ne[0]["standardText"] == "देब्रे मोड्नुहोस्।"
    assert ne[0]["customText"] == ne[0]["standardText"]
    assert ne[0]["audioUrl"] is None
    assert ne[0]["isRecorded"] is False


def test_persistence_across_reloads(store_path: Path):
    store = AppStore(store_path)
    store.update_instruction("seed-ne", "turn_left_001", custom_text="मेरो आफ्नै।", is_recorded=True)
    store.attach_audio("seed-ne", "turn_left_001", "/v1/audio/test.wav")

    reloaded = AppStore(store_path, seed=False)  # file exists now; no reseed
    instr = reloaded.get_instruction("seed-ne", "turn_left_001")
    assert instr["customText"] == "मेरो आफ्नै।"
    assert instr["isRecorded"] is True
    assert instr["audioUrl"] == "/v1/audio/test.wav"
    assert reloaded.progress("seed-ne") == {"recorded": 1, "total": 23}


def test_create_pack_builds_instructions_for_language(store_path: Path):
    store = AppStore(store_path)
    created = store.create_pack("My English", "en", "joe", "firm")
    assert created["id"].startswith("pack-")
    assert created["language"] == "en"
    assert len(store.get_instructions(created["id"])) == 22


def test_missing_pack_raises(store_path: Path):
    store = AppStore(store_path)
    with pytest.raises(StoreError):
        store.get_pack("nope")
    with pytest.raises(StoreError):
        store.get_instructions("nope")


def test_missing_instruction_raises(store_path: Path):
    store = AppStore(store_path)
    with pytest.raises(StoreError):
        store.get_instruction("seed-ne", "nope")
