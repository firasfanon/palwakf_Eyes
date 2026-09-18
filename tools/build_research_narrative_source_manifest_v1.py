#!/usr/bin/env python3
"""Build the 62-item research narrative source manifest from promotion CSV."""

from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path

DRAFT_ID_RE = re.compile(r"(?:unified draft|unified document ID)\s+([A-Za-z0-9_-]{20,})", re.I)
EXPECTED_COMPLETED = 62


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--promotion-csv', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()

    sources = []
    with args.promotion_csv.open('r', encoding='utf-8-sig', newline='') as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            if row.get('package_class') != 'GOVERNED_CONTENT_PACKAGE_REFERENCE_MANIFEST':
                continue
            source_reference = row.get('source_reference', '')
            match = DRAFT_ID_RE.search(source_reference)
            if not match:
                raise SystemExit(f"UNIFIED_DRAFT_LOCATOR_MISSING={row.get('package_id')}")
            sources.append(
                {
                    'packageId': row['package_id'].strip(),
                    'censusRecordId': row['census_record_id'].strip(),
                    'catalogSiteId': row['catalog_site_id'].strip(),
                    'sourceDocumentId': match.group(1),
                }
            )

    if len(sources) != EXPECTED_COMPLETED:
        raise SystemExit(
            f"COMPLETED_SOURCE_COUNT_MISMATCH expected={EXPECTED_COMPLETED} actual={len(sources)}"
        )

    site_ids = {item['catalogSiteId'] for item in sources}
    if len(site_ids) != len(sources):
        raise SystemExit('DUPLICATE_CATALOG_SITE_ID_IN_SOURCE_MANIFEST')

    payload = {
        'schema': 'PAL_EYES_RESEARCH_NARRATIVE_SOURCE_MANIFEST_V1',
        'sourceCount': len(sources),
        'sources': sources,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
        newline='\n',
    )
    print(f"SOURCE_MANIFEST_COUNT={len(sources)}")
    print(f"SOURCE_MANIFEST_OUTPUT={args.output}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
