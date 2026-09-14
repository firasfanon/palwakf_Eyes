#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_BASELINE = (
    "PAL_EYES_OSM_TILE_PROVIDER_POLICY_AND_PRODUCTION_READINESS_"
    "R9_0_2_20260803"
)
MANIFEST_SNAPSHOT_COMMIT = "b39df1bb5b3efdd187033e68c342b14de64a980c"
MANIFEST_SNAPSHOT_BLOB = "6d405019207003f7b4c69bdea870fb52ab6c810d"


def read_text(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8-sig")


def snapshot_bytes(relative: str) -> tuple[bytes | None, str | None]:
    completed = subprocess.run(
        ["git", "show", f"{MANIFEST_SNAPSHOT_COMMIT}:{relative}"],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if completed.returncode != 0:
        error = completed.stderr.decode("utf-8", errors="replace").strip()
        return None, error
    return completed.stdout, None


def manifest_byte_candidates(data: bytes) -> list[bytes]:
    candidates: list[bytes] = [data]
    if b"\x00" not in data:
        lf = data.replace(b"\r\n", b"\n")
        crlf = lf.replace(b"\n", b"\r\n")
        candidates.extend((lf, crlf))
    unique: list[bytes] = []
    for candidate in candidates:
        if candidate not in unique:
            unique.append(candidate)
    return unique


def verify_manifest() -> tuple[bool, list[str]]:
    path = ROOT / "BASELINE_MANIFEST.json"
    if not path.is_file():
        return False, ["BASELINE_MANIFEST.json missing"]
    try:
        payload = json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as error:
        return False, [f"manifest parse error: {error}"]

    failures: list[str] = []
    if payload.get("schema_version") != 2:
        failures.append("manifest schema mismatch")
    if payload.get("manifest_role") != "VALIDATED_CANDIDATE_METADATA":
        failures.append("manifest role mismatch")
    if payload.get("baseline_name") != TARGET_BASELINE:
        failures.append("manifest baseline mismatch")
    if payload.get("version") != "9.0.2":
        failures.append("manifest version mismatch")
    if payload.get("build") != 31:
        failures.append("manifest build mismatch")
    if payload.get("status") != "VALIDATED_CANDIDATE_METADATA":
        failures.append("manifest status mismatch")
    if payload.get("candidate_metadata_only") is not True:
        failures.append("manifest candidate-only flag mismatch")
    if payload.get("sovereign_baseline_promotion") is not False:
        failures.append("manifest sovereign promotion boundary mismatch")

    snapshot_ref = payload.get("snapshot")
    if not isinstance(snapshot_ref, dict):
        failures.append("manifest snapshot reference missing")
        snapshot_ref = {}
    if snapshot_ref.get("commit") != MANIFEST_SNAPSHOT_COMMIT:
        failures.append("manifest snapshot commit mismatch")
    if snapshot_ref.get("manifest_git_blob_sha") != MANIFEST_SNAPSHOT_BLOB:
        failures.append("manifest snapshot blob mismatch")
    if snapshot_ref.get("integrity_scope") != "IMMUTABLE_R9_0_2_CHECKPOINT":
        failures.append("manifest integrity scope mismatch")

    governance = payload.get("governance")
    if not isinstance(governance, dict):
        failures.append("manifest governance missing")
        governance = {}
    if governance.get("database_write") is not False:
        failures.append("manifest database-write boundary mismatch")
    if governance.get("publication") != "BLOCKED":
        failures.append("manifest publication boundary mismatch")
    if governance.get("production_deployment") != "NOT_APPROVED":
        failures.append("manifest production boundary mismatch")
    if governance.get("baseline_promotion") != "NO":
        failures.append("manifest baseline-promotion boundary mismatch")

    snapshot_manifest, snapshot_error = snapshot_bytes("BASELINE_MANIFEST.json")
    if snapshot_manifest is None:
        return False, failures + [
            "manifest snapshot unavailable: "
            f"{MANIFEST_SNAPSHOT_COMMIT}: {snapshot_error}"
        ]
    try:
        snapshot_payload = json.loads(snapshot_manifest.decode("utf-8-sig"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        return False, failures + [f"snapshot manifest parse error: {error}"]

    if snapshot_payload.get("baseline_name") != TARGET_BASELINE:
        failures.append("snapshot baseline mismatch")
    files = snapshot_payload.get("files")
    if not isinstance(files, list):
        return False, failures + ["snapshot manifest files missing"]
    if snapshot_ref.get("file_count") != len(files):
        failures.append("manifest snapshot file-count mismatch")

    for entry in files:
        if not isinstance(entry, dict):
            failures.append("snapshot manifest entry malformed")
            continue
        relative = entry.get("path")
        if not isinstance(relative, str):
            failures.append("snapshot manifest path malformed")
            continue
        data, error = snapshot_bytes(relative)
        if data is None:
            failures.append(
                "manifest snapshot file missing: "
                f"{relative} @ {MANIFEST_SNAPSHOT_COMMIT}"
                + (f": {error}" if error else "")
            )
            continue
        expected_digest = entry.get("sha256")
        expected_size = entry.get("size_bytes")
        candidates = manifest_byte_candidates(data)
        exact_match = any(
            hashlib.sha256(candidate).hexdigest() == expected_digest
            and len(candidate) == expected_size
            for candidate in candidates
        )
        if exact_match:
            continue
        digest_match = any(
            hashlib.sha256(candidate).hexdigest() == expected_digest
            for candidate in candidates
        )
        size_match = any(len(candidate) == expected_size for candidate in candidates)
        if not digest_match:
            failures.append(f"manifest hash mismatch: {relative}")
        if not size_match:
            failures.append(f"manifest size mismatch: {relative}")
        if digest_match and size_match:
            failures.append(f"manifest digest/size pair mismatch: {relative}")

    return not failures, failures


def main() -> int:
    policy = read_text("lib/core/config/map_tile_provider_policy.dart")
    map_screen = read_text("lib/features/map/presentation/map_screen.dart")
    surface = read_text("lib/core/widgets/map_tile_policy_surface.dart")
    baseline = read_text("PAL_EYES_BASELINE_ID.txt")
    env_example = read_text(".env.example")
    web_index = read_text("web/index.html")
    pubspec = read_text("pubspec.yaml")
    workflow = read_text(".github/workflows/r9_0_2_osm_policy_validation.yml")
    manifest_ok, manifest_failures = verify_manifest()

    checks = {
        "version_9_0_2_31": bool(re.search(r"(?m)^version:\s*9\.0\.2\+31\s*$", pubspec)),
        "baseline_target": f"BASELINE_NAME={TARGET_BASELINE}" in baseline,
        "candidate_validated_not_promoted": all(
            token in baseline
            for token in (
                "STATUS=VALIDATED_CANDIDATE_METADATA",
                "CANDIDATE_METADATA_ONLY=TRUE",
                "SOVEREIGN_BASELINE_PROMOTION=NO",
            )
        ),
        "parent_commit_exact": (
            "AUTHORITATIVE_PARENT_COMMIT="
            "21d70b068870be72e573140ceb7a9ba17e644da3" in baseline
        ),
        "osm_exact_https_endpoint": "https://tile.openstreetmap.org/{z}/{x}/{y}.png" in policy,
        "production_requires_external_mode": "requestedMode != 'approved_external'" in policy,
        "production_requires_approval": "!environment.mapTileProviderApproved" in policy,
        "prefetch_disabled": "prefetchEnabled: false" in policy,
        "offline_archive_disabled": "offlineArchiveEnabled: false" in policy,
        "visible_attribution": "map-tile-attribution-visible" in surface and "\u00a9 OpenStreetMap contributors" in policy,
        "map_issue_link": "https://www.openstreetmap.org/fixthemap" in policy and "map-attribution-report-link" in surface,
        "map_screen_uses_policy": "MapTileProviderPolicy.resolve(environment)" in map_screen,
        "map_screen_has_no_hardcoded_osm_url": "https://tile.openstreetmap.org" not in map_screen,
        "map_screen_fail_closed_surface": "PalEyesMapTileBlockedNotice" in map_screen,
        "web_referrer_policy": '<meta name="referrer" content="strict-origin-when-cross-origin">' in web_index,
        "url_launcher_pinned": bool(re.search(r"(?m)^\s*url_launcher:\s*6\.3\.2\s*$", pubspec)),
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
        "policy_test_present": (ROOT / "test/map_tile_provider_policy_test.dart").is_file(),
        "surface_test_present": (ROOT / "test/map_tile_policy_surface_test.dart").is_file(),
        "new_ci_workflow": "verify_osm_tile_provider_policy_r9_0_2.py" in workflow and "flutter build web --release --no-pub" in workflow,
        "old_ci_workflow_removed": not (ROOT / ".github/workflows/r9_0_1_reconstructed_candidate_validation.yml").exists(),
        "database_write_false": "DATABASE_WRITE=FALSE" in baseline,
        "supabase_apply_false": "SUPABASE_APPLY=FALSE" in baseline,
        "public_coordinates_zero": "PUBLIC_COORDINATES=0" in baseline,
        "public_markers_zero": "PUBLIC_MARKERS=0" in baseline,
        "publication_blocked": "PUBLICATION=BLOCKED" in baseline,
        "production_not_approved": "PRODUCTION_DEPLOYMENT=NOT_APPROVED" in baseline,
        "manifest_verified": manifest_ok,
    }

    failures = [name for name, value in checks.items() if not value]
    failures.extend(manifest_failures)
    print(json.dumps({
        "result": "PASS" if not failures else "FAIL",
        "mode": "OSM_TILE_PROVIDER_POLICY_R9_0_2_VALIDATED_CANDIDATE",
        "baseline": TARGET_BASELINE,
        "checks": checks,
        "failures": failures,
    }, ensure_ascii=False, indent=2))
    if failures:
        return 1
    print("PAL_EYES_OSM_TILE_PROVIDER_POLICY_R9_0_2_STATIC_VERIFY=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
