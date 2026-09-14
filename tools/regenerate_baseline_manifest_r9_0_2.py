#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "BASELINE_MANIFEST.json"
TARGET_BASELINE = (
    "PAL_EYES_OSM_TILE_PROVIDER_POLICY_AND_PRODUCTION_READINESS_"
    "R9_0_2_20260803"
)
SNAPSHOT_COMMIT = "b39df1bb5b3efdd187033e68c342b14de64a980c"
SNAPSHOT_BLOB = "6d405019207003f7b4c69bdea870fb52ab6c810d"


def snapshot_manifest() -> dict[str, object]:
    completed = subprocess.run(
        ["git", "show", f"{SNAPSHOT_COMMIT}:BASELINE_MANIFEST.json"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return json.loads(completed.stdout)


def main() -> int:
    snapshot = snapshot_manifest()
    file_count = snapshot.get("file_count")
    if not isinstance(file_count, int) or file_count <= 0:
        raise SystemExit("SNAPSHOT_FILE_COUNT_INVALID")

    payload = {
        "schema_version": 2,
        "project_id": "pal_eyes",
        "manifest_role": "VALIDATED_CANDIDATE_METADATA",
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
        "metadata_reconciled_date": "2026-09-14",
        "status": "VALIDATED_CANDIDATE_METADATA",
        "candidate_metadata_only": True,
        "sovereign_baseline_promotion": False,
        "snapshot": {
            "commit": SNAPSHOT_COMMIT,
            "manifest_path": "BASELINE_MANIFEST.json",
            "manifest_git_blob_sha": SNAPSHOT_BLOB,
            "file_count": file_count,
            "integrity_scope": "IMMUTABLE_R9_0_2_CHECKPOINT",
        },
        "validation_contract": {
            "classification": (
                "TECHNICALLY_VALIDATED_CANDIDATE_NOT_SOVEREIGN_BASELINE"
            ),
            "current_pr_head_ci_required": True,
            "required_workflows": [
                "Pal Eyes R9.0.2 OSM policy candidate",
                "Pal Eyes governed development hosting",
            ],
            "exact_run_evidence_authority": "PALWAKF_WORKSPACE_DRIVE",
        },
        "governance": {
            "database_write": False,
            "supabase_apply": False,
            "public_coordinates": 0,
            "public_markers": 0,
            "approved_media": 0,
            "publication": "BLOCKED",
            "production_deployment": "NOT_APPROVED",
            "product_production": "NO",
            "baseline_promotion": "NO",
            "production_tile_runtime": (
                "FAIL_CLOSED_UNTIL_APPROVED_EXTERNAL_PROVIDER"
            ),
            "prefetch": "FORBIDDEN",
            "offline_tile_archive": "FORBIDDEN",
        },
    }

    OUTPUT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"BASELINE_MANIFEST_SNAPSHOT_FILE_COUNT={file_count}")
    print("BASELINE_MANIFEST_ROLE=VALIDATED_CANDIDATE_METADATA")
    print("SOVEREIGN_BASELINE_PROMOTION=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
