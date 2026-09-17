#!/usr/bin/env python3
"""Build the non-production research narrative sidecar from Google Docs.

Input is a JSON manifest containing package/site/document IDs only. Research text
is fetched at execution time with an OAuth access token and is never canonicalized
into Git history. Output is intended for post-build injection into staging only.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

SCHEMA = "PAL_EYES_RESEARCH_NARRATIVE_SIDECAR_V1"
DOCS_API = "https://docs.googleapis.com/v1/documents/{}"
ALLOWED_STYLES = {"TITLE", "SUBTITLE", "HEADING_1", "HEADING_2", "HEADING_3", "NORMAL_TEXT"}

def _fetch_document(document_id: str, token: str) -> dict:
    fields = (
        "documentId,title,revisionId,body(content(paragraph(paragraphStyle(namedStyleType),"
        "elements(textRun(content))))),tabs(tabProperties(tabId),documentTab(body(content(paragraph("
        "paragraphStyle(namedStyleType),elements(textRun(content)))))))"
    )
    url = DOCS_API.format(urllib.parse.quote(document_id, safe=""))
    url += "?includeTabsContent=true&fields=" + urllib.parse.quote(fields, safe=",()")
    request = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Bearer {token}",
            "User-Agent": "pal-eyes-research-narrative-extractor-v1",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"GOOGLE_DOC_FETCH_FAILED {document_id} HTTP {exc.code}: {body}") from exc

def _paragraph_text(paragraph: dict) -> str:
    parts: list[str] = []
    for element in paragraph.get("elements", []):
        text_run = element.get("textRun") or {}
        content = text_run.get("content")
        if isinstance(content, str):
            parts.append(content)
    return "".join(parts).strip()


def _extract_blocks_from_content(content: list[dict]) -> list[dict[str, str]]:
    blocks: list[dict[str, str]] = []
    for structural in content:
        paragraph = structural.get("paragraph")
        if not isinstance(paragraph, dict):
            continue
        text = _paragraph_text(paragraph)
        if not text:
            continue
        style = ((paragraph.get("paragraphStyle") or {}).get("namedStyleType") or "NORMAL_TEXT").upper()
        if style not in ALLOWED_STYLES:
            style = "NORMAL_TEXT"
        blocks.append({"style": style, "text": text})
    return blocks

def _extract_blocks(document: dict) -> list[dict[str, str]]:
    tabs = document.get("tabs")
    if isinstance(tabs, list) and tabs:
        blocks: list[dict[str, str]] = []
        for tab in tabs:
            document_tab = (tab or {}).get("documentTab") or {}
            body = document_tab.get("body") or {}
            content = body.get("content") or []
            blocks.extend(_extract_blocks_from_content(content))
        if blocks:
            return blocks
    body = document.get("body") or {}
    return _extract_blocks_from_content(body.get("content") or [])


def _content_hash(blocks: list[dict[str, str]]) -> str:
    canonical = json.dumps(
        blocks,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(canonical).hexdigest()


def _required(item: dict, key: str) -> str:
    value = item.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"SOURCE_MANIFEST_MISSING_{key.upper()}")
    return value.strip()

def build_sidecar(source_manifest: dict, token: str) -> dict:
    raw_sources = source_manifest.get("sources")
    if not isinstance(raw_sources, list) or not raw_sources:
        raise ValueError("SOURCE_MANIFEST_SOURCES_EMPTY")

    documents: list[dict] = []
    site_ids: set[str] = set()
    for item in raw_sources:
        if not isinstance(item, dict):
            raise ValueError("SOURCE_MANIFEST_ITEM_INVALID")
        package_id = _required(item, "packageId")
        census_id = _required(item, "censusRecordId")
        site_id = _required(item, "catalogSiteId")
        document_id = _required(item, "sourceDocumentId")
        if site_id in site_ids:
            raise ValueError(f"DUPLICATE_SITE_ID={site_id}")
        site_ids.add(site_id)

        source = _fetch_document(document_id, token)
        blocks = _extract_blocks(source)
        if not blocks:
            raise ValueError(f"NO_NARRATIVE_BLOCKS={document_id}")
        revision_id = source.get("revisionId")
        if not isinstance(revision_id, str) or not revision_id:
            raise ValueError(f"REVISION_ID_MISSING={document_id}")

        documents.append(
            {
                "packageId": package_id,
                "censusRecordId": census_id,
                "catalogSiteId": site_id,
                "sourceDocumentId": document_id,
                "sourceRevisionId": revision_id,
                "sourceTitle": str(source.get("title") or document_id),
                "contentSha256": _content_hash(blocks),
                "blocks": blocks,
            }
        )

    return {
        "schema": SCHEMA,
        "documentCount": len(documents),
        "documents": documents,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument(
        "--access-token-env",
        default="GOOGLE_OAUTH_ACCESS_TOKEN",
        help="Environment variable containing a short-lived Google OAuth token.",
    )
    args = parser.parse_args()

    token = os.environ.get(args.access_token_env, "").strip()
    if not token:
        raise SystemExit(f"ACCESS_TOKEN_MISSING_ENV={args.access_token_env}")

    source_manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    sidecar = build_sidecar(source_manifest, token)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(sidecar, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"SIDECAR_SCHEMA={SCHEMA}")
    print(f"SIDECAR_DOCUMENT_COUNT={sidecar['documentCount']}")
    print(f"SIDECAR_OUTPUT={args.output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"ERROR={exc}", file=sys.stderr)
        raise SystemExit(1) from exc
