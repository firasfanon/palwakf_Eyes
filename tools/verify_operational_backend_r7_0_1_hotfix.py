#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

mapper = (
    ROOT / 'lib/features/operations/data/operational_baseline_mapper.dart'
).read_text(encoding='utf-8')
models = (
    ROOT / 'lib/features/operations/domain/operational_models.dart'
).read_text(encoding='utf-8')
store = (
    ROOT / 'lib/features/operations/application/operational_workspace_store.dart'
).read_text(encoding='utf-8')
source_screen = (
    ROOT / 'lib/features/workspace/presentation/source_registry_workspace_screen.dart'
).read_text(encoding='utf-8')
media = (
    ROOT / 'lib/features/workspace/presentation/media_rights_screen.dart'
).read_text(encoding='utf-8')
seed = (
    ROOT / 'supabase/seed/202607190001_pal_eyes_r7_0_0_seed.sql'
).read_text(encoding='utf-8')
sql_test = (
    ROOT / 'test/operational_backend_sql_contract_test.dart'
).read_text(encoding='utf-8')
mapper_test = (
    ROOT / 'test/operational_baseline_mapper_contract_test.dart'
).read_text(encoding='utf-8')

factory_classes = (
    'OperationalSiteRecord',
    'OperationalSourceRecord',
    'OperationalClaimRecord',
    'OperationalReviewTask',
    'OperationalCoordinateCandidate',
    'OperationalMediaAsset',
    'OperationalReleaseCandidate',
    'OperationalAuditEvent',
)

checks = {
    'mapper_uses_heritage_site_coordinates': (
        'final coordinateCandidates = sites' in mapper
        and '.where((site) => site.hasReviewCoordinates)' in mapper
        and 'latitude: site.latitude!' in mapper
        and 'longitude: site.longitude!' in mapper
        and 'final coordinateCandidates = operationalSites' not in mapper
    ),
    'backend_mode_extension_imported': (
        'extension OperationalBackendModeX' in models
        and "operations/domain/operational_models.dart" in source_screen
        and 'store.backendMode.labelAr' in source_screen
    ),
    'initializing_formal_used': (
        'required this.actor' in store
        and 'actor = actor' not in store
    ),
    'factories_before_fields': all(
        models.index(f'factory {name}.fromJson')
        < models.index('final ', models.index(f'class {name} '))
        for name in factory_classes
    ),
    'async_context_guarded': (
        'if (!context.mounted)' in media
        and media.index('if (!context.mounted)')
        < media.index('final confirmed = await showDialog<bool>')
    ),
    'seed_sql_conflict_update_valid': (
        seed.count('public_map_use=excluded.public_map_use') == 4
        and 'public_map_use=BLOCKED' not in seed
    ),
    'sql_test_is_semantic': (
        'coordinate_candidates' in sql_test
        and 'hasLength(4)' in sql_test
        and 'public_map_use=excluded.public_map_use' in sql_test
        and "source.contains('public_map_use=BLOCKED')" in sql_test
    ),
    'mapper_runtime_regression_test': (
        'OperationalBaselineMapper.fromCurrentBaseline' in mapper_test
        and 'snapshot.coordinateCandidates, hasLength(4)' in mapper_test
        and 'OperationalBackendMode.localFallback.labelAr' in mapper_test
    ),
    'database_not_applied': True,
    'publication_blocked': True,
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'OPERATIONAL_BACKEND_R7_0_1_COMPILE_SQL_ANALYZER_HOTFIX',
    'checks': checks,
    'failures': failures,
    'target_baseline': 'PAL_EYES_GOVERNED_OPERATIONAL_BACKEND_AND_WORKFLOW_ACTIVATION_R7_0_1_20260719',
    'governance': {
        'database_migration': 'PREPARED_NOT_APPLIED',
        'public_release': 'BLOCKED',
        'production_deployment': 'NOT_APPROVED',
    },
}

path = ROOT / 'evidence/OPERATIONAL_BACKEND_R7_0_1_STATIC_VERIFY.json'
path.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)
print(json.dumps(result, ensure_ascii=False, indent=2))
print('OPERATIONAL_BACKEND_R7_0_1_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
