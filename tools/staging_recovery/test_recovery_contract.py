"""Offline-only, fail-closed PAL_EYES staging recovery proposal tests.

Do not connect to Staging or execute candidate SQL. All fixtures are sanitized.
"""
import copy
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SNAP = json.loads((ROOT / "live_preflight_sanitized_20261015.json").read_text(encoding="utf-8"))
SQL = (ROOT / "legacy_public_research_repair_CANDIDATE.sql").read_text(encoding="utf-8")


def security_preflight(snapshot, sql=SQL):
    if snapshot["project_status"] != "ACTIVE_HEALTHY":
        return "HOLD_PROJECT_NOT_HEALTHY"
    if snapshot["legacy_view_definition_md5"] != "9d934935cd0891caf9e171ce1e994afe":
        return "HOLD_LEGACY_VIEW_DEFINITION_DRIFT"
    if snapshot["approved_manifests"] or snapshot["published_sites"] or snapshot["legacy_view_rows"]:
        return "HOLD_PUBLIC_CONTENT_REQUIRES_PLAN"
    if snapshot["anonymous_direct_sites_select"] or snapshot["anonymous_direct_manifests_select"]:
        return "HOLD_ANON_BASE_GRANTS"
    if not all(snapshot[k] for k in (
        "authenticated_view_select", "authenticated_sites_select",
        "authenticated_manifests_select", "preview_view_security_invoker"
    )):
        return "HOLD_AUTHENTICATED_COMPATIBILITY"
    if "REVOKE SELECT ON pal_eyes.public_research_v1 FROM PUBLIC, anon;" not in sql:
        return "HOLD_ANON_REVOKE_MISSING"
    if "security_invoker=true, security_barrier=true" not in sql:
        return "HOLD_INVOKER_GUARD_MISSING"
    if re.search(r"\bGRANT\s+[^;]*\bTO\s+(?:PUBLIC|anon)\b", sql, re.IGNORECASE):
        return "HOLD_UNSAFE_GRANTS"
    if not sql.lstrip().startswith("-- PAL_EYES:"):
        return "HOLD_UNREVIEWED_CANDIDATE"
    return "SECURITY_PATCH_DESIGN_READY_UNAPPLIED"


def recovery_decision(snapshot):
    security = security_preflight(snapshot)
    if security != "SECURITY_PATCH_DESIGN_READY_UNAPPLIED":
        return security
    if not snapshot["recoverable_backup_verified"] or not snapshot["isolated_restore_test_pass"]:
        return "HOLD_BACKUP_AND_RESTORE_NOT_PROVEN"
    if snapshot["active_editor_assignments"] < 1:
        return "HOLD_EDITOR_IDENTITY"
    if snapshot["active_system_admin_assignments"] + snapshot["active_review_manager_assignments"] < 1:
        return "HOLD_INDEPENDENT_REVIEW_AUTHORITY"
    if snapshot["verified_mfa_factors"] < 1:
        return "HOLD_VERIFIED_AAL2_CREDENTIAL"
    # UAT is a later gate, not an authorization for mutation.
    return "READY_FOR_SEPARATE_SECURITY_PATCH_AUTHORIZATION_ONLY"


class RecoveryGateTests(unittest.TestCase):
    def test_exact_live_preflight_design_ready_but_not_applied(self):
        self.assertEqual(security_preflight(SNAP), "SECURITY_PATCH_DESIGN_READY_UNAPPLIED")

    def test_actual_recovery_denies_mutation_without_backup(self):
        self.assertEqual(recovery_decision(SNAP), "HOLD_BACKUP_AND_RESTORE_NOT_PROVEN")

    def test_source_view_definition_drift_fails_closed(self):
        x = copy.deepcopy(SNAP)
        x["legacy_view_definition_md5"] = "unexpected"
        self.assertEqual(security_preflight(x), "HOLD_LEGACY_VIEW_DEFINITION_DRIFT")

    def test_public_content_prevents_legacy_deprecation(self):
        for field in ("legacy_view_rows", "published_sites", "approved_manifests"):
            x = copy.deepcopy(SNAP)
            x[field] = 1
            self.assertEqual(security_preflight(x), "HOLD_PUBLIC_CONTENT_REQUIRES_PLAN")

    def test_unexpected_direct_anonymous_grants_block(self):
        for field in ("anonymous_direct_sites_select", "anonymous_direct_manifests_select"):
            x = copy.deepcopy(SNAP)
            x[field] = True
            self.assertEqual(security_preflight(x), "HOLD_ANON_BASE_GRANTS")

    def test_authenticated_compatibility_required(self):
        x = copy.deepcopy(SNAP)
        x["authenticated_sites_select"] = False
        self.assertEqual(security_preflight(x), "HOLD_AUTHENTICATED_COMPATIBILITY")

    def test_patch_has_no_grant_of_sensitive_data(self):
        self.assertNotRegex(SQL, r"(?i)\bGRANT\s+[^;]*\bTO\s+(?:PUBLIC|anon)\b")
        self.assertIn("REVOKE SELECT ON pal_eyes.public_research_v1 FROM PUBLIC, anon;", SQL)

    def test_patch_does_not_create_or_change_tables_or_accounts(self):
        self.assertNotRegex(SQL, r"(?i)\b(CREATE\s+TABLE|ALTER\s+TABLE|ALTER\s+ROLE|UPDATE\s+auth\.users|INSERT\s+INTO|DROP\s+VIEW)\b")

    def test_patch_requires_fresh_catalog_and_zero_public_records(self):
        self.assertIn("md5(pg_get_viewdef", SQL)
        self.assertIn("EXISTING_PUBLIC_CONTENT_REQUIRES_MIGRATION_PLAN", SQL)
        self.assertIn("LEGACY_VIEW_REPAIR_POSTCHECK_FAILED", SQL)

    def test_no_restoration_of_insecure_definer_as_rollback(self):
        self.assertNotIn("security_invoker=false", SQL)
        self.assertNotIn("GRANT SELECT ON pal_eyes.public_research_v1 TO anon", SQL)

    def test_candidate_cannot_bypass_backup_with_mock_good_mfa(self):
        x = copy.deepcopy(SNAP)
        x["verified_mfa_factors"] = 2
        self.assertEqual(recovery_decision(x), "HOLD_BACKUP_AND_RESTORE_NOT_PROVEN")

    def test_verified_backup_without_restore_proof_still_hold(self):
        x = copy.deepcopy(SNAP)
        x["recoverable_backup_verified"] = True
        self.assertEqual(recovery_decision(x), "HOLD_BACKUP_AND_RESTORE_NOT_PROVEN")

    def test_isolated_restore_without_mfa_still_hold(self):
        x = copy.deepcopy(SNAP)
        x["recoverable_backup_verified"] = True
        x["isolated_restore_test_pass"] = True
        self.assertEqual(recovery_decision(x), "HOLD_VERIFIED_AAL2_CREDENTIAL")

    def test_all_gates_only_offer_separate_authorization(self):
        x = copy.deepcopy(SNAP)
        x["recoverable_backup_verified"] = True
        x["isolated_restore_test_pass"] = True
        x["verified_mfa_factors"] = 2
        self.assertEqual(recovery_decision(x), "READY_FOR_SEPARATE_SECURITY_PATCH_AUTHORIZATION_ONLY")


if __name__ == "__main__":
    unittest.main()
