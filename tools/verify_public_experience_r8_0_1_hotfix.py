#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

detail = (ROOT / 'lib/features/places/presentation/place_detail_screen.dart').read_text(encoding='utf-8')
places = (ROOT / 'lib/features/places/presentation/places_screen.dart').read_text(encoding='utf-8')
site_card = (ROOT / 'lib/features/places/presentation/widgets/site_card.dart').read_text(encoding='utf-8')
layout_test = (ROOT / 'test/site_card_dual_narrative_badge_layout_test.dart').read_text(encoding='utf-8')
r6_0_1 = (ROOT / 'tools/verify_product_ux_r6_0_1_hotfix.py').read_text(encoding='utf-8')
r6_0_2 = (ROOT / 'tools/verify_product_ux_r6_0_2_hotfix.py').read_text(encoding='utf-8')


def imports_sorted(source: str) -> bool:
    imports = [line for line in source.splitlines() if line.startswith('import ')]
    return imports == sorted(imports)


checks = {
    'place_detail_imports_sorted': imports_sorted(detail),
    'places_imports_sorted': imports_sorted(places),
    'site_card_uses_public_story_label': (
        "'حكاية موسعة'" in site_card
        and "'رواية أصلية موسعة'" not in site_card
    ),
    'layout_test_uses_public_story_label': (
        "find.text('حكاية موسعة')" in layout_test
        and "find.text('رواية أصلية موسعة')" not in layout_test
        and 'height: 402' in layout_test
        and 'tester.takeException()' in layout_test
    ),
    'r6_0_1_contract_reconciled': (
        'site_card_public_story_badge_layout_regression_test' in r6_0_1
        and "find.text('حكاية موسعة')" in r6_0_1
    ),
    'r6_0_2_contract_reconciled': (
        'public_story_badge_information_preserved' in r6_0_2
        and "'حكاية موسعة' in site_card" in r6_0_2
    ),
    'public_experience_identity_preserved': (
        'PalEyesMediaStage' in detail
        and 'أطلس المواقع الفلسطينية' in places
        and 'اكتشف الحكاية' in site_card
    ),
    'database_write_absent': not any(
        marker in '\n'.join(
            path.read_text(encoding='utf-8', errors='ignore')
            for path in (ROOT / 'lib').rglob('*.dart')
            if not path.as_posix().endswith(
                'lib/features/operations/data/supabase_operational_data_backend.dart'
            )
        ).lower()
        for marker in ('.insert(', '.update(', '.upsert(', '.delete(')
    ),
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'PUBLIC_EXPERIENCE_ANALYZER_AND_STORY_BADGE_R8_0_1',
    'checks': checks,
    'failures': failures,
    'target_baseline': 'PAL_EYES_PUBLIC_EXPERIENCE_ATLAS_MUSEUM_MAGAZINE_R8_0_1_20260720',
    'governance': {
        'database_write': False,
        'public_release': 'BLOCKED',
        'production_deployment': 'NOT_APPROVED',
    },
}

evidence = ROOT / 'evidence/PUBLIC_EXPERIENCE_R8_0_1_STATIC_VERIFY.json'
evidence.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result, ensure_ascii=False, indent=2))
print('PUBLIC_EXPERIENCE_R8_0_1_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
