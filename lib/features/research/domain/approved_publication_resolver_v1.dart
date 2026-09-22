import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';
import 'package:pal_eyes/features/research/domain/research_package_v1.dart';

class ApprovedPublicationSnapshotV1 {
  const ApprovedPublicationSnapshotV1({
    required this.packageId,
    required this.version,
    required this.siteEntityId,
    required this.sectionCount,
    required this.claimCount,
    required this.sourceCount,
  });

  final String packageId;
  final String version;
  final String siteEntityId;
  final int sectionCount;
  final int claimCount;
  final int sourceCount;
}

class ApprovedOnlyPublicationResolverV1 {
  const ApprovedOnlyPublicationResolverV1();

  ApprovedPublicationSnapshotV1? resolve(ResearchPackageV1 package) {
    if (ResearchPackageV1Validator.validate(package).isNotEmpty) return null;
    if (package.lifecycleStage != ResearchPackageStage.publicationDecision ||
        package.publicationDecision != ResearchPublicationDecision.approved) {
      return null;
    }

    bool accepted(ResearchReviewStage stage) => package.reviews.any(
      (review) =>
          review.stage == stage &&
          review.decision == ResearchReviewDecision.accept,
    );

    if (!accepted(ResearchReviewStage.specialistExpert) ||
        !accepted(ResearchReviewStage.competentAuthority) ||
        !accepted(ResearchReviewStage.sovereignCurrent) ||
        package.mediaRights.any((rights) => !rights.publicUseApproved)) {
      return null;
    }

    return ApprovedPublicationSnapshotV1(
      packageId: package.packageId,
      version: package.version,
      siteEntityId: package.siteEntityId,
      sectionCount: package.sections.length,
      claimCount: package.claims.length,
      sourceCount: package.sources.length,
    );
  }
}

class ApprovedCitationV1 {
  const ApprovedCitationV1({
    required this.claimId,
    required this.claimText,
    required this.sourceId,
    required this.sourceTitle,
    required this.locator,
    required this.relationType,
    required this.confidence,
  });

  final String claimId;
  final String claimText;
  final String sourceId;
  final String sourceTitle;
  final String locator;
  final String relationType;
  final String confidence;
}

extension ApprovedCitationResolverV1 on ApprovedOnlyPublicationResolverV1 {
  List<ApprovedCitationV1> resolveCitations(ResearchPackageV1 package) {
    if (resolve(package) == null) return const <ApprovedCitationV1>[];

    final claims = <String, ResearchClaimV1>{
      for (final claim in package.claims) claim.id: claim,
    };
    final sources = <String, ResearchSourceV1>{
      for (final source in package.sources) source.id: source,
    };
    final locators = <String, ResearchLocatorV1>{
      for (final locator in package.locators) locator.id: locator,
    };

    return package.evidence
        .map((evidence) {
          final claim = claims[evidence.claimId]!;
          final source = sources[evidence.sourceId]!;
          final locator = locators[evidence.locatorId]!;
          return ApprovedCitationV1(
            claimId: claim.id,
            claimText: claim.text,
            sourceId: source.id,
            sourceTitle: source.title,
            locator: locator.locator,
            relationType: evidence.relationType.name,
            confidence: claim.informationConfidence,
          );
        })
        .toList(growable: false);
  }
}
