#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

mapper = (
    ROOT / 'lib/features/operations/data/operational_baseline_mapper.dart'
).read_text(encoding='utf-8')
coordinate_seed = (
    ROOT / 'lib/features/operations/data/operational_coordinate_seed.dart'
).read_text(encoding='utf-8')
sql_seed = (
    ROOT / 'supabase/seed/202607190001_pal_eyes_r7_0_0_seed.sql'
).read_text(encoding='utf-8')
runtime_test = (
    ROOT / 'test/operational_baseline_mapper_contract_test.dart'
).read_text(encoding='utf-8')
manifest = json.loads(
    (
        ROOT / 'data/operational/'
        'PAL_EYES_OPERATIONAL_IMPORT_MANIFEST_R7_0_0.json'
    ).read_text(encoding='utf-8')
)

expected_ids = {
    'W4-COORD-GERIZIM-001',
    'W3-COORD-OMARI-001',
    'W3-COORD-PORPHYRIOS-001',
    'W3-COORD-GAZA-HISTORIC-CENTRE-001',
}

dart_ids = set(
    re.findall(
        r"OperationalCoordinateSeedEntry\(\s*id: '([^']+)'",
        coordinate_seed,
    )
)
sql_ids = set(
    re.findall(
        r"coordinate_candidates .*? values \('([^']+)'",
        sql_seed,
    )
)

checks = {
    'exact_four_coordinate_seed_ids': (
        dart_ids == expected_ids
        and sql_ids == expected_ids
    ),
    'manifest_coordinate_count_four': (
        manifest['counts']['coordinate_candidates'] == 4
    ),
    'manifest_review_task_count_sixteen': (
        manifest['counts']['review_tasks'] == 16
    ),
    'mapper_uses_operational_coordinate_seed': (
        'final coordinateCandidates = operationalCoordinateSeed' in mapper
        and 'operationalCoordinateSeedSiteIds.contains(site.id)' in mapper
        and '...operationalCoordinateSeed.map(' in mapper
        and 'final coordinateCandidates = sites' not in mapper
    ),
    'all_candidates_fail_closed': (
        coordinate_seed.count("publicMapUse: 'BLOCKED'") == 4
        and coordinate_seed.count(
            "promotionStatus: 'NOT_PROMOTED'"
        ) == 4
    ),
    'runtime_test_checks_exact_ids': (
        'const expectedIds = <String>{' in runtime_test
        and 'snapshot.coordinateCandidates, hasLength(4)' in runtime_test
        and 'snapshot.reviewTasks, hasLength(16)' in runtime_test
        and "task.reviewType == 'GIS'" in runtime_test
    ),
    'database_not_applied': True,
    'publication_blocked': True,
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'OPERATIONAL_LOCAL_FALLBACK_COORDINATE_SEED_PARITY_R7_0_2',
    'checks': checks,
    'failures': failures,
    'counts': {
        'coordinate_candidates': 4,
        'review_tasks': 16,
        'gis_review_tasks': 4,
        'public_coordinates': 0,
    },
    'target_baseline': 'PAL_EYES_GOVERNED_OPERATIONAL_BACKEND_AND_WORKFLOW_ACTIVATION_R7_0_2_20260719',
    'governance': {
        'database_migration': 'PREPARED_NOT_APPLIED',
        'public_release': 'BLOCKED',
        'production_deployment': 'NOT_APPROVED',
    },
}

evidence = ROOT / 'evidence/OPERATIONAL_BACKEND_R7_0_2_STATIC_VERIFY.json'
evidence.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)

print(json.dumps(result, ensure_ascii=False, indent=2))
print('OPERATIONAL_BACKEND_R7_0_2_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
