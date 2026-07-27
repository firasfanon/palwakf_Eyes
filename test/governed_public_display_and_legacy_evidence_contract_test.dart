import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/draft_catalog_generated.dart';
import 'package:pal_eyes/features/places/data/governed_catalog_generated.dart';

void main() {
  test('legacy evidence metrics remain measurable', () {
    expect(
      fullDraftSiteCatalog.where((site) => site.hasExpandedNarrative),
      hasLength(ContentCatalogMetrics.expandedNarrativeCount),
    );
    expect(
      fullDraftSiteCatalog.where((site) => site.hasCoordinates),
      hasLength(ContentCatalogMetrics.mappedCoordinateCount),
    );
  });

  test('governed public display keeps coordinates blocked', () {
    expect(
      governedSiteCatalog.where((site) => site.hasPublicCoordinates),
      isEmpty,
    );
    expect(
      governedSiteCatalog.where((site) => site.hasReviewCoordinates),
      hasLength(ContentCatalogMetrics.reviewCoordinateCount),
    );
  });
}
