import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/draft_catalog_generated.dart';

void main() {
  test('full document site catalog has the governed size', () {
    expect(
      fullDraftSiteCatalog,
      hasLength(ContentCatalogMetrics.extractedSiteCount),
    );
    expect(ContentCatalogMetrics.extractedSiteCount, 79);
  });

  test('expanded narrative and coordinate counts match evidence', () {
    final expanded = fullDraftSiteCatalog
        .where((site) => site.hasExpandedNarrative)
        .length;
    final mapped =
        fullDraftSiteCatalog.where((site) => site.hasCoordinates).length;

    expect(expanded, ContentCatalogMetrics.expandedNarrativeCount);
    expect(expanded, 47);
    expect(mapped, ContentCatalogMetrics.mappedCoordinateCount);
    expect(mapped, 3);
  });

  test('catalog includes key Palestinian sites from the draft', () {
    final names = fullDraftSiteCatalog.map((site) => site.nameAr).toSet();

    expect(
      names.any((name) => name.contains('المسجد الأقصى')),
      isTrue,
    );
    expect(names.contains('الحرم الإبراهيمي'), isTrue);
    expect(names.contains('كنيسة المهد'), isTrue);
    expect(names.contains('برك سليمان'), isTrue);
    expect(
      names.any((name) => name.startsWith('سبسطية')),
      isTrue,
    );
    expect(
      names.any((name) => name.startsWith('تل السلطان')),
      isTrue,
    );
    expect(names.contains('مدينة غزة القديمة'), isTrue);
    expect(names.contains('رفح التاريخية'), isTrue);
  });

  test('catalog contains no approved or published fixture', () {
    expect(
      fullDraftSiteCatalog.every(
        (site) =>
            site.status != ContentReviewStatus.approved &&
            site.status != ContentReviewStatus.published,
      ),
      isTrue,
    );
  });

  test('unmapped sites remain in the catalog', () {
    final unmapped =
        fullDraftSiteCatalog.where((site) => !site.hasCoordinates).length;
    expect(
      unmapped,
      ContentCatalogMetrics.extractedSiteCount -
          ContentCatalogMetrics.mappedCoordinateCount,
    );
    expect(unmapped, 76);
  });
}
