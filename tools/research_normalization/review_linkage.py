"""Generate a human-only source-to-site linkage review register. No guesses or DB writes."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

from normalize import normalize


def build_linkage_review(sites_doc, sources_doc):
    graph = normalize(sites_doc, sources_doc)
    pending = set(graph["sources_pending_site_linkage"])
    linked = {link["source_id"] for link in graph["source_links"]}
    if pending & linked:
        raise ValueError("PENDING_LINKAGE_HAS_AUTOMATIC_ASSIGNMENT")
    records = []
    for source in sources_doc["records"]:
        if source["id"] not in pending:
            continue
        records.append({
            "source_id": source["id"],
            "source_title": source.get("title", ""),
            "source_type": source.get("source_type_ar", ""),
            "source_attribution": source.get("attribution", ""),
            "source_review_status": source.get("review_status", ""),
            "source_git_blob": graph["source_git_blobs"]["sources"],
            "candidate_site_id": "",
            "review_decision": "PENDING_HUMAN_LINKAGE",
            "evidence_locator": "",
            "reviewer": "",
            "verification_status": "PENDING_HUMAN_REVIEW",
            "publication_status": "BLOCKED"
        })
    if len(records) != graph["counts"]["sources_pending_site_linkage"]:
        raise ValueError("PENDING_LINKAGE_COUNT_MISMATCH")
    return records


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    seed = args.root / "content_seed"
    sources_bytes = (seed / "PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json").read_bytes()
    sites_bytes = (seed / "PAL_EYES_DRAFT_SITE_CATALOG_V1.json").read_bytes()
    rows = build_linkage_review(json.loads(sites_bytes), json.loads(sources_bytes))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(json.dumps({"pending_sources": len(rows),
                      "source_sha256": hashlib.sha256(sources_bytes).hexdigest(),
                      "site_sha256": hashlib.sha256(sites_bytes).hexdigest(),
                      "output": str(args.out)}))


if __name__ == "__main__":
    main()
