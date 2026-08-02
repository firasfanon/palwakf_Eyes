#!/usr/bin/env python3
from __future__ import annotations
import json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
checks = {}
def has(path, token):
    p=ROOT/path
    return p.is_file() and token in p.read_text(encoding="utf-8-sig")
checks["version"] = has("pubspec.yaml", "version: 9.0.1+30")
checks["baseline"] = has("PAL_EYES_BASELINE_ID.txt", "BASELINE_NAME=PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802")
checks["status_registered"] = (
    has("PAL_EYES_BASELINE_ID.txt", "STATUS=SESSION_RECONSTRUCTED_GITHUB_CANDIDATE_PENDING_FORMAT_REPLAY")
    or has("PAL_EYES_BASELINE_ID.txt", "STATUS=ACCEPTED_LOCAL_BASELINE_AFTER_FORMAT_REPLAY")
)
checks["browser_uat_closed"] = has("PAL_EYES_BASELINE_ID.txt", "BROWSER_UAT=CLOSED_BY_EXPLICIT_OPERATOR_AUTHORIZATION")
checks["runtime_zero"] = has("PAL_EYES_BASELINE_ID.txt", "RUNTIME_EXCEPTIONS=0")
checks["public_coordinates_zero"] = has("PAL_EYES_BASELINE_ID.txt", "PUBLIC_COORDINATES=0")
checks["production_blocked"] = has("PAL_EYES_BASELINE_ID.txt", "PRODUCTION_DEPLOYMENT=NOT_APPROVED")
checks["acceptance_evidence"] = (ROOT/"evidence/DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_ACCEPTANCE_EVIDENCE.json").is_file()
checks["uat_index"] = (ROOT/"evidence/BROWSER_UAT_R9_0_1/INDEX.json").is_file()
checks["handoff"] = has("docs/project_memory/PAL_EYES_SESSION_HANDOFF_CURRENT.md", "BASELINE=PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802")
checks["guide"] = has("PAL_EYES_PROJECT_COMPREHENSIVE_GUIDE.md", "PAL_EYES_R9_0_1_GUIDE_UPDATE")
checks["changelog"] = has("docs/CHANGELOG.md", "PAL_EYES_R9_0_1_PROMOTION_SECTION")
checks["decision"] = has("docs/DECISION_LOG.md", "PAL_EYES_R9_0_1_PROMOTION_DECISION")
checks["error_record"] = has("docs/ERROR_RECORD.md", "PAL_EYES_R9_0_1_FORMAT_AND_NESTED_REPOSITORY_ERROR_RECORD")
failures=[k for k,v in checks.items() if not v]
result={"result":"PASS" if not failures else "FAIL","mode":"DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1","checks":checks,"failures":failures,"baseline":"PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802"}
print(json.dumps(result, ensure_ascii=False, indent=2))
if failures:
    sys.exit(1)
print("DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_STATIC_VERIFY=PASS")
