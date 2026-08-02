#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = 'PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_0_20260802'
PARENT = 'PAL_EYES_PUBLIC_EXPERIENCE_MEDIA_STAGE_BOUNDED_LAYOUT_R8_0_2_20260802'


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding='utf-8')


required_files = [
    'lib/core/widgets/direct_flutter_maturity_r9.dart',
    'test/direct_flutter_maturity_r9_widget_test.dart',
    'test/direct_flutter_maturity_r9_contract_test.dart',
    'docs/SESSION_HANDOFF_20260802_DIRECT_FLUTTER_R9_0_0.md',
    'evidence/DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_0_BUILD_EVIDENCE.json',
    'data/trackers/PAL_EYES_MASTER_SITE_STATUS_TRACKER_CURRENT.xlsx',
]

shared = read('lib/core/widgets/direct_flutter_maturity_r9.dart')
home = read('lib/features/home/presentation/home_screen.dart')
discovery = read('lib/features/discovery/presentation/discovery_screen.dart')
places = read('lib/features/places/presentation/places_screen.dart')
place_detail = read('lib/features/places/presentation/place_detail_screen.dart')
map_screen = read('lib/features/map/presentation/map_screen.dart')
stories = read('lib/features/stories/presentation/stories_screen.dart')
story_detail = read('lib/features/stories/presentation/story_detail_screen.dart')
theme = read('lib/app/theme/app_theme.dart')
widget_test = read('test/direct_flutter_maturity_r9_widget_test.dart')
contract_test = read('test/direct_flutter_maturity_r9_contract_test.dart')
baseline_id = read('PAL_EYES_BASELINE_ID.txt')
decisions = read('docs/DECISION_LOG.md')
state = json.loads(read('docs/project_memory/PAL_EYES_PROJECT_STATE_SNAPSHOT_CURRENT.json'))

ui_sources = '\n'.join(
    [
        shared,
        home,
        discovery,
        places,
        place_detail,
        map_screen,
        stories,
        story_detail,
        theme,
    ]
).lower()
write_markers = (
    '.insert(',
    '.update(',
    '.upsert(',
    '.delete(',
    'supabase.from(',
    'rpc(',
)

with (ROOT / 'data/trackers/PAL_EYES_MASTER_SITE_STATUS_TRACKER_CURRENT.csv').open(
    'r', encoding='utf-8-sig', newline=''
) as handle:
    tracker_rows = list(csv.DictReader(handle))

checks = {
    'required_files_present': all((ROOT / path).is_file() for path in required_files),
    'version_9_0_0_build_29': 'version: 9.0.0+29' in read('pubspec.yaml'),
    'target_baseline_registered': f'BASELINE_NAME={TARGET}' in baseline_id,
    'parent_baseline_registered': f'PARENT_BASELINE={PARENT}' in baseline_id,
    'figma_dependency_removed': (
        'FIGMA_DEPENDENCY=FALSE' in baseline_id
        and 'FIGMA_AS_MANDATORY_WORKFLOW=REJECTED' in baseline_id
        and 'CLOSED_AS_NON_AUTHORITATIVE_EXPERIMENT' in decisions
    ),
    'atlas_museum_magazine_identity_component': all(
        marker in shared
        for marker in (
            'class PalEyesPublicIdentityStrip',
            "PalEyesPublicPillar.atlas => 'أطلس المكان'",
            "PalEyesPublicPillar.museum => 'متحف الحكاية'",
            "PalEyesPublicPillar.magazine => 'مجلة الذاكرة'",
        )
    ),
    'identity_integrated_home_and_discovery': (
        'PalEyesPublicIdentityStrip' in home
        and 'PalEyesPublicIdentityStrip' in discovery
    ),
    'atlas_editorial_prelude': (
        'PalEyesEditorialPrelude' in places
        and '79 موقعاً تقودك من الجغرافيا إلى الحكاية' in places
    ),
    'magazine_editorial_prelude': (
        'PalEyesEditorialPrelude' in stories
        and 'ثلاث قصص تقرأ فلسطين' in stories
    ),
    'place_content_compass': (
        'PalEyesContentCompass' in place_detail
        and 'المادة التاريخية الأصلية' in place_detail
    ),
    'story_reading_maturity': (
        'PalEyesChapterRail' in story_detail
        and 'PalEyesReadingFrame' in story_detail
    ),
    'map_empty_experience_fail_closed': (
        'PalEyesMapEmptyExperience' in map_screen
        and 'mappedSitesProvider' in map_screen
        and 'reviewCoordinateSitesProvider' not in map_screen
        and 'لا نقاط مؤقتة على الخريطة العامة' in shared
    ),
    'mobile_390px_rtl_regression': (
        'Size(390, 844)' in widget_test
        and 'TextDirection.rtl' in widget_test
        and 'tester.takeException()' in widget_test
    ),
    'desktop_adaptive_regression': 'Size(1180, 800)' in widget_test,
    'accessibility_hardening': (
        'Semantics(' in shared
        and 'MaterialTapTargetSize.padded' in theme
        and 'focusColor:' in theme
        and 'hoverColor:' in theme
    ),
    'static_contract_test_present': (
        'round 3 is implemented directly in Flutter' in contract_test
        and 'preserves fail-closed publication' in contract_test
    ),
    'tracker_exact_79_rows': len(tracker_rows) == 79,
    'tracker_r9_status_applied': all(
        row.get('development_status') == 'R9_0_0_UI_BUILT_PENDING_LOCAL_UAT'
        and row.get('last_development_update') == '2026-08-02'
        for row in tracker_rows
    ),
    'state_snapshot_current': (
        state.get('governance_baseline') == TARGET
        and state.get('next_priority')
        == 'APPLY_R9_0_0_FORMAT_ANALYZE_TEST_AND_DESKTOP_MOBILE_BROWSER_UAT'
    ),
    'database_write_absent_from_ui_scope': not any(
        marker in ui_sources for marker in write_markers
    ),
    'publication_and_production_blocked': (
        'DATABASE_WRITE=FALSE' in baseline_id
        and 'SUPABASE_APPLY=FALSE' in baseline_id
        and 'PUBLICATION=BLOCKED' in baseline_id
        and 'PRODUCTION_DEPLOYMENT=NOT_APPROVED' in baseline_id
    ),
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_0',
    'checks': checks,
    'failures': failures,
    'target_baseline': TARGET,
    'parent_baseline': PARENT,
    'public_experience': {
        'identity': ['atlas', 'museum', 'magazine'],
        'site_count': 79,
        'source_count': 95,
        'story_count': 3,
        'story_chapter_count': 12,
        'public_coordinates': 0,
        'approved_media': 0,
    },
    'local_gates': {
        'dart_format': 'PENDING',
        'flutter_analyze': 'PENDING',
        'flutter_test': 'PENDING',
        'desktop_browser_uat': 'PENDING',
        'mobile_browser_uat': 'PENDING',
    },
    'governance': {
        'figma_dependency': False,
        'database_write': False,
        'supabase_apply': False,
        'public_release': 'BLOCKED',
        'production_deployment': 'NOT_APPROVED',
    },
}

evidence = (
    ROOT
    / 'evidence/DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_0_STATIC_VERIFY.json'
)
evidence.parent.mkdir(parents=True, exist_ok=True)
evidence.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)

print(json.dumps(result, ensure_ascii=False, indent=2))
print(
    'DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_0_STATIC_VERIFY='
    + result['result']
)
raise SystemExit(0 if not failures else 1)
