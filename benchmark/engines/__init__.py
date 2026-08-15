"""Engine adapters for the TTS benchmark.

Each subpackage implements :class:`benchmark.core.tts.TTSAdapter` for one engine
and registers itself via ``@register`` on import. Importing this package loads
every adapter; the CLI and tests rely on that.

The ``dummy`` adapter needs no extra dependencies and is always available — it is
used by tests and as a wiring reference for new adapters.

Engines with heavy or conflicting dependencies (e.g. Qwen3-TTS needing its own
Python env) must isolate those requirements in their own subpackage and degrade
gracefully via ``check_available()`` when missing.
"""

from benchmark.engines import chatterbox, dummy, kokoro, piper, qwen3  # noqa: F401
