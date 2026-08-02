import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/data/dual_narrative_catalog.dart';
import 'package:pal_eyes/features/places/domain/draft_content_profile.dart';

void main() {
  test('all 79 sites retain an original historical draft layer', () {
    expect(
      dualNarrativeSiteCatalog,
      hasLength(ContentCatalogMetrics.originalDraftLayerSiteCount),
    );
    expect(
      dualNarrativeSiteCatalog.every(
        (site) => site.hasOriginalHistoricalDraft,
      ),
      isTrue,
    );
  });

  test('original 47 expanded narratives and 32 summaries are preserved', () {
    final expanded = dualNarrativeSiteCatalog.where(
      (site) => site.hasOriginalExpandedNarrative,
    );
    final summaries = dualNarrativeSiteCatalog.where(
      (site) =>
          site.originalHistoricalDraft?.contentProfile ==
          DraftContentProfile.catalogSummary,
    );

    expect(expanded, hasLength(47));
    expect(summaries, hasLength(32));
  });

  test('original provenance and public-release block are exact', () {
    for (final site in dualNarrativeSiteCatalog) {
      final draft = site.originalHistoricalDraft!;
      expect(
        draft.referenceFileSha256,
        '1f82a6c9941063436b40d13e258f7d03b1b3b00ef209494fe7032ee756673f6d',
      );
      expect(draft.referenceLineCount, 5334);
      expect(draft.referenceSizeBytes, 440042);
      expect(draft.publicReleaseApproved, isFalse);
    }
  });

  test('governed and original narratives remain separate', () {
    final governed = dualNarrativeSiteCatalog.where(
      (site) => site.isGovernedDraft,
    );
    final limited = dualNarrativeSiteCatalog.where(
      (site) => site.isLimitedResearch,
    );

    expect(governed, hasLength(57));
    expect(limited, hasLength(22));
    expect(limited.every((site) => site.narrativeSections.isEmpty), isTrue);
    expect(
      dualNarrativeSiteCatalog.where(
        (site) => site.hasOriginalExpandedNarrative,
      ),
      hasLength(47),
    );
  });
}
