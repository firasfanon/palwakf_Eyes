import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/draft_catalog_generated.dart';

void main() {
  test('all governed governorate groups are visible', () {
    expect(
      fullGovernorateCoverage,
      hasLength(ContentCatalogMetrics.governorateCoverageCount),
    );
    expect(fullGovernorateCoverage, hasLength(16));
  });

  test('coverage totals reconcile with the catalog', () {
    final siteTotal = fullGovernorateCoverage.fold<int>(
      0,
      (total, item) => total + item.siteCount,
    );
    final expandedTotal = fullGovernorateCoverage.fold<int>(
      0,
      (total, item) => total + item.expandedNarrativeCount,
    );
    final mappedTotal = fullGovernorateCoverage.fold<int>(
      0,
      (total, item) => total + item.mappedSiteCount,
    );

    expect(siteTotal, ContentCatalogMetrics.extractedSiteCount);
    expect(expandedTotal, ContentCatalogMetrics.expandedNarrativeCount);
    expect(mappedTotal, ContentCatalogMetrics.mappedCoordinateCount);
  });

  test('zero-row extraction gaps remain explicit', () {
    final gaps = fullGovernorateCoverage
        .where((item) => !item.hasExtractedSites)
        .toList(growable: false);

    expect(
      gaps,
      hasLength(ContentCatalogMetrics.governoratesWithoutSiteRows),
    );
    expect(
      gaps.map((item) => item.nameAr).toSet(),
      containsAll(<String>{'شمال غزة', 'دير البلح'}),
    );
  });
}
