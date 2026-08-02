#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
widget = (ROOT / 'lib/core/widgets/public_experience_maturity.dart').read_text(encoding='utf-8')
test_source = (ROOT / 'test/pal_eyes_media_stage_bounded_layout_test.dart').read_text(encoding='utf-8')
pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
baseline = (ROOT / 'PAL_EYES_BASELINE_ID.txt').read_text(encoding='utf-8')

checks = {
    'media_stage_explicit_finite_height': (
        'class PalEyesMediaStage extends StatelessWidget' in widget
        and 'height: height,' in widget
    ),
    'min_height_only_contract_removed': (
        'constraints: BoxConstraints(minHeight: height)' not in widget
    ),
    'stack_visual_composition_preserved': (
        'child: Stack(' in widget
        and 'const Positioned.fill(child: PalEyesPattern' in widget
        and 'PositionedDirectional(' in widget
    ),
    'desktop_scrollable_regression_test': (
        'desktop scrollable column' in test_source
        and 'SingleChildScrollView' in test_source
        and 'height: 370' in test_source
        and 'expect(stageSize.height, 370)' in test_source
    ),
    'mobile_390px_regression_test': (
        '390 pixel mobile width' in test_source
        and 'Size(390, 844)' in test_source
        and 'height: 340' in test_source
        and 'expect(stageSize.height, 340)' in test_source
    ),
    'finite_size_and_exception_assertions': (
        'stageSize.width.isFinite' in test_source
        and 'stageSize.height.isFinite' in test_source
        and 'tester.takeException()' in test_source
    ),
    'version_8_0_2': 'version: 8.0.2+28' in pubspec,
    'target_baseline_registered': 'BASELINE_NAME=PAL_EYES_PUBLIC_EXPERIENCE_MEDIA_STAGE_BOUNDED_LAYOUT_R8_0_2_20260802' in baseline,
    'database_write_absent': not any(
        marker in widget.lower()
        for marker in ('.insert(', '.update(', '.upsert(', '.delete(')
    ),
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'PUBLIC_EXPERIENCE_MEDIA_STAGE_BOUNDED_LAYOUT_R8_0_2',
    'checks': checks,
    'failures': failures,
    'target_baseline': 'PAL_EYES_PUBLIC_EXPERIENCE_MEDIA_STAGE_BOUNDED_LAYOUT_R8_0_2_20260802',
    'parent_baseline': 'PAL_EYES_PUBLIC_EXPERIENCE_ATLAS_MUSEUM_MAGAZINE_R8_0_1_20260720',
    'runtime_failure_closed': 'Stack size.isFinite under unbounded vertical constraints',
    'governance': {
        'database_write': False,
        'public_release': 'BLOCKED',
        'production_deployment': 'NOT_APPROVED',
    },
}

evidence = ROOT / 'evidence/PUBLIC_EXPERIENCE_MEDIA_STAGE_BOUNDED_LAYOUT_R8_0_2_STATIC_VERIFY.json'
evidence.parent.mkdir(parents=True, exist_ok=True)
evidence.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result, ensure_ascii=False, indent=2))
print('PUBLIC_EXPERIENCE_MEDIA_STAGE_BOUNDED_LAYOUT_R8_0_2_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
