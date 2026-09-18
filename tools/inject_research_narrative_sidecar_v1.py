#!/usr/bin/env python3
"""Inject a validated research narrative sidecar into a non-production web build."""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

SCHEMA = 'PAL_EYES_RESEARCH_NARRATIVE_SIDECAR_V1'
EXPECTED_COMPLETED = 62
TARGET_NAME = 'research_narratives_v1.json'


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--sidecar', required=True, type=Path)
    parser.add_argument('--build-dir', required=True, type=Path)
    parser.add_argument('--environment', required=True)
    args = parser.parse_args()

    environment = args.environment.strip().lower()
    if environment in {'production', 'prod'}:
        raise SystemExit('PRODUCTION_SIDECAR_INJECTION_PROHIBITED')

    payload = json.loads(args.sidecar.read_text(encoding='utf-8'))
    if payload.get('schema') != SCHEMA:
        raise SystemExit('SIDECAR_SCHEMA_MISMATCH')
    documents = payload.get('documents')
    if not isinstance(documents, list) or len(documents) != EXPECTED_COMPLETED:
        raise SystemExit(
            f"SIDECAR_DOCUMENT_COUNT_MISMATCH expected={EXPECTED_COMPLETED} actual={len(documents) if isinstance(documents, list) else 'invalid'}"
        )

    site_ids = [str(item.get('catalogSiteId', '')).strip() for item in documents]
    if any(not site_id for site_id in site_ids):
        raise SystemExit('SIDECAR_SITE_ID_MISSING')
    if len(set(site_ids)) != len(site_ids):
        raise SystemExit('SIDECAR_DUPLICATE_SITE_ID')

    args.build_dir.mkdir(parents=True, exist_ok=True)
    target = args.build_dir / TARGET_NAME
    shutil.copyfile(args.sidecar, target)
    print(f'SIDECAR_INJECTION_ENVIRONMENT={environment}')
    print(f'SIDECAR_INJECTION_DOCUMENT_COUNT={len(documents)}')
    print(f'SIDECAR_INJECTION_TARGET={target}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
