enum ResearchEntityRelationType {
  existingOwnerLink,
  componentOf,
  relatedTo,
  probableIdentification,
  separateModernEntity,
}

enum ResearchVerificationState {
  verified,
  probable,
  tradition,
  hypothesis,
  unresolved,
  timeStampedCurrentStatus,
}

enum SourceVerificationState { pending, verified, rejected, unresolved }

enum MediaClearanceState {
  notCleared,
  researchApproved,
  publicApproved,
  rejected,
}

enum ResearchPackageStage {
  researchCompleteReviewDeferred,
  independentReview,
  approvedContentPackage,
  previewStagingIngest,
  verifiedProductReadback,
  publicationDecision,
}

enum ResearchPublicationDecision { pending, approved, rejected }

enum GovernedAliasType {
  commonName,
  historicalName,
  transliteration,
  alternativeSpelling,
}

enum ResearchBoundaryType {
  archaeologicalExtent,
  historicUrbanCore,
  tentativeHeritageBoundary,
  modernMunicipalBoundary,
  currentCrossingInfrastructure,
  propertyTitleBoundary,
}

enum CurrentConditionType { damage, access, use, generalCondition }

enum ResearchObservationScope { wholeEntity, component }

class ResearchEntityRelation {
  const ResearchEntityRelation({
    required this.id,
    required this.sourceEntityId,
    required this.targetEntityId,
    required this.type,
    required this.provenance,
    required this.verificationState,
  });

  final String id;
  final String sourceEntityId;
  final String targetEntityId;
  final ResearchEntityRelationType type;
  final String provenance;
  final ResearchVerificationState verificationState;

  bool get mergesEntities => false;
}

class GovernedEntityAlias {
  const GovernedEntityAlias({
    required this.id,
    required this.entityId,
    required this.label,
    required this.language,
    required this.type,
    required this.provenance,
    required this.verificationState,
    this.validPeriod,
    this.disambiguationNote = '',
  });

  final String id;
  final String entityId;
  final String label;
  final String language;
  final GovernedAliasType type;
  final String provenance;
  final ResearchVerificationState verificationState;
  final String? validPeriod;
  final String disambiguationNote;

  bool get directsEntityMerge => false;
}

class ResearchEvidenceIntegrityState {
  const ResearchEvidenceIntegrityState({
    required this.sourceVerification,
    required this.claimVerification,
    required this.mediaClearance,
  });

  final SourceVerificationState sourceVerification;
  final ResearchVerificationState claimVerification;
  final MediaClearanceState mediaClearance;
}

class ResearchSpatialBoundaryObservation {
  const ResearchSpatialBoundaryObservation({
    required this.id,
    required this.entityId,
    required this.type,
    required this.sourceId,
    required this.scope,
    required this.temporalScope,
    required this.certainty,
    this.observedAt,
    this.geometryReference,
  });

  final String id;
  final String entityId;
  final ResearchBoundaryType type;
  final String sourceId;
  final String scope;
  final String temporalScope;
  final ResearchVerificationState certainty;
  final DateTime? observedAt;
  final String? geometryReference;

  bool get mayInferPropertyTitle => false;
  bool get mayInferCurrentWaqfStatus => false;
  bool get mayInferSovereignty => false;
}

class CurrentConditionObservation {
  const CurrentConditionObservation({
    required this.id,
    required this.entityId,
    required this.type,
    required this.status,
    required this.observedAt,
    required this.sourceId,
    required this.scope,
    this.componentEntityId,
    this.note = '',
  });

  final String id;
  final String entityId;
  final CurrentConditionType type;
  final String status;
  final DateTime observedAt;
  final String sourceId;
  final ResearchObservationScope scope;
  final String? componentEntityId;
  final String note;
}

class ResearchContentPackage {
  const ResearchContentPackage({
    required this.packageId,
    required this.version,
    required this.siteEntityId,
    required this.stage,
    this.researchTopicId,
    this.publicationDecision = ResearchPublicationDecision.pending,
    this.relations = const <ResearchEntityRelation>[],
    this.aliases = const <GovernedEntityAlias>[],
    this.evidenceStates = const <ResearchEvidenceIntegrityState>[],
    this.boundaries = const <ResearchSpatialBoundaryObservation>[],
    this.currentConditions = const <CurrentConditionObservation>[],
  });

  final String packageId;
  final String version;
  final String siteEntityId;
  final String? researchTopicId;
  final ResearchPackageStage stage;
  final ResearchPublicationDecision publicationDecision;
  final List<ResearchEntityRelation> relations;
  final List<GovernedEntityAlias> aliases;
  final List<ResearchEvidenceIntegrityState> evidenceStates;
  final List<ResearchSpatialBoundaryObservation> boundaries;
  final List<CurrentConditionObservation> currentConditions;

  bool get isPublicationEligible =>
      stage == ResearchPackageStage.publicationDecision &&
      publicationDecision == ResearchPublicationDecision.approved;
}

class ResearchIntegrityIssue {
  const ResearchIntegrityIssue(this.code, this.message);

  final String code;
  final String message;
}

class ResearchIntegrityValidator {
  const ResearchIntegrityValidator._();

  static List<ResearchIntegrityIssue> validate(ResearchContentPackage package) {
    final issues = <ResearchIntegrityIssue>[];

    if (package.packageId.trim().isEmpty ||
        package.version.trim().isEmpty ||
        package.siteEntityId.trim().isEmpty) {
      issues.add(
        const ResearchIntegrityIssue(
          'PACKAGE_IDENTITY_REQUIRED',
          'Package, version, and site entity identity are required.',
        ),
      );
    }

    if (package.publicationDecision == ResearchPublicationDecision.approved &&
        package.stage != ResearchPackageStage.publicationDecision) {
      issues.add(
        const ResearchIntegrityIssue(
          'PUBLICATION_APPROVAL_OUTSIDE_DECISION_STAGE',
          'Publication approval is valid only at the publication decision stage.',
        ),
      );
    }

    _validateRelations(package.relations, issues);
    _validateAliases(package.aliases, issues);
    _validateBoundaries(package.boundaries, issues);
    _validateCurrentConditions(package.currentConditions, issues);
    return issues;
  }

  static void _validateRelations(
    List<ResearchEntityRelation> relations,
    List<ResearchIntegrityIssue> issues,
  ) {
    final ids = <String>{};
    final ownerSources = <String>{};
    final componentEdges = <String>{};

    for (final relation in relations) {
      if (!ids.add(relation.id)) {
        issues.add(
          const ResearchIntegrityIssue(
            'DUPLICATE_RELATION_ID',
            'Research relation IDs must be unique.',
          ),
        );
      }
      if (relation.sourceEntityId == relation.targetEntityId) {
        issues.add(
          ResearchIntegrityIssue(
            'SELF_RELATION_NOT_ALLOWED',
            'Relation ${relation.id} cannot target its source entity.',
          ),
        );
      }
      if (relation.type == ResearchEntityRelationType.existingOwnerLink &&
          !ownerSources.add(relation.sourceEntityId)) {
        issues.add(
          ResearchIntegrityIssue(
            'DUPLICATE_OWNER_LINK',
            'Entity ${relation.sourceEntityId} has more than one owner link.',
          ),
        );
      }
      if (relation.type == ResearchEntityRelationType.componentOf) {
        final forward =
            '${relation.sourceEntityId}->${relation.targetEntityId}';
        final reverse =
            '${relation.targetEntityId}->${relation.sourceEntityId}';
        if (componentEdges.contains(reverse)) {
          issues.add(
            ResearchIntegrityIssue(
              'COMPONENT_RELATION_CYCLE',
              'Component relation ${relation.id} creates a direct cycle.',
            ),
          );
        }
        componentEdges.add(forward);
      }
    }
  }

  static void _validateAliases(
    List<GovernedEntityAlias> aliases,
    List<ResearchIntegrityIssue> issues,
  ) {
    final entitiesByLabel = <String, Set<String>>{};
    final aliasesByLabel = <String, List<GovernedEntityAlias>>{};
    for (final alias in aliases) {
      final label = _normalizeAlias(alias.label);
      entitiesByLabel.putIfAbsent(label, () => <String>{}).add(alias.entityId);
      aliasesByLabel
          .putIfAbsent(label, () => <GovernedEntityAlias>[])
          .add(alias);
    }

    for (final entry in entitiesByLabel.entries) {
      if (entry.value.length <= 1) {
        continue;
      }
      final ambiguous = aliasesByLabel[entry.key]!.any(
        (alias) => alias.disambiguationNote.trim().isEmpty,
      );
      if (ambiguous) {
        issues.add(
          ResearchIntegrityIssue(
            'AMBIGUOUS_ALIAS_REQUIRES_DISAMBIGUATION',
            'Alias "${entry.key}" maps to multiple entities without full disambiguation.',
          ),
        );
      }
    }
  }

  static void _validateBoundaries(
    List<ResearchSpatialBoundaryObservation> boundaries,
    List<ResearchIntegrityIssue> issues,
  ) {
    for (final boundary in boundaries) {
      if (boundary.sourceId.trim().isEmpty ||
          boundary.scope.trim().isEmpty ||
          boundary.temporalScope.trim().isEmpty) {
        issues.add(
          ResearchIntegrityIssue(
            'BOUNDARY_PROVENANCE_SCOPE_TIME_REQUIRED',
            'Boundary ${boundary.id} requires source, scope, and temporal scope.',
          ),
        );
      }
    }
  }

  static void _validateCurrentConditions(
    List<CurrentConditionObservation> observations,
    List<ResearchIntegrityIssue> issues,
  ) {
    for (final observation in observations) {
      if (observation.sourceId.trim().isEmpty ||
          observation.status.trim().isEmpty) {
        issues.add(
          ResearchIntegrityIssue(
            'CURRENT_CONDITION_PROVENANCE_REQUIRED',
            'Current condition ${observation.id} requires source and status.',
          ),
        );
      }
      final hasComponent =
          observation.componentEntityId?.trim().isNotEmpty ?? false;
      if (observation.scope == ResearchObservationScope.component &&
          !hasComponent) {
        issues.add(
          ResearchIntegrityIssue(
            'COMPONENT_SCOPE_REQUIRES_COMPONENT_ID',
            'Component observation ${observation.id} requires a component entity.',
          ),
        );
      }
      if (observation.scope == ResearchObservationScope.wholeEntity &&
          hasComponent) {
        issues.add(
          ResearchIntegrityIssue(
            'COMPONENT_DAMAGE_MUST_NOT_IMPLY_WHOLE_ENTITY',
            'Component observation ${observation.id} cannot be scoped to the whole entity.',
          ),
        );
      }
    }
  }

  static String _normalizeAlias(String value) => value.trim().toLowerCase();
}
