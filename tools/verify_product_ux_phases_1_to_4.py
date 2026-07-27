#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required = [
    'docs/planning/PAL_EYES_PRODUCT_UX_PHASES_1_TO_4_MASTER_PLAN.md',
    'lib/core/widgets/pal_eyes_product_ux.dart',
    'lib/features/workspace/presentation/workspace_today_screen.dart',
    'lib/features/workspace/presentation/site_editor_screen.dart',
    'lib/features/workspace/presentation/source_registry_workspace_screen.dart',
    'lib/features/workspace/presentation/claim_workspace_screen.dart',
    'lib/features/workspace/presentation/review_queue_screen.dart',
    'lib/features/workspace/presentation/gis_review_screen.dart',
    'lib/features/workspace/presentation/media_rights_screen.dart',
    'lib/features/workspace/presentation/relationships_workspace_screen.dart',
    'lib/features/workspace/presentation/release_control_screen.dart',
    'lib/features/workspace/presentation/audit_log_screen.dart',
]

route_paths = (ROOT / 'lib/app/router/route_paths.dart').read_text(encoding='utf-8')
router = (ROOT / 'lib/app/router/app_router.dart').read_text(encoding='utf-8')
shell = (ROOT / 'lib/core/widgets/workspace_shell.dart').read_text(encoding='utf-8')
home = (ROOT / 'lib/features/home/presentation/home_screen.dart').read_text(encoding='utf-8')
release = (ROOT / 'lib/features/workspace/presentation/release_control_screen.dart').read_text(encoding='utf-8')
editor = (ROOT / 'lib/features/workspace/presentation/site_editor_screen.dart').read_text(encoding='utf-8')

checks = {
    'required_files': all((ROOT / item).is_file() for item in required),
    'phase_1_public_gateways': '_ProductGatewaysSection' in home,
    'phase_2_today': 'WorkspaceTodayScreen' in router and 'workspaceToday' in route_paths,
    'phase_2_site_editor': 'SiteEditorScreen' in router and 'workspaceSiteEditor' in route_paths,
    'phase_2_sources_claims_reviews': all(
        marker in router
        for marker in (
            'SourceRegistryWorkspaceScreen',
            'ClaimWorkspaceScreen',
            'ReviewQueueScreen',
        )
    ),
    'phase_3_gis_media_relationships': all(
        marker in router
        for marker in (
            'GisReviewScreen',
            'MediaRightsScreen',
            'RelationshipsWorkspaceScreen',
        )
    ),
    'phase_4_release_audit': (
        'ReleaseControlScreen' in router and 'AuditLogScreen' in router
    ),
    'sidebar_navigation_complete': all(
        marker in shell
        for marker in (
            "label: 'اليوم'",
            "label: 'محرر الموقع'",
            "label: 'سجل المصادر'",
            "label: 'العلاقات والأسماء'",
            "label: 'المعاينة ومرشح الإصدار'",
            "label: 'سجل التدقيق'",
        )
    ),
    'publication_default_blocked': (
        'onPressed: ready ? _createCandidate : null' in release
        and 'بوابة النشر مغلقة' in release
        and 'مرشح الإصدار' in release
    ),
    'editor_fixed_actions': all(
        marker in editor
        for marker in ('حفظ المسودة', 'معاينة', 'إرسال للمراجعة')
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
    'mode': 'PRODUCT_UX_PHASES_1_TO_4_STATIC_CONTRACT',
    'checks': checks,
    'failures': failures,
    'baseline': 'PAL_EYES_PRODUCT_UX_PHASES_1_TO_4_FOUNDATION_R6_0_0_20260719',
    'governance': {
        'database_write': False,
        'automatic_publication': False,
        'production_deployment': 'NOT_APPROVED',
    },
}
evidence = ROOT / 'evidence/PRODUCT_UX_PHASES_1_TO_4_STATIC_VERIFY_R6_0_0.json'
evidence.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)
print(json.dumps(result, ensure_ascii=False, indent=2))
print('PRODUCT_UX_PHASES_1_TO_4_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
