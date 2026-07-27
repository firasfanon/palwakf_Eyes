import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/features/governorates/domain/governorate_coverage.dart';
import 'package:pal_eyes/features/places/data/draft_catalog_generated.dart'
    show fullGovernorateCoverage;
import 'package:pal_eyes/features/places/data/draft_heritage_site_repository.dart';
import 'package:pal_eyes/features/places/data/heritage_site_repository.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/research/data/governed_research_backlog_generated.dart';
import 'package:pal_eyes/features/research/domain/governed_research_backlog_item.dart';
import 'package:pal_eyes/features/sources/data/governed_source_registry_generated.dart';
import 'package:pal_eyes/features/sources/domain/draft_source_registry_entry.dart';

final heritageSiteRepositoryProvider = Provider<HeritageSiteRepository>(
  (ref) => const DraftHeritageSiteRepository(),
);

final foundationSitesProvider = Provider<List<HeritageSite>>(
  (ref) => ref.watch(heritageSiteRepositoryProvider).listSites(),
);

final featuredSitesProvider = Provider<List<HeritageSite>>(
  (ref) => ref
      .watch(foundationSitesProvider)
      .where((site) => site.featured)
      .take(8)
      .toList(growable: false),
);

final mappedSitesProvider = Provider<List<HeritageSite>>(
  (ref) => ref
      .watch(foundationSitesProvider)
      .where((site) => site.hasPublicCoordinates)
      .toList(growable: false),
);

final reviewCoordinateSitesProvider = Provider<List<HeritageSite>>(
  (ref) => ref
      .watch(foundationSitesProvider)
      .where((site) => site.hasReviewCoordinates && !site.hasPublicCoordinates)
      .toList(growable: false),
);

final expandedNarrativeSitesProvider = Provider<List<HeritageSite>>(
  (ref) => ref
      .watch(foundationSitesProvider)
      .where((site) => site.hasOriginalExpandedNarrative)
      .toList(growable: false),
);

final governedDraftSitesProvider = Provider<List<HeritageSite>>(
  (ref) => ref
      .watch(foundationSitesProvider)
      .where((site) => site.isGovernedDraft)
      .toList(growable: false),
);

final draftSourceRegistryProvider = Provider<List<DraftSourceRegistryEntry>>(
  (ref) => governedSourceRegistry,
);

final governedResearchBacklogProvider =
    Provider<List<GovernedResearchBacklogItem>>(
      (ref) => governedResearchBacklog,
    );

final governorateCoverageProvider = Provider<List<GovernorateCoverage>>(
  (ref) => fullGovernorateCoverage,
);

final heritageSiteBySlugProvider = Provider.family<HeritageSite?, String>((
  ref,
  slug,
) {
  return ref.watch(heritageSiteRepositoryProvider).findBySlug(slug);
});
