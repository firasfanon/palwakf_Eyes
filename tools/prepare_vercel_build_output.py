#!/usr/bin/env python3
from __future__ import annotations
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB_BUILD = ROOT / "build" / "web"
OUTPUT = ROOT / ".vercel" / "output"
STATIC = OUTPUT / "static"

def main() -> int:
    if not WEB_BUILD.is_dir():
        raise SystemExit("FLUTTER_WEB_BUILD_MISSING=build/web")
    if OUTPUT.exists():
        shutil.rmtree(OUTPUT)
    STATIC.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(WEB_BUILD, STATIC)
    config = {
        "version": 3,
        "routes": [
            {"handle": "filesystem"},
            {"src": "/.*", "dest": "/index.html"},
        ],
    }
    (OUTPUT / "config.json").write_text(
        json.dumps(config, indent=2) + "\n", encoding="utf-8"
    )
    count = sum(1 for p in STATIC.rglob("*") if p.is_file())
    if count == 0:
        raise SystemExit("VERCEL_STATIC_OUTPUT_EMPTY")
    print(f"VERCEL_BUILD_OUTPUT_STATIC_FILES={count}")
    print("VERCEL_BUILD_OUTPUT_API_VERSION=3")
    print("SPA_FILESYSTEM_FIRST_FALLBACK=PASS")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
