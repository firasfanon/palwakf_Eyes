"""Independent negative-path editorial packet regressions."""
import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from review_linkage import build_linkage_review
from review_acceptance import validate_review_register

ROOT = Path(__file__).resolve().parents[2]
SITES = json.loads((ROOT / "content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_text(encoding="utf-8"))
SOURCES = json.loads((ROOT / "content_seed/PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_text(encoding="utf-8"))
SITE_ID = SITES["records"][0]["id"]


def pending_rows():
    return copy.deepcopy(build_linkage_review(SITES, SOURCES))


def submitted_rows():
    records = pending_rows()
    records[0].update(candidate_site_id=SITE_ID, review_decision="EVIDENCE_SUBMITTED",
                      evidence_locator="archive/example/page-12", reviewer="primary-reviewer")
    return records


class EditorialReviewAcceptanceTests(unittest.TestCase):
    def test_all_pending_are_valid_but_not_approved(self):
        result = validate_review_register(SITES, SOURCES, pending_rows())
        self.assertEqual(result["sources_in_scope"], 11)
        self.assertEqual(result["review_states"]["PENDING_HUMAN_LINKAGE"], 11)
        self.assertFalse(result["approval_granted"])
        self.assertFalse(result["publication_allowed"])

    def test_evidence_submission_is_not_scientific_verification(self):
        result = validate_review_register(SITES, SOURCES, submitted_rows())
        self.assertEqual(result["review_states"]["EVIDENCE_SUBMITTED"], 1)
        self.assertFalse(result["approval_granted"])

    def test_independent_review_requires_distinct_reviewer_and_notes(self):
        records = submitted_rows()
        records[0].update(review_decision="INDEPENDENT_REVIEW_RECORDED",
                          independent_reviewer="second-reviewer",
                          independent_review_decision="SUPPORTS_CANDIDATE",
                          review_notes="Evidence packet inspected, no database change approved")
        result = validate_review_register(SITES, SOURCES, records)
        self.assertEqual(result["review_states"]["INDEPENDENT_REVIEW_RECORDED"], 1)
        self.assertFalse(result["approval_granted"])

    def test_unknown_site_rejected(self):
        rows = submitted_rows()
        rows[0]["candidate_site_id"] = "nonexistent"
        with self.assertRaisesRegex(ValueError, "CANDIDATE_SITE_NOT_IN_CANONICAL_CATALOG"):
            validate_review_register(SITES, SOURCES, rows)

    def test_missing_evidence_rejected(self):
        rows = submitted_rows()
        rows[0]["evidence_locator"] = ""
        with self.assertRaisesRegex(ValueError, "EVIDENCE_AND_HUMAN_REVIEWER_REQUIRED"):
            validate_review_register(SITES, SOURCES, rows)

    def test_same_reviewer_rejected(self):
        rows = submitted_rows()
        rows[0].update(review_decision="INDEPENDENT_REVIEW_RECORDED",
                       independent_reviewer="PRIMARY-REVIEWER",
                       independent_review_decision="SUPPORTS_CANDIDATE",
                       review_notes="Unacceptable self-review")
        with self.assertRaisesRegex(ValueError, "INDEPENDENT_REVIEWER_MUST_DIFFER"):
            validate_review_register(SITES, SOURCES, rows)

    def test_source_metadata_tamper_rejected(self):
        rows = pending_rows()
        rows[0]["source_title"] = "Injected new source claim"
        with self.assertRaisesRegex(ValueError, "CANONICAL_SOURCE_PROVENANCE_TAMPERED"):
            validate_review_register(SITES, SOURCES, rows)

    def test_publication_bypass_rejected(self):
        rows = pending_rows()
        rows[0]["publication_status"] = "PUBLISHED"
        with self.assertRaisesRegex(ValueError, "CANONICAL_SOURCE_PROVENANCE_TAMPERED|PUBLICATION_MUTATION_DENIED"):
            validate_review_register(SITES, SOURCES, rows)

    def test_duplicates_rejected(self):
        rows = pending_rows()
        rows[-1] = copy.deepcopy(rows[0])
        with self.assertRaisesRegex(ValueError, "REVIEW_REGISTER_SOURCE_SET_DRIFT|DUPLICATE_REVIEW_SOURCE_ID"):
            validate_review_register(SITES, SOURCES, rows)

    def test_unreviewed_assignment_rejected(self):
        rows = pending_rows()
        rows[0]["candidate_site_id"] = SITE_ID
        with self.assertRaisesRegex(ValueError, "PENDING_WITH_UNRECORDED_PARTIAL_REVIEW"):
            validate_review_register(SITES, SOURCES, rows)

    def test_unrecognized_editorial_state_rejected(self):
        rows = pending_rows()
        rows[0]["review_decision"] = "APPROVED"
        with self.assertRaisesRegex(ValueError, "UNAUTHORIZED_EDITORIAL_REVIEW_STATE"):
            validate_review_register(SITES, SOURCES, rows)


if __name__ == "__main__":
    unittest.main()
