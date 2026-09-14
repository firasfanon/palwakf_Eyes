#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(relative: str) -> str:
    path = ROOT / relative
    return (
        path.read_text(encoding="utf-8-sig")
        if path.is_file()
        else ""
    )


def main() -> int:
    workflow_path = (
        ".github/workflows/vercel_development_hosting.yml"
    )

    workflow = read(workflow_path)
    config = read("vercel.json")
    gitignore = read(".gitignore")
    prepare = read("tools/prepare_vercel_build_output.py")
    state = read(
        "PAL_EYES_VERCEL_DEVELOPMENT_HOSTING_STATE.txt"
    )

    checks = {
        "workflow_present": bool(workflow),

        "legacy_preview_workflow_removed": not (
            ROOT
            / ".github/workflows/vercel_preview.yml"
        ).exists(),

        "legacy_preview_verifier_removed": not (
            ROOT
            / "tools/verify_vercel_preview_foundation.py"
        ).exists(),

        "development_hosting_workflow_name": (
            "Pal Eyes governed development hosting"
            in workflow
        ),

        "staging_compile_environment": (
            "PAL_EYES_ENV=staging" in workflow
            and
            "MAP_TILE_PROVIDER_MODE=osm_standard"
            in workflow
            and
            "MAP_TILE_PROVIDER_APPROVED=false"
            in workflow
        ),

        "no_product_production_runtime_compile": (
            "PAL_EYES_ENV=production"
            not in workflow
        ),

        "validation_before_deploy": all(
            token in workflow
            for token in (
                "flutter analyze --no-pub",
                "flutter test --no-pub",
                "flutter build web",
                "verify_vercel_development_hosting.py",
                "needs: validate",
            )
        ),

        "development_deployment_enabled": (
            "development-hosting:" in workflow
            and 'if: ${{ false }}' not in workflow
        ),

        "required_secrets": all(
            token in workflow
            for token in (
                "VERCEL_TOKEN",
                "VERCEL_ORG_ID",
                "VERCEL_PROJECT_ID",
            )
        ),

        "no_secret_id_literal": all(
            token not in workflow
            for token in (
                "team_8DIevPeFrbvT01rUqXDnJ0dQ",
                "prj_",
            )
        ),

        "prebuilt_deployment": (
            "deploy \\" in workflow
            and "--prebuilt" in workflow
        ),

        "technical_production_target_explicit": (
            "--prod" in workflow
        ),

        "development_project_domain": (
            "pal-eyes-development.vercel.app"
            in workflow
        ),

        "runtime_production_assertion": all(
            token in workflow
            for token in (
                "api.vercel.com/v7/deployments",
                '"target": "production"',
                "production_hosts",
                "PRODUCTION_CONFIRMED_DEV_ONLY",
            )
        ),

        "stable_domain_health_check": (
            "DEVELOPMENT_STABLE_URL_NOT_REACHABLE"
            in workflow
        ),

        "build_output_api_v3": (
            '"version": 3' in prepare
        ),

        "spa_filesystem_first": (
            '"handle": "filesystem"' in prepare
            and
            '"dest": "/index.html"' in prepare
        ),

        "automatic_git_deployments_disabled": (
            '"deploymentEnabled": false'
            in config
        ),

        "local_vercel_state_ignored": (
            ".vercel/" in gitignore
        ),

        "safe_environment_ignore_contract": (
            ".env.*" in gitignore
            and "!.env.example" in gitignore
            and "\n.env*\n" not in gitignore
        ),

        "development_hosting_state": all(
            token in state
            for token in (
                "INTEGRATION_MODE=DEVELOPMENT_HOSTING",
                "VERCEL_PROJECT_NAME=pal-eyes-development",
                "PRODUCT_LIFECYCLE=DEVELOPMENT",
                "PAL_EYES_RUNTIME_ENVIRONMENT=staging",
                "DEVELOPMENT_HOSTING=AUTHORIZED",
            )
        ),

        "technical_vs_product_production_separated": all(
            token in state
            for token in (
                "VERCEL_TECHNICAL_ENVIRONMENT=production",
                "PRODUCT_PRODUCTION_RELEASE=NOT_APPROVED",
                "PRODUCT_PRODUCTION_DEPLOYMENT=NOT_APPROVED",
            )
        ),

        "future_production_project_separate": (
            "FUTURE_PRODUCTION_PROJECT=palwakf_eyes"
            in state
        ),

        "production_project_absent_from_workflow": (
            "palwakf_eyes" not in workflow
        ),

        "governance_boundaries": all(
            token in state
            for token in (
                "DATABASE_WRITE=FALSE",
                "SUPABASE_APPLY=FALSE",
                "PUBLICATION=BLOCKED",
                "PUBLIC_COORDINATES=0",
                "PUBLIC_MARKERS=0",
            )
        ),
    }

    failures = [
        name
        for name, passed in checks.items()
        if not passed
    ]

    print(
        json.dumps(
            {
                "result": (
                    "PASS"
                    if not failures
                    else "FAIL"
                ),
                "mode": (
                    "PAL_EYES_GOVERNED_"
                    "DEVELOPMENT_HOSTING"
                ),
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
        "PAL_EYES_GOVERNED_"
        "DEVELOPMENT_HOSTING_STATIC_VERIFY=PASS"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())