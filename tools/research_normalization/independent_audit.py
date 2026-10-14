"""Independent, read-only acceptance of an offline PAL_EYES normalization artifact.

Checks source bytes, graph relations, exact unaltered section text and
non-publication invariants. Does NOT prove historical truth or DB readiness.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path


def git_blob_sha(content):
    return hashlib.sha1(b"blob " + str(len(content)).encode() + b"\0" + content).hexdigest()


def audit(source_sites_bytes, source_registry_bytes, normalized):
    raw_sites = json.loads(source_sites_bytes)["records"]
    raw_sources = json.loads(source_registry_bytes)["records"]
    if len(raw_sites) != 79 or len(raw_sources) != 79:
        raise ValueError("AUDIT_SOURCE_CARDINALITY_DRIFT")
    hash_site, hash_source = git_blob_sha(source_sites_bytes), git_blob_sha(source_registry_bytes)
    if normalized["source_git_blobs"] != {"sites": hash_site, "sources": hash_source}:
        raise ValueError("AUDIT_SOURCE_BLOB_MISMATCH")
    if normalized["input_sha256"] != {
        "sites": hashlib.sha256(source_sites_bytes).hexdigest(),
        "sources": hashlib.sha256(source_registry_bytes).hexdigest()
    }:
        raise ValueError("AUDIT_SOURCE_BYTES_MISMATCH")
    site_by_id = {site["id"]: site for site in raw_sites}
    source_by_id = {src["id"]: src for src in raw_sources}
    slug_to_site = {site["slug"]: site["id"] for site in raw_sites}
    if len(site_by_id) != 79 or len(source_by_id) != 79 or len(slug_to_site) != 79:
        raise ValueError("AUDIT_DUPLICATE_SOURCE_KEYS")

    expected_narrative_ids = {"draft-narrative-" + site["id"] for site in raw_sites
                              if site.get("expanded_narrative_draft") is not None}
    narratives = normalized["narratives"]
    if {n["id"] for n in narratives} != expected_narrative_ids or len(narratives) != len(expected_narrative_ids):
        raise ValueError("AUDIT_NARRATIVE_IDENTITY_DRIFT")
    sections = normalized["sections"]
    paragraphs = normalized["paragraphs"]
    all_sections = {s["id"]: s for s in sections}
    all_paragraphs = {p["id"]: p for p in paragraphs}
    if len(all_sections) != len(sections) or len(all_paragraphs) != len(paragraphs):
        raise ValueError("AUDIT_DUPLICATE_SUBRECORD")
    expected_sections, expected_paragraphs = {}, {}
    for n in narratives:
        raw = site_by_id.get(n["site_id"])
        draft = raw and raw.get("expanded_narrative_draft")
        if draft is None or n["title"] != draft["title"] or n["id"] != "draft-narrative-" + raw["id"]:
            raise ValueError("AUDIT_NARRATIVE_SOURCE_MISMATCH")
        if n["source_git_blob"] != hash_site or n["publication_status"] != "BLOCKED" or n["scholarly_verified"] is not False:
            raise ValueError("AUDIT_NARRATIVE_PUBLICATION_OR_PROVENANCE_DRIFT")
        for number, pair in enumerate(draft["sections"], start=1):
            section_id = f"draft-section-{raw['id']}-{number}"
            title, text = pair
            expected_sections[section_id] = (n["id"], number, title, text)
            for paragraph_number, value in enumerate(re.split(r"\n[ \t]*\n", text), start=1):
                if value.strip():
                    pid = f"draft-paragraph-{section_id}-{paragraph_number}"
                    expected_paragraphs[pid] = (section_id, paragraph_number, value.strip())
    if set(all_sections) != set(expected_sections) or set(all_paragraphs) != set(expected_paragraphs):
        raise ValueError("AUDIT_SECTION_PARAGRAPH_IDENTITY_DRIFT")
    for sid, section in all_sections.items():
        expected = expected_sections[sid]
        actual = (section["narrative_id"], section["section_order"], section["title"],
                  section["original_text"])
        if actual != expected or section["verification_status"] != "PENDING_HUMAN_REVIEW":
            raise ValueError("AUDIT_SECTION_TEXT_TAMPER")
    for pid, paragraph in all_paragraphs.items():
        expected = expected_paragraphs[pid]
        actual = (paragraph["section_id"], paragraph["paragraph_order"], paragraph["paragraph_text"])
        if actual != expected or paragraph["verification_status"] != "PENDING_HUMAN_REVIEW":
            raise ValueError("AUDIT_PARAGRAPH_TEXT_TAMPER")

    expected_links = {(src["id"], slug_to_site[slug]) for src in raw_sources
                      for slug in src["site_slugs"]}
    links = normalized["source_links"]
    actual_links = {(link["source_id"], link["site_id"]) for link in links}
    if expected_links != actual_links or len(links) != len(expected_links):
        raise ValueError("AUDIT_SOURCE_LINKAGE_DRIFT")
    if any(link["verification_status"] != "PENDING_HUMAN_REVIEW" or
           link["publication_status"] != "BLOCKED" or
           link["source_git_blob"] != hash_source for link in links):
        raise ValueError("AUDIT_SOURCE_LINK_VERIFICATION_BYPASS")
    expected_pending = {src["id"] for src in raw_sources if not src["site_slugs"]}
    if set(normalized["sources_pending_site_linkage"]) != expected_pending:
        raise ValueError("AUDIT_UNLINKED_SOURCE_GAP_DRIFT")
    if len(normalized["packages"]) != len(raw_sites) or {
        p["site_id"] for p in normalized["packages"]
    } != set(site_by_id) or any(p["publication_decision"] != "pending" for p in normalized["packages"]):
        raise ValueError("AUDIT_PACKAGE_PUBLICATION_DRIFT")
    controls = normalized["controls"]
    if controls != {
        "public_preview_allowed": False, "production_publication_allowed": False,
        "requires_human_review": True, "database_applied": False
    }:
        raise ValueError("AUDIT_PUBLICATION_GUARD_DRIFT")
    counts = normalized["counts"]
    reference = {
        "sites": len(raw_sites), "sources": len(raw_sources), "narratives": len(narratives),
        "sections": len(expected_sections), "paragraphs": len(expected_paragraphs),
        "source_links": len(expected_links), "packages": len(raw_sites),
        "sources_pending_site_linkage": len(expected_pending),
    }
    if counts != reference:
        raise ValueError("AUDIT_COUNTS_DRIFT")
    return {
        "engineering_result": "SOURCE_STRUCTURE_AND_PROVENANCE_PASS",
        "independent_human_evidence_review": "HOLD",
        "staging_database_ingestion": "NOT_EXECUTED",
        "publication_authorized": False,
        "counts": counts, "source_git_blobs": {"sites": hash_site, "sources": hash_source}
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--artifact", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.resolve() == args.artifact.resolve():
        raise ValueError("AUDIT_OUTPUT_MUST_NOT_OVERWRITE_SOURCE")
    seed = args.root / "content_seed"
    report = audit((seed / "PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_bytes(),
                   (seed / "PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_bytes(),
                   json.loads(args.artifact.read_bytes()))
    report["normalized_artifact_sha256"] = hashlib.sha256(args.artifact.read_bytes()).hexdigest()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
