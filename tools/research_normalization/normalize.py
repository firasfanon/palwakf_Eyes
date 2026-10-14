"""Deterministic unpublished research-corpus normalization. No DB/network operations."""
import argparse
import hashlib
import json
import re
from pathlib import Path

SITE_BLOB = "ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c"
SOURCE_BLOB = "285a708df8423cf57fcdbaa88afcb15931dfd6e7"


def normalize(sites_document, sources_document):
    sites = sites_document["records"]
    sources = sources_document["records"]
    if len(sites) != 79 or len(sources) != 79:
        raise ValueError("SOURCE_COUNT_DRIFT")
    by_slug = {}
    for site in sites:
        slug = site["slug"]
        if slug in by_slug:
            raise ValueError("DUPLICATE_SITE_SLUG")
        by_slug[slug] = site
    site_ids = {site["id"] for site in sites}
    if len(site_ids) != len(sites):
        raise ValueError("DUPLICATE_SITE_ID")
    source_ids = {source["id"] for source in sources}
    if len(source_ids) != len(sources):
        raise ValueError("DUPLICATE_SOURCE_ID")

    narratives, sections, paragraphs, links = [], [], [], []
    unlinked_sources = []
    for site in sites:
        narrative = site.get("expanded_narrative_draft")
        if narrative is None:
            if site.get("content_profile") == "expandedNarrative":
                raise ValueError("MISSING_EXPANDED_NARRATIVE")
            continue
        if site.get("content_profile") != "expandedNarrative":
            raise ValueError("UNEXPECTED_EXPANDED_NARRATIVE")
        raw_sections = narrative.get("sections")
        if not isinstance(raw_sections, list) or not raw_sections:
            raise ValueError("EMPTY_NARRATIVE_SECTIONS")
        narrative_id = "draft-narrative-" + site["id"]
        narratives.append({
            "id": narrative_id, "site_id": site["id"],
            "title": narrative["title"],
            "source_git_blob": SITE_BLOB,
            "original_source_path": "content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json",
            "research_status": "UNDER_HUMAN_REVIEW",
            "publication_status": "BLOCKED",
            "scholarly_verified": False
        })
        for index, raw_section in enumerate(raw_sections, 1):
            if not isinstance(raw_section, list) or len(raw_section) != 2:
                raise ValueError("MALFORMED_NARRATIVE_SECTION")
            heading, body = raw_section
            if not isinstance(heading, str) or not heading.strip() or not isinstance(body, str) or not body.strip():
                raise ValueError("EMPTY_SECTION_HEADING_OR_TEXT")
            section_id = f"draft-section-{site['id']}-{index}"
            sections.append({"id": section_id, "narrative_id": narrative_id, "section_order": index,
                             "title": heading, "original_text": body,
                             "verification_status": "PENDING_HUMAN_REVIEW"})
            for position, paragraph in enumerate(re.split(r"\n[ \t]*\n", body), 1):
                if paragraph.strip():
                    paragraphs.append({"id": f"draft-paragraph-{section_id}-{position}",
                                       "section_id": section_id, "paragraph_order": position,
                                       "paragraph_text": paragraph.strip(),
                                       "verification_status": "PENDING_HUMAN_REVIEW"})
    if len(narratives) != 47:
        raise ValueError("NARRATIVE_COUNT_DRIFT")
    for source in sources:
        slugs = source.get("site_slugs")
        if not isinstance(slugs, list):
            raise ValueError("INVALID_SOURCE_SITE_SLUGS")
        if not slugs:
            unlinked_sources.append(source["id"])
        for slug in slugs:
            if slug not in by_slug:
                raise ValueError(f"UNKNOWN_SOURCE_SITE_SLUG:{slug}")
            links.append({"id": f"draft-mention-{source['id']}-{by_slug[slug]['id']}",
                          "site_id": by_slug[slug]["id"], "source_id": source["id"],
                          "link_role": "UNVERIFIED_SOURCE_MENTION",
                          "verification_status": "PENDING_HUMAN_REVIEW",
                          "publication_status": "BLOCKED",
                          "source_git_blob": SOURCE_BLOB})
    if len({link["id"] for link in links}) != len(links):
        raise ValueError("DUPLICATE_SOURCE_LINK")
    if not paragraphs or len(sections) < len(narratives):
        raise ValueError("INCOMPLETE_NARRATIVE_NORMALIZATION")
    packages = [{"record_id": "draft-package-" + site["id"], "site_id": site["id"],
                 "source_git_blob": SITE_BLOB, "publication_decision": "pending",
                 "review_status": "PENDING_HUMAN_REVIEW"} for site in sites]
    return {
        "schema": "PAL_EYES_GOVERNED_RESEARCH_NORMALIZATION_V1",
        "purpose": "UNPUBLISHED_RESEARCH_REVIEW_ONLY",
        "source_git_blobs": {"sites": SITE_BLOB, "sources": SOURCE_BLOB},
        "counts": {"sites": len(sites), "sources": len(sources), "narratives": len(narratives),
                   "sections": len(sections), "paragraphs": len(paragraphs),
                   "source_links": len(links), "packages": len(packages),
                   "sources_pending_site_linkage": len(unlinked_sources)},
        "narratives": narratives, "sections": sections, "paragraphs": paragraphs,
        "source_links": links, "packages": packages,
        "sources_pending_site_linkage": unlinked_sources,
        "controls": {"public_preview_allowed": False, "production_publication_allowed": False,
                     "requires_human_review": True, "database_applied": False}
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    seed = args.root / "content_seed"
    site_bytes = (seed / "PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_bytes()
    source_bytes = (seed / "PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_bytes()
    normalized = normalize(json.loads(site_bytes), json.loads(source_bytes))
    normalized["input_sha256"] = {
        "sites": hashlib.sha256(site_bytes).hexdigest(),
        "sources": hashlib.sha256(source_bytes).hexdigest()
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"counts": normalized["counts"], "output": str(args.out)}))


if __name__ == "__main__":
    main()
