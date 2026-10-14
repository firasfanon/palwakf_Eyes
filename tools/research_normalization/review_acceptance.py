"""Fail-closed editorial evidence review, with no approval/publishing authority.

CSV may contain HUMAN-PROPOSED linkages. This checker only validates completeness,
provenance and separation of reviewers; it never verifies the underlying evidence.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path

from review_linkage import build_linkage_review

STATES = {"PENDING_HUMAN_LINKAGE", "EVIDENCE_SUBMITTED", "INDEPENDENT_REVIEW_RECORDED"}
REVIEW_DECISIONS = {"SUPPORTS_CANDIDATE", "REQUEST_MORE_EVIDENCE", "REJECT_CANDIDATE"}
PERMITTED = {
    "candidate_site_id", "review_decision", "evidence_locator", "reviewer",
    "independent_reviewer", "independent_review_decision", "review_notes",
}


def validate_review_register(sites_doc, sources_doc, submitted):
    canonical = build_linkage_review(sites_doc, sources_doc)
    expected = {row["source_id"]: row for row in canonical}
    site_ids = {site["id"] for site in sites_doc["records"]}
    if len(submitted) != len(canonical):
        raise ValueError("REVIEW_REGISTER_ROW_COUNT_DRIFT")
    if {row.get("source_id") for row in submitted} != set(expected):
        raise ValueError("REVIEW_REGISTER_SOURCE_SET_DRIFT")
    if len({row["source_id"] for row in submitted}) != len(submitted):
        raise ValueError("DUPLICATE_REVIEW_SOURCE_ID")

    counts = {state: 0 for state in STATES}
    for row in submitted:
        reference = expected[row["source_id"]]
        if set(row) != set(reference):
            raise ValueError("REVIEW_REGISTER_COLUMNS_DRIFT")
        for field in reference:
            if field not in PERMITTED and row[field] != reference[field]:
                raise ValueError(f"CANONICAL_SOURCE_PROVENANCE_TAMPERED:{field}")
        if row["verification_status"] != "PENDING_HUMAN_REVIEW":
            raise ValueError("SELF_VERIFICATION_DENIED")
        if row["publication_status"] != "BLOCKED":
            raise ValueError("PUBLICATION_MUTATION_DENIED")
        state = row["review_decision"]
        if state not in STATES:
            raise ValueError("UNAUTHORIZED_EDITORIAL_REVIEW_STATE")
        counts[state] += 1
        candidate = row["candidate_site_id"].strip()
        locator = row["evidence_locator"].strip()
        reviewer = row["reviewer"].strip()
        second = row["independent_reviewer"].strip()
        verdict = row["independent_review_decision"].strip()
        note = row["review_notes"].strip()
        if state == "PENDING_HUMAN_LINKAGE":
            if candidate or locator or reviewer or second or verdict or note:
                raise ValueError("PENDING_WITH_UNRECORDED_PARTIAL_REVIEW")
            continue
        if candidate not in site_ids:
            raise ValueError("CANDIDATE_SITE_NOT_IN_CANONICAL_CATALOG")
        if not locator or not reviewer or len(locator) < 8:
            raise ValueError("EVIDENCE_AND_HUMAN_REVIEWER_REQUIRED")
        if state == "EVIDENCE_SUBMITTED":
            if second or verdict:
                raise ValueError("INDEPENDENT_DECISION_REQUIRES_RECORDED_REVIEW_STATE")
            continue
        if not second or second.casefold() == reviewer.casefold():
            raise ValueError("INDEPENDENT_REVIEWER_MUST_DIFFER")
        if verdict not in REVIEW_DECISIONS or not note:
            raise ValueError("INDEPENDENT_REVIEW_DECISION_AND_NOTES_REQUIRED")
    return {
        "status": "EDITORIAL_PACKET_STRUCTURALLY_VALID_NOT_SCHOLARLY_VERIFIED",
        "sources_in_scope": len(canonical),
        "review_states": {state: counts[state] for state in sorted(counts)},
        "approval_granted": False,
        "data_mutated": False,
        "publication_allowed": False,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--register", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.resolve() == args.register.resolve():
        raise ValueError("OUTPUT_MUST_NOT_OVERWRITE_HUMAN_REGISTER")
    seed = args.root / "content_seed"
    sites = json.loads((seed / "PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_bytes())
    sources = json.loads((seed / "PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_bytes())
    raw = args.register.read_bytes()
    with args.register.open(encoding="utf-8-sig", newline="") as handle:
        submitted = list(csv.DictReader(handle))
    report = validate_review_register(sites, sources, submitted)
    report["register_sha256"] = hashlib.sha256(raw).hexdigest()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
