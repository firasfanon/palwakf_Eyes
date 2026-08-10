#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def read(relative: str) -> str:
    path = ROOT / relative
    return path.read_text(encoding="utf-8-sig") if path.is_file() else ""

def main() -> int:
    workflow = read(".github/workflows/vercel_preview.yml")
    config = read("vercel.json")
    gitignore = read(".gitignore")
    prepare = read("tools/prepare_vercel_build_output.py")
    state = read("PAL_EYES_VERCEL_PREVIEW_INTEGRATION_STATE.txt")
    checks = {
        "workflow_present": bool(workflow),
        "preview_only_no_prod_flag": "--prod" not in workflow,
        "preview_only_no_production_target": "target=production" not in workflow,
        "staging_compile_environment": (
            "PAL_EYES_ENV=staging" in workflow
            and "MAP_TILE_PROVIDER_MODE=osm_standard" in workflow
        ),
        "validation_before_deploy": all(
            token in workflow
            for token in (
                "flutter analyze --no-pub",
                "flutter test --no-pub",
                "flutter build web",
                "verify_vercel_preview_foundation.py",
            )
        ),
        "same_repository_pr_guard": (
            "github.event.pull_request.head.repo.full_name == github.repository"
            in workflow
        ),
        "required_secrets": all(
            token in workflow
            for token in ("VERCEL_TOKEN", "VERCEL_ORG_ID", "VERCEL_PROJECT_ID")
        ),
        "no_secret_literal": all(
            token not in workflow for token in ("team_8DIevPeFrbvT01rUqXDnJ0dQ", "prj_")
        ),
        "prebuilt_deployment": "deploy --prebuilt" in workflow,
        "build_output_api_v3": '"version": 3' in prepare,
        "spa_filesystem_first": (
            '"handle": "filesystem"' in prepare
            and '"dest": "/index.html"' in prepare
        ),
        "automatic_git_deployments_disabled": (
            '"deploymentEnabled": false' in config
        ),
        "local_vercel_state_ignored": ".vercel/" in gitignore,
        "preview_only_state": (
            "INTEGRATION_MODE=PREVIEW_ONLY" in state
            and "PRODUCTION_DEPLOYMENT=NOT_APPROVED" in state
        ),
        "governance_boundaries": all(
            token in state
            for token in (
                "DATABASE_WRITE=FALSE",
                "SUPABASE_APPLY=FALSE",
                "PUBLICATION=BLOCKED",
            )
        ),
    }
    failures = [name for name, passed in checks.items() if not passed]
    print(json.dumps({
        "result": "PASS" if not failures else "FAIL",
        "mode": "PAL_EYES_VERCEL_PREVIEW_GIT_INTEGRATION_FOUNDATION",
        "checks": checks,
        "failures": failures,
    }, ensure_ascii=False, indent=2))
    if failures:
        return 1
    print("PAL_EYES_VERCEL_PREVIEW_FOUNDATION_STATIC_VERIFY=PASS")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
