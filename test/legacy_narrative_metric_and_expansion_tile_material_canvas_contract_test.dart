import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/dual_narrative_catalog.dart';

void main() {
  test('legacy narrative profile remains distinct from governed page adoption', () {
    final expandedNarratives = dualNarrativeSiteCatalog.where(
      (site) => site.hasOriginalExpandedNarrative,
    );
    final governedPages = dualNarrativeSiteCatalog.where(
      (site) => site.isGovernedDraft,
    );
    final limitedPages = dualNarrativeSiteCatalog.where(
      (site) => site.isLimitedResearch,
    );

    expect(
      expandedNarratives,
      hasLength(ContentCatalogMetrics.expandedNarrativeCount),
    );
    expect(expandedNarratives, hasLength(47));
    expect(
      governedPages,
      hasLength(ContentCatalogMetrics.governedDraftPageCount),
    );
    expect(governedPages, hasLength(57));
    expect(
      limitedPages,
      hasLength(ContentCatalogMetrics.limitedResearchPageCount),
    );
    expect(limitedPages, hasLength(22));
  });

  test('workspace ExpansionTile headers sit below a Material canvas', () {
    final source =
        File('lib/core/widgets/workspace_shell.dart').readAsStringSync();

    expect(source.contains('ExpansionTile('), isTrue);
    expect(source.contains('return ColoredBox('), isFalse);
    expect(
      source.contains(
        'return Material(\n'
        '      color: Theme.of(context).colorScheme.surface,',
      ),
      isTrue,
    );
  });
}
