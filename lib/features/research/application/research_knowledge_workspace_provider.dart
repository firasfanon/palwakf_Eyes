import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/features/research/data/qattanin_research_package_pilot_v1.dart';
import 'package:pal_eyes/features/research/data/staging_research_corpus_v1.dart';
import 'package:pal_eyes/features/research/domain/research_package_v1.dart';

class ResearchKnowledgeWorkspaceMetrics {
  const ResearchKnowledgeWorkspaceMetrics({
    required this.sectionCount,
    required this.claimCount,
    required this.sourceCount,
    required this.locatorCount,
    required this.conflictCount,
    required this.openConflictCount,
    required this.rightsReadyCount,
    required this.validationIssueCount,
    required this.specialistDebtCount,
  });

  final int sectionCount;
  final int claimCount;
  final int sourceCount;
  final int locatorCount;
  final int conflictCount;
  final int openConflictCount;
  final int rightsReadyCount;
  final int validationIssueCount;
  final int specialistDebtCount;

  bool get pilotReady => validationIssueCount == 0;
}

final qattaninResearchPackagePilotProvider = Provider<ResearchPackageV1>((ref) {
  final manifest = buildFrozenStagingResearchCorpus().singleWhere(
    (item) => item.censusRecordId == 'PAL-EYES-CENSUS-005',
  );
  return buildQattaninResearchPackagePilotV1(
    siteEntityId: manifest.catalogSiteId!,
    researchTopicId: manifest.researchTopicId,
  );
});

final researchKnowledgeWorkspaceMetricsProvider =
    Provider<ResearchKnowledgeWorkspaceMetrics>((ref) {
      final package = ref.watch(qattaninResearchPackagePilotProvider);
      final issues = ResearchPackageV1Validator.validate(package);
      final specialistDebt = package.reviews.where(
        (review) =>
            review.stage == ResearchReviewStage.specialistExpert &&
            review.decision == ResearchReviewDecision.pending,
      );
      return ResearchKnowledgeWorkspaceMetrics(
        sectionCount: package.sections.length,
        claimCount: package.claims.length,
        sourceCount: package.sources.length,
        locatorCount: package.locators.length,
        conflictCount: package.conflicts.length,
        openConflictCount: package.conflicts
            .where((item) => item.status != ResearchConflictStatus.resolved)
            .length,
        rightsReadyCount: package.mediaRights
            .where((item) => item.publicUseApproved)
            .length,
        validationIssueCount: issues.length,
        specialistDebtCount: specialistDebt.length,
      );
    });
