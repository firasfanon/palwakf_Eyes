import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/features/places/domain/draft_content_profile.dart';
import 'package:pal_eyes/features/places/domain/historical_content.dart';
import 'package:pal_eyes/features/places/domain/original_historical_draft_layer.dart';

enum GovernedPageCategory {
  governedDraft,
  limitedResearch,
}

extension GovernedPageCategoryX on GovernedPageCategory {
  String get labelAr => switch (this) {
        GovernedPageCategory.governedDraft => 'صفحة مسودة محكومة',
        GovernedPageCategory.limitedResearch => 'صفحة بحث محدودة',
      };

  String get descriptionAr => switch (this) {
        GovernedPageCategory.governedDraft =>
          'تضم رواية عربية مراجعة تاريخياً ومتصلة بمصادر قابلة للتعقب.',
        GovernedPageCategory.limitedResearch =>
          'تعرض الهوية وفجوات التوثيق فقط، دون رواية تاريخية غير متحققة.',
      };
}

class HeritageSite {
  const HeritageSite({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    required this.localityAr,
    required this.governorateAr,
    required this.siteTypeAr,
    required this.latitude,
    required this.longitude,
    required this.summaryDraft,
    required this.periods,
    required this.status,
    required this.documentationProgress,
    required this.preservationStatus,
    required this.narrativeSections,
    required this.sources,
    required this.timeline,
    required this.mediaCount,
    required this.oralHistoryCount,
    required this.featured,
    required this.contentProfile,
    required this.sourceMentionCount,
    this.pageCategory = GovernedPageCategory.limitedResearch,
    this.identityStatus = 'UNREVIEWED',
    this.specialHold,
    this.heldClaimCount = 0,
    this.p0ClaimCount = 0,
    this.p0Findings = const <String>[],
    this.parentSiteIds = const <String>[],
    this.constituentSiteIds = const <String>[],
    this.coordinateStatusAr = 'تحتاج تحققاً جغرافياً',
    this.mapDisplayApproved = false,
    this.approvedMediaCount = 0,
    this.mediaStatus = 'NO_APPROVED_MEDIA_ASSET',
    this.publicationBlocked = true,
    this.databaseImportBlocked = true,
    this.originalHistoricalDraft,
  });

  final String id;
  final String slug;
  final String nameAr;
  final String nameEn;
  final String localityAr;
  final String governorateAr;
  final String siteTypeAr;
  final double? latitude;
  final double? longitude;
  final String summaryDraft;
  final List<String> periods;
  final ContentReviewStatus status;
  final int documentationProgress;
  final String preservationStatus;
  final List<HistoricalNarrativeSection> narrativeSections;
  final List<HistoricalSourceReference> sources;
  final List<HistoricalTimelineEntry> timeline;
  final int mediaCount;
  final int oralHistoryCount;
  final bool featured;
  final DraftContentProfile contentProfile;
  final int sourceMentionCount;
  final GovernedPageCategory pageCategory;
  final String identityStatus;
  final String? specialHold;
  final int heldClaimCount;
  final int p0ClaimCount;
  final List<String> p0Findings;
  final List<String> parentSiteIds;
  final List<String> constituentSiteIds;
  final String coordinateStatusAr;
  final bool mapDisplayApproved;
  final int approvedMediaCount;
  final String mediaStatus;
  final bool publicationBlocked;
  final bool databaseImportBlocked;
  final OriginalHistoricalDraftLayer? originalHistoricalDraft;

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasPublicCoordinates => mapDisplayApproved && hasCoordinates;
  bool get hasReviewCoordinates => hasCoordinates;
  bool get hasExpandedNarrative =>
      contentProfile == DraftContentProfile.expandedNarrative;
  bool get isGovernedDraft =>
      pageCategory == GovernedPageCategory.governedDraft;
  bool get isLimitedResearch =>
      pageCategory == GovernedPageCategory.limitedResearch;
  bool get hasOriginalHistoricalDraft =>
      originalHistoricalDraft != null;
  bool get hasOriginalExpandedNarrative =>
      originalHistoricalDraft?.hasExpandedNarrative ?? false;

  HeritageSite withOriginalHistoricalDraft(
    OriginalHistoricalDraftLayer layer,
  ) {
    return HeritageSite(
      id: id,
      slug: slug,
      nameAr: nameAr,
      nameEn: nameEn,
      localityAr: localityAr,
      governorateAr: governorateAr,
      siteTypeAr: siteTypeAr,
      latitude: latitude,
      longitude: longitude,
      summaryDraft: summaryDraft,
      periods: periods,
      status: status,
      documentationProgress: documentationProgress,
      preservationStatus: preservationStatus,
      narrativeSections: narrativeSections,
      sources: sources,
      timeline: timeline,
      mediaCount: mediaCount,
      oralHistoryCount: oralHistoryCount,
      featured: featured,
      contentProfile: contentProfile,
      sourceMentionCount: sourceMentionCount,
      pageCategory: pageCategory,
      identityStatus: identityStatus,
      specialHold: specialHold,
      heldClaimCount: heldClaimCount,
      p0ClaimCount: p0ClaimCount,
      p0Findings: p0Findings,
      parentSiteIds: parentSiteIds,
      constituentSiteIds: constituentSiteIds,
      coordinateStatusAr: coordinateStatusAr,
      mapDisplayApproved: mapDisplayApproved,
      approvedMediaCount: approvedMediaCount,
      mediaStatus: mediaStatus,
      publicationBlocked: publicationBlocked,
      databaseImportBlocked: databaseImportBlocked,
      originalHistoricalDraft: layer,
    );
  }

  int get claimCount => narrativeSections.fold(
        0,
        (total, section) => total + section.claimCount,
      );

  int get citedClaimCount => narrativeSections.fold(
        0,
        (total, section) => total + section.citedClaimCount,
      );

  bool matches(String query) {
    final normalized = normalizeArabicSearch(query);
    if (normalized.isEmpty) {
      return true;
    }

    final haystack = normalizeArabicSearch(
      <String>[
        nameAr,
        nameEn,
        localityAr,
        governorateAr,
        siteTypeAr,
        summaryDraft,
        pageCategory.labelAr,
        identityStatus,
        ...periods,
        ...narrativeSections.map((section) => section.title),
        ...narrativeSections.map((section) => section.draftText),
        ...sources.map((source) => source.title),
      ].join(' '),
    );
    return haystack.contains(normalized);
  }

  static String normalizeArabicSearch(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp('[إأآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
