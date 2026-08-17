"""FastAPI TTS service package.

Serves Piper-generated navigation audio to the Flutter frontend over HTTP.
Drives Piper through the existing ``benchmark/engines/piper/adapter.py``
subprocess adapter (never imports piper Python APIs directly).
"""
