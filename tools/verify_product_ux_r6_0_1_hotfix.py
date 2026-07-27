#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

site_card = (
    ROOT / 'lib/features/places/presentation/widgets/site_card.dart'
).read_text(encoding='utf-8')
router = (
    ROOT / 'lib/app/router/app_router.dart'
).read_text(encoding='utf-8')
detail = (
    ROOT / 'lib/features/places/presentation/place_detail_screen.dart'
).read_text(encoding='utf-8')
editor = (
    ROOT / 'lib/features/workspace/presentation/site_editor_screen.dart'
).read_text(encoding='utf-8')
foundation_verifier = (
    ROOT / 'tools/verify_flutter_runtime_foundation_static.py'
).read_text(encoding='utf-8')
compile_verifier = (
    ROOT / 'tools/verify_governed_content_compile_contract.py'
).read_text(encoding='utf-8')
regression = (
    ROOT / 'test/site_card_dual_narrative_badge_layout_test.dart'
).read_text(encoding='utf-8')

def imports_sorted(source: str) -> bool:
    lines = source.splitlines()
    imports = [line for line in lines if line.startswith('import ')]
    return imports == sorted(imports)

checks = {
    'site_card_two_badges_only': (
        'ContentStatusBadge(' in site_card
        and '_CompactTag(' in site_card
        and 'label: Text(site.pageCategory.labelAr)' not in site_card
    ),
    'compact_tag_present': 'class _CompactTag extends StatelessWidget' in site_card,
    'site_card_public_story_badge_layout_regression_test': (
        'height: 402' in regression
        and "find.text('حكاية موسعة')" in regression
        and 'tester.takeException()' in regression
        and "find.text('رواية أصلية موسعة')" not in regression
    ),
    'router_imports_sorted': imports_sorted(router),
    'detail_imports_sorted': imports_sorted(detail),
    'unnecessary_underscores_removed': (
        'separatorBuilder: (_, _) =>' in editor
        and 'separatorBuilder: (_, __) =>' not in editor
    ),
    'foundation_site_card_public_contract_updated': (
        'site.hasExpandedNarrative' in foundation_verifier
        and "'site.pageCategory.labelAr' not in read_text" in foundation_verifier
        and 'اكتشف الحكاية' in foundation_verifier
    ),
    'compile_verifier_formatter_tolerant': (
        'تستمر عملية اكتشاف المصادر في مساحة الباحث.' in compile_verifier
        and 'child: Text(\\"تستمر عملية اكتشاف المصادر' not in compile_verifier
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
    'mode': 'PRODUCT_UX_R6_0_1_HOTFIX_STATIC_CONTRACT',
    'checks': checks,
    'failures': failures,
    'target_baseline': 'PAL_EYES_PRODUCT_UX_PHASES_1_TO_4_FOUNDATION_R6_0_1_20260719',
    'governance': {
        'database_write': False,
        'automatic_publication': False,
        'production_deployment': 'NOT_APPROVED',
    },
}

evidence = ROOT / 'evidence/PRODUCT_UX_R6_0_1_STATIC_VERIFY.json'
evidence.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)

print(json.dumps(result, ensure_ascii=False, indent=2))
print('PRODUCT_UX_R6_0_1_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
