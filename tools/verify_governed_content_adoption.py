#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL={message}")
    raise SystemExit(1)


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
    required = [
        'lib/features/places/data/governed_catalog_generated.dart',
        'lib/features/sources/data/governed_source_registry_generated.dart',
        'lib/features/research/data/governed_research_backlog_generated.dart',
        'lib/features/research/domain/governed_research_backlog_item.dart',
        'test/governed_content_adoption_contract_test.dart',
        'test/list_tile_material_boundary_contract_test.dart',
        'test/governed_public_display_and_legacy_evidence_contract_test.dart',
        'test/legacy_narrative_metric_and_expansion_tile_material_canvas_contract_test.dart',
        'test/original_historical_draft_layer_contract_test.dart',
        'test/dual_narrative_page_surface_contract_test.dart',
        'lib/features/places/data/dual_narrative_catalog.dart',
        'lib/features/places/domain/original_historical_draft_layer.dart',
        'lib/features/places/application/original_draft_visibility_policy.dart',
        'tools/verify_governed_content_compile_contract.py',
        'content_seed/governed/PAL_EYES_MASTER_SITE_STATUS_REGISTRY_R5_0_0.json',
        'content_seed/governed/PAL_EYES_HISTORICALLY_REVIEWED_EDITORIAL_BASELINE_V1.json',
        'content_seed/governed/PAL_EYES_HELD_CLAIM_RESEARCH_BACKLOG_V1.json',
        'content_seed/governed/PAL_EYES_SOURCE_RIGHTS_TRIAGE_V1.json',
    ]
    missing = [path for path in required if not (root / path).is_file()]
    if missing:
        fail('MISSING_FILES=' + ','.join(missing))

    catalog_text = (root / required[0]).read_text(encoding='utf-8')
    source_text = (root / required[1]).read_text(encoding='utf-8')
    backlog_text = (root / required[2]).read_text(encoding='utf-8')
    detail_text = (root / 'lib/features/places/presentation/place_detail_screen.dart').read_text(encoding='utf-8')
    places_text = (root / 'lib/features/places/presentation/places_screen.dart').read_text(encoding='utf-8')
    source_screen = (root / 'lib/features/sources/presentation/sources_screen.dart').read_text(encoding='utf-8')
    research_screen = (root / 'lib/features/research/presentation/research_workspace_screen.dart').read_text(encoding='utf-8')
    map_text = (root / 'lib/features/map/presentation/map_screen.dart').read_text(encoding='utf-8')
    public_shell_text = (root / 'lib/core/widgets/public_shell.dart').read_text(encoding='utf-8')
    workspace_shell_text = (root / 'lib/core/widgets/workspace_shell.dart').read_text(encoding='utf-8')
    material_test_text = (root / 'test/list_tile_material_boundary_contract_test.dart').read_text(encoding='utf-8')
    site_domain_text = (root / 'lib/features/places/domain/heritage_site.dart').read_text(encoding='utf-8')
    provider_text = (root / 'lib/features/places/application/heritage_sites_provider.dart').read_text(encoding='utf-8')
    dual_contract_text = (root / 'test/governed_public_display_and_legacy_evidence_contract_test.dart').read_text(encoding='utf-8')
    metric_material_test_text = (root / 'test/legacy_narrative_metric_and_expansion_tile_material_canvas_contract_test.dart').read_text(encoding='utf-8')

    checks = {
        'site_count_79': catalog_text.count('  HeritageSite(') == 79,
        'governed_page_count_57': catalog_text.count('pageCategory: GovernedPageCategory.governedDraft') == 57,
        'limited_page_count_22': catalog_text.count('pageCategory: GovernedPageCategory.limitedResearch') == 22,
        'editorial_record_count_92': catalog_text.count('      HistoricalNarrativeSection(') == 92,
        'source_count_95': source_text.count('  DraftSourceRegistryEntry(') == 95,
        'backlog_count_211': backlog_text.count('  GovernedResearchBacklogItem(') == 211,
        'publication_blocked_79': catalog_text.count('publicationBlocked: true') == 79,
        'database_import_blocked_79': catalog_text.count('databaseImportBlocked: true') == 79,
        'map_approval_false_79': catalog_text.count('mapDisplayApproved: false') == 79,
        'approved_media_zero_79': catalog_text.count('approvedMediaCount: 0') == 79,
        'detail_uses_governed_narrative': 'الحكاية المحررة' in detail_text and 'أسئلة البحث' in detail_text,
        'places_page_categories': ('حكاية موسعة' in places_text and 'بطاقة تعريف أولية' in places_text and 'صفحة بحكاية موسعة' in places_text),
        'sources_governed_registry': ('draftSourceRegistryProvider' in source_screen and 'ContentCatalogMetrics.governedSourceRegistryCount' in source_screen and 'مكتبة المصادر' in source_screen),
        'research_backlog_visible': '211 ادعاءً في Research Backlog' in research_screen,
        'public_map_guard': ('mappedSitesProvider' in map_text and 'reviewCoordinateSitesProvider' not in map_text and 'الإحداثيات العامة المعتمدة' in map_text),
        'public_shell_list_tile_material_boundaries': ('class _DrawerItem extends StatelessWidget' in public_shell_text and 'Material(\n      color: Colors.transparent,\n      child: ListTile(' in public_shell_text and 'MaterialType.transparency' not in public_shell_text),
        'workspace_list_tile_material_boundary': workspace_shell_text.count('color: Colors.transparent,') >= 1,
        'workspace_expansion_tile_material_canvas': 'return Material(\n      color: Theme.of(context).colorScheme.surface,' in workspace_shell_text and 'return ColoredBox(' not in workspace_shell_text,
        'map_list_tile_material_boundary': 'ListTile(' not in map_text,
        'map_root_material_canvas': 'return Material(\n      color: AppColors.midnight,' in map_text and 'return ColoredBox(' not in map_text,
        'material_boundary_regression_test': 'ListTile and ExpansionTile surfaces own painted Material canvases' in material_test_text,
        'public_coordinate_contract_separated': 'bool get hasPublicCoordinates => mapDisplayApproved && hasCoordinates;' in site_domain_text and '.where((site) => site.hasPublicCoordinates)' in provider_text,
        'legacy_evidence_contract_preserved': 'contentProfile == DraftContentProfile.expandedNarrative;' in site_domain_text and 'legacy evidence metrics remain measurable' in dual_contract_text and 'legacy narrative profile remains distinct from governed page adoption' in metric_material_test_text,
        'no_database_writes': not re.search(r'\.(insert|update|upsert|delete)\s*\(', '\n'.join([catalog_text, detail_text, places_text, source_screen, research_screen, map_text])),
    }

    master = json.loads((root / 'content_seed/governed/PAL_EYES_MASTER_SITE_STATUS_REGISTRY_R5_0_0.json').read_text(encoding='utf-8'))
    checks['master_site_registry_79'] = len(master['sites']) == 79
    checks['master_editorial_records_92'] = len(master['editorial_records']) == 92
    checks['master_held_claims_211'] = len(master['held_claims']) == 211

    failures = [name for name, passed in checks.items() if not passed]
    print(json.dumps({'result': 'PASS' if not failures else 'FAIL', 'checks': checks, 'failures': failures}, ensure_ascii=False, indent=2))
    if failures:
        return 1
    print('GOVERNED_CONTENT_ADOPTION_STATIC_VERIFY=PASS')
    print('DATABASE_MUTATION=NONE')
    print('PUBLICATION_APPROVAL=NOT_GRANTED')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
