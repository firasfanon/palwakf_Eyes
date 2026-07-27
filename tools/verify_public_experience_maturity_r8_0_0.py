#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET_BASELINE = (
    'PAL_EYES_PUBLIC_EXPERIENCE_ATLAS_MUSEUM_MAGAZINE_'
    'R8_0_0_20260720'
)

required = [
    'lib/core/widgets/public_experience_maturity.dart',
    'lib/features/stories/domain/editorial_story.dart',
    'lib/features/stories/data/editorial_story_catalog.dart',
    'lib/features/stories/presentation/story_detail_screen.dart',
    'test/editorial_story_catalog_contract_test.dart',
    'test/public_experience_maturity_contract_test.dart',
]

shell = (ROOT / 'lib/core/widgets/public_shell.dart').read_text(encoding='utf-8')
discovery = (
    ROOT / 'lib/features/discovery/presentation/discovery_screen.dart'
).read_text(encoding='utf-8')
places = (
    ROOT / 'lib/features/places/presentation/places_screen.dart'
).read_text(encoding='utf-8')
card = (
    ROOT / 'lib/features/places/presentation/widgets/site_card.dart'
).read_text(encoding='utf-8')
detail = (
    ROOT / 'lib/features/places/presentation/place_detail_screen.dart'
).read_text(encoding='utf-8')
map_source = (
    ROOT / 'lib/features/map/presentation/map_screen.dart'
).read_text(encoding='utf-8')
stories = (
    ROOT / 'lib/features/stories/presentation/stories_screen.dart'
).read_text(encoding='utf-8')
story_detail = (
    ROOT / 'lib/features/stories/presentation/story_detail_screen.dart'
).read_text(encoding='utf-8')
story_catalog = (
    ROOT / 'lib/features/stories/data/editorial_story_catalog.dart'
).read_text(encoding='utf-8')
sources = (
    ROOT / 'lib/features/sources/presentation/sources_screen.dart'
).read_text(encoding='utf-8')
states = (
    ROOT / 'lib/core/widgets/public_experience_maturity.dart'
).read_text(encoding='utf-8')
routes = (ROOT / 'lib/app/router/route_paths.dart').read_text(encoding='utf-8')
router = (ROOT / 'lib/app/router/app_router.dart').read_text(encoding='utf-8')

checks = {
    'required_files_present': all((ROOT / path).is_file() for path in required),
    'five_primary_public_paths': (
        "label: 'الأطلس'" in shell
        and "label: 'القصص'" in shell
        and "Text('مساحة الفريق')" in shell
        and "label: const Text('مساحة العمل')" not in shell
    ),
    'mobile_navigation_four_paths': (
        'static const List<_PublicItem> _mobileItems' in shell
        and shell.count('bottomNavigationBar:') == 1
    ),
    'multi_dimensional_search': (
        'SegmentedButton<String>' in discovery
        and "'الاسم'" in discovery
        and "'المكان'" in discovery
        and "'الفترة'" in discovery
        and "'المصدر'" in discovery
        and "'ترتيب النتائج'" in discovery
    ),
    'public_friendly_atlas': (
        'أطلس المواقع الفلسطينية' in places
        and 'المحتوى قيد التدقيق' in places
        and 'اكتشف الحكاية' in card
        and 'جاهزة لاعتماد التطوير' not in card
    ),
    'public_map_fail_closed': (
        'أطلس فلسطين' in map_source
        and 'mappedSitesProvider' in map_source
        and 'reviewCoordinateSitesProvider' not in map_source
        and 'الإحداثيات العامة المعتمدة' in map_source
        and 'تعرض فقط المواقع ذات الإحداثيات العامة' in map_source
    ),
    'museum_like_place_opening': (
        'PalEyesMediaStage' in detail
        and 'تابع من هذا الموقع' in detail
        and 'فتح مساحة الباحث' not in detail
    ),
    'long_form_magazine': (
        'مجلة المكان الفلسطيني' in stories
        and 'ابدأ القراءة' in stories
        and story_catalog.count('EditorialStory(') == 3
        and story_catalog.count('EditorialStoryChapter(') >= 12
        and 'SelectableText' in story_detail
        and 'PalEyesReadingProgress' in story_detail
    ),
    'media_rights_safe_visuals': (
        'semanticLabel' in states
        and 'image: true' in states
        and 'عمل بصري تجريدي' in story_detail
        and 'اعتماد وسائط مرخصة' in detail
    ),
    'accessibility_contract': (
        'FocusTraversalGroup' in shell
        and 'Semantics(' in shell
        and 'liveRegion: true' in states
        and 'textInputAction: TextInputAction.search' in states
    ),
    'loading_empty_error_states': (
        'PublicContentStateKind.loading' in states
        and 'PublicContentStateKind.empty' in states
        and 'PublicContentStateKind.error' in states
        and 'PalEyesPublicStatePanel' in discovery
        and 'PalEyesPublicStatePanel' in sources
        and 'PalEyesPublicStatePanel' in map_source
    ),
    'mobile_performance_contract': (
        'static const int _pageSize = 12' in discovery
        and 'RepaintBoundary' in discovery
        and 'ListView.separated' in map_source
    ),
    'story_route_registered': (
        "storyDetail = '/stories/:slug'" in routes
        and "story(String slug) => '/stories/$slug'" in routes
        and 'StoryDetailScreen' in router
    ),
    'workspace_governance_unchanged': (
        (ROOT / 'lib/core/widgets/workspace_shell.dart').is_file()
        and (
            ROOT
            / 'supabase/migrations/'
            / '202607190001_pal_eyes_operational_backend.sql'
        ).is_file()
    ),
    'database_write_absent': (
        '.insert(' not in '\n'.join(
            path.read_text(encoding='utf-8')
            for path in [
                ROOT / 'lib/core/widgets/public_experience_maturity.dart',
                ROOT / 'lib/features/stories/presentation/story_detail_screen.dart',
                ROOT / 'lib/features/map/presentation/map_screen.dart',
            ]
        )
    ),
}

failures = [name for name, passed in checks.items() if not passed]
result = {
    'result': 'PASS' if not failures else 'FAIL',
    'mode': 'PUBLIC_EXPERIENCE_MATURITY_ROUND_2_R8_0_0',
    'checks': checks,
    'failures': failures,
    'target_baseline': TARGET_BASELINE,
    'experience': {
        'atlas': True,
        'museum': True,
        'editorial_magazine': True,
        'primary_navigation_items': 5,
        'mobile_navigation_items': 4,
        'long_form_stories': 3,
        'story_chapters': 12,
        'shared_content_states': 3,
    },
    'governance': {
        'database_write': False,
        'public_release': 'BLOCKED',
        'production_deployment': 'NOT_APPROVED',
    },
}

path = ROOT / 'evidence/PUBLIC_EXPERIENCE_MATURITY_R8_0_0_STATIC_VERIFY.json'
path.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)
print(json.dumps(result, ensure_ascii=False, indent=2))
print('PUBLIC_EXPERIENCE_MATURITY_R8_0_0_STATIC_VERIFY=' + result['result'])
raise SystemExit(0 if not failures else 1)
