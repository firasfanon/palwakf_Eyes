import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/draft_heritage_site_repository.dart';

void main() {
  test('all governed development records remain visible and unpublished', () {
    final sites = const DraftHeritageSiteRepository().listSites();
    final governed = sites.where((site) => site.isGovernedDraft).toList();
    final limited = sites.where((site) => site.isLimitedResearch).toList();

    expect(sites, hasLength(ContentCatalogMetrics.extractedSiteCount));
    expect(governed, hasLength(ContentCatalogMetrics.governedDraftPageCount));
    expect(limited, hasLength(ContentCatalogMetrics.limitedResearchPageCount));
    expect(
      sites.every(
        (site) =>
            site.status != ContentReviewStatus.approved &&
            site.status != ContentReviewStatus.published &&
            !site.status.isPubliclyPublished,
      ),
      isTrue,
    );
    expect(governed.every((site) => site.narrativeSections.isNotEmpty), isTrue);
    expect(governed.every((site) => site.sources.isNotEmpty), isTrue);
    expect(limited.every((site) => site.narrativeSections.isEmpty), isTrue);
    expect(limited.every((site) => site.sources.isEmpty), isTrue);
    expect(sites.every((site) => site.hasOriginalHistoricalDraft), isTrue);
    expect(
      sites.where((site) => site.hasOriginalExpandedNarrative),
      hasLength(ContentCatalogMetrics.expandedNarrativeCount),
    );
  });

  test('draft status has an explicit Arabic label', () {
    expect(ContentReviewStatus.draft.labelAr, 'مسودة خاضعة للتدقيق');
  });
}
