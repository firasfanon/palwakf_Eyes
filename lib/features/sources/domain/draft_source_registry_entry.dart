import 'package:pal_eyes/core/content/content_review_status.dart';

class DraftSourceRegistryEntry {
  const DraftSourceRegistryEntry({
    required this.id,
    required this.title,
    required this.attribution,
    required this.sourceTypeAr,
    required this.note,
    required this.status,
    required this.siteSlugs,
    required this.registryTier,
    this.url = '',
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
  final String sourceTypeAr;
  final String note;
  final ContentReviewStatus status;
  final List<String> siteSlugs;
  final String registryTier;
  final String url;
  final String adoptionRole;
  final String textReuseStatus;
  final String imageReuseStatus;
  final String mapReuseStatus;
  final String publicReleaseStatus;
  final String evidenceScopeStatus;
  final String citationLocatorSummary;

  int get mentionedSiteCount => siteSlugs.length;
  bool get isEditorialSource => adoptionRole == 'PAGE_EDITORIAL_SOURCE';
}
