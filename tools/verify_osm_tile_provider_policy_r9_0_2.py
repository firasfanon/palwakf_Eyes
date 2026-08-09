#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_BASELINE = (
    "PAL_EYES_OSM_TILE_PROVIDER_POLICY_AND_PRODUCTION_READINESS_"
    "R9_0_2_20260803"
)


def read_text(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8-sig")


def verify_manifest() -> tuple[bool, list[str]]:
    path = ROOT / "BASELINE_MANIFEST.json"
    if not path.is_file():
        return False, ["BASELINE_MANIFEST.json missing"]

    try:
        payload = json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as error:
        return False, [f"manifest parse error: {error}"]

    failures: list[str] = []
    if payload.get("baseline_name") != TARGET_BASELINE:
        failures.append("manifest baseline mismatch")
    if payload.get("version") != "9.0.2":
        failures.append("manifest version mismatch")
    if payload.get("build") != 31:
        failures.append("manifest build mismatch")

    files = payload.get("files")
    if not isinstance(files, list):
        return False, failures + ["manifest files missing"]

    for entry in files:
        if not isinstance(entry, dict):
            failures.append("manifest entry malformed")
            continue
        relative = entry.get("path")
        if not isinstance(relative, str):
            failures.append("manifest path malformed")
            continue
        target = ROOT / relative
        if not target.is_file():
            failures.append(f"manifest file missing: {relative}")
            continue
        data = target.read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        if digest != entry.get("sha256"):
            failures.append(f"manifest hash mismatch: {relative}")
        if len(data) != entry.get("size_bytes"):
            failures.append(f"manifest size mismatch: {relative}")

    return not failures, failures


def main() -> int:
    policy = read_text("lib/core/config/map_tile_provider_policy.dart")
    map_screen = read_text("lib/features/map/presentation/map_screen.dart")
    surface = read_text("lib/core/widgets/map_tile_policy_surface.dart")
    baseline = read_text("PAL_EYES_BASELINE_ID.txt")
    env_example = read_text(".env.example")
    web_index = read_text("web/index.html")
    pubspec = read_text("pubspec.yaml")
    workflow = read_text(
        ".github/workflows/r9_0_2_osm_policy_validation.yml"
    )

    manifest_ok, manifest_failures = verify_manifest()

    checks = {
        "version_9_0_2_31": bool(
            re.search(r"(?m)^version:\s*9\.0\.2\+31\s*$", pubspec)
        ),
        "baseline_target": f"BASELINE_NAME={TARGET_BASELINE}" in baseline,
        "candidate_not_promoted": (
            "STATUS=BUILT_PENDING_LOCAL_VALIDATION" in baseline
        ),
        "parent_commit_exact": (
            "AUTHORITATIVE_PARENT_COMMIT="
            "21d70b068870be72e573140ceb7a9ba17e644da3"
            in baseline
        ),
        "osm_exact_https_endpoint": (
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png" in policy
        ),
        "production_requires_external_mode": (
            "requestedMode != 'approved_external'" in policy
        ),
        "production_requires_approval": (
            "!environment.mapTileProviderApproved" in policy
        ),
        "prefetch_disabled": "prefetchEnabled: false" in policy,
        "offline_archive_disabled": "offlineArchiveEnabled: false" in policy,
        "visible_attribution": (
            "map-tile-attribution-visible" in surface
            and "© OpenStreetMap contributors" in policy
        ),
        "map_issue_link": (
            "https://www.openstreetmap.org/fixthemap" in policy
            and "map-attribution-report-link" in surface
        ),
        "map_screen_uses_policy": (
            "MapTileProviderPolicy.resolve(environment)" in map_screen
        ),
        "map_screen_has_no_hardcoded_osm_url": (
            "https://tile.openstreetmap.org" not in map_screen
        ),
        "map_screen_fail_closed_surface": (
            "PalEyesMapTileBlockedNotice" in map_screen
        ),
        "web_referrer_policy": (
            '<meta name="referrer" '
            'content="strict-origin-when-cross-origin">'
            in web_index
        ),
        "url_launcher_pinned": (
            bool(re.search(r"(?m)^\s*url_launcher:\s*6\.3\.2\s*$", pubspec))
        ),
        "environment_contract": all(
            token in env_example
            for token in (
                "MAP_TILE_PROVIDER_MODE",
                "MAP_TILE_URL_TEMPLATE",
                "MAP_TILE_PROVIDER_APPROVED",
                "MAP_TILE_ATTRIBUTION_TEXT",
                "MAP_TILE_ATTRIBUTION_URL",
                "MAP_TILE_ISSUE_REPORT_URL",
            )
        ),
        "no_no_cache_headers": (
            "Cache-Control: no-cache" not in policy
            and "Pragma: no-cache" not in policy
            and "Cache-Control: no-cache" not in map_screen
            and "Pragma: no-cache" not in map_screen
        ),
        "policy_test_present": (
            ROOT / "test/map_tile_provider_policy_test.dart"
        ).is_file(),
        "surface_test_present": (
            ROOT / "test/map_tile_policy_surface_test.dart"
        ).is_file(),
        "new_ci_workflow": (
            "verify_osm_tile_provider_policy_r9_0_2.py" in workflow
            and "flutter build web --release --no-pub" in workflow
        ),
        "old_ci_workflow_removed": not (
            ROOT
            / ".github/workflows/"
            "r9_0_1_reconstructed_candidate_validation.yml"
        ).exists(),
        "database_write_false": "DATABASE_WRITE=FALSE" in baseline,
        "supabase_apply_false": "SUPABASE_APPLY=FALSE" in baseline,
        "public_coordinates_zero": "PUBLIC_COORDINATES=0" in baseline,
        "public_markers_zero": "PUBLIC_MARKERS=0" in baseline,
        "publication_blocked": "PUBLICATION=BLOCKED" in baseline,
        "production_not_approved": (
            "PRODUCTION_DEPLOYMENT=NOT_APPROVED" in baseline
        ),
        "manifest_verified": manifest_ok,
    }

    failures = [name for name, value in checks.items() if not value]
    failures.extend(manifest_failures)

    print(
        json.dumps(
            {
                "result": "PASS" if not failures else "FAIL",
                "mode": "OSM_TILE_PROVIDER_POLICY_R9_0_2_CANDIDATE",
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

    print("PAL_EYES_OSM_TILE_PROVIDER_POLICY_R9_0_2_STATIC_VERIFY=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
