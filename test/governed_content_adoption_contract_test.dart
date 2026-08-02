import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/governed_catalog_generated.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/research/data/governed_research_backlog_generated.dart';
import 'package:pal_eyes/features/sources/data/governed_source_registry_generated.dart';

void main() {
  test('governed content adoption counts and publication gates are exact', () {
    expect(governedSiteCatalog.length, 79);
    expect(
      governedSiteCatalog.where((site) => site.isGovernedDraft).length,
      ContentCatalogMetrics.governedDraftPageCount,
    );
    expect(
      governedSiteCatalog.where((site) => site.isLimitedResearch).length,
      ContentCatalogMetrics.limitedResearchPageCount,
    );
    expect(
      governedSiteCatalog.fold<int>(0, (sum, site) => sum + site.claimCount),
      ContentCatalogMetrics.reviewedEditorialRecordCount,
    );
    expect(governedSourceRegistry.length, 95);
    expect(governedResearchBacklog.length, 211);
    expect(governedSiteCatalog.every((site) => site.publicationBlocked), isTrue);
    expect(governedSiteCatalog.every((site) => site.databaseImportBlocked), isTrue);
    expect(governedSiteCatalog.every((site) => !site.mapDisplayApproved), isTrue);
    expect(governedSiteCatalog.every((site) => site.approvedMediaCount == 0), isTrue);
  });

  test('limited pages do not expose historical narrative', () {
    final limited = governedSiteCatalog.where(
      (site) => site.pageCategory == GovernedPageCategory.limitedResearch,
    );
    expect(limited.length, 22);
    expect(limited.every((site) => site.narrativeSections.isEmpty), isTrue);
    expect(limited.every((site) => site.sources.isEmpty), isTrue);
  });

  test('every adopted narrative source resolves in the governed registry', () {
    for (final site in governedSiteCatalog) {
      for (final section in site.narrativeSections) {
        expect(section.sourceIds, isNotEmpty);
        for (final sourceId in section.sourceIds) {
          expect(governedSourcesById.containsKey(sourceId), isTrue);
        }
      }
    }
  });
}
