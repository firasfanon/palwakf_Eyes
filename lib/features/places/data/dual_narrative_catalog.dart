import 'package:pal_eyes/features/places/data/draft_catalog_generated.dart';
import 'package:pal_eyes/features/places/data/governed_catalog_generated.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/places/domain/original_historical_draft_layer.dart';

final Map<String, HeritageSite> _originalDraftSitesById =
    <String, HeritageSite>{
  for (final HeritageSite site in fullDraftSiteCatalog) site.id: site,
};

final List<HeritageSite> dualNarrativeSiteCatalog =
    List<HeritageSite>.unmodifiable(
  governedSiteCatalog.map((HeritageSite governedSite) {
    final HeritageSite? originalSite =
        _originalDraftSitesById[governedSite.id];
    if (originalSite == null) {
      throw StateError(
        'Original historical draft is missing for ${governedSite.id}',
      );
    }

    return governedSite.withOriginalHistoricalDraft(
      OriginalHistoricalDraftLayer(
        referenceFileName: 'نص واحد ملصق .txt',
        referenceFileSha256:
            '1f82a6c9941063436b40d13e258f7d03b1b3b00ef209494fe7032ee756673f6d',
        referenceLineCount: 5334,
        referenceSizeBytes: 440042,
        summaryDraft: originalSite.summaryDraft,
        periods: originalSite.periods,
        narrativeSections: originalSite.narrativeSections,
        sources: originalSite.sources,
        timeline: originalSite.timeline,
        contentProfile: originalSite.contentProfile,
        sourceMentionCount: originalSite.sourceMentionCount,
      ),
    );
  }),
);
