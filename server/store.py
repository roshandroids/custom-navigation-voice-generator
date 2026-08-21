"""JSON-file-backed store for voice packs and instructions.

Persistence for the app's content + workflow state. On first run it seeds the
two default packs (`seed-ne`, `seed-en`) from the benchmark corpora, mirroring
what the frontend's ``SampleCorpus`` previously held. Text and category come
from the canonical ``benchmark/corpus`` JSON; the short situation labels come
from a curated id->situation map kept in this module (the corpus JSON does not
carry them).

The store lives at ``benchmark/output/app_store.json`` (gitignored) and is
saved on every mutation so created packs and recorded progress survive restarts.
"""

from __future__ import annotations

import json
import time
from datetime import datetime
from pathlib import Path
from typing import Any

from server.voices import LANGUAGE_DEFAULT_VOICE

STORE_PATH = (
    Path(__file__).resolve().parents[1] / "benchmark" / "output" / "app_store.json"
)
PHRASES_NE_PATH = (
    Path(__file__).resolve().parents[1] / "benchmark" / "corpus" / "phrases.json"
)
PHRASES_EN_PATH = (
    Path(__file__).resolve().parents[1] / "benchmark" / "corpus" / "phrases_en.json"
)

# Curated id -> short situation label, mirroring frontend SampleCorpus.
SITUATIONS: dict[str, str] = {
    # Nepali
    "turn_left_001": "बायाँ मोड",
    "turn_right_001": "दायाँ मोड",
    "keep_left_002": "बायाँ रहनुहोस्",
    "continue_straight_002": "सीधा जानुहोस्",
    "uturn_002": "यू-टर्न",
    "roundabout_002": "गोलचक्कर",
    "exit_002": "निकास",
    "distance_100m_002": "१०० मिटर",
    "distance_500m_002": "५०० मिटर",
    "distance_1km_002": "१ किलोमिटर",
    "distance_200m_001": "२०० मिटर",
    "distance_300m_001": "३०० मिटर",
    "traffic_ahead_001": "ट्राफिक",
    "traffic_heavy_002": "भारी ट्राफिक",
    "accident_ahead_002": "दुर्घटना",
    "construction_002": "निर्माण",
    "road_closed_002": "बाटो बन्द",
    "speed_camera_001": "स्पिड क्यामेरा",
    "speed_camera_002": "स्पिड क्यामेरा",
    "redlight_camera_002": "रातो बत्ती क्यामेरा",
    "police_002": "पुलिस",
    "arrival_002": "गन्तव्य",
    "arrival_005": "गन्तव्य नजिक",
    # English
    "en_turn_left_001": "Turn left",
    "en_turn_right_001": "Turn right",
    "en_keep_left_001": "Keep left",
    "en_keep_right_001": "Keep right",
    "en_continue_straight_001": "Continue straight",
    "en_uturn_001": "U-turn",
    "en_roundabout_001": "Roundabout",
    "en_exit_001": "Exit",
    "en_distance_100m_001": "100 meters",
    "en_distance_500m_001": "500 meters",
    "en_distance_1km_001": "1 kilometer",
    "en_traffic_ahead_001": "Traffic ahead",
    "en_traffic_heavy_001": "Heavy traffic",
    "en_accident_ahead_001": "Accident ahead",
    "en_construction_001": "Construction",
    "en_road_closed_001": "Road closed",
    "en_speed_camera_001": "Speed camera",
    "en_speed_camera_004": "Speed camera",
    "en_redlight_camera_001": "Red-light camera",
    "en_police_001": "Police ahead",
    "en_arrival_001": "Arrival",
    "en_arrival_002": "Destination on left",
}

# Ordered seed instruction ids per language (matches SampleCorpus order).
_NE_SEED_IDS: list[str] = [
    "turn_left_001", "turn_right_001", "keep_left_002", "continue_straight_002",
    "uturn_002", "roundabout_002", "exit_002", "distance_100m_002",
    "distance_500m_002", "distance_1km_002", "distance_200m_001",
    "distance_300m_001", "traffic_ahead_001", "traffic_heavy_002",
    "accident_ahead_002", "construction_002", "road_closed_002",
    "speed_camera_001", "speed_camera_002", "redlight_camera_002", "police_002",
    "arrival_002", "arrival_005",
]
_EN_SEED_IDS: list[str] = [
    "en_turn_left_001", "en_turn_right_001", "en_keep_left_001",
    "en_keep_right_001", "en_continue_straight_001", "en_uturn_001",
    "en_roundabout_001", "en_exit_001", "en_distance_100m_001",
    "en_distance_500m_001", "en_distance_1km_001", "en_traffic_ahead_001",
    "en_traffic_heavy_001", "en_accident_ahead_001", "en_construction_001",
    "en_road_closed_001", "en_speed_camera_001", "en_speed_camera_004",
    "en_redlight_camera_001", "en_police_001", "en_arrival_001",
    "en_arrival_002",
]

SEED_PACKS: list[dict[str, Any]] = [
    {
        "id": "seed-ne",
        "name": "My Nepali Voice",
        "language": "ne",
        "voice": LANGUAGE_DEFAULT_VOICE["ne"],
        "personality": "savage",
        "created_at": "2026-08-15T00:00:00",
        "seed_ids": _NE_SEED_IDS,
        "corpus": "ne",
    },
    {
        "id": "seed-en",
        "name": "English Daily",
        "language": "en",
        "voice": LANGUAGE_DEFAULT_VOICE["en"],
        "personality": "normal",
        "created_at": "2026-08-14T00:00:00",
        "seed_ids": _EN_SEED_IDS,
        "corpus": "en",
    },
]


class StoreError(Exception):
    """Raised when a store operation is invalid (e.g. missing pack/instruction)."""


def _load_phrases_by_language(path: Path, language: str) -> dict[str, dict[str, Any]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    out: dict[str, dict[str, Any]] = {}
    for entry in data.get("phrases", []):
        if entry.get("language") == language:
            out[entry["id"]] = entry
    return out


class AppStore:
    """Loads, mutates, and persists the app's voice-pack/instruction state."""

    def __init__(self, path: Path | None = None, seed: bool = True) -> None:
        self._path = path or STORE_PATH
        self._packs: dict[str, dict[str, Any]] = {}
        self._instructions: dict[str, list[dict[str, Any]]] = {}
        if self._path.exists():
            self._load()
        elif seed:
            self._seed()
        else:
            self._save()  # create an empty store file

    # -- read ------------------------------------------------
    def _load(self) -> None:
        data = json.loads(self._path.read_text(encoding="utf-8"))
        self._instructions = {
            p["id"]: p["instructions"] for p in data.get("voice_packs", [])
        }
        self._packs = {
            p["id"]: {k: v for k, v in p.items() if k != "instructions"}
            for p in data.get("voice_packs", [])
        }

    def _save(self) -> None:
        self._path.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            "voice_packs": [
                {**self._packs[i], "instructions": self._instructions[i]}
                for i in self._packs
            ]
        }
        self._path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
        )

    # -- seeding ---------------------------------------------
    def _seed(self) -> None:
        phrases_ne = _load_phrases_by_language(PHRASES_NE_PATH, "ne")
        phrases_en = _load_phrases_by_language(PHRASES_EN_PATH, "en")
        corpora = {
            "ne": phrases_ne,
            "en": phrases_en,
        }
        for spec in SEED_PACKS:
            corpus = corpora[spec["corpus"]]
            instructions = []
            for pid in spec["seed_ids"]:
                phrase = corpus[pid]
                text = phrase["text"]
                instructions.append(
                    {
                        "id": pid,
                        "category": phrase["category"],
                        "situation": SITUATIONS[pid],
                        "standardText": text,
                        "customText": text,
                        "audioUrl": None,
                        "isRecorded": False,
                    }
                )
            self._packs[spec["id"]] = {
                "id": spec["id"],
                "name": spec["name"],
                "language": spec["language"],
                "voice": spec["voice"],
                "personality": spec["personality"],
                "createdAt": spec["created_at"],
            }
            self._instructions[spec["id"]] = instructions
        self._save()

    # -- packs ------------------------------------------------
    def get_packs(self) -> list[dict[str, Any]]:
        return [dict(self._packs[i]) for i in self._packs]

    def get_pack(self, pack_id: str) -> dict[str, Any]:
        try:
            return dict(self._packs[pack_id])
        except KeyError as exc:
            raise StoreError(f"voice pack not found: {pack_id}") from exc

    def create_pack(
        self, name: str, language: str, voice: str, personality: str
    ) -> dict[str, Any]:
        pack_id = f"pack-{time.time_ns() // 1000}"
        self._packs[pack_id] = {
            "id": pack_id,
            "name": name,
            "language": language,
            "voice": voice,
            "personality": personality,
            "createdAt": datetime.now().isoformat(),
        }
        # A new pack starts with the canonical instructions for its language.
        self._instructions[pack_id] = self._build_instructions_for(language)
        self._save()
        return dict(self._packs[pack_id])

    def _build_instructions_for(self, language: str) -> list[dict[str, Any]]:
        corpus_key = "ne" if language == "ne" else "en"
        phrases = _load_phrases_by_language(
            PHRASES_NE_PATH if corpus_key == "ne" else PHRASES_EN_PATH, corpus_key
        )
        ids = _NE_SEED_IDS if corpus_key == "ne" else _EN_SEED_IDS
        instructions = []
        for pid in ids:
            phrase = phrases[pid]
            text = phrase["text"]
            instructions.append(
                {
                    "id": pid,
                    "category": phrase["category"],
                    "situation": SITUATIONS[pid],
                    "standardText": text,
                    "customText": text,
                    "audioUrl": None,
                    "isRecorded": False,
                }
            )
        return instructions

    # -- instructions -----------------------------------------
    def _pack_ids(self, pack_id: str) -> None:
        if pack_id not in self._packs:
            raise StoreError(f"voice pack not found: {pack_id}")

    def _instr(self, pack_id: str, instr_id: str) -> dict[str, Any]:
        self._pack_ids(pack_id)
        for i in self._instructions[pack_id]:
            if i["id"] == instr_id:
                return i
        raise StoreError(f"instruction not found: {instr_id}")

    def get_instructions(self, pack_id: str) -> list[dict[str, Any]]:
        self._pack_ids(pack_id)
        return [dict(i) for i in self._instructions[pack_id]]

    def get_instruction(self, pack_id: str, instr_id: str) -> dict[str, Any]:
        return dict(self._instr(pack_id, instr_id))

    def update_instruction(
        self, pack_id: str, instr_id: str, *, custom_text: str | None = None,
        is_recorded: bool | None = None,
    ) -> dict[str, Any]:
        instr = self._instr(pack_id, instr_id)
        if custom_text is not None:
            instr["customText"] = custom_text
        if is_recorded is not None:
            instr["isRecorded"] = is_recorded
        self._save()
        return dict(instr)

    def attach_audio(self, pack_id: str, instr_id: str, audio_url: str) -> dict[str, Any]:
        instr = self._instr(pack_id, instr_id)
        instr["audioUrl"] = audio_url
        self._save()
        return dict(instr)

    def progress(self, pack_id: str) -> dict[str, int]:
        instrs = self.get_instructions(pack_id)
        recorded = sum(1 for i in instrs if i["isRecorded"])
        return {"recorded": recorded, "total": len(instrs)}
