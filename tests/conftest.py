"""Shared fixtures for benchmark tests."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

# Make the repo importable without installation.
REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from benchmark import engines  # noqa: E402,F401  (import registers all adapters)


@pytest.fixture
def corpus_path(tmp_path: Path) -> Path:
    phrases = [
        {
            "id": "turn_left_001",
            "category": "directions",
            "language": "ne",
            "text": "देब्रे मोड्नुहोस्।",
            "tts_text": "Debre modnuhos.",
        },
        {
            "id": "speed_camera_001",
            "category": "enforcement",
            "language": "en",
            "text": "Speed camera ahead.",
        },
    ]
    data = {"version": 1, "phrases": phrases}
    path = tmp_path / "phrases.json"
    path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    return path


@pytest.fixture
def real_corpus_path() -> Path:
    return Path(__file__).resolve().parents[1] / "benchmark" / "corpus" / "phrases.json"
