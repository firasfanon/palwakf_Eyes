#!/usr/bin/env python3
"""Pal_Eyes repository and runtime discovery.

Read-only by default. It inventories the target directory, checks common
Flutter/Supabase runtime markers, and prints JSON. It never edits the target.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


RUNTIME_MARKERS = [
    "pubspec.yaml",
    "pubspec.lock",
    "analysis_options.yaml",
    "lib/main.dart",
    "web/index.html",
    "android",
    "ios",
    "test",
    "integration_test",
    "supabase/config.toml",
    "supabase/migrations",
    "supabase/functions",
    "package.json",
]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def discover(root: Path) -> dict[str, Any]:
    if not root.exists() or not root.is_dir():
        raise SystemExit(f"Target directory does not exist: {root}")

    files = sorted(p for p in root.rglob("*") if p.is_file())
    top_dirs = sorted(p.name for p in root.iterdir() if p.is_dir())
    markers = {}
    for marker in RUNTIME_MARKERS:
        target = root / marker
        markers[marker] = {
            "exists": target.exists(),
            "kind": "directory" if target.is_dir() else ("file" if target.is_file() else "missing"),
        }

    flutter_present = (root / "pubspec.yaml").is_file() and (root / "lib/main.dart").is_file()
    supabase_local_present = (root / "supabase/config.toml").is_file()

    return {
        "target": str(root.resolve()),
        "mode": "READ_ONLY",
        "file_count": len(files),
        "top_level_directories": top_dirs,
        "runtime_markers": markers,
        "classification": {
            "flutter_runtime": "PRESENT" if flutter_present else "NOT_PRESENT",
            "supabase_local_project": "PRESENT" if supabase_local_present else "NOT_PRESENT",
            "repository_type": (
                "FLUTTER_RUNTIME_REPOSITORY"
                if flutter_present
                else "DOCUMENTATION_AND_GOVERNANCE_BASELINE"
            ),
        },
        "files": [
            {
                "path": str(p.relative_to(root)).replace("\\", "/"),
                "size_bytes": p.stat().st_size,
                "sha256": sha256_file(p),
            }
            for p in files
        ],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".", help="Repository root")
    parser.add_argument("--output", help="Optional JSON output path outside or inside target")
    args = parser.parse_args()

    result = discover(Path(args.root))
    payload = json.dumps(result, ensure_ascii=False, indent=2)
    print(payload)

    if args.output:
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
