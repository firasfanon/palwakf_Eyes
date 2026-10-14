"""Regression checks for governed draft normalization (standard-library only)."""
import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from normalize import normalize

ROOT = Path(__file__).resolve().parents[2]
SITES = json.loads((ROOT / "content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_text(encoding="utf-8"))
SOURCES = json.loads((ROOT / "content_seed/PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_text(encoding="utf-8"))


class NormalizeCorpusTests(unittest.TestCase):
    def test_complete_draft_graph(self):
        graph = normalize(SITES, SOURCES)
        self.assertEqual(graph["counts"], {"sites": 79, "sources": 79, "narratives": 47, "sections": 189,
                                           "paragraphs": 248, "source_links": 79, "packages": 79,
                                           "sources_pending_site_linkage": 11})
        self.assertEqual(len({n["site_id"] for n in graph["narratives"]}), 47)
        self.assertTrue({p["section_id"] for p in graph["paragraphs"]} <= {s["id"] for s in graph["sections"]})
        self.assertTrue({s["narrative_id"] for s in graph["sections"]} <= {n["id"] for n in graph["narratives"]})
        self.assertTrue({l["site_id"] for l in graph["source_links"]} <= {s["id"] for s in SITES["records"]})
        self.assertTrue({l["source_id"] for l in graph["source_links"]} <= {s["id"] for s in SOURCES["records"]})
        self.assertTrue(all(n["publication_status"] == "BLOCKED" and not n["scholarly_verified"]
                            for n in graph["narratives"]))
        self.assertTrue(all(l["verification_status"] == "PENDING_HUMAN_REVIEW"
                            for l in graph["source_links"]))
        self.assertFalse(graph["controls"]["database_applied"])
        self.assertFalse(graph["controls"]["public_preview_allowed"])

    def test_deterministic(self):
        self.assertEqual(normalize(SITES, SOURCES), normalize(SITES, SOURCES))

    def test_unknown_slug_rejected(self):
        sources = copy.deepcopy(SOURCES)
        sources["records"][0]["site_slugs"] = ["unknown-nonexistent-site"]
        with self.assertRaisesRegex(ValueError, "UNKNOWN_SOURCE_SITE_SLUG"):
            normalize(SITES, sources)

    def test_source_count_drift_rejected(self):
        sources = copy.deepcopy(SOURCES)
        sources["records"].pop()
        with self.assertRaisesRegex(ValueError, "SOURCE_COUNT_DRIFT"):
            normalize(SITES, sources)

    def test_absent_links_remain_explicitly_unverified(self):
        graph = normalize(SITES, SOURCES)
        self.assertEqual(len(graph["sources_pending_site_linkage"]), 11)
        self.assertFalse(set(graph["sources_pending_site_linkage"]) &
                         {link["source_id"] for link in graph["source_links"]})


if __name__ == "__main__":
    unittest.main()
