"""Mutation-based source provenance acceptance regressions."""
import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from independent_audit import audit
from normalize import normalize

ROOT = Path(__file__).resolve().parents[2]
SITE_BYTES = (ROOT / "content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_bytes()
SOURCE_BYTES = (ROOT / "content_seed/PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_bytes()
SITES, SOURCES = json.loads(SITE_BYTES), json.loads(SOURCE_BYTES)


def graph():
    from hashlib import sha256
    result = normalize(SITES, SOURCES)
    result["input_sha256"] = {"sites": sha256(SITE_BYTES).hexdigest(),
                              "sources": sha256(SOURCE_BYTES).hexdigest()}
    return result


class IndependentAuditTests(unittest.TestCase):
    def test_accepted_original_bytes(self):
        result = audit(SITE_BYTES, SOURCE_BYTES, graph())
        self.assertEqual(result["engineering_result"], "SOURCE_STRUCTURE_AND_PROVENANCE_PASS")
        self.assertEqual(result["independent_human_evidence_review"], "HOLD")
        self.assertFalse(result["publication_authorized"])

    def test_changed_source_bytes_rejected(self):
        changed = SITE_BYTES + b" "
        with self.assertRaisesRegex(ValueError, "AUDIT_SOURCE_BYTES_MISMATCH|AUDIT_SOURCE_BLOB_MISMATCH"):
            audit(changed, SOURCE_BYTES, graph())

    def test_changed_section_text_rejected(self):
        result = graph()
        result["sections"][0]["original_text"] = "Fabricated research"
        with self.assertRaisesRegex(ValueError, "AUDIT_SECTION_TEXT_TAMPER"):
            audit(SITE_BYTES, SOURCE_BYTES, result)

    def test_removed_paragraph_rejected(self):
        result = graph()
        result["paragraphs"].pop()
        with self.assertRaisesRegex(ValueError, "AUDIT_SECTION_PARAGRAPH_IDENTITY_DRIFT"):
            audit(SITE_BYTES, SOURCE_BYTES, result)

    def test_fabricated_source_relation_rejected(self):
        result = graph()
        result["source_links"][0]["site_id"] = "invented-site"
        with self.assertRaisesRegex(ValueError, "AUDIT_SOURCE_LINKAGE_DRIFT"):
            audit(SITE_BYTES, SOURCE_BYTES, result)

    def test_publication_bypass_rejected(self):
        result = graph()
        result["narratives"][0]["publication_status"] = "PUBLISHED"
        with self.assertRaisesRegex(ValueError, "AUDIT_NARRATIVE_PUBLICATION_OR_PROVENANCE_DRIFT"):
            audit(SITE_BYTES, SOURCE_BYTES, result)

    def test_approval_flag_rejected(self):
        result = graph()
        result["controls"]["public_preview_allowed"] = True
        with self.assertRaisesRegex(ValueError, "AUDIT_PUBLICATION_GUARD_DRIFT"):
            audit(SITE_BYTES, SOURCE_BYTES, result)

    def test_historical_source_not_automatically_verified(self):
        result = graph()
        result["source_links"][0]["verification_status"] = "VERIFIED"
        with self.assertRaisesRegex(ValueError, "AUDIT_SOURCE_LINK_VERIFICATION_BYPASS"):
            audit(SITE_BYTES, SOURCE_BYTES, result)

    def test_open_linkage_gap_cannot_be_hidden(self):
        result = graph()
        result["sources_pending_site_linkage"].pop()
        with self.assertRaisesRegex(ValueError, "AUDIT_UNLINKED_SOURCE_GAP_DRIFT"):
            audit(SITE_BYTES, SOURCE_BYTES, result)


if __name__ == "__main__":
    unittest.main()
