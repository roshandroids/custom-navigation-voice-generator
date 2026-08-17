"""Run the TTS service: ``python -m server`` or ``run-tts-server``."""

from __future__ import annotations

import argparse
import sys


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run the Custom Nav TTS service.")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--reload", action="store_true", help="Dev auto-reload.")
    args = parser.parse_args(argv)

    # Imported lazily so ``--help`` / import errors don't need uvicorn installed.
    import uvicorn

    uvicorn.run("server.app:app", host=args.host, port=args.port, reload=args.reload)
    return 0


if __name__ == "__main__":
    sys.exit(main())
