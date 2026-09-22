import 'dart:convert';

import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';

const String palEyesResearchPackageSchemaV1 = 'PAL_EYES_RESEARCH_PACKAGE_V1';

enum ResearchClaimType { fact, inference, oralTradition, contested }

enum EvidenceRelationType { supports, contradicts, qualifies, context }

enum ResearchSourceRole { primary, secondary, official, oral, archivalBridge }

enum ResearchConflictRelation {
  contradicts,
  alternateInterpretation,
  supersedes,
  qualifies,
}

enum ResearchConflictStatus { open, resolved, unresolved }

enum TemporalAssertionDimension {
  assetOwnership,
  revenueShare,
  waterRight,
  lease,
  unitCount,
  other,
}

enum ResearchReviewStage {
  experimentalHuman,
  specialistExpert,
  competentAuthority,
  sovereignCurrent,
  publication,
}

enum ResearchReviewDecision {
  pending,
  accept,
  defer,
  reject,
  needsMoreEvidence,
}

T _enumByName<T extends Enum>(List<T> values, String? raw, T fallback) {
  final value = (raw ?? '').trim();
  for (final item in values) {
    if (item.name == value) return item;
  }
  return fallback;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = (json[key] as String? ?? '').trim();
  if (value.isEmpty) throw FormatException('$key is required');
  return value;
}

List<Object?> _list(Map<String, Object?> json, String key) =>
    (json[key] as List<Object?>?) ?? const <Object?>[];

Map<String, Object?> _map(Object? value) =>
    Map<String, Object?>.from((value as Map?) ?? const <Object?, Object?>{});

class ResearchNarrativeParagraphV1 {
  const ResearchNarrativeParagraphV1({
    required this.id,
    required this.text,
    this.claimIds = const <String>[],
  });

  factory ResearchNarrativeParagraphV1.fromJson(Map<String, Object?> json) =>
      ResearchNarrativeParagraphV1(
        id: _requiredString(json, 'id'),
        text: _requiredString(json, 'text'),
        claimIds: _list(
          json,
          'claimIds',
        ).map((e) => e.toString()).toList(growable: false),
      );

  final String id;
  final String text;
  final List<String> claimIds;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'text': text,
    'claimIds': claimIds,
  };
}

class ResearchNarrativeSectionV1 {
  const ResearchNarrativeSectionV1({
    required this.id,
    required this.title,
    required this.order,
    required this.paragraphs,
  });

  factory ResearchNarrativeSectionV1.fromJson(Map<String, Object?> json) =>
      ResearchNarrativeSectionV1(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        order: (json['order'] as num?)?.toInt() ?? 0,
        paragraphs: _list(json, 'paragraphs')
            .map((e) => ResearchNarrativeParagraphV1.fromJson(_map(e)))
            .toList(growable: false),
      );

  final String id;
  final String title;
  final int order;
  final List<ResearchNarrativeParagraphV1> paragraphs;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'order': order,
    'paragraphs': paragraphs.map((e) => e.toJson()).toList(),
  };
}

class ResearchSourceV1 {
  const ResearchSourceV1({
    required this.id,
    required this.title,
    required this.identityStatus,
    required this.authorityAssessment,
    this.canonicalUrl = '',
    this.identifiers = const <String, String>{},
    this.edition = '',
    this.publisher = '',
    this.institution = '',
    this.legacyMentions = const <String>[],
  });

  factory ResearchSourceV1.fromJson(Map<String, Object?> json) =>
      ResearchSourceV1(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        identityStatus: _requiredString(json, 'identityStatus'),
        authorityAssessment: _requiredString(json, 'authorityAssessment'),
        canonicalUrl: (json['canonicalUrl'] as String? ?? '').trim(),
        identifiers: _map(
          json['identifiers'],
        ).map((k, v) => MapEntry(k, v.toString())),
        edition: (json['edition'] as String? ?? '').trim(),
        publisher: (json['publisher'] as String? ?? '').trim(),
        institution: (json['institution'] as String? ?? '').trim(),
        legacyMentions: _list(
          json,
          'legacyMentions',
        ).map((e) => e.toString()).toList(growable: false),
      );

  final String id;
  final String title;
  final String identityStatus;
  final String authorityAssessment;
  final String canonicalUrl;
  final Map<String, String> identifiers;
  final String edition;
  final String publisher;
  final String institution;
  final List<String> legacyMentions;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'identityStatus': identityStatus,
    'authorityAssessment': authorityAssessment,
    'canonicalUrl': canonicalUrl,
    'identifiers': identifiers,
    'edition': edition,
    'publisher': publisher,
    'institution': institution,
    'legacyMentions': legacyMentions,
  };
}

class ResearchLocatorV1 {
  const ResearchLocatorV1({
    required this.id,
    required this.sourceId,
    required this.locatorType,
    required this.locator,
    this.originalDate = '',
    this.copyDate = '',
    this.custodian = '',
    this.accessCopy = '',
  });

  factory ResearchLocatorV1.fromJson(Map<String, Object?> json) =>
      ResearchLocatorV1(
        id: _requiredString(json, 'id'),
        sourceId: _requiredString(json, 'sourceId'),
        locatorType: _requiredString(json, 'locatorType'),
        locator: _requiredString(json, 'locator'),
        originalDate: (json['originalDate'] as String? ?? '').trim(),
        copyDate: (json['copyDate'] as String? ?? '').trim(),
        custodian: (json['custodian'] as String? ?? '').trim(),
        accessCopy: (json['accessCopy'] as String? ?? '').trim(),
      );

  final String id;
  final String sourceId;
  final String locatorType;
  final String locator;
  final String originalDate;
  final String copyDate;
  final String custodian;
  final String accessCopy;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'sourceId': sourceId,
    'locatorType': locatorType,
    'locator': locator,
    'originalDate': originalDate,
    'copyDate': copyDate,
    'custodian': custodian,
    'accessCopy': accessCopy,
  };
}

class ResearchClaimV1 {
  const ResearchClaimV1({
    required this.id,
    required this.text,
    required this.type,
    required this.informationConfidence,
    required this.confidenceRationale,
  });

  factory ResearchClaimV1.fromJson(Map<String, Object?> json) =>
      ResearchClaimV1(
        id: _requiredString(json, 'id'),
        text: _requiredString(json, 'text'),
        type: _enumByName(
          ResearchClaimType.values,
          json['type'] as String?,
          ResearchClaimType.contested,
        ),
        informationConfidence: _requiredString(json, 'informationConfidence'),
        confidenceRationale: _requiredString(json, 'confidenceRationale'),
      );

  final String id;
  final String text;
  final ResearchClaimType type;
  final String informationConfidence;
  final String confidenceRationale;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'text': text,
    'type': type.name,
    'informationConfidence': informationConfidence,
    'confidenceRationale': confidenceRationale,
  };
}

class ResearchEvidenceV1 {
  const ResearchEvidenceV1({
    required this.id,
    required this.claimId,
    required this.sourceId,
    required this.locatorId,
    required this.relationType,
    required this.sourceRole,
    required this.strength,
    this.inspectedBy = '',
    this.inspectedAt = '',
    this.representationChecksum = '',
  });

  factory ResearchEvidenceV1.fromJson(Map<String, Object?> json) =>
      ResearchEvidenceV1(
        id: _requiredString(json, 'id'),
        claimId: _requiredString(json, 'claimId'),
        sourceId: _requiredString(json, 'sourceId'),
        locatorId: _requiredString(json, 'locatorId'),
        relationType: _enumByName(
          EvidenceRelationType.values,
          json['relationType'] as String?,
          EvidenceRelationType.context,
        ),
        sourceRole: _enumByName(
          ResearchSourceRole.values,
          json['sourceRole'] as String?,
          ResearchSourceRole.secondary,
        ),
        strength: _requiredString(json, 'strength'),
        inspectedBy: (json['inspectedBy'] as String? ?? '').trim(),
        inspectedAt: (json['inspectedAt'] as String? ?? '').trim(),
        representationChecksum:
            (json['representationChecksum'] as String? ?? '').trim(),
      );

  final String id;
  final String claimId;
  final String sourceId;
  final String locatorId;
  final EvidenceRelationType relationType;
  final ResearchSourceRole sourceRole;
  final String strength;
  final String inspectedBy;
  final String inspectedAt;
  final String representationChecksum;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'claimId': claimId,
    'sourceId': sourceId,
    'locatorId': locatorId,
    'relationType': relationType.name,
    'sourceRole': sourceRole.name,
    'strength': strength,
    'inspectedBy': inspectedBy,
    'inspectedAt': inspectedAt,
    'representationChecksum': representationChecksum,
  };
}

class ResearchConflictV1 {
  const ResearchConflictV1({
    required this.id,
    required this.issue,
    required this.claimIds,
    required this.relation,
    required this.status,
    this.resolution = '',
    this.narrativeEffect = '',
  });

  factory ResearchConflictV1.fromJson(Map<String, Object?> json) =>
      ResearchConflictV1(
        id: _requiredString(json, 'id'),
        issue: _requiredString(json, 'issue'),
        claimIds: _list(
          json,
          'claimIds',
        ).map((e) => e.toString()).toList(growable: false),
        relation: _enumByName(
          ResearchConflictRelation.values,
          json['relation'] as String?,
          ResearchConflictRelation.alternateInterpretation,
        ),
        status: _enumByName(
          ResearchConflictStatus.values,
          json['status'] as String?,
          ResearchConflictStatus.unresolved,
        ),
        resolution: (json['resolution'] as String? ?? '').trim(),
        narrativeEffect: (json['narrativeEffect'] as String? ?? '').trim(),
      );

  final String id;
  final String issue;
  final List<String> claimIds;
  final ResearchConflictRelation relation;
  final ResearchConflictStatus status;
  final String resolution;
  final String narrativeEffect;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'issue': issue,
    'claimIds': claimIds,
    'relation': relation.name,
    'status': status.name,
    'resolution': resolution,
    'narrativeEffect': narrativeEffect,
  };
}

class TemporalAssertionV1 {
  const TemporalAssertionV1({
    required this.id,
    required this.subject,
    required this.predicate,
    required this.objectValue,
    required this.dimension,
    required this.sourceIds,
    this.validFrom = '',
    this.validTo = '',
    this.eventDate = '',
  });

  factory TemporalAssertionV1.fromJson(Map<String, Object?> json) =>
      TemporalAssertionV1(
        id: _requiredString(json, 'id'),
        subject: _requiredString(json, 'subject'),
        predicate: _requiredString(json, 'predicate'),
        objectValue: _requiredString(json, 'objectValue'),
        dimension: _enumByName(
          TemporalAssertionDimension.values,
          json['dimension'] as String?,
          TemporalAssertionDimension.other,
        ),
        sourceIds: _list(
          json,
          'sourceIds',
        ).map((e) => e.toString()).toList(growable: false),
        validFrom: (json['validFrom'] as String? ?? '').trim(),
        validTo: (json['validTo'] as String? ?? '').trim(),
        eventDate: (json['eventDate'] as String? ?? '').trim(),
      );

  final String id;
  final String subject;
  final String predicate;
  final String objectValue;
  final TemporalAssertionDimension dimension;
  final List<String> sourceIds;
  final String validFrom;
  final String validTo;
  final String eventDate;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'subject': subject,
    'predicate': predicate,
    'objectValue': objectValue,
    'dimension': dimension.name,
    'sourceIds': sourceIds,
    'validFrom': validFrom,
    'validTo': validTo,
    'eventDate': eventDate,
  };
}

class ArchiveProvenanceV1 {
  const ArchiveProvenanceV1({
    required this.id,
    required this.sourceId,
    required this.repository,
    this.fonds = '',
    this.series = '',
    this.register = '',
    this.item = '',
    this.manifestation = '',
    this.originalDate = '',
    this.copyDate = '',
  });

  factory ArchiveProvenanceV1.fromJson(Map<String, Object?> json) =>
      ArchiveProvenanceV1(
        id: _requiredString(json, 'id'),
        sourceId: _requiredString(json, 'sourceId'),
        repository: _requiredString(json, 'repository'),
        fonds: (json['fonds'] as String? ?? '').trim(),
        series: (json['series'] as String? ?? '').trim(),
        register: (json['register'] as String? ?? '').trim(),
        item: (json['item'] as String? ?? '').trim(),
        manifestation: (json['manifestation'] as String? ?? '').trim(),
        originalDate: (json['originalDate'] as String? ?? '').trim(),
        copyDate: (json['copyDate'] as String? ?? '').trim(),
      );

  final String id;
  final String sourceId;
  final String repository;
  final String fonds;
  final String series;
  final String register;
  final String item;
  final String manifestation;
  final String originalDate;
  final String copyDate;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'sourceId': sourceId,
    'repository': repository,
    'fonds': fonds,
    'series': series,
    'register': register,
    'item': item,
    'manifestation': manifestation,
    'originalDate': originalDate,
    'copyDate': copyDate,
  };
}

class ResearchMediaRightsV1 {
  const ResearchMediaRightsV1({
    required this.id,
    required this.assetId,
    required this.rightsHolder,
    required this.allowedUse,
    required this.reviewStatus,
    this.creator = '',
    this.sourcePageUrl = '',
    this.originalAssetUrl = '',
    this.licenseCode = '',
    this.licenseUrl = '',
    this.attributionText = '',
    this.derivativeProvenance = '',
  });

  factory ResearchMediaRightsV1.fromJson(Map<String, Object?> json) =>
      ResearchMediaRightsV1(
        id: _requiredString(json, 'id'),
        assetId: _requiredString(json, 'assetId'),
        rightsHolder: _requiredString(json, 'rightsHolder'),
        allowedUse: _requiredString(json, 'allowedUse'),
        reviewStatus: _requiredString(json, 'reviewStatus'),
        creator: (json['creator'] as String? ?? '').trim(),
        sourcePageUrl: (json['sourcePageUrl'] as String? ?? '').trim(),
        originalAssetUrl: (json['originalAssetUrl'] as String? ?? '').trim(),
        licenseCode: (json['licenseCode'] as String? ?? '').trim(),
        licenseUrl: (json['licenseUrl'] as String? ?? '').trim(),
        attributionText: (json['attributionText'] as String? ?? '').trim(),
        derivativeProvenance: (json['derivativeProvenance'] as String? ?? '')
            .trim(),
      );

  final String id;
  final String assetId;
  final String rightsHolder;
  final String allowedUse;
  final String reviewStatus;
  final String creator;
  final String sourcePageUrl;
  final String originalAssetUrl;
  final String licenseCode;
  final String licenseUrl;
  final String attributionText;
  final String derivativeProvenance;

  bool get publicUseApproved => reviewStatus == 'PUBLIC_APPROVED';

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'assetId': assetId,
    'rightsHolder': rightsHolder,
    'allowedUse': allowedUse,
    'reviewStatus': reviewStatus,
    'creator': creator,
    'sourcePageUrl': sourcePageUrl,
    'originalAssetUrl': originalAssetUrl,
    'licenseCode': licenseCode,
    'licenseUrl': licenseUrl,
    'attributionText': attributionText,
    'derivativeProvenance': derivativeProvenance,
  };
}

class ResearchReviewAdjudicationV1 {
  const ResearchReviewAdjudicationV1({
    required this.id,
    required this.stage,
    required this.reviewerBody,
    required this.authorityRef,
    required this.scope,
    required this.decision,
    required this.evidenceFreezeId,
    this.approvedVersionId = '',
    this.supersedesVersion = '',
  });

  factory ResearchReviewAdjudicationV1.fromJson(Map<String, Object?> json) =>
      ResearchReviewAdjudicationV1(
        id: _requiredString(json, 'id'),
        stage: _enumByName(
          ResearchReviewStage.values,
          json['stage'] as String?,
          ResearchReviewStage.experimentalHuman,
        ),
        reviewerBody: _requiredString(json, 'reviewerBody'),
        authorityRef: _requiredString(json, 'authorityRef'),
        scope: _requiredString(json, 'scope'),
        decision: _enumByName(
          ResearchReviewDecision.values,
          json['decision'] as String?,
          ResearchReviewDecision.pending,
        ),
        evidenceFreezeId: _requiredString(json, 'evidenceFreezeId'),
        approvedVersionId: (json['approvedVersionId'] as String? ?? '').trim(),
        supersedesVersion: (json['supersedesVersion'] as String? ?? '').trim(),
      );

  final String id;
  final ResearchReviewStage stage;
  final String reviewerBody;
  final String authorityRef;
  final String scope;
  final ResearchReviewDecision decision;
  final String evidenceFreezeId;
  final String approvedVersionId;
  final String supersedesVersion;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'stage': stage.name,
    'reviewerBody': reviewerBody,
    'authorityRef': authorityRef,
    'scope': scope,
    'decision': decision.name,
    'evidenceFreezeId': evidenceFreezeId,
    'approvedVersionId': approvedVersionId,
    'supersedesVersion': supersedesVersion,
  };
}

class ResearchPackageV1 {
  const ResearchPackageV1({
    required this.packageId,
    required this.version,
    required this.siteEntityId,
    required this.researchTopicId,
    required this.lifecycleStage,
    required this.sections,
    required this.sources,
    required this.locators,
    required this.claims,
    required this.evidence,
    required this.conflicts,
    required this.temporalAssertions,
    required this.archiveProvenance,
    required this.mediaRights,
    required this.reviews,
    this.relations = const <ResearchEntityRelation>[],
    this.aliases = const <GovernedEntityAlias>[],
    this.boundaries = const <ResearchSpatialBoundaryObservation>[],
    this.currentConditions = const <CurrentConditionObservation>[],
    this.publicationDecision = ResearchPublicationDecision.pending,
  });

  factory ResearchPackageV1.fromJson(Map<String, Object?> json) {
    if (json['schema'] != palEyesResearchPackageSchemaV1) {
      throw const FormatException('Unsupported research package schema.');
    }
    return ResearchPackageV1(
      packageId: _requiredString(json, 'packageId'),
      version: _requiredString(json, 'version'),
      siteEntityId: _requiredString(json, 'siteEntityId'),
      researchTopicId: _requiredString(json, 'researchTopicId'),
      lifecycleStage: _enumByName(
        ResearchPackageStage.values,
        json['lifecycleStage'] as String?,
        ResearchPackageStage.researchCompleteReviewDeferred,
      ),
      sections: _list(json, 'sections')
          .map((e) => ResearchNarrativeSectionV1.fromJson(_map(e)))
          .toList(growable: false),
      sources: _list(
        json,
        'sources',
      ).map((e) => ResearchSourceV1.fromJson(_map(e))).toList(growable: false),
      locators: _list(
        json,
        'locators',
      ).map((e) => ResearchLocatorV1.fromJson(_map(e))).toList(growable: false),
      claims: _list(
        json,
        'claims',
      ).map((e) => ResearchClaimV1.fromJson(_map(e))).toList(growable: false),
      evidence: _list(json, 'evidence')
          .map((e) => ResearchEvidenceV1.fromJson(_map(e)))
          .toList(growable: false),
      conflicts: _list(json, 'conflicts')
          .map((e) => ResearchConflictV1.fromJson(_map(e)))
          .toList(growable: false),
      temporalAssertions: _list(json, 'temporalAssertions')
          .map((e) => TemporalAssertionV1.fromJson(_map(e)))
          .toList(growable: false),
      archiveProvenance: _list(json, 'archiveProvenance')
          .map((e) => ArchiveProvenanceV1.fromJson(_map(e)))
          .toList(growable: false),
      mediaRights: _list(json, 'mediaRights')
          .map((e) => ResearchMediaRightsV1.fromJson(_map(e)))
          .toList(growable: false),
      reviews: _list(json, 'reviews')
          .map((e) => ResearchReviewAdjudicationV1.fromJson(_map(e)))
          .toList(growable: false),
      relations: _list(
        json,
        'relations',
      ).map((e) => _relationFromJson(_map(e))).toList(growable: false),
      aliases: _list(
        json,
        'aliases',
      ).map((e) => _aliasFromJson(_map(e))).toList(growable: false),
      boundaries: _list(
        json,
        'boundaries',
      ).map((e) => _boundaryFromJson(_map(e))).toList(growable: false),
      currentConditions: _list(
        json,
        'currentConditions',
      ).map((e) => _conditionFromJson(_map(e))).toList(growable: false),
      publicationDecision: _enumByName(
        ResearchPublicationDecision.values,
        json['publicationDecision'] as String?,
        ResearchPublicationDecision.pending,
      ),
    );
  }

  factory ResearchPackageV1.fromJsonString(String source) {
    final value = jsonDecode(source);
    if (value is! Map) {
      throw const FormatException('Research package root must be an object.');
    }
    return ResearchPackageV1.fromJson(Map<String, Object?>.from(value));
  }

  final String packageId;
  final String version;
  final String siteEntityId;
  final String researchTopicId;
  final ResearchPackageStage lifecycleStage;
  final List<ResearchNarrativeSectionV1> sections;
  final List<ResearchSourceV1> sources;
  final List<ResearchLocatorV1> locators;
  final List<ResearchClaimV1> claims;
  final List<ResearchEvidenceV1> evidence;
  final List<ResearchConflictV1> conflicts;
  final List<TemporalAssertionV1> temporalAssertions;
  final List<ArchiveProvenanceV1> archiveProvenance;
  final List<ResearchMediaRightsV1> mediaRights;
  final List<ResearchReviewAdjudicationV1> reviews;
  final List<ResearchEntityRelation> relations;
  final List<GovernedEntityAlias> aliases;
  final List<ResearchSpatialBoundaryObservation> boundaries;
  final List<CurrentConditionObservation> currentConditions;
  final ResearchPublicationDecision publicationDecision;

  String toJsonString() => jsonEncode(toJson());

  Map<String, Object?> toJson() => <String, Object?>{
    'schema': palEyesResearchPackageSchemaV1,
    'packageId': packageId,
    'version': version,
    'siteEntityId': siteEntityId,
    'researchTopicId': researchTopicId,
    'lifecycleStage': lifecycleStage.name,
    'publicationDecision': publicationDecision.name,
    'sections': sections.map((e) => e.toJson()).toList(),
    'sources': sources.map((e) => e.toJson()).toList(),
    'locators': locators.map((e) => e.toJson()).toList(),
    'claims': claims.map((e) => e.toJson()).toList(),
    'evidence': evidence.map((e) => e.toJson()).toList(),
    'conflicts': conflicts.map((e) => e.toJson()).toList(),
    'temporalAssertions': temporalAssertions.map((e) => e.toJson()).toList(),
    'archiveProvenance': archiveProvenance.map((e) => e.toJson()).toList(),
    'mediaRights': mediaRights.map((e) => e.toJson()).toList(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'relations': relations.map(_relationToJson).toList(),
    'aliases': aliases.map(_aliasToJson).toList(),
    'boundaries': boundaries.map(_boundaryToJson).toList(),
    'currentConditions': currentConditions.map(_conditionToJson).toList(),
  };

  ResearchContentPackage toIntegrityPackage() => ResearchContentPackage(
    packageId: packageId,
    version: version,
    siteEntityId: siteEntityId,
    researchTopicId: researchTopicId,
    stage: lifecycleStage,
    publicationDecision: publicationDecision,
    relations: relations,
    aliases: aliases,
    boundaries: boundaries,
    currentConditions: currentConditions,
    evidenceStates: mediaRights
        .map(
          (rights) => ResearchEvidenceIntegrityState(
            sourceVerification: SourceVerificationState.verified,
            claimVerification: ResearchVerificationState.unresolved,
            mediaClearance: rights.publicUseApproved
                ? MediaClearanceState.publicApproved
                : MediaClearanceState.notCleared,
          ),
        )
        .toList(growable: false),
  );
}

class ResearchPackageValidationIssue {
  const ResearchPackageValidationIssue(this.code, this.message);
  final String code;
  final String message;
}

class ResearchPackageV1Validator {
  const ResearchPackageV1Validator._();

  static List<ResearchPackageValidationIssue> validate(
    ResearchPackageV1 package,
  ) {
    final issues = <ResearchPackageValidationIssue>[];
    _uniqueIds(package.sections.map((e) => e.id), 'SECTION_ID', issues);
    _uniqueIds(package.sources.map((e) => e.id), 'SOURCE_ID', issues);
    _uniqueIds(package.locators.map((e) => e.id), 'LOCATOR_ID', issues);
    _uniqueIds(package.claims.map((e) => e.id), 'CLAIM_ID', issues);
    _uniqueIds(package.evidence.map((e) => e.id), 'EVIDENCE_ID', issues);
    _uniqueIds(package.conflicts.map((e) => e.id), 'CONFLICT_ID', issues);

    final sourceIds = package.sources.map((e) => e.id).toSet();
    final locatorById = <String, ResearchLocatorV1>{
      for (final item in package.locators) item.id: item,
    };
    final claimIds = package.claims.map((e) => e.id).toSet();
    for (final locator in package.locators) {
      if (!sourceIds.contains(locator.sourceId)) {
        issues.add(
          ResearchPackageValidationIssue('LOCATOR_SOURCE_MISSING', locator.id),
        );
      }
    }
    for (final evidence in package.evidence) {
      if (!claimIds.contains(evidence.claimId) ||
          !sourceIds.contains(evidence.sourceId)) {
        issues.add(
          ResearchPackageValidationIssue(
            'EVIDENCE_REFERENCE_MISSING',
            evidence.id,
          ),
        );
      }
      if (!locatorById.containsKey(evidence.locatorId)) {
        issues.add(
          ResearchPackageValidationIssue(
            'EVIDENCE_LOCATOR_MISSING',
            evidence.id,
          ),
        );
      }
    }
    for (final section in package.sections) {
      for (final paragraph in section.paragraphs) {
        for (final claimId in paragraph.claimIds) {
          if (!claimIds.contains(claimId)) {
            issues.add(
              ResearchPackageValidationIssue(
                'PARAGRAPH_CLAIM_MISSING',
                paragraph.id,
              ),
            );
          }
        }
      }
    }
    for (final conflict in package.conflicts) {
      if (conflict.claimIds.any((id) => !claimIds.contains(id))) {
        issues.add(
          ResearchPackageValidationIssue('CONFLICT_CLAIM_MISSING', conflict.id),
        );
      }
    }
    for (final item in package.temporalAssertions) {
      if (item.sourceIds.any((id) => !sourceIds.contains(id))) {
        issues.add(
          ResearchPackageValidationIssue('TEMPORAL_SOURCE_MISSING', item.id),
        );
      }
    }
    for (final item in package.archiveProvenance) {
      if (!sourceIds.contains(item.sourceId)) {
        issues.add(
          ResearchPackageValidationIssue('ARCHIVE_SOURCE_MISSING', item.id),
        );
      }
    }

    for (final issue in ResearchIntegrityValidator.validate(
      package.toIntegrityPackage(),
    )) {
      issues.add(ResearchPackageValidationIssue(issue.code, issue.message));
    }

    final acceptedExperimental = package.reviews.any(
      (review) =>
          review.stage == ResearchReviewStage.experimentalHuman &&
          review.decision == ResearchReviewDecision.accept,
    );
    final specialistAccepted = package.reviews.any(
      (review) =>
          review.stage == ResearchReviewStage.specialistExpert &&
          review.decision == ResearchReviewDecision.accept,
    );
    final competentAccepted = package.reviews.any(
      (review) =>
          review.stage == ResearchReviewStage.competentAuthority &&
          review.decision == ResearchReviewDecision.accept,
    );
    if (acceptedExperimental &&
        package.publicationDecision == ResearchPublicationDecision.approved &&
        (!specialistAccepted || !competentAccepted)) {
      issues.add(
        const ResearchPackageValidationIssue(
          'EXPERIMENTAL_APPROVAL_CANNOT_ESCALATE_TO_PUBLICATION',
          'Experimental approval never substitutes for specialist and competent authority approval.',
        ),
      );
    }

    for (final rights in package.mediaRights) {
      if (rights.publicUseApproved &&
          (rights.rightsHolder.isEmpty ||
              rights.allowedUse.isEmpty ||
              rights.sourcePageUrl.isEmpty)) {
        issues.add(
          ResearchPackageValidationIssue(
            'MEDIA_PUBLIC_APPROVAL_REQUIRES_RIGHTS_BASIS',
            rights.id,
          ),
        );
      }
    }
    return issues;
  }

  static void _uniqueIds(
    Iterable<String> ids,
    String prefix,
    List<ResearchPackageValidationIssue> issues,
  ) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        issues.add(ResearchPackageValidationIssue('DUPLICATE_$prefix', id));
      }
    }
  }
}

Map<String, Object?> _relationToJson(ResearchEntityRelation value) =>
    <String, Object?>{
      'id': value.id,
      'sourceEntityId': value.sourceEntityId,
      'targetEntityId': value.targetEntityId,
      'type': value.type.name,
      'provenance': value.provenance,
      'verificationState': value.verificationState.name,
    };

ResearchEntityRelation _relationFromJson(Map<String, Object?> json) =>
    ResearchEntityRelation(
      id: _requiredString(json, 'id'),
      sourceEntityId: _requiredString(json, 'sourceEntityId'),
      targetEntityId: _requiredString(json, 'targetEntityId'),
      type: _enumByName(
        ResearchEntityRelationType.values,
        json['type'] as String?,
        ResearchEntityRelationType.relatedTo,
      ),
      provenance: _requiredString(json, 'provenance'),
      verificationState: _enumByName(
        ResearchVerificationState.values,
        json['verificationState'] as String?,
        ResearchVerificationState.unresolved,
      ),
    );

Map<String, Object?> _aliasToJson(GovernedEntityAlias value) =>
    <String, Object?>{
      'id': value.id,
      'entityId': value.entityId,
      'label': value.label,
      'language': value.language,
      'type': value.type.name,
      'provenance': value.provenance,
      'verificationState': value.verificationState.name,
      'validPeriod': value.validPeriod,
      'disambiguationNote': value.disambiguationNote,
    };

GovernedEntityAlias _aliasFromJson(Map<String, Object?> json) =>
    GovernedEntityAlias(
      id: _requiredString(json, 'id'),
      entityId: _requiredString(json, 'entityId'),
      label: _requiredString(json, 'label'),
      language: _requiredString(json, 'language'),
      type: _enumByName(
        GovernedAliasType.values,
        json['type'] as String?,
        GovernedAliasType.alternativeSpelling,
      ),
      provenance: _requiredString(json, 'provenance'),
      verificationState: _enumByName(
        ResearchVerificationState.values,
        json['verificationState'] as String?,
        ResearchVerificationState.unresolved,
      ),
      validPeriod: (json['validPeriod'] as String?)?.trim(),
      disambiguationNote: (json['disambiguationNote'] as String? ?? '').trim(),
    );

Map<String, Object?> _boundaryToJson(
  ResearchSpatialBoundaryObservation value,
) => <String, Object?>{
  'id': value.id,
  'entityId': value.entityId,
  'type': value.type.name,
  'sourceId': value.sourceId,
  'scope': value.scope,
  'temporalScope': value.temporalScope,
  'certainty': value.certainty.name,
  'observedAt': value.observedAt?.toIso8601String(),
  'geometryReference': value.geometryReference,
};

ResearchSpatialBoundaryObservation _boundaryFromJson(
  Map<String, Object?> json,
) => ResearchSpatialBoundaryObservation(
  id: _requiredString(json, 'id'),
  entityId: _requiredString(json, 'entityId'),
  type: _enumByName(
    ResearchBoundaryType.values,
    json['type'] as String?,
    ResearchBoundaryType.tentativeHeritageBoundary,
  ),
  sourceId: _requiredString(json, 'sourceId'),
  scope: _requiredString(json, 'scope'),
  temporalScope: _requiredString(json, 'temporalScope'),
  certainty: _enumByName(
    ResearchVerificationState.values,
    json['certainty'] as String?,
    ResearchVerificationState.unresolved,
  ),
  observedAt: DateTime.tryParse((json['observedAt'] as String? ?? '').trim()),
  geometryReference: (json['geometryReference'] as String?)?.trim(),
);

Map<String, Object?> _conditionToJson(CurrentConditionObservation value) =>
    <String, Object?>{
      'id': value.id,
      'entityId': value.entityId,
      'type': value.type.name,
      'status': value.status,
      'observedAt': value.observedAt.toIso8601String(),
      'sourceId': value.sourceId,
      'scope': value.scope.name,
      'componentEntityId': value.componentEntityId,
      'note': value.note,
    };

CurrentConditionObservation _conditionFromJson(Map<String, Object?> json) =>
    CurrentConditionObservation(
      id: _requiredString(json, 'id'),
      entityId: _requiredString(json, 'entityId'),
      type: _enumByName(
        CurrentConditionType.values,
        json['type'] as String?,
        CurrentConditionType.generalCondition,
      ),
      status: _requiredString(json, 'status'),
      observedAt: DateTime.parse(_requiredString(json, 'observedAt')),
      sourceId: _requiredString(json, 'sourceId'),
      scope: _enumByName(
        ResearchObservationScope.values,
        json['scope'] as String?,
        ResearchObservationScope.wholeEntity,
      ),
      componentEntityId: (json['componentEntityId'] as String?)?.trim(),
      note: (json['note'] as String? ?? '').trim(),
    );
