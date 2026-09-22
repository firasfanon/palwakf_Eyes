import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';
import 'package:pal_eyes/features/research/domain/research_package_v1.dart';
import 'package:pal_eyes/features/research/domain/staging_research_package_manifest.dart';

class ResearchPackageStagingAdapterV1 {
  const ResearchPackageStagingAdapterV1._();

  static ResearchPackageV1 fromManifest(
    StagingResearchPackageManifest manifest,
  ) {
    final siteId = manifest.catalogSiteId;
    if (siteId == null || !manifest.exposesResearchNarrativeReference) {
      throw StateError('STAGING_MANIFEST_NOT_CONTENT_PACKAGE');
    }
    return ResearchPackageV1(
      packageId: manifest.packageId,
      version: 'STAGING-COMPATIBILITY-V1',
      siteEntityId: siteId,
      researchTopicId: manifest.researchTopicId,
      lifecycleStage: ResearchPackageStage.previewStagingIngest,
      publicationDecision: ResearchPublicationDecision.pending,
      sections: const <ResearchNarrativeSectionV1>[],
      sources: const <ResearchSourceV1>[],
      locators: const <ResearchLocatorV1>[],
      claims: const <ResearchClaimV1>[],
      evidence: const <ResearchEvidenceV1>[],
      conflicts: const <ResearchConflictV1>[],
      temporalAssertions: const <TemporalAssertionV1>[],
      archiveProvenance: const <ArchiveProvenanceV1>[],
      mediaRights: const <ResearchMediaRightsV1>[],
      reviews: const <ResearchReviewAdjudicationV1>[],
      relations: manifest.relations,
    );
  }
}
