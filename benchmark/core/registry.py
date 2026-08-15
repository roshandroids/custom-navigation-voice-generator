"""Engine registry: maps engine names to adapter classes.

The registry is the single place that knows which engines exist. The runner only
talks to the registry + the ``TTSAdapter`` interface, never to concrete engines.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from benchmark.core.tts import TTSAdapter

_REGISTRY: dict[str, type[TTSAdapter]] = {}


def register(cls: type[TTSAdapter]) -> type[TTSAdapter]:
    """Register an adapter class under its ``name`` attribute.

    Used as a class decorator. Duplicate names are an error (would silently shadow).
    """
    name = cls.name
    if not name or not isinstance(name, str):
        raise ValueError(f"adapter {cls.__name__} must define a non-empty 'name'")
    if name in _REGISTRY:
        raise ValueError(f"duplicate engine registration: {name!r}")
    _REGISTRY[name] = cls
    return cls


def get_registry() -> dict[str, type[TTSAdapter]]:
    """Return a copy of the registry (engine name -> adapter class)."""
    return dict(_REGISTRY)


def available_engines() -> list[str]:
    """Names of all registered engines, sorted."""
    return sorted(_REGISTRY)


def create_engine(name: str, **kwargs) -> TTSAdapter:
    """Instantiate a registered engine adapter by name.

    Raises ``KeyError`` for unknown engines.
    """
    try:
        cls = _REGISTRY[name]
    except KeyError:
        raise KeyError(f"unknown engine: {name!r} (registered: {available_engines()})") from None
    return cls(**kwargs)


def clear_registry() -> None:
    """Remove all registrations (used by tests)."""
    _REGISTRY.clear()
