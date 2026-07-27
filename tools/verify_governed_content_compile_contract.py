#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
    files = {
        'detail': root / 'lib/features/places/presentation/place_detail_screen.dart',
        'site': root / 'lib/features/places/domain/heritage_site.dart',
        'provider': root / 'lib/features/places/application/heritage_sites_provider.dart',
        'workspace': root / 'lib/features/workspace/presentation/workspace_places_screen.dart',
        'catalog': root / 'lib/features/places/data/governed_catalog_generated.dart',
        'places': root / 'lib/features/places/presentation/places_screen.dart',
        'research': root / 'lib/features/research/presentation/research_workspace_screen.dart',
        'visibility_test': root / 'test/draft_content_visibility_test.dart',
        'dual_test': root / 'test/governed_public_display_and_legacy_evidence_contract_test.dart',
        'metric_material_test': root / 'test/legacy_narrative_metric_and_expansion_tile_material_canvas_contract_test.dart',
        'workspace_shell': root / 'lib/core/widgets/workspace_shell.dart',
        'map_screen': root / 'lib/features/map/presentation/map_screen.dart',
    }
    missing = [name for name, path in files.items() if not path.is_file()]
    if missing:
        print(json.dumps({'result': 'FAIL', 'missing': missing}, indent=2))
        return 1

    text = {name: path.read_text(encoding='utf-8') for name, path in files.items()}
    checks = {
        'detail_multiline_string_closed': all(marker in text['detail'] for marker in ('section.evidenceNote', 'الادعاء:', 'المصادر:')),
        'broken_detail_literal_absent': "text: '${section.evidenceNote}\nالادعاء:" not in text['detail'],
        'non_const_constrained_box': 'const ConstrainedBox(' not in text['detail'],
        'source_empty_message_double_quoted': 'تستمر عملية اكتشاف المصادر في مساحة الباحث.' in text['detail'],
        'trailing_added_outside_collection': 'header.add(trailing!);' in text['detail'],
        'raw_coordinate_getter': 'bool get hasCoordinates => latitude != null && longitude != null;' in text['site'],
        'public_coordinate_getter': 'bool get hasPublicCoordinates => mapDisplayApproved && hasCoordinates;' in text['site'],
        'raw_narrative_getter': 'contentProfile == DraftContentProfile.expandedNarrative;' in text['site'],
        'provider_uses_public_coordinates': '.where((site) => site.hasPublicCoordinates)' in text['provider'],
        'provider_review_coordinates_separate': '!site.hasPublicCoordinates' in text['provider'],
        'detail_uses_public_coordinates': text['detail'].count('site.hasPublicCoordinates') >= 4,
        'workspace_uses_review_coordinates': text['workspace'].count('site.hasReviewCoordinates') >= 2,
        'unused_catalog_import_removed': 'governed_source_registry_generated.dart' not in text['catalog'],
        'unused_places_import_removed': "features/places/domain/heritage_site.dart" not in text['places'],
        'research_if_has_braces': 'if (value != null) {' in text['research'],
        'visibility_test_has_57_22_contract': 'governedDraftPageCount' in text['visibility_test'] and 'limitedResearchPageCount' in text['visibility_test'],
        'dual_contract_test_present': 'legacy evidence metrics remain measurable' in text['dual_test'] and 'governed public display keeps coordinates blocked' in text['dual_test'],
        'legacy_metric_split_test_present': 'legacy narrative profile remains distinct from governed page adoption' in text['metric_material_test'] and 'dualNarrativeSiteCatalog' in text['metric_material_test'] and 'fullDraftSiteCatalog' not in text['metric_material_test'],
        'workspace_expansion_tile_material_canvas': 'return Material(\n      color: Theme.of(context).colorScheme.surface,' in text['workspace_shell'] and 'return ColoredBox(' not in text['workspace_shell'],
        'map_root_material_canvas': 'return Material(\n      color: AppColors.midnight,' in text['map_screen'] and 'return ColoredBox(' not in text['map_screen'],
    }
    failures = [name for name, value in checks.items() if not value]
    result = {'result': 'PASS' if not failures else 'FAIL', 'checks': checks, 'failures': failures}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if failures:
        return 1
    print('GOVERNED_CONTENT_COMPILE_CONTRACT_STATIC_VERIFY=PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
