import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';
import 'package:pal_eyes/features/research/domain/research_package_v1.dart';

ResearchPackageV1 buildQattaninResearchPackagePilotV1({
  required String siteEntityId,
  required String researchTopicId,
}) {
  final sections = List<ResearchNarrativeSectionV1>.generate(
    12,
    (index) => ResearchNarrativeSectionV1(
      id: 'qattanin-section-${index + 1}',
      title: 'قسم تجريبي ${index + 1}',
      order: index + 1,
      paragraphs: <ResearchNarrativeParagraphV1>[
        ResearchNarrativeParagraphV1(
          id: 'qattanin-paragraph-${index + 1}',
          text:
              'محتوى تقني غير منشور للتحقق من حفظ بنية المسودة دون تسطيح — القسم ${index + 1}.',
          claimIds: index < 2
              ? <String>['qattanin-claim-${index + 1}']
              : const <String>[],
        ),
      ],
    ),
    growable: false,
  );

  return ResearchPackageV1(
    packageId: 'RCP-V1-005',
    version: 'PDR-MEGABATCH-PILOT-V1',
    siteEntityId: siteEntityId,
    researchTopicId: researchTopicId,
    lifecycleStage: ResearchPackageStage.verifiedProductReadback,
    publicationDecision: ResearchPublicationDecision.pending,
    sections: sections,
    sources: const <ResearchSourceV1>[
      ResearchSourceV1(
        id: 'qattanin-source-primary',
        title: 'Qattanin technical pilot primary source placeholder',
        identityStatus: 'VERIFIED_TECHNICAL_FIXTURE',
        authorityAssessment: 'PRIMARY_FIXTURE_ONLY',
        canonicalUrl: 'https://example.invalid/pal-eyes/qattanin-primary',
        identifiers: <String, String>{'fixture': 'QATTANIN-P1'},
        institution: 'PAL_EYES_ENGINEERING_FIXTURE',
      ),
      ResearchSourceV1(
        id: 'qattanin-source-secondary',
        title: 'Qattanin technical pilot secondary source placeholder',
        identityStatus: 'VERIFIED_TECHNICAL_FIXTURE',
        authorityAssessment: 'SECONDARY_FIXTURE_ONLY',
        canonicalUrl: 'https://example.invalid/pal-eyes/qattanin-secondary',
        identifiers: <String, String>{'fixture': 'QATTANIN-S1'},
        legacyMentions: <String>['legacy-mention-preserved-not-canonical'],
      ),
    ],
    locators: const <ResearchLocatorV1>[
      ResearchLocatorV1(
        id: 'qattanin-locator-primary',
        sourceId: 'qattanin-source-primary',
        locatorType: 'REGISTER',
        locator: 'TECHNICAL-FIXTURE/REGISTER/001',
        originalDate: 'FIXTURE',
        custodian: 'PAL_EYES_ENGINEERING_FIXTURE',
      ),
      ResearchLocatorV1(
        id: 'qattanin-locator-secondary',
        sourceId: 'qattanin-source-secondary',
        locatorType: 'PAGE',
        locator: 'TECHNICAL-FIXTURE/PAGE/002',
        custodian: 'PAL_EYES_ENGINEERING_FIXTURE',
      ),
    ],
    claims: const <ResearchClaimV1>[
      ResearchClaimV1(
        id: 'qattanin-claim-1',
        text: 'Technical fixture claim used to validate evidence round-trip.',
        type: ResearchClaimType.fact,
        informationConfidence: 'HIGH_FOR_FIXTURE',
        confidenceRationale: 'Deterministic engineering fixture.',
      ),
      ResearchClaimV1(
        id: 'qattanin-claim-2',
        text:
            'Technical fixture contested claim used to preserve disagreement.',
        type: ResearchClaimType.contested,
        informationConfidence: 'MEDIUM_FOR_FIXTURE',
        confidenceRationale:
            'Deliberately modeled as contested for regression coverage.',
      ),
    ],
    evidence: const <ResearchEvidenceV1>[
      ResearchEvidenceV1(
        id: 'qattanin-evidence-1',
        claimId: 'qattanin-claim-1',
        sourceId: 'qattanin-source-primary',
        locatorId: 'qattanin-locator-primary',
        relationType: EvidenceRelationType.supports,
        sourceRole: ResearchSourceRole.primary,
        strength: 'STRONG_FIXTURE',
        inspectedBy: 'PAL_EYES_ENGINEERING_TEST',
        inspectedAt: '2026-09-22',
        representationChecksum: 'fixture-checksum-primary',
      ),
      ResearchEvidenceV1(
        id: 'qattanin-evidence-2',
        claimId: 'qattanin-claim-2',
        sourceId: 'qattanin-source-secondary',
        locatorId: 'qattanin-locator-secondary',
        relationType: EvidenceRelationType.qualifies,
        sourceRole: ResearchSourceRole.secondary,
        strength: 'QUALIFYING_FIXTURE',
        inspectedBy: 'PAL_EYES_ENGINEERING_TEST',
        inspectedAt: '2026-09-22',
        representationChecksum: 'fixture-checksum-secondary',
      ),
    ],
    conflicts: const <ResearchConflictV1>[
      ResearchConflictV1(
        id: 'qattanin-conflict-1',
        issue: 'Technical fixture alternative interpretation.',
        claimIds: <String>['qattanin-claim-1', 'qattanin-claim-2'],
        relation: ResearchConflictRelation.alternateInterpretation,
        status: ResearchConflictStatus.unresolved,
        narrativeEffect: 'Preserve disagreement in research workspace.',
      ),
    ],
    temporalAssertions: const <TemporalAssertionV1>[
      TemporalAssertionV1(
        id: 'qattanin-temporal-1',
        subject: 'RCP-V1-005',
        predicate: 'technical_fixture_state',
        objectValue: 'NON_PRODUCTION_ONLY',
        dimension: TemporalAssertionDimension.other,
        sourceIds: <String>['qattanin-source-primary'],
        eventDate: '2026-09-22',
      ),
    ],
    archiveProvenance: const <ArchiveProvenanceV1>[
      ArchiveProvenanceV1(
        id: 'qattanin-archive-1',
        sourceId: 'qattanin-source-primary',
        repository: 'PAL_EYES_ENGINEERING_FIXTURE',
        fonds: 'PDR-MEGABATCH',
        series: 'QATTANIN-PILOT',
        register: '001',
        item: '001',
        manifestation: 'TECHNICAL_FIXTURE',
      ),
    ],
    mediaRights: const <ResearchMediaRightsV1>[
      ResearchMediaRightsV1(
        id: 'qattanin-rights-1',
        assetId: 'qattanin-fixture-media-1',
        rightsHolder: 'PAL_EYES_ENGINEERING_FIXTURE',
        allowedUse: 'NON_PRODUCTION_RESEARCH_TEST_ONLY',
        reviewStatus: 'RESEARCH_APPROVED',
        creator: 'PAL_EYES_ENGINEERING_FIXTURE',
        sourcePageUrl: 'https://example.invalid/pal-eyes/qattanin-media',
        attributionText: 'Engineering fixture only.',
      ),
    ],
    reviews: const <ResearchReviewAdjudicationV1>[
      ResearchReviewAdjudicationV1(
        id: 'qattanin-review-experimental-1',
        stage: ResearchReviewStage.experimentalHuman,
        reviewerBody: 'PAL_EYES_DEV_HUMAN_001',
        authorityRef: 'PAL_EYES_TEMP_HUMAN_APPROVER_AUTH_20260922',
        scope: 'NON_PRODUCTION_RESEARCH_AND_STAGING_ONLY',
        decision: ResearchReviewDecision.accept,
        evidenceFreezeId: 'PAL_EYES_62_EVIDENCE_FREEZE_20260922',
        approvedVersionId: 'PDR-MEGABATCH-PILOT-V1',
      ),
      ResearchReviewAdjudicationV1(
        id: 'qattanin-review-specialist-debt-1',
        stage: ResearchReviewStage.specialistExpert,
        reviewerBody: 'UNASSIGNED_SPECIALIST',
        authorityRef: 'SPECIALIST_REVIEW_DEBT',
        scope: 'PRE_PUBLICATION_WHERE_APPLICABLE',
        decision: ResearchReviewDecision.pending,
        evidenceFreezeId: 'PAL_EYES_62_EVIDENCE_FREEZE_20260922',
      ),
    ],
    aliases: <GovernedEntityAlias>[
      GovernedEntityAlias(
        id: 'qattanin-alias-1',
        entityId: siteEntityId,
        label: 'Souq al-Qattanin',
        language: 'en',
        type: GovernedAliasType.transliteration,
        provenance: 'engineering pilot alias contract',
        verificationState: ResearchVerificationState.verified,
        disambiguationNote: 'Alias only; never a merge directive.',
      ),
    ],
    boundaries: <ResearchSpatialBoundaryObservation>[
      ResearchSpatialBoundaryObservation(
        id: 'qattanin-boundary-1',
        entityId: siteEntityId,
        type: ResearchBoundaryType.tentativeHeritageBoundary,
        sourceId: 'qattanin-source-primary',
        scope: 'TECHNICAL_FIXTURE_NON_LEGAL_BOUNDARY',
        temporalScope: 'engineering pilot',
        certainty: ResearchVerificationState.probable,
        observedAt: DateTime.utc(2026, 9, 22),
      ),
    ],
    currentConditions: <CurrentConditionObservation>[
      CurrentConditionObservation(
        id: 'qattanin-condition-1',
        entityId: siteEntityId,
        type: CurrentConditionType.generalCondition,
        status: 'TECHNICAL_FIXTURE_ONLY',
        observedAt: DateTime.utc(2026, 9, 22),
        sourceId: 'qattanin-source-primary',
        scope: ResearchObservationScope.wholeEntity,
        note: 'No real-world condition is asserted by this fixture.',
      ),
    ],
  );
}
