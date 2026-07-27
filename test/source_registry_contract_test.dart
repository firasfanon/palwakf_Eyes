import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/draft_catalog_generated.dart';

void main() {
  test('draft source registry has the governed size', () {
    expect(
      fullDraftSourceRegistry,
      hasLength(ContentCatalogMetrics.sourceRegistryCount),
    );
    expect(fullDraftSourceRegistry, hasLength(79));
  });

  test('source registry entries stay outside approval and publication', () {
    expect(
      fullDraftSourceRegistry.every(
        (entry) =>
            entry.status != ContentReviewStatus.approved &&
            entry.status != ContentReviewStatus.published,
      ),
      isTrue,
    );
  });

  test('every source entry retains verification context', () {
    expect(
      fullDraftSourceRegistry.every(
        (entry) =>
            entry.title.trim().isNotEmpty &&
            entry.note.trim().isNotEmpty &&
            entry.registryTier.trim().isNotEmpty,
      ),
      isTrue,
    );
  });
}
