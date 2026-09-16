import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/features/research/data/staging_research_corpus_v1.dart';
import 'package:pal_eyes/features/research/domain/staging_research_package_manifest.dart';

final researchPreviewEnabledProvider = Provider<bool>((ref) {
  return !ref.watch(appEnvironmentProvider).isProduction;
});

final frozenStagingResearchCorpusProvider =
    Provider<List<StagingResearchPackageManifest>>((ref) {
      if (!ref.watch(researchPreviewEnabledProvider)) {
        return const <StagingResearchPackageManifest>[];
      }
      return buildFrozenStagingResearchCorpus();
    });

final stagingResearchPackageBySiteIdProvider =
    Provider.family<StagingResearchPackageManifest?, String>((ref, siteId) {
      for (final package in ref.watch(frozenStagingResearchCorpusProvider)) {
        if (package.catalogSiteId == siteId) {
          return package;
        }
      }
      return null;
    });

final stagingResearchCorpusSummaryProvider = Provider<ResearchCorpusSummary>((
  ref,
) {
  final packages = ref.watch(frozenStagingResearchCorpusProvider);
  return ResearchCorpusSummary.from(packages);
});

class ResearchCorpusSummary {
  const ResearchCorpusSummary({
    required this.total,
    required this.contentPackages,
    required this.statusOnly,
    required this.linked,
    required this.incomplete,
  });

  factory ResearchCorpusSummary.from(
    List<StagingResearchPackageManifest> packages,
  ) {
    var content = 0;
    var status = 0;
    var linked = 0;
    var incomplete = 0;
    for (final package in packages) {
      switch (package.packageClass) {
        case StagingResearchPackageClass.governedContentReferenceManifest:
          content++;
        case StagingResearchPackageClass.statusOnlyNoNarrative:
          status++;
        case StagingResearchPackageClass.linkedResearchReference:
          linked++;
        case StagingResearchPackageClass.notPromotedResearchIncomplete:
          incomplete++;
      }
    }
    return ResearchCorpusSummary(
      total: packages.length,
      contentPackages: content,
      statusOnly: status,
      linked: linked,
      incomplete: incomplete,
    );
  }

  final int total;
  final int contentPackages;
  final int statusOnly;
  final int linked;
  final int incomplete;
}
