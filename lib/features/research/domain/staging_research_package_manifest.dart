import 'package:pal_eyes/features/research/domain/research_integrity_contracts.dart';

enum StagingResearchPackageClass {
  governedContentReferenceManifest,
  statusOnlyNoNarrative,
  linkedResearchReference,
  notPromotedResearchIncomplete,
}

enum StagingResearchIngestMode {
  stagingContentPackage,
  stagingStatusRecordOnly,
  stagingLinkReference,
  notPromoted,
}

class StagingResearchPackageManifest {
  const StagingResearchPackageManifest({
    required this.packageId,
    required this.censusRecordId,
    required this.siteEntityName,
    required this.researchTopicId,
    required this.packageClass,
    required this.ingestMode,
    required this.evidenceGate,
    required this.uncertaintyClass,
    required this.sourceReference,
    required this.packageAcceptance,
    required this.editorialReadback,
    this.catalogSiteId,
    this.relationSummary = '',
    this.relations = const <ResearchEntityRelation>[],
  });

  final String packageId;
  final String censusRecordId;
  final String? catalogSiteId;
  final String siteEntityName;
  final String researchTopicId;
  final StagingResearchPackageClass packageClass;
  final StagingResearchIngestMode ingestMode;
  final String evidenceGate;
  final String uncertaintyClass;
  final String sourceReference;
  final String packageAcceptance;
  final String editorialReadback;
  final String relationSummary;
  final List<ResearchEntityRelation> relations;

  bool get publicationEligible => false;
  bool get databaseMutationAllowed => false;
  MediaClearanceState get mediaClearance => MediaClearanceState.notCleared;

  bool get exposesResearchNarrativeReference =>
      packageClass ==
      StagingResearchPackageClass.governedContentReferenceManifest;

  bool get isStatusOnly =>
      packageClass == StagingResearchPackageClass.statusOnlyNoNarrative ||
      packageClass == StagingResearchPackageClass.notPromotedResearchIncomplete;

  bool get isLinkedReference =>
      packageClass == StagingResearchPackageClass.linkedResearchReference;

  String get previewStatusLabelAr => switch (packageClass) {
    StagingResearchPackageClass.governedContentReferenceManifest =>
      'اعتماد تجريبي غير إنتاجي — الدين التخصصي مفتوح',
    StagingResearchPackageClass.statusOnlyNoNarrative =>
      'الدليل غير كافٍ حاليًا',
    StagingResearchPackageClass.linkedResearchReference => 'بحث مستقل مرتبط',
    StagingResearchPackageClass.notPromotedResearchIncomplete =>
      'بحث قيد التحقق',
  };

  String get previewStatusDescriptionAr => switch (packageClass) {
    StagingResearchPackageClass.governedContentReferenceManifest =>
      'اعتمدت الحزمة بشريًا للاستخدام البحثي والتجريبي غير الإنتاجي فقط. تبقى المراجعة التخصصية المطلوبة دينًا صريحًا قبل أي نشر أو إنتاج.',
    StagingResearchPackageClass.statusOnlyNoNarrative =>
      'تظهر حالة البحث وفجوات الدليل فقط، ولا يُعرض سرد بحثي غير متحقق.',
    StagingResearchPackageClass.linkedResearchReference =>
      'هذا السجل مرتبط ببحث قائم، وتبقى المراجعة لدى البحث المالك دون إنشاء سلسلة مكررة.',
    StagingResearchPackageClass.notPromotedResearchIncomplete =>
      'البحث لم يكتمل بعد؛ تظهر حالته للمتابعة والتدقيق دون تقديمه كحقيقة نهائية.',
  };

  ResearchContentPackage? toIntegrityPackage() {
    if (catalogSiteId == null || !exposesResearchNarrativeReference) {
      return null;
    }
    return ResearchContentPackage(
      packageId: packageId,
      version: 'V1-FROZEN-2026-09-15',
      siteEntityId: catalogSiteId!,
      researchTopicId: researchTopicId,
      stage: ResearchPackageStage.previewStagingIngest,
      publicationDecision: ResearchPublicationDecision.pending,
      relations: relations,
      evidenceStates: const <ResearchEvidenceIntegrityState>[
        ResearchEvidenceIntegrityState(
          sourceVerification: SourceVerificationState.pending,
          claimVerification: ResearchVerificationState.unresolved,
          mediaClearance: MediaClearanceState.notCleared,
        ),
      ],
    );
  }
}
