import 'package:pal_eyes/core/content/content_review_status.dart';

class HistoricalNarrativeSection {
  const HistoricalNarrativeSection({
    required this.id,
    required this.title,
    required this.draftText,
    required this.status,
    required this.evidenceNote,
    required this.claimCount,
    required this.citedClaimCount,
    this.claimId,
    this.sourceIds = const <String>[],
    this.historicalReviewStatus = 'PENDING',
    this.rightsStatus = 'PENDING',
  });

  final String id;
  final String title;
  final String draftText;
  final ContentReviewStatus status;
  final String evidenceNote;
  final int claimCount;
  final int citedClaimCount;
  final String? claimId;
  final List<String> sourceIds;
  final String historicalReviewStatus;
  final String rightsStatus;
}

class HistoricalSourceReference {
  const HistoricalSourceReference({
    required this.id,
    required this.title,
    required this.attribution,
    required this.note,
    required this.status,
    this.url = '',
    this.sourceClass = '',
    this.adoptionRole = '',
    this.textReuseStatus = '',
    this.imageReuseStatus = '',
    this.mapReuseStatus = '',
    this.publicReleaseStatus = 'BLOCKED',
    this.evidenceScopeStatus = '',
    this.citationLocatorSummary = '',
  });

  final String id;
  final String title;
  final String attribution;
  final String note;
  final ContentReviewStatus status;
  final String url;
  final String sourceClass;
  final String adoptionRole;
  final String textReuseStatus;
  final String imageReuseStatus;
  final String mapReuseStatus;
  final String publicReleaseStatus;
  final String evidenceScopeStatus;
  final String citationLocatorSummary;
}

class HistoricalTimelineEntry {
  const HistoricalTimelineEntry({
    required this.period,
    required this.title,
    required this.draftText,
    required this.status,
  });

  final String period;
  final String title;
  final String draftText;
  final ContentReviewStatus status;
}
