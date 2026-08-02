#!/usr/bin/env python3
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_BASELINE = "PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802"


def read_text(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8-sig")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-finalized", action="store_true")
    arguments = parser.parse_args()

    checks = {
        "pubspec_9_0_1_30": bool(
            re.search(
                r"(?m)^version:\s*9\.0\.1\+30\s*$",
                read_text("pubspec.yaml"),
            )
        ),
        "baseline_r9_0_1": (
            f"BASELINE_NAME={TARGET_BASELINE}"
            in read_text("PAL_EYES_BASELINE_ID.txt")
        ),
        "r9_widget": (
            ROOT / "lib/core/widgets/direct_flutter_maturity_r9.dart"
        ).is_file(),
        "r9_contract_test": (
            ROOT / "test/direct_flutter_maturity_r9_contract_test.dart"
        ).is_file(),
        "r9_widget_test": (
            ROOT / "test/direct_flutter_maturity_r9_widget_test.dart"
        ).is_file(),
        "media_stage_test": (
            ROOT / "test/pal_eyes_media_stage_bounded_layout_test.dart"
        ).is_file(),
        "session_attestation": (
            ROOT
            / "evidence/R9_0_1_SESSION_RECONSTRUCTION_ATTESTATION.json"
        ).is_file(),
        "github_audit": (
            ROOT / "evidence/GITHUB_REMOTE_AUDIT_20260802.json"
        ).is_file(),
        "uat_index": (
            ROOT / "evidence/BROWSER_UAT_R9_0_1/INDEX.json"
        ).is_file(),
        "database_write_false": (
            "DATABASE_WRITE=FALSE"
            in read_text("PAL_EYES_BASELINE_ID.txt")
        ),
        "production_not_approved": (
            "PRODUCTION_DEPLOYMENT=NOT_APPROVED"
            in read_text("PAL_EYES_BASELINE_ID.txt")
        ),
        "public_coordinates_zero": (
            "PUBLIC_COORDINATES=0"
            in read_text("PAL_EYES_BASELINE_ID.txt")
        ),
    }

    if arguments.require_finalized:
        checks["format_replay_pass"] = (
            "TARGETED_FORMAT_REPLAY=PASS"
            in read_text("PAL_EYES_BASELINE_ID.txt")
        )
        checks["accepted_after_replay"] = (
            "STATUS=ACCEPTED_LOCAL_BASELINE_AFTER_FORMAT_REPLAY"
            in read_text("PAL_EYES_BASELINE_ID.txt")
        )

    failures = [
        name for name, value in checks.items() if not value
    ]
    print(
        json.dumps(
            {
                "result": "PASS" if not failures else "FAIL",
                "mode": (
                    "R9_0_1_SESSION_RECONSTRUCTED_GITHUB_CANDIDATE"
                ),
                "baseline": TARGET_BASELINE,
                "checks": checks,
                "failures": failures,
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    if failures:
        return 1
    print(
        "PAL_EYES_R9_0_1_SESSION_RECONSTRUCTION_"
        "STATIC_VERIFY=PASS"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
