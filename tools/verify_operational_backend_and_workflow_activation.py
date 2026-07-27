#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required = [
    'lib/features/operations/domain/operational_models.dart',
    'lib/features/operations/data/operational_data_backend.dart',
    'lib/features/operations/data/local_operational_data_backend.dart',
    'lib/features/operations/data/operational_baseline_mapper.dart',
    'lib/features/operations/data/operational_coordinate_seed.dart',
    'lib/features/operations/data/supabase_operational_data_backend.dart',
    'lib/features/operations/application/operational_workspace_store.dart',
    'lib/features/operations/application/operational_providers.dart',
    'supabase/migrations/202607190001_pal_eyes_operational_backend.sql',
    'supabase/seed/202607190001_pal_eyes_r7_0_0_seed.sql',
    'data/operational/PAL_EYES_OPERATIONAL_IMPORT_MANIFEST_R7_0_0.json',
    'test/operational_backend_workflow_test.dart',
    'test/operational_backend_sql_contract_test.dart',
    'test/operational_workspace_ui_binding_contract_test.dart',
    'test/operational_baseline_mapper_contract_test.dart',
]

migration = (
    ROOT / 'supabase/migrations/202607190001_pal_eyes_operational_backend.sql'
).read_text(encoding='utf-8')
seed = (
    ROOT / 'supabase/seed/202607190001_pal_eyes_r7_0_0_seed.sql'
).read_text(encoding='utf-8')
provider = (
    ROOT / 'lib/features/operations/application/operational_providers.dart'
).read_text(encoding='utf-8')
supabase_backend = (
    ROOT / 'lib/features/operations/data/supabase_operational_data_backend.dart'
).read_text(encoding='utf-8')
local_backend = (
    ROOT / 'lib/features/operations/data/local_operational_data_backend.dart'
).read_text(encoding='utf-8')
release = (ROOT / 'lib/features/workspace/presentation/release_control_screen.dart').read_text(encoding='utf-8')
audit = (ROOT / 'lib/features/workspace/presentation/audit_log_screen.dart').read_text(encoding='utf-8')
mapper = (ROOT / 'lib/features/operations/data/operational_baseline_mapper.dart').read_text(encoding='utf-8')
coordinate_seed = (ROOT / 'lib/features/operations/data/operational_coordinate_seed.dart').read_text(encoding='utf-8')
models = (ROOT / 'lib/features/operations/domain/operational_models.dart').read_text(encoding='utf-8')
source_screen = (ROOT / 'lib/features/workspace/presentation/source_registry_workspace_screen.dart').read_text(encoding='utf-8')

manifest = json.loads(
    (
        ROOT / 'data/operational/'
        'PAL_EYES_OPERATIONAL_IMPORT_MANIFEST_R7_0_0.json'
    ).read_text(encoding='utf-8')
)
counts = manifest['counts']

checks = {
    'required_files_present': all((ROOT / item).is_file() for item in required),
    'schema_pal_eyes': 'create schema if not exists pal_eyes' in migration,
    'rls_enabled_and_forced': (
        'enable row level security' in migration
        and 'force row level security' in migration
    ),
    'role_function_present': 'pal_eyes.has_any_role' in migration,
    'anonymous_writes_forbidden': (
        'grant insert on all tables in schema pal_eyes to anon' not in migration
        and 'revoke all on all tables in schema pal_eyes from anon' in migration
    ),
    'original_draft_not_public_view': 'public_original_draft' not in migration,
    'release_candidate_not_publication': (
        'createReleaseCandidate' in release
        and 'بوابة النشر مغلقة' in release
        and 'النشر الفعلي ما زال محظوراً' in release
    ),
    'hybrid_backend_selection': (
        'SupabaseOperationalDataBackend' in provider
        and 'LocalOperationalDataBackend' in provider
        and 'bootstrap.isEnabled' in provider
    ),
    'supabase_writes_confined': (
        ".schema('pal_eyes')" in supabase_backend
        and '.insert(' in supabase_backend
        and '.update(' in supabase_backend
    ),
    'local_workflow_mutations': (
        'SITE_DRAFT_SAVED' in local_backend
        and 'REVIEW_DECISION_RECORDED' in local_backend
        and 'RELEASE_CANDIDATE_CREATED' in local_backend
    ),
    'workspace_data_bound': all(
        'operationalSnapshotProvider' in (
            ROOT / path
        ).read_text(encoding='utf-8')
        for path in (
            'lib/features/workspace/presentation/workspace_today_screen.dart',
            'lib/features/workspace/presentation/site_editor_screen.dart',
            'lib/features/workspace/presentation/source_registry_workspace_screen.dart',
            'lib/features/workspace/presentation/claim_workspace_screen.dart',
            'lib/features/workspace/presentation/review_queue_screen.dart',
            'lib/features/workspace/presentation/gis_review_screen.dart',
            'lib/features/workspace/presentation/media_rights_screen.dart',
            'lib/features/workspace/presentation/release_control_screen.dart',
            'lib/features/workspace/presentation/audit_log_screen.dart',
        )
    ),
    'audit_surface_data_bound': 'auditEvents' in audit,
    'seed_sites_79': seed.count('insert into pal_eyes.sites ') == 79,
    'seed_original_layers_79': seed.count('insert into pal_eyes.original_draft_layers ') == 79,
    'seed_sources_95': seed.count('insert into pal_eyes.sources ') == 95,
    'seed_editorial_92': seed.count('insert into pal_eyes.editorial_records ') == 92,
    'seed_claims_211': seed.count('insert into pal_eyes.claims ') == 211,
    'manifest_counts_exact': counts == {
        'sites': 79,
        'original_draft_layers': 79,
        'sources': 95,
        'editorial_records': 92,
        'claims': 211,
        'site_source_links': 144,
        'relationships': 9,
        'coordinate_candidates': 4,
        'review_tasks': 16,
        'media_assets': 0,
        'release_candidates': 0,
    },
    'publication_fail_closed': (
        "publication_status text not null default 'BLOCKED'" in migration
        and "public_release_status text not null default 'BLOCKED'" in migration
        and "public_map_use text not null default 'BLOCKED'" in migration
    ),
    'local_coordinate_seed_matches_operational_seed': (
        coordinate_seed.count('OperationalCoordinateSeedEntry(') == 5
        and coordinate_seed.count("publicMapUse: 'BLOCKED'") == 4
        and "'W4-COORD-GERIZIM-001'" in coordinate_seed
        and "'W3-COORD-OMARI-001'" in coordinate_seed
        and "'W3-COORD-PORPHYRIOS-001'" in coordinate_seed
        and "'W3-COORD-GAZA-HISTORIC-CENTRE-001'" in coordinate_seed
        and 'final coordinateCandidates = operationalCoordinateSeed' in mapper
        and 'operationalCoordinateSeedSiteIds.contains(site.id)' in mapper
        and '...operationalCoordinateSeed.map(' in mapper
        and 'final coordinateCandidates = sites' not in mapper
    ),
    'backend_mode_label_extension_imported': (
        'extension OperationalBackendModeX' in models
        and "operations/domain/operational_models.dart" in source_screen
        and 'store.backendMode.labelAr' in source_screen
    ),
    'seed_coordinate_conflict_update_valid': (
        seed.count('public_map_use=excluded.public_map_use') == 4
        and 'public_map_use=BLOCKED' not in seed
    ),
    'service_role_not_in_client': 'SERVICE_ROLE' not in '\n'.join(
        path.read_text(encoding='utf-8', errors='ignore')
        for path in (ROOT / 'lib').rglob('*.dart')
    ).upper(),
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'GOVERNED_OPERATIONAL_BACKEND_AND_WORKFLOW_ACTIVATION_STATIC_CONTRACT',
    'checks': checks,
    'failures': failures,
    'counts': counts,
    'governance': {
        'production_apply': 'NOT_EXECUTED',
        'database_migration': 'PREPARED_NOT_APPLIED',
        'public_release': 'BLOCKED',
        'service_role_in_client': False,
    },
}

path = ROOT / 'evidence/OPERATIONAL_BACKEND_AND_WORKFLOW_STATIC_VERIFY_R7_0_0.json'
path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result, ensure_ascii=False, indent=2))
print('OPERATIONAL_BACKEND_AND_WORKFLOW_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
