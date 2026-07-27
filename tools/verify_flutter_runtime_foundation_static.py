#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

REQUIRED_FILES = [
    'pubspec.yaml',
    'analysis_options.yaml',
    'web/index.html',
    'lib/main.dart',
    'lib/app/app.dart',
    'lib/app/router/app_router.dart',
    'lib/app/router/route_paths.dart',
    'lib/core/widgets/public_shell.dart',
    'lib/core/widgets/workspace_shell.dart',
    'lib/core/widgets/draft_content_banner.dart',
    'lib/core/widgets/pal_eyes_visual_system.dart',
    'lib/core/content/content_review_status.dart',
    'lib/features/places/domain/heritage_site.dart',
    'lib/features/places/domain/draft_content_profile.dart',
    'lib/features/sources/domain/draft_source_registry_entry.dart',
    'lib/features/governorates/domain/governorate_coverage.dart',
    'lib/features/places/data/content_catalog_metrics.dart',
    'lib/features/places/data/draft_catalog_generated.dart',
    'lib/features/places/data/governed_catalog_generated.dart',
    'lib/features/sources/data/governed_source_registry_generated.dart',
    'lib/features/research/data/governed_research_backlog_generated.dart',
    'lib/features/research/domain/governed_research_backlog_item.dart',
    'test/governed_content_adoption_contract_test.dart',
    'tools/verify_governed_content_adoption.py',
    'lib/features/places/data/draft_heritage_site_repository.dart',
    'lib/features/places/application/heritage_sites_provider.dart',
    'lib/features/places/presentation/widgets/site_card.dart',
    'lib/features/places/presentation/places_screen.dart',
    'lib/features/discovery/presentation/discovery_screen.dart',
    'lib/features/governorates/presentation/governorates_screen.dart',
    'lib/features/sources/presentation/sources_screen.dart',
    'lib/features/map/presentation/map_screen.dart',
    'lib/features/timeline/presentation/timeline_screen.dart',
    'lib/features/workspace/presentation/workspace_dashboard_screen.dart',
    'lib/features/workspace/presentation/workspace_places_screen.dart',
    'reference_input/PAL_EYES_REFERENCE_DRAFT_ORIGINAL.txt',
    'content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json',
    'content_seed/PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json',
    'content_seed/PAL_EYES_GOVERNORATE_COVERAGE_V1.json',
    'evidence/FULL_DRAFT_CATALOG_EXTRACTION.json',
    'test/app_smoke_test.dart',
    'test/route_contract_test.dart',
    'test/draft_content_visibility_test.dart',
    'test/full_draft_catalog_contract_test.dart',
    'test/source_registry_contract_test.dart',
    'test/governorate_coverage_contract_test.dart',
    'test/pal_eyes_visual_card_layout_test.dart',
    'PAL_EYES_BASELINE_ID.txt',
    'Install-PalEyesDevelopmentBaseline.ps1',
    'tools/Verify-PalEyesDevelopmentBaseline.ps1',
]

DEPENDENCIES = {
    'flutter_riverpod': '^3.3.2',
    'go_router': '^17.3.0',
    'supabase_flutter': '^2.16.0',
    'flutter_map': '^8.3.1',
    'latlong2': '^0.10.1',
    'intl': '0.20.2',
}

EXPECTED_METRICS = {
    'extractedSiteCount': 79,
    'expandedNarrativeCount': 47,
    'sourceRegistryCount': 79,
    'governorateCoverageCount': 16,
    'mappedCoordinateCount': 3,
    'governedDraftPageCount': 57,
    'limitedResearchPageCount': 22,
    'reviewedEditorialRecordCount': 92,
    'governedSourceRegistryCount': 95,
    'heldClaimBacklogCount': 211,
    'publicMapCoordinateCount': 0,
    'governoratesWithoutSiteRows': 2,
}

KEY_SITE_NAMES = [
    'المسجد الأقصى المبارك / الحرم القدسي الشريف',
    'الحرم الإبراهيمي',
    'كنيسة المهد',
    'برك سليمان',
    'سبسطية',
    'تل السلطان',
    'مدينة غزة القديمة',
    'رفح التاريخية',
]

PUBLIC_ROUTES = [
    "'/'",
    "'/discover'",
    "'/places'",
    "'/places/:slug'",
    "'/map'",
    "'/timeline'",
    "'/governorates'",
    "'/stories'",
    "'/sources'",
    "'/contribute'",
    "'/methodology'",
]

WORKSPACE_ROUTE_PREFIX = "'/workspace"
GOVERNANCE_ROUTE_PREFIX = "'/admin/governance"

FORBIDDEN_PATTERNS = {
    'legacy_riverpod_import': r'flutter_riverpod/legacy\.dart',
    'service_role_literal': r'(?i)service[_-]?role',
    'hardcoded_supabase_url': r'https://[a-z0-9-]+\.supabase\.co',
    'database_insert_call': r'\.insert\s*\(',
    'database_update_call': r'\.update\s*\(',
    'database_upsert_call': r'\.upsert\s*\(',
    'database_delete_call': r'\.delete\s*\(',
    'broken_postfix_null_aware_element': r'\btrailing\?\s*,',
    'fragile_prefix_null_aware_element': r'\?trailing\s*,',
}

def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()

def read_text(root: Path, relative: str) -> str:
    return (root / relative).read_text(encoding='utf-8')

def check_json_count(
    root: Path,
    relative: str,
    expected: int,
    key: str = 'records',
) -> tuple[bool, int]:
    payload = json.loads(read_text(root, relative))
    records = payload[key]
    return len(records) == expected, len(records)

def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
    failures: list[str] = []
    checks: dict[str, object] = {}

    missing = [
        relative
        for relative in REQUIRED_FILES
        if not (root / relative).is_file()
    ]
    checks['required_files'] = (
        'PASS'
        if not missing
        else {'status': 'FAIL', 'missing': missing}
    )
    if missing:
        failures.append('required_files')

    pubspec = read_text(root, 'pubspec.yaml')
    dependency_checks: dict[str, str] = {}
    for name, version in DEPENDENCIES.items():
        pattern = (
            rf'^\s*{re.escape(name)}:\s*'
            rf'{re.escape(version)}\s*$'
        )
        passed = re.search(pattern, pubspec, re.MULTILINE) is not None
        dependency_checks[name] = 'PASS' if passed else 'FAIL'
        if not passed:
            failures.append(f'dependency:{name}')
    checks['dependencies'] = dependency_checks

    analysis_options = read_text(root, 'analysis_options.yaml')
    backup_excluded = '- backups/**' in analysis_options
    checks['backup_directory_excluded'] = (
        'PASS' if backup_excluded else 'FAIL'
    )
    if not backup_excluded:
        failures.append('backup_directory_excluded')

    dart_files = sorted(root.glob('lib/**/*.dart'))
    all_dart = '\n'.join(
        path.read_text(encoding='utf-8')
        for path in dart_files
    )

    governed_adapter_path = (
        root
        / 'lib/features/operations/data/'
        'supabase_operational_data_backend.dart'
    )
    non_backend_dart = '\n'.join(
        path.read_text(encoding='utf-8')
        for path in dart_files
        if path != governed_adapter_path
    )

    forbidden_checks: dict[str, str] = {}
    database_pattern_names = {
        'database_insert_call',
        'database_update_call',
        'database_upsert_call',
        'database_delete_call',
    }
    for name, pattern in FORBIDDEN_PATTERNS.items():
        haystack = (
            non_backend_dart
            if name in database_pattern_names
            else all_dart
        )
        found = re.search(pattern, haystack) is not None
        forbidden_checks[name] = 'FAIL' if found else 'PASS'
        if found:
            failures.append(f'forbidden:{name}')
    checks['forbidden_patterns'] = forbidden_checks

    migration_root = root / 'supabase/migrations'
    governed_migration = (
        migration_root
        / '202607190001_pal_eyes_operational_backend.sql'
    )
    migration_contract_passed = (
        governed_migration.is_file()
        and 'enable row level security'
        in governed_migration.read_text(encoding='utf-8')
        and 'PUBLICATION' not in governed_migration.name.upper()
    )
    checks['governed_database_migration_contract'] = (
        'PASS' if migration_contract_passed else 'FAIL'
    )
    if not migration_contract_passed:
        failures.append('governed_database_migration_contract')

    route_text = read_text(root, 'lib/app/router/route_paths.dart')
    route_checks: dict[str, str] = {}
    for route in PUBLIC_ROUTES:
        passed = route in route_text
        route_checks[route] = 'PASS' if passed else 'FAIL'
        if not passed:
            failures.append(f'route:{route}')
    workspace_grouped = WORKSPACE_ROUTE_PREFIX in route_text
    governance_isolated = GOVERNANCE_ROUTE_PREFIX in route_text
    route_checks['workspace_grouped'] = (
        'PASS' if workspace_grouped else 'FAIL'
    )
    route_checks['governance_isolated'] = (
        'PASS' if governance_isolated else 'FAIL'
    )
    if not workspace_grouped:
        failures.append('workspace_grouped')
    if not governance_isolated:
        failures.append('governance_isolated')
    checks['routes'] = route_checks

    metrics_text = read_text(
        root,
        'lib/features/places/data/content_catalog_metrics.dart',
    )
    metric_checks: dict[str, str] = {}
    for name, value in EXPECTED_METRICS.items():
        pattern = rf'static const int {name} = {value};'
        passed = pattern in metrics_text
        metric_checks[name] = 'PASS' if passed else 'FAIL'
        if not passed:
            failures.append(f'metric:{name}')
    checks['content_catalog_metrics'] = metric_checks

    generated_text = read_text(
        root,
        'lib/features/places/data/draft_catalog_generated.dart',
    )
    generated_counts = {
        'HeritageSite': generated_text.count('HeritageSite('),
        'DraftSourceRegistryEntry': generated_text.count(
            'DraftSourceRegistryEntry('
        ),
        'GovernorateCoverage': generated_text.count(
            'GovernorateCoverage('
        ),
        'expandedNarrative': generated_text.count(
            'contentProfile: DraftContentProfile.expandedNarrative'
        ),
        'mappedCoordinates': 79 - generated_text.count('latitude: null'),
    }
    expected_generated_counts = {
        'HeritageSite': 79,
        'DraftSourceRegistryEntry': 79,
        'GovernorateCoverage': 16,
        'expandedNarrative': 47,
        'mappedCoordinates': 3,
    }
    generated_checks: dict[str, object] = {}
    for name, expected in expected_generated_counts.items():
        actual = generated_counts[name]
        passed = actual == expected
        generated_checks[name] = {
            'status': 'PASS' if passed else 'FAIL',
            'expected': expected,
            'actual': actual,
        }
        if not passed:
            failures.append(f'generated_count:{name}')
    checks['generated_catalog_counts'] = generated_checks

    key_site_checks: dict[str, str] = {}
    for site_name in KEY_SITE_NAMES:
        passed = site_name in generated_text
        key_site_checks[site_name] = 'PASS' if passed else 'FAIL'
        if not passed:
            failures.append(f'key_site:{site_name}')
    checks['key_sites'] = key_site_checks

    fixture_publication_blocked = (
        'status: ContentReviewStatus.approved' not in generated_text
        and 'status: ContentReviewStatus.published' not in generated_text
    )
    checks['development_fixtures_unpublished'] = (
        'PASS' if fixture_publication_blocked else 'FAIL'
    )
    if not fixture_publication_blocked:
        failures.append('development_fixtures_unpublished')

    profile_text = read_text(
        root,
        'lib/features/places/domain/heritage_site.dart',
    )
    nullable_coordinates = (
        'final double? latitude;' in profile_text
        and 'final double? longitude;' in profile_text
        and 'bool get hasCoordinates' in profile_text
    )
    checks['nullable_coordinate_contract'] = (
        'PASS' if nullable_coordinates else 'FAIL'
    )
    if not nullable_coordinates:
        failures.append('nullable_coordinate_contract')

    map_text = read_text(
        root,
        'lib/features/map/presentation/map_screen.dart',
    )
    map_contract = (
        'mappedSitesProvider' in map_text
        and 'site.latitude!' in map_text
        and 'site.longitude!' in map_text
        and 'الإحداثيات العامة المعتمدة' in map_text
        and 'reviewCoordinateSitesProvider' not in map_text
        and 'PalEyesPublicStatePanel' in map_text
    )
    checks['map_coordinate_gap_contract'] = (
        'PASS' if map_contract else 'FAIL'
    )
    if not map_contract:
        failures.append('map_coordinate_gap_contract')

    governorate_text = read_text(
        root,
        'lib/features/governorates/presentation/governorates_screen.dart',
    )
    governorate_gap_contract = (
        'governorateCoverageProvider' in governorate_text
        and 'فجوة استخراج معلنة' in governorate_text
        and 'لا يعني عدم وجود مواقع تاريخية' in governorate_text
    )
    checks['governorate_gap_visibility'] = (
        'PASS' if governorate_gap_contract else 'FAIL'
    )
    if not governorate_gap_contract:
        failures.append('governorate_gap_visibility')

    source_screen_text = read_text(
        root,
        'lib/features/sources/presentation/sources_screen.dart',
    )
    source_registry_contract = (
        'draftSourceRegistryProvider' in source_screen_text
        and 'مكتبة المصادر' in source_screen_text
        and 'textReuseStatus' in source_screen_text
        and 'PalEyesPublicDisclosure' in source_screen_text
    )
    checks['source_registry_ui_contract'] = (
        'PASS' if source_registry_contract else 'FAIL'
    )
    if not source_registry_contract:
        failures.append('source_registry_ui_contract')

    pagination_files = {
        'places': 'lib/features/places/presentation/places_screen.dart',
        'discovery': (
            'lib/features/discovery/presentation/discovery_screen.dart'
        ),
        'sources': 'lib/features/sources/presentation/sources_screen.dart',
        'timeline': 'lib/features/timeline/presentation/timeline_screen.dart',
        'workspace_places': (
            'lib/features/workspace/presentation/'
            'workspace_places_screen.dart'
        ),
    }
    pagination_checks: dict[str, str] = {}
    for name, relative in pagination_files.items():
        text = read_text(root, relative)
        passed = '_pageSize' in text and 'take(' in text
        pagination_checks[name] = 'PASS' if passed else 'FAIL'
        if not passed:
            failures.append(f'pagination:{name}')
    checks['progressive_rendering'] = pagination_checks

    seed_checks: dict[str, object] = {}
    for relative, expected in [
        ('content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json', 79),
        ('content_seed/PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json', 79),
        ('content_seed/PAL_EYES_GOVERNORATE_COVERAGE_V1.json', 16),
    ]:
        passed, actual = check_json_count(root, relative, expected)
        seed_checks[relative] = {
            'status': 'PASS' if passed else 'FAIL',
            'expected': expected,
            'actual': actual,
        }
        if not passed:
            failures.append(f'seed_count:{relative}')
    checks['content_seed_counts'] = seed_checks

    extraction = json.loads(
        read_text(root, 'evidence/FULL_DRAFT_CATALOG_EXTRACTION.json')
    )
    extraction_contract = (
        extraction['extraction']['raw_site_rows'] == 79
        and extraction['extraction']['final_unique_site_catalog'] == 79
        and extraction['extraction']['expanded_narrative_mappings'] == 47
        and extraction['extraction']['source_registry_entries'] == 79
        and extraction['extraction']['governorate_coverage_records'] == 16
        and extraction['extraction']['mapped_coordinate_records'] == 3
        and extraction['extraction']['coordinate_gaps'] == 76
        and set(
            extraction['extraction'][
                'governorates_without_extracted_site_rows'
            ]
        ) == {'شمال غزة', 'دير البلح'}
        and extraction['content_policy']['published_records'] == 0
        and extraction['content_policy']['approved_records'] == 0
    )
    checks['extraction_evidence_contract'] = (
        'PASS' if extraction_contract else 'FAIL'
    )
    if not extraction_contract:
        failures.append('extraction_evidence_contract')

    import_scope_checks = {
        'site_card_governed_page_contract': (
            "import 'package:pal_eyes/features/places/domain/"
            "heritage_site.dart';"
            in read_text(
                root,
                'lib/features/places/presentation/widgets/site_card.dart',
            )
            and 'site.hasExpandedNarrative' in read_text(
                root,
                'lib/features/places/presentation/widgets/site_card.dart',
            )
            and 'site.pageCategory.labelAr' not in read_text(
                root,
                'lib/features/places/presentation/widgets/site_card.dart',
            )
            and 'اكتشف الحكاية' in read_text(
                root,
                'lib/features/places/presentation/widgets/site_card.dart',
            )
        ),
        'places_screen_unused_profile_import_removed': (
            "import 'package:pal_eyes/features/places/domain/"
            "draft_content_profile.dart';"
            not in read_text(
                root,
                'lib/features/places/presentation/places_screen.dart',
            )
        ),
        'workspace_unused_metrics_import_removed': (
            "import 'package:pal_eyes/features/places/data/"
            "content_catalog_metrics.dart';"
            not in read_text(
                root,
                'lib/features/workspace/presentation/'
                'workspace_dashboard_screen.dart',
            )
        ),
    }
    checks['extension_import_scope_regression'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in import_scope_checks.items()
    }
    for name, passed in import_scope_checks.items():
        if not passed:
            failures.append(f'extension_import_scope:{name}')

    home_source = read_text(
        root,
        'lib/features/home/presentation/home_screen.dart',
    )
    catalog_test_source = read_text(
        root,
        'test/full_draft_catalog_contract_test.dart',
    )
    smoke_test_source = read_text(
        root,
        'test/app_smoke_test.dart',
    )
    test_contract_checks = {
        'canonical_home_draft_banner_title': (
            "title: 'مسودة خاضعة للتدقيق'" in home_source
        ),
        'sebastia_qualifier_aware_assertion': (
            "name.startsWith('سبسطية')" in catalog_test_source
            and "names.contains('سبسطية')" not in catalog_test_source
        ),
        'tell_es_sultan_qualifier_aware_assertion': (
            "name.startsWith('تل السلطان')" in catalog_test_source
            and "names.contains('تل السلطان')" not in catalog_test_source
        ),
        'smoke_test_uses_governed_banner_identity': (
            "find.byKey(const Key('home-governed-draft-banner'))"
            in smoke_test_source
            and "find.text('مسودة خاضعة للتدقيق')" in smoke_test_source
            and "scrollUntilVisible" not in smoke_test_source
        ),
    }
    checks['test_contract_and_draft_banner_regression'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in test_contract_checks.items()
    }
    for name, passed in test_contract_checks.items():
        if not passed:
            failures.append(f'test_contract_banner:{name}')

    home_source = read_text(
        root,
        'lib/features/home/presentation/home_screen.dart',
    )
    smoke_test_source = read_text(
        root,
        'test/app_smoke_test.dart',
    )
    home_banner_identity_checks = {
        'banner_key_is_unique': (
            home_source.count(
                "key: Key('home-governed-draft-banner')"
            ) == 1
        ),
        'banner_is_inside_first_hero_surface': (
            home_source.index(
                "key: Key('home-governed-draft-banner')"
            ) < home_source.index(
                "'فلسطين تُروى من المكان'"
            )
        ),
        'smoke_asserts_key_identity': (
            "find.byKey(const Key('home-governed-draft-banner'))"
            in smoke_test_source
        ),
        'repeated_label_is_allowed': (
            "expect(find.text('مسودة خاضعة للتدقيق'), findsWidgets);"
            in smoke_test_source
        ),
        'fragile_scroll_contract_removed': (
            "scrollUntilVisible" not in smoke_test_source
        ),
    }
    checks['home_banner_smoke_identity_regression'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in home_banner_identity_checks.items()
    }
    for name, passed in home_banner_identity_checks.items():
        if not passed:
            failures.append(f'home_banner_identity:{name}')

    public_shell_source = read_text(
        root,
        'lib/core/widgets/public_shell.dart',
    )
    workspace_shell_source = read_text(
        root,
        'lib/core/widgets/workspace_shell.dart',
    )
    visual_system_source = read_text(
        root,
        'lib/core/widgets/pal_eyes_visual_system.dart',
    )
    page_source = read_text(
        root,
        'lib/core/widgets/pal_eyes_page.dart',
    )
    stories_source = read_text(
        root,
        'lib/features/stories/presentation/stories_screen.dart',
    )
    methodology_source = read_text(
        root,
        'lib/features/methodology/presentation/methodology_screen.dart',
    )
    contribute_source = read_text(
        root,
        'lib/features/contributions/presentation/contribute_screen.dart',
    )
    design_system_checks = {
        'brand_mark_component': (
            'class PalEyesBrandMark' in visual_system_source
        ),
        'palestine_map_artwork_component': (
            'class PalestineMapArtwork' in visual_system_source
            and 'class _PalestineMapPainter' in visual_system_source
        ),
        'page_hero_component': (
            'class PalEyesPageHero' in visual_system_source
            and 'PalEyesPageHero(' in page_source
        ),
        'public_shell_uses_brand_system': (
            'PalEyesBrandMark' in public_shell_source
            and 'AppColors.sovereignGradient' in public_shell_source
        ),
        'workspace_shell_uses_brand_system': (
            'PalEyesBrandMark' in workspace_shell_source
            and 'PalEyesPattern' in workspace_shell_source
        ),
        'home_has_map_story_category_timeline_journey': (
            'class _MapGateway' in home_source
            and 'class _EditorialStories' in home_source
            and 'class _CategoryGrid' in home_source
            and 'PalEyesTimelineBand' in home_source
            and 'class _EvidenceJourney' in home_source
            and 'class _OralMemorySection' in home_source
            and 'class _ContributionSection' in home_source
        ),
        'stories_editorial_surface': (
            'PalEyesMediaStage' in stories_source
            and 'مجلة المكان الفلسطيني' in stories_source
            and 'ابدأ القراءة' in stories_source
        ),
        'methodology_visual_journey': (
            'class _MethodStep' in methodology_source
            and 'سبع محطات واضحة' in methodology_source
        ),
        'contribution_guided_surface': (
            'class _ContributionGuide' in contribute_source
            and 'حفظ المساهمة كمسودة' in contribute_source
        ),
    }
    checks['immersive_ui_design_system'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in design_system_checks.items()
    }
    for name, passed in design_system_checks.items():
        if not passed:
            failures.append(f'immersive_ui:{name}')

    public_shell_source = read_text(
        root,
        'lib/core/widgets/public_shell.dart',
    )
    workspace_shell_source = read_text(
        root,
        'lib/core/widgets/workspace_shell.dart',
    )
    map_screen_source = read_text(
        root,
        'lib/features/map/presentation/map_screen.dart',
    )
    immersive_test_source = read_text(
        root,
        'test/immersive_home_contract_test.dart',
    )
    material_boundary_checks = {
        'public_shell_material_boundaries': (
            'class _DrawerItem extends StatelessWidget'
            in public_shell_source
            and 'color: Colors.transparent'
            in public_shell_source
            and 'child: ListTile('
            in public_shell_source
            and 'type: MaterialType.transparency'
            not in public_shell_source
        ),
        'workspace_navigation_material_boundary': (
            'color: Colors.transparent'
            in workspace_shell_source
            and 'child: ListTile(' in workspace_shell_source
            and 'type: MaterialType.transparency'
            not in workspace_shell_source
            and 'return Material(\n      color: Theme.of(context).colorScheme.surface,'
            in workspace_shell_source
            and 'return ColoredBox(' not in workspace_shell_source
        ),
        'map_gap_list_material_boundary': (
            'return Material(' in map_screen_source
            and 'color: AppColors.midnight' in map_screen_source
            and 'ListTile(' not in map_screen_source
            and 'return ColoredBox(' not in map_screen_source
        ),
        'immersive_home_dedicated_test': (
            "find.text('فلسطين تُروى من المكان')"
            in immersive_test_source
            and "home-stories-section" in immersive_test_source
            and "home-evidence-section" in immersive_test_source
            and "scrollUntilVisible" in immersive_test_source
        ),
    }
    checks['material_boundary_and_immersive_test_regression'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in material_boundary_checks.items()
    }
    for name, passed in material_boundary_checks.items():
        if not passed:
            failures.append(f'material_boundary:{name}')

    visual_system_source = read_text(
        root,
        'lib/core/widgets/pal_eyes_visual_system.dart',
    )
    home_screen_source = read_text(
        root,
        'lib/features/home/presentation/home_screen.dart',
    )
    analyzer_and_lazy_test_checks = {
        'timeline_separator_uses_wildcards': (
            'separatorBuilder: (_, _) => SizedBox('
            in visual_system_source
            and 'separatorBuilder: (_, __) => SizedBox('
            not in visual_system_source
        ),
        'map_separator_uses_wildcards': (
            'separatorBuilder: (_, _) => const SizedBox(width: 9),'
            in map_screen_source
            and 'separatorBuilder: (_, __)'
            not in map_screen_source
        ),
        'stories_section_has_stable_key': (
            "key: const Key('home-stories-section')"
            in home_screen_source
        ),
        'evidence_section_has_stable_key': (
            "key: Key('home-evidence-section')"
            in home_screen_source
        ),
        'immersive_test_scrolls_lazy_sections': (
            'scrollUntilVisible' in immersive_test_source
            and "home-stories-section" in immersive_test_source
            and "home-evidence-section" in immersive_test_source
        ),
    }
    checks['analyzer_cleanup_and_lazy_section_test_regression'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in analyzer_and_lazy_test_checks.items()
    }
    for name, passed in analyzer_and_lazy_test_checks.items():
        if not passed:
            failures.append(f'analyzer_lazy_test:{name}')

    visual_card_source = read_text(
        root,
        'lib/core/widgets/pal_eyes_visual_system.dart',
    )
    visual_card_test_source = read_text(
        root,
        'test/pal_eyes_visual_card_layout_test.dart',
    )
    compact_visual_card_checks = {
        'card_uses_bounded_layout_builder': (
            'final compact = constraints.maxHeight < 220;'
            in visual_card_source
        ),
        'description_uses_expanded_space': (
            'maxLines: compact ? 3 : 5'
            in visual_card_source
            and 'alignment: AlignmentDirectional.topStart'
            in visual_card_source
        ),
        'compact_text_uses_ellipsis': (
            visual_card_source.count(
                'overflow: TextOverflow.ellipsis'
            ) >= 3
        ),
        'compact_layout_has_widget_regression_test': (
            'visual card fits compact story height without overflow'
            in visual_card_test_source
            and 'expect(tester.takeException(), isNull);'
            in visual_card_test_source
        ),
    }
    checks['compact_visual_card_overflow_regression'] = {
        name: 'PASS' if passed else 'FAIL'
        for name, passed in compact_visual_card_checks.items()
    }
    for name, passed in compact_visual_card_checks.items():
        if not passed:
            failures.append(f'compact_visual_card:{name}')

    local_import_failures: list[str] = []
    for dart_file in dart_files:
        dart_text = dart_file.read_text(encoding='utf-8')
        imports = re.findall(
            r"import\s+'package:pal_eyes/([^']+)'\s*;",
            dart_text,
        )
        for imported in imports:
            imported_path = root / 'lib' / imported
            if not imported_path.is_file():
                local_import_failures.append(
                    f'{dart_file.relative_to(root)} -> {imported}'
                )
    checks['local_package_imports'] = (
        'PASS'
        if not local_import_failures
        else {
            'status': 'FAIL',
            'missing': local_import_failures,
        }
    )
    if local_import_failures:
        failures.append('local_package_imports')

    delimiter_failures: list[str] = []
    for dart_file in dart_files:
        text = dart_file.read_text(encoding='utf-8')
        if text.count('{') != text.count('}'):
            delimiter_failures.append(
                f'brace:{dart_file.relative_to(root)}'
            )
        if text.count('(') != text.count(')'):
            delimiter_failures.append(
                f'paren:{dart_file.relative_to(root)}'
            )
        if text.count('[') != text.count(']'):
            delimiter_failures.append(
                f'bracket:{dart_file.relative_to(root)}'
            )
    checks['basic_delimiter_balance'] = (
        'PASS'
        if not delimiter_failures
        else {
            'status': 'FAIL',
            'failures': delimiter_failures,
        }
    )
    if delimiter_failures:
        failures.append('basic_delimiter_balance')

    result = {
        'result': 'PASS' if not failures else 'FAIL',
        'mode': 'FULL_DRAFT_SITE_CATALOG_STATIC_CONTRACT',
        'root': str(root),
        'checks': checks,
        'failures': failures,
        'dart_file_count': len(dart_files),
        'source_snapshot': [
            {
                'path': str(path.relative_to(root)).replace('\\', '/'),
                'sha256': sha256_file(path),
                'size_bytes': path.stat().st_size,
            }
            for path in dart_files
        ],
        'local_flutter_gates': {
            'flutter_pub_get': 'PENDING_USER_ENVIRONMENT',
            'flutter_analyze': 'PENDING_USER_ENVIRONMENT',
            'flutter_test': 'PENDING_USER_ENVIRONMENT',
            'flutter_build_web': 'PENDING_USER_ENVIRONMENT',
            'browser_uat': 'PENDING_USER_ENVIRONMENT',
        },
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result['result'] == 'PASS' else 1

if __name__ == '__main__':
    raise SystemExit(main())
