#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "BASELINE_MANIFEST.json"
TARGET_BASELINE = (
    "PAL_EYES_OSM_TILE_PROVIDER_POLICY_AND_PRODUCTION_READINESS_"
    "R9_0_2_20260803"
)


def candidate_paths() -> list[str]:
    completed = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    paths = []
    for raw in completed.stdout.splitlines():
        relative = raw.strip().replace("\\", "/")
        if not relative or relative == "BASELINE_MANIFEST.json":
            continue
        target = ROOT / relative
        if target.is_file():
            paths.append(relative)
    return sorted(set(paths))


def main() -> int:
    files = []
    for relative in candidate_paths():
        target = ROOT / relative
        data = target.read_bytes()
        files.append(
            {
                "path": relative,
                "sha256": hashlib.sha256(data).hexdigest(),
                "size_bytes": len(data),
            }
        )

    payload = {
        "project_id": "pal_eyes",
        "baseline_name": TARGET_BASELINE,
        "parent_baseline": (
            "PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_"
            "R9_0_1_20260802"
        ),
        "authoritative_parent_commit": (
            "21d70b068870be72e573140ceb7a9ba17e644da3"
        ),
        "version": "9.0.2",
        "build": 31,
        "date": "2026-08-03",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "status": "BUILT_PENDING_LOCAL_VALIDATION",
        "manifest_self_excluded": True,
        "governance": {
            "database_write": False,
            "supabase_apply": False,
            "public_coordinates": 0,
            "public_markers": 0,
            "approved_media": 0,
            "publication": "BLOCKED",
            "production_deployment": "NOT_APPROVED",
            "production_tile_runtime": (
                "FAIL_CLOSED_UNTIL_APPROVED_EXTERNAL_PROVIDER"
            ),
            "prefetch": "FORBIDDEN",
            "offline_tile_archive": "FORBIDDEN",
        },
        "file_count": len(files),
        "files": files,
    }

    OUTPUT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"BASELINE_MANIFEST_FILE_COUNT={len(files)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
