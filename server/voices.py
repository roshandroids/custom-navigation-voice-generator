"""Voice registry for the TTS service.

Maps the frontend's short voice ids (``chitwan``, ``google-medium``, ...) to
the full Piper voice-model names the benchmark uses (``ne_NP-chitwan-medium``,
...), and provides per-language default voices.

Mirrors ``frontend/lib/features/voice_packs/domain/value_objects/voice_profile.dart``
(VoiceCatalog) and ``benchmark/scripts/run_waze_voicepack.py``.
"""

from __future__ import annotations

from benchmark.engines.piper.adapter import MODELS_DIR, PiperAdapter

# Short frontend voice id -> full Piper voice-model name.
VOICE_MAP: dict[str, str] = {
    # Nepali
    "chitwan": "ne_NP-chitwan-medium",
    "google-medium": "ne_NP-google-medium",
    "google-x-low": "ne_NP-google-x_low",
    # English
    "joe": "en_US-joe-medium",
    "kristin": "en_US-kristin-medium",
    "ljspeech": "en_US-ljspeech-medium",
}

# Language code -> short default voice id (kept in VoiceCatalog order).
LANGUAGE_DEFAULT_VOICE: dict[str, str] = {
    "ne": "chitwan",
    "en": "joe",
}

# Short voice id -> language code it speaks.
LANGUAGE_BY_VOICE: dict[str, str] = {
    "chitwan": "ne",
    "google-medium": "ne",
    "google-x-low": "ne",
    "joe": "en",
    "kristin": "en",
    "ljspeech": "en",
}

SUPPORTED_LANGUAGES = ("ne", "en")


def resolve_voice(voice: str) -> str:
    """Resolve a short voice id to its full Piper voice-model name."""
    try:
        return VOICE_MAP[voice]
    except KeyError as exc:
        raise ValueError(f"unknown voice id: {voice!r}") from exc


def validate_language(voice: str, language: str) -> None:
    """Raise ValueError if the voice id cannot speak the given language."""
    if language not in SUPPORTED_LANGUAGES:
        raise ValueError(f"unsupported language: {language!r}")
    if LANGUAGE_BY_VOICE.get(voice) != language:
        raise ValueError(f"voice {voice!r} does not speak language {language!r}")


def default_voice_for(language: str) -> str:
    """Return the default short voice id for a language code."""
    try:
        return LANGUAGE_DEFAULT_VOICE[language]
    except KeyError as exc:
        raise ValueError(f"unsupported language: {language!r}") from exc


def available_voices() -> list[str]:
    """List the short voice ids whose Piper model files exist locally."""
    short_ids: list[str] = []
    for short_id, full_name in VOICE_MAP.items():
        if (MODELS_DIR / f"{full_name}.onnx").exists():
            short_ids.append(short_id)
    return sorted(short_ids)


def make_adapter(voice: str) -> PiperAdapter:
    """Build a configured PiperAdapter for a short voice id."""
    return PiperAdapter(voice=resolve_voice(voice))


def piper_ok() -> bool:
    """Whether the piper CLI and the default voice model are available."""
    return PiperAdapter(voice=resolve_voice(default_voice_for("ne"))).check_available() is None
