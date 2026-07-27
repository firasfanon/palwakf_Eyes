#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT / 'content_seed/original/'
    'PAL_EYES_ORIGINAL_HISTORICAL_DRAFT_SOURCE_1F82A6C9.txt'
)
REGISTRY = (
    ROOT / 'content_seed/original/'
    'PAL_EYES_ORIGINAL_HISTORICAL_DRAFT_LAYER_REGISTRY_V1.json'
)

def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

registry = json.loads(REGISTRY.read_text(encoding='utf-8'))
records = registry['records']

heritage = (
    ROOT / 'lib/features/places/domain/heritage_site.dart'
).read_text(encoding='utf-8')
dual_catalog = (
    ROOT / 'lib/features/places/data/dual_narrative_catalog.dart'
).read_text(encoding='utf-8')
repository = (
    ROOT / 'lib/features/places/data/draft_heritage_site_repository.dart'
).read_text(encoding='utf-8')
detail = (
    ROOT / 'lib/features/places/presentation/place_detail_screen.dart'
).read_text(encoding='utf-8')
policy = (
    ROOT / 'lib/features/places/application/'
    'original_draft_visibility_policy.dart'
).read_text(encoding='utf-8')
governed = (
    ROOT / 'lib/features/places/data/governed_catalog_generated.dart'
).read_text(encoding='utf-8')
metric_test = (
    ROOT / 'test/legacy_narrative_metric_and_expansion_tile_material_canvas_contract_test.dart'
).read_text(encoding='utf-8')

checks = {
    'source_file_present': SOURCE.is_file(),
    'source_sha256_exact': sha256(SOURCE) == '1f82a6c9941063436b40d13e258f7d03b1b3b00ef209494fe7032ee756673f6d',
    'source_line_count_5334': len(
        SOURCE.read_text(encoding='utf-8').splitlines()
    ) == 5334,
    'registry_site_count_79': len(records) == 79,
    'registry_expanded_count_47': sum(
        item['content_profile'] == 'expandedNarrative'
        for item in records
    ) == 47,
    'registry_summary_count_32': sum(
        item['content_profile'] == 'catalogSummary'
        for item in records
    ) == 32,
    'heritage_original_layer_field': (
        'OriginalHistoricalDraftLayer? originalHistoricalDraft'
        in heritage
    ),
    'dual_catalog_attaches_original_layer': (
        'withOriginalHistoricalDraft' in dual_catalog
        and 'fullDraftSiteCatalog' in dual_catalog
        and 'governedSiteCatalog' in dual_catalog
    ),
    'repository_uses_dual_catalog': (
        'dualNarrativeSiteCatalog' in repository
        and 'governedSiteCatalog' not in repository
    ),
    'dual_navigation_labels': (
        "'الحكاية المحررة'" in detail
        and "'المادة التاريخية الأصلية'" in detail
    ),
    'original_surface_present': (
        '_OriginalHistoricalDraftSection' in detail
        and 'المسودة التاريخية الأصلية' in detail
    ),
    'debug_gate_enforced': (
        'kDebugMode' in policy
        and 'publicReleaseApproved = false' in policy
        and 'canRenderOriginalDraft' in detail
    ),
    'governed_catalog_not_replaced': (
        'OriginalHistoricalDraftLayer' not in governed
        and 'fullDraftSiteCatalog' not in governed
    ),
    'metric_test_uses_dual_catalog': (
        'dualNarrativeSiteCatalog' in metric_test
        and 'fullDraftSiteCatalog' not in metric_test
        and 'hasOriginalExpandedNarrative' in metric_test
    ),
    'database_writes_confined_to_governed_adapter': not any(
        marker in '\n'.join(
            path.read_text(encoding='utf-8', errors='ignore')
            for path in (ROOT / 'lib').rglob('*.dart')
            if path.as_posix().endswith(
                'lib/features/operations/data/supabase_operational_data_backend.dart'
            ) is False
        ).lower()
        for marker in ('.insert(', '.update(', '.upsert(', '.delete(')
    ),
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'ORIGINAL_HISTORICAL_DRAFT_DUAL_SURFACE_STATIC_CONTRACT',
    'checks': checks,
    'failures': failures,
    'counts': {
        'sites': len(records),
        'expanded_narratives': 47,
        'catalog_summaries': 32,
        'governed_draft_pages': 57,
        'limited_research_pages': 22,
        'reviewed_editorial_records': 92,
    },
    'governance': {
        'development_visibility': 'DEBUG_ONLY',
        'public_release': 'BLOCKED',
        'database_write': False,
    },
}

evidence = (
    ROOT / 'evidence/'
    'ORIGINAL_HISTORICAL_DRAFT_DUAL_SURFACE_STATIC_VERIFY_R5_2_1.json'
)
evidence.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)
print(json.dumps(result, ensure_ascii=False, indent=2))
print(
    'ORIGINAL_HISTORICAL_DRAFT_DUAL_SURFACE_STATIC_VERIFY='
    + result['result']
)
raise SystemExit(0 if not failures else 1)
