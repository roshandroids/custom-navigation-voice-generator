"""Tests for corpus loading and validation."""

from __future__ import annotations

import json

import pytest

from benchmark.core.corpus import (
    DEVANAGARI_RE,
    CorpusError,
    corpus_stats,
    load_corpus,
)


def test_loads_valid_corpus(corpus_path):
    phrases = load_corpus(corpus_path)
    assert len(phrases) == 2
    assert phrases[0].id == "turn_left_001"
    assert phrases[0].category == "directions"
    assert phrases[0].language == "ne"
    assert phrases[0].tts_text == "Debre modnuhos."
    assert phrases[1].id == "speed_camera_001"


def test_bundled_corpus_is_valid_and_has_stable_ids(real_corpus_path):
    phrases = load_corpus(real_corpus_path)
    assert len(phrases) >= 40, "corpus should have ~40-50 phrases"
    assert len({p.id for p in phrases}) == len(phrases), "IDs must be unique"

    # IDs must be stable: deterministic function of the file content.
    first = load_corpus(real_corpus_path)
    second = load_corpus(real_corpus_path)
    assert [p.id for p in first] == [p.id for p in second]


def test_duplicate_ids_rejected(tmp_path):
    phrases = [
        {
            "id": "turn_left_001",
            "category": "directions",
            "language": "en",
            "text": "Turn left.",
        },
        {
            "id": "turn_left_001",
            "category": "directions",
            "language": "en",
            "text": "Turn left again.",
        },
    ]
    path = tmp_path / "dup.json"
    path.write_text(json.dumps({"phrases": phrases}), encoding="utf-8")
    with pytest.raises(CorpusError, match="duplicate phrase id"):
        load_corpus(path)


def test_missing_required_field_rejected(tmp_path):
    path = tmp_path / "bad.json"
    path.write_text(
        json.dumps({"phrases": [{"id": "x_001", "language": "en", "text": "hi"}]}),
        encoding="utf-8",
    )
    with pytest.raises(CorpusError, match="missing required field"):
        load_corpus(path)


def test_invalid_language_rejected(tmp_path):
    path = tmp_path / "bad.json"
    path.write_text(
        json.dumps(
            {"phrases": [{"id": "x_001", "category": "directions", "language": "xx", "text": "hi"}]}
        ),
        encoding="utf-8",
    )
    with pytest.raises(CorpusError, match="invalid language"):
        load_corpus(path)


def test_invalid_category_rejected(tmp_path):
    path = tmp_path / "bad.json"
    path.write_text(
        json.dumps(
            {"phrases": [{"id": "x_001", "category": "nonsense", "language": "en", "text": "hi"}]}
        ),
        encoding="utf-8",
    )
    with pytest.raises(CorpusError, match="invalid category"):
        load_corpus(path)


def test_invalid_id_format_rejected(tmp_path):
    path = tmp_path / "bad.json"
    entry = {"id": "Bad ID!", "category": "directions", "language": "en", "text": "hi"}
    path.write_text(json.dumps({"phrases": [entry]}), encoding="utf-8")
    with pytest.raises(CorpusError, match="invalid id"):
        load_corpus(path)


def test_devanagari_without_tts_text_rejected(tmp_path):
    path = tmp_path / "bad.json"
    path.write_text(
        json.dumps(
            {
                "phrases": [
                    {
                        "id": "x_001",
                        "category": "directions",
                        "language": "ne",
                        "text": "देब्रे मोड्नुहोस्।",
                    }
                ]
            }
        ),
        encoding="utf-8",
    )
    with pytest.raises(CorpusError, match="tts_text"):
        load_corpus(path)


def test_missing_file_raises(tmp_path):
    with pytest.raises(CorpusError, match="not found"):
        load_corpus(tmp_path / "nope.json")


def test_invalid_json_raises(tmp_path):
    path = tmp_path / "bad.json"
    path.write_text("{not json", encoding="utf-8")
    with pytest.raises(CorpusError, match="not valid JSON"):
        load_corpus(path)


def test_extra_fields_are_preserved(corpus_path):
    phrases = load_corpus(corpus_path)
    assert phrases[0].tags == ()
    assert phrases[0].extra == {}


def test_corpus_stats(real_corpus_path):
    phrases = load_corpus(real_corpus_path)
    stats = corpus_stats(phrases)
    assert stats["total"] == len(phrases)
    assert set(stats["categories"]) == {
        "directions", "distances", "traffic", "enforcement", "arrival", "language_tests",
    }
    assert set(stats["languages"]) == {"ne", "en", "ne-en"}


def test_devanagari_regex():
    assert DEVANAGARI_RE.search("देब्रे मोड्नुहोस्।")
    assert not DEVANAGARI_RE.search("Turn left.")
