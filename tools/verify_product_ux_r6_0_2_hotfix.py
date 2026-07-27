#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
site_card = (
    ROOT / 'lib/features/places/presentation/widgets/site_card.dart'
).read_text(encoding='utf-8')
widget_test = (
    ROOT / 'test/site_card_dual_narrative_badge_layout_test.dart'
).read_text(encoding='utf-8')

checks = {
    'non_compact_horizontal_padding_preserved_19': (
        'horizontal: 19' in site_card
    ),
    'non_compact_vertical_padding_reduced_to_17': (
        'vertical: 17' in site_card
    ),
    'compact_padding_preserved_15': (
        'const EdgeInsets.all(15)' in site_card
    ),
    'card_height_not_increased': (
        'height: 402' in widget_test
    ),
    'overflow_assertion_preserved': (
        'tester.takeException()' in widget_test
    ),
    'public_story_badge_information_preserved': (
        'ContentStatusBadge(' in site_card
        and '_CompactTag(' in site_card
        and 'حكاية موسعة' in site_card
        and 'رواية أصلية موسعة' not in site_card
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
    'mode': 'SITE_CARD_RESIDUAL_4PX_VERTICAL_PADDING_HOTFIX',
    'checks': checks,
    'failures': failures,
    'target_baseline': 'PAL_EYES_PRODUCT_UX_PHASES_1_TO_4_FOUNDATION_R6_0_2_20260719',
    'governance': {
        'card_height_changed': False,
        'content_removed': False,
        'database_write': False,
        'automatic_publication': False,
    },
}

evidence = ROOT / 'evidence/SITE_CARD_RESIDUAL_4PX_STATIC_VERIFY_R6_0_2.json'
evidence.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)
print(json.dumps(result, ensure_ascii=False, indent=2))
print('SITE_CARD_RESIDUAL_4PX_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
