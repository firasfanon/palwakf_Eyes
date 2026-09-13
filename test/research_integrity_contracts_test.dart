import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';

ResearchContentPackage _package({
  ResearchPackageStage stage =
      ResearchPackageStage.researchCompleteReviewDeferred,
  ResearchPublicationDecision publicationDecision =
      ResearchPublicationDecision.pending,
  List<ResearchEntityRelation> relations = const <ResearchEntityRelation>[],
  List<GovernedEntityAlias> aliases = const <GovernedEntityAlias>[],
  List<ResearchEvidenceIntegrityState> evidenceStates =
      const <ResearchEvidenceIntegrityState>[],
  List<ResearchSpatialBoundaryObservation> boundaries =
      const <ResearchSpatialBoundaryObservation>[],
  List<CurrentConditionObservation> currentConditions =
      const <CurrentConditionObservation>[],
}) {
  return ResearchContentPackage(
    packageId: 'pkg-pilot',
    version: '1',
    siteEntityId: 'site-pilot',
    researchTopicId: 'research-pilot',
    stage: stage,
    publicationDecision: publicationDecision,
    relations: relations,
    aliases: aliases,
    evidenceStates: evidenceStates,
    boundaries: boundaries,
    currentConditions: currentConditions,
  );
}

void main() {
  test('review deferred can never be publication eligible', () {
    final package = _package(
      stage: ResearchPackageStage.researchCompleteReviewDeferred,
    );

    expect(package.isPublicationEligible, isFalse);
    expect(ResearchIntegrityValidator.validate(package), isEmpty);
  });

  test('publication approval is accepted only at publication decision', () {
    final invalid = _package(
      stage: ResearchPackageStage.approvedContentPackage,
      publicationDecision: ResearchPublicationDecision.approved,
    );
    final valid = _package(
      stage: ResearchPackageStage.publicationDecision,
      publicationDecision: ResearchPublicationDecision.approved,
    );

    expect(invalid.isPublicationEligible, isFalse);
    expect(
      ResearchIntegrityValidator.validate(invalid).map((issue) => issue.code),
      contains('PUBLICATION_APPROVAL_OUTSIDE_DECISION_STAGE'),
    );
    expect(valid.isPublicationEligible, isTrue);
    expect(ResearchIntegrityValidator.validate(valid), isEmpty);
  });

  test('existing-owner linking prevents duplicate owner creation', () {
    final package = _package(
      relations: const <ResearchEntityRelation>[
        ResearchEntityRelation(
          id: 'rel-owner-1',
          sourceEntityId: 'site-nabi-musa-maqam',
          targetEntityId: 'owner-nabi-musa-complex',
          type: ResearchEntityRelationType.existingOwnerLink,
          provenance: 'governed owner discovery',
          verificationState: ResearchVerificationState.verified,
        ),
        ResearchEntityRelation(
          id: 'rel-owner-2',
          sourceEntityId: 'site-nabi-musa-maqam',
          targetEntityId: 'owner-duplicate',
          type: ResearchEntityRelationType.existingOwnerLink,
          provenance: 'duplicate attempt',
          verificationState: ResearchVerificationState.unresolved,
        ),
      ],
    );

    expect(
      ResearchIntegrityValidator.validate(package).map((issue) => issue.code),
      contains('DUPLICATE_OWNER_LINK'),
    );
  });

  test('component-of relation preserves component and whole identities', () {
    const relation = ResearchEntityRelation(
      id: 'rel-barquq-khan-yunis',
      sourceEntityId: 'site-barquq-castle',
      targetEntityId: 'site-historic-khan-yunis',
      type: ResearchEntityRelationType.componentOf,
      provenance: 'Census-073 and Census-078 crosswalk',
      verificationState: ResearchVerificationState.verified,
    );
    final package = _package(
      relations: const <ResearchEntityRelation>[relation],
    );

    expect(relation.sourceEntityId, isNot(relation.targetEntityId));
    expect(relation.mergesEntities, isFalse);
    expect(ResearchIntegrityValidator.validate(package), isEmpty);
  });

  test('probable identification stays explicitly non-certain', () {
    const relation = ResearchEntityRelation(
      id: 'rel-anthedon-blakhiyya',
      sourceEntityId: 'catalog-old-gaza-port',
      targetEntityId: 'anthedon-blakhiyya-complex',
      type: ResearchEntityRelationType.probableIdentification,
      provenance: 'Census-077 evidence chain',
      verificationState: ResearchVerificationState.probable,
    );

    expect(relation.verificationState, ResearchVerificationState.probable);
    expect(relation.mergesEntities, isFalse);
  });

  test('shared aliases require disambiguation and never imply merge', () {
    const aliases = <GovernedEntityAlias>[
      GovernedEntityAlias(
        id: 'alias-raphia-ancient',
        entityId: 'tell-rafah-raphia',
        label: 'Rafah',
        language: 'en',
        type: GovernedAliasType.historicalName,
        provenance: 'Census-079',
        verificationState: ResearchVerificationState.verified,
        disambiguationNote: 'Ancient archaeological landscape.',
      ),
      GovernedEntityAlias(
        id: 'alias-rafah-modern',
        entityId: 'modern-rafah',
        label: 'Rafah',
        language: 'en',
        type: GovernedAliasType.commonName,
        provenance: 'current identity',
        verificationState: ResearchVerificationState.verified,
        disambiguationNote: 'Modern city entity.',
      ),
    ];
    final package = _package(aliases: aliases);

    expect(aliases.every((alias) => !alias.directsEntityMerge), isTrue);
    expect(ResearchIntegrityValidator.validate(package), isEmpty);
  });

  test('ambiguous alias without notes is rejected', () {
    final package = _package(
      aliases: const <GovernedEntityAlias>[
        GovernedEntityAlias(
          id: 'a1',
          entityId: 'entity-1',
          label: 'Jaba',
          language: 'en',
          type: GovernedAliasType.transliteration,
          provenance: 'legacy mention',
          verificationState: ResearchVerificationState.unresolved,
        ),
        GovernedEntityAlias(
          id: 'a2',
          entityId: 'entity-2',
          label: 'Jaba',
          language: 'en',
          type: GovernedAliasType.transliteration,
          provenance: 'independent candidate',
          verificationState: ResearchVerificationState.unresolved,
        ),
      ],
    );

    expect(
      ResearchIntegrityValidator.validate(package).map((issue) => issue.code),
      contains('AMBIGUOUS_ALIAS_REQUIRES_DISAMBIGUATION'),
    );
  });

  test('source claim and media states remain independent', () {
    const state = ResearchEvidenceIntegrityState(
      sourceVerification: SourceVerificationState.verified,
      claimVerification: ResearchVerificationState.probable,
      mediaClearance: MediaClearanceState.notCleared,
    );
    final package = _package(
      evidenceStates: const <ResearchEvidenceIntegrityState>[state],
    );

    expect(state.sourceVerification, SourceVerificationState.verified);
    expect(state.claimVerification, ResearchVerificationState.probable);
    expect(state.mediaClearance, MediaClearanceState.notCleared);
    expect(ResearchIntegrityValidator.validate(package), isEmpty);
  });

  test('boundary semantics never imply legal status', () {
    final boundary = ResearchSpatialBoundaryObservation(
      id: 'boundary-tell-rafah',
      entityId: 'tell-rafah-raphia',
      type: ResearchBoundaryType.archaeologicalExtent,
      sourceId: 'srv-archaeology',
      scope: 'archaeological tell extent',
      temporalScope: 'archaeological / historical research layer',
      certainty: ResearchVerificationState.probable,
      observedAt: DateTime.utc(2026, 9, 13),
    );

    expect(boundary.mayInferPropertyTitle, isFalse);
    expect(boundary.mayInferCurrentWaqfStatus, isFalse);
    expect(boundary.mayInferSovereignty, isFalse);
    expect(
      ResearchIntegrityValidator.validate(_package(boundaries: [boundary])),
      isEmpty,
    );
  });

  test('component damage cannot be generalized to whole entity', () {
    final valid = CurrentConditionObservation(
      id: 'condition-component',
      entityId: 'historic-gaza-core',
      componentEntityId: 'omari-mosque',
      type: CurrentConditionType.damage,
      status: 'documented damage',
      observedAt: DateTime.utc(2026, 9, 13),
      sourceId: 'srv-current-condition',
      scope: ResearchObservationScope.component,
    );
    final invalid = CurrentConditionObservation(
      id: 'condition-invalid',
      entityId: 'historic-gaza-core',
      componentEntityId: 'omari-mosque',
      type: CurrentConditionType.damage,
      status: 'documented damage',
      observedAt: DateTime.utc(2026, 9, 13),
      sourceId: 'srv-current-condition',
      scope: ResearchObservationScope.wholeEntity,
    );

    expect(
      ResearchIntegrityValidator.validate(_package(currentConditions: [valid])),
      isEmpty,
    );
    expect(
      ResearchIntegrityValidator.validate(
        _package(currentConditions: [invalid]),
      ).map((issue) => issue.code),
      contains('COMPONENT_DAMAGE_MUST_NOT_IMPLY_WHOLE_ENTITY'),
    );
  });
}
