import 'package:pal_eyes/features/places/data/governed_catalog_generated.dart';
import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';
import 'package:pal_eyes/features/research/domain/staging_research_package_manifest.dart';

const String researchCorpusFreezeId =
    'PAL_EYES_GOVERNED_RESEARCH_CORPUS_V1_FROZEN_2026_09_15';
const int researchCorpusTotalCount = 80;
const int researchCorpusCatalogCount = 79;
const int researchCorpusCompletedCount = 62;
const int researchCorpusInsufficientCount = 12;
const int researchCorpusLinkedCount = 3;
const int researchCorpusIncompleteCount = 3;

const Set<int> _incomplete = <int>{1, 2, 3};
const Set<int> _insufficient = <int>{
  4,
  16,
  34,
  42,
  46,
  50,
  51,
  53,
  55,
  57,
  59,
  61,
};
const Set<int> _linkedCatalog = <int>{22, 27};

List<StagingResearchPackageManifest> buildFrozenStagingResearchCorpus() {
  assert(governedSiteCatalog.length == researchCorpusCatalogCount);
  final manifests = <StagingResearchPackageManifest>[
    for (var index = 0; index < governedSiteCatalog.length; index++)
      _catalogManifest(index + 1),
    _externalManifest,
  ];
  return List<StagingResearchPackageManifest>.unmodifiable(manifests);
}

StagingResearchPackageManifest _catalogManifest(int censusNumber) {
  final site = governedSiteCatalog[censusNumber - 1];
  final censusId = 'PAL-EYES-CENSUS-${censusNumber.toString().padLeft(3, '0')}';
  final packageId = 'RCP-V1-${censusNumber.toString().padLeft(3, '0')}';
  final researchTopicId =
      'RESEARCH_TOPIC_${site.id.substring('site-'.length).toUpperCase()}_GENERAL';

  final packageClass = _packageClass(censusNumber);
  return StagingResearchPackageManifest(
    packageId: packageId,
    censusRecordId: censusId,
    catalogSiteId: site.id,
    siteEntityName: site.nameAr,
    researchTopicId: researchTopicId,
    packageClass: packageClass,
    ingestMode: _ingestMode(packageClass),
    evidenceGate: _evidenceGate(packageClass),
    uncertaintyClass: _uncertaintyClass(packageClass),
    sourceReference:
        'Workspace Drive / Corpus_Acceptance_V1 / $censusId / $researchCorpusFreezeId',
    packageAcceptance: _packageAcceptance(packageClass),
    editorialReadback: _editorialReadback(packageClass),
    relationSummary: _relationSummary(censusNumber),
    relations: _relations(censusNumber),
  );
}

StagingResearchPackageClass _packageClass(int n) {
  if (_incomplete.contains(n)) {
    return StagingResearchPackageClass.notPromotedResearchIncomplete;
  }
  if (_insufficient.contains(n)) {
    return StagingResearchPackageClass.statusOnlyNoNarrative;
  }
  if (_linkedCatalog.contains(n)) {
    return StagingResearchPackageClass.linkedResearchReference;
  }
  return StagingResearchPackageClass.governedContentReferenceManifest;
}

StagingResearchIngestMode _ingestMode(StagingResearchPackageClass value) =>
    switch (value) {
      StagingResearchPackageClass.governedContentReferenceManifest =>
        StagingResearchIngestMode.stagingContentPackage,
      StagingResearchPackageClass.statusOnlyNoNarrative =>
        StagingResearchIngestMode.stagingStatusRecordOnly,
      StagingResearchPackageClass.linkedResearchReference =>
        StagingResearchIngestMode.stagingLinkReference,
      StagingResearchPackageClass.notPromotedResearchIncomplete =>
        StagingResearchIngestMode.notPromoted,
    };

String _evidenceGate(StagingResearchPackageClass value) => switch (value) {
  StagingResearchPackageClass.governedContentReferenceManifest => 'PASS',
  StagingResearchPackageClass.statusOnlyNoNarrative => 'FAIL_CURRENTLY',
  StagingResearchPackageClass.linkedResearchReference =>
    'NOT_RESCREENED_CURRENT_CYCLE',
  StagingResearchPackageClass.notPromotedResearchIncomplete =>
    'NOT_YET_SCREENED',
};

String _uncertaintyClass(StagingResearchPackageClass value) => switch (value) {
  StagingResearchPackageClass.governedContentReferenceManifest =>
    'PRESERVE_CLAIM_LEVEL_UNCERTAINTY',
  StagingResearchPackageClass.statusOnlyNoNarrative =>
    'UNRESOLVED_NOT_REJECTED',
  StagingResearchPackageClass.linkedResearchReference =>
    'LINKED_PROJECT_REVIEW_STATE',
  StagingResearchPackageClass.notPromotedResearchIncomplete =>
    'NOT_SCREENED_PENDING_OR_BOUNDARY_REQUIRED',
};

String _packageAcceptance(StagingResearchPackageClass value) =>
    value == StagingResearchPackageClass.notPromotedResearchIncomplete
    ? 'NOT_PROMOTED_RESEARCH_INCOMPLETE'
    : 'ACCEPTED_FOR_STAGING_ONLY';

String _editorialReadback(StagingResearchPackageClass value) => switch (value) {
  StagingResearchPackageClass.governedContentReferenceManifest =>
    'MANIFEST_EDITORIAL_READBACK_PASS_SOURCE_REVIEW_DEFERRED',
  StagingResearchPackageClass.statusOnlyNoNarrative =>
    'EDITORIAL_STATUS_READBACK_PASS_NO_NARRATIVE',
  StagingResearchPackageClass.linkedResearchReference =>
    'LINK_REFERENCE_READBACK_PASS_REVIEW_OWNED_BY_LINKED_PROJECT',
  StagingResearchPackageClass.notPromotedResearchIncomplete =>
    'NOT_APPLICABLE_RESEARCH_INCOMPLETE',
};

String _siteId(int censusNumber) => governedSiteCatalog[censusNumber - 1].id;

String _relationSummary(int n) => switch (n) {
  20 => 'CHILD_COMPONENT_OF_CENSUS_011_IBRAHIMI_SANCTUARY',
  22 => 'EXISTING_INDEPENDENT_RESEARCH_LINKED_NOT_DUPLICATED',
  27 => 'COMPONENT_OF_CENSUS_022_SOLOMON_POOLS_OWNER_RESEARCH',
  66 =>
    'NABI_MUSA_COMPLEX_OWNER_WITH_CENOTAPH_COMPONENT; CENSUS_069_LINKS_HERE',
  69 =>
    'EXISTING_OWNER_LINK_TO_CENSUS_066; NO_DUPLICATE_OWNER_OR_RESEARCH_CHAIN',
  70 => 'GREAT_OMARI_COMPONENT_OF_GAZA_HISTORIC_CENTRE_CENSUS_075',
  71 => 'TELL_EL_AJJUL_DISTINCT_FROM_GAZA_HISTORIC_CENTRE_CENSUS_075',
  72 => 'HAMMAM_AL_SAMMARA_COMPONENT_OF_GAZA_HISTORIC_CENTRE_CENSUS_075',
  73 => 'BARQUQ_CASTLE_COMPONENT_OF_HISTORIC_KHAN_YUNIS_CENSUS_078',
  74 => 'SAINT_PORPHYRIUS_COMPONENT_OF_GAZA_HISTORIC_CENTRE_CENSUS_075',
  75 =>
    'GAZA_HISTORIC_CENTRE_WHOLE; OMARI_PORPHYRIUS_HAMMAM_COMPONENTS; TELL_EL_AJJUL_SEPARATE',
  76 =>
    'MAQAM_DISTINCT_FROM_CEMETERY_AND_NEIGHBORHOOD; PETER_MONASTERY_LINK_HYPOTHESIS_ONLY',
  77 =>
    'ANTHEDON_BLAKHIYYA_IDENTIFICATION_PROBABLE_NOT_ABSOLUTE; MAIUMAS_SEPARATE',
  78 =>
    'HISTORIC_KHAN_YUNIS_URBAN_CORE_WHOLE; BARQUQ_FOUNDATIONAL_COMPONENT; MODERN_CITY_DISTINCT',
  79 =>
    'TELL_RAFAH_RAPHIA_DISTINCT_FROM_MODERN_CITY_1906_BOUNDARY_AND_CURRENT_CROSSING',
  _ => '',
};

List<ResearchEntityRelation> _relations(int n) => switch (n) {
  20 => <ResearchEntityRelation>[
    _relation(
      n,
      11,
      ResearchEntityRelationType.componentOf,
      'C020_COMPONENT_OF_C011',
    ),
  ],
  27 => <ResearchEntityRelation>[
    _relation(
      n,
      22,
      ResearchEntityRelationType.componentOf,
      'C027_COMPONENT_OF_C022',
    ),
  ],
  69 => <ResearchEntityRelation>[
    _relation(
      n,
      66,
      ResearchEntityRelationType.existingOwnerLink,
      'C069_OWNER_LINK_C066',
    ),
  ],
  70 => <ResearchEntityRelation>[
    _relation(
      n,
      75,
      ResearchEntityRelationType.componentOf,
      'C070_COMPONENT_OF_C075',
    ),
  ],
  71 => <ResearchEntityRelation>[
    _relation(
      n,
      75,
      ResearchEntityRelationType.relatedTo,
      'C071_DISTINCT_RELATED_C075',
    ),
  ],
  72 => <ResearchEntityRelation>[
    _relation(
      n,
      75,
      ResearchEntityRelationType.componentOf,
      'C072_COMPONENT_OF_C075',
    ),
  ],
  73 => <ResearchEntityRelation>[
    _relation(
      n,
      78,
      ResearchEntityRelationType.componentOf,
      'C073_COMPONENT_OF_C078',
    ),
  ],
  74 => <ResearchEntityRelation>[
    _relation(
      n,
      75,
      ResearchEntityRelationType.componentOf,
      'C074_COMPONENT_OF_C075',
    ),
  ],
  77 => <ResearchEntityRelation>[
    ResearchEntityRelation(
      id: 'C077_PROBABLE_ANTHEDON_IDENTIFICATION',
      sourceEntityId: _siteId(77),
      targetEntityId: 'research-entity-anthedon-ancient-harbour-city',
      type: ResearchEntityRelationType.probableIdentification,
      provenance: 'Corpus_Acceptance_V1/PAL-EYES-CENSUS-077',
      verificationState: ResearchVerificationState.probable,
    ),
  ],
  79 => <ResearchEntityRelation>[
    ResearchEntityRelation(
      id: 'C079_SEPARATE_MODERN_RAFAH',
      sourceEntityId: _siteId(79),
      targetEntityId: 'modern-rafah-city',
      type: ResearchEntityRelationType.separateModernEntity,
      provenance: 'Corpus_Acceptance_V1/PAL-EYES-CENSUS-079',
      verificationState: ResearchVerificationState.verified,
    ),
    ResearchEntityRelation(
      id: 'C079_SEPARATE_CURRENT_CROSSING',
      sourceEntityId: _siteId(79),
      targetEntityId: 'current-rafah-crossing-infrastructure',
      type: ResearchEntityRelationType.separateModernEntity,
      provenance: 'Corpus_Acceptance_V1/PAL-EYES-CENSUS-079',
      verificationState: ResearchVerificationState.verified,
    ),
  ],
  _ => const <ResearchEntityRelation>[],
};

ResearchEntityRelation _relation(
  int sourceCensus,
  int targetCensus,
  ResearchEntityRelationType type,
  String id,
) => ResearchEntityRelation(
  id: id,
  sourceEntityId: _siteId(sourceCensus),
  targetEntityId: _siteId(targetCensus),
  type: type,
  provenance:
      'Corpus_Acceptance_V1/PAL-EYES-CENSUS-${sourceCensus.toString().padLeft(3, '0')}',
  verificationState: ResearchVerificationState.verified,
);

const StagingResearchPackageManifest
_externalManifest = StagingResearchPackageManifest(
  packageId: 'RCP-V1-EXT-001',
  censusRecordId: 'PAL-EYES-CENSUS-EXT-001',
  siteEntityName: 'مسجد بلال بن رباح / قبة راحيل',
  researchTopicId: 'TOPIC_BILAL_HERITAGE_TERMINOLOGY_EXISTING',
  packageClass: StagingResearchPackageClass.linkedResearchReference,
  ingestMode: StagingResearchIngestMode.stagingLinkReference,
  evidenceGate: 'NOT_RESCREENED_CURRENT_CYCLE',
  uncertaintyClass: 'LINKED_PROJECT_REVIEW_STATE',
  sourceReference:
      'Workspace Drive / Corpus_Acceptance_V1 / PAL-EYES-CENSUS-EXT-001 / PAL_EYES_GOVERNED_RESEARCH_CORPUS_V1_FROZEN_2026_09_15',
  packageAcceptance: 'ACCEPTED_FOR_STAGING_ONLY',
  editorialReadback:
      'LINK_REFERENCE_READBACK_PASS_REVIEW_OWNED_BY_LINKED_PROJECT',
  relationSummary:
      'EXTERNAL_ENTITY_LINKED_NOT_PRESENT_IN_79_CATALOG; EXISTING_RESEARCH_LINKED_NOT_MERGED',
);
