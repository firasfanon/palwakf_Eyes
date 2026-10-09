import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/features/places/data/heritage_site_repository.dart';
import 'package:pal_eyes/features/places/domain/draft_content_profile.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

/// Where public site content comes from.
///
/// * `catalog`   — the governed draft catalog compiled into the app (current
///   baseline behaviour, unchanged).
/// * `published` — only rows of `pal_eyes.public_sites_v1`, i.e. records a
///   release manager explicitly published. Never falls back to the catalog.
enum PublicContentSource { catalog, published }

PublicContentSource publicContentSourceFrom(String raw) =>
    raw.trim().toLowerCase() == 'published'
    ? PublicContentSource.published
    : PublicContentSource.catalog;

enum PublishedContentStatus { notRequested, loaded, notConfigured, failed }

class PublishedContentLoad {
  const PublishedContentLoad(this.status, this.sites, {this.detail = ''});

  const PublishedContentLoad.notRequested()
    : status = PublishedContentStatus.notRequested,
      sites = const <HeritageSite>[],
      detail = '';

  final PublishedContentStatus status;
  final List<HeritageSite> sites;
  final String detail;
}

final publishedContentLoadProvider = Provider<PublishedContentLoad>(
  (ref) => const PublishedContentLoad.notRequested(),
);

class PublishedSiteRepository implements HeritageSiteRepository {
  const PublishedSiteRepository(this._sites);

  final List<HeritageSite> _sites;

  @override
  List<HeritageSite> listSites() => _sites;

  @override
  HeritageSite? findBySlug(String slug) {
    for (final site in _sites) {
      if (site.slug == slug) return site;
    }
    return null;
  }
}

/// Maps one `public_sites_v1` row. The view exposes no coordinates, original
/// drafts or internal workflow fields, so none are invented here: the map
/// stays fail-closed until a public coordinate view is approved.
HeritageSite publishedSiteFromRow(Map<String, Object?> row) {
  String text(String key) => (row[key] ?? '').toString();
  return HeritageSite(
    id: text('id'),
    slug: text('slug'),
    nameAr: text('name_ar'),
    nameEn: text('name_en'),
    localityAr: text('locality_ar'),
    governorateAr: text('governorate_ar'),
    siteTypeAr: text('site_type_ar'),
    latitude: null,
    longitude: null,
    summaryDraft: text('editorial_draft'),
    periods: const <String>[],
    status: ContentReviewStatus.published,
    documentationProgress: 100,
    preservationStatus: '',
    narrativeSections: const [],
    sources: const [],
    timeline: const [],
    mediaCount: 0,
    oralHistoryCount: 0,
    featured: false,
    contentProfile: DraftContentProfile.catalogSummary,
    sourceMentionCount: 0,
    identityStatus: 'PUBLISHED',
    publicationBlocked: false,
    databaseImportBlocked: false,
  );
}

typedef PublishedRowsFetcher = Future<List<Map<String, Object?>>> Function();

/// Loads published sites. `fetch == null` means no backend is configured.
Future<PublishedContentLoad> loadPublishedSites(
  PublishedRowsFetcher? fetch,
) async {
  if (fetch == null) {
    return const PublishedContentLoad(
      PublishedContentStatus.notConfigured,
      <HeritageSite>[],
      detail: 'PUBLISHED_SOURCE_REQUIRES_SUPABASE_CONFIGURATION',
    );
  }
  try {
    final rows = await fetch();
    final sites = rows
        .map(publishedSiteFromRow)
        .where((site) => site.slug.isNotEmpty)
        .toList(growable: false);
    return PublishedContentLoad(PublishedContentStatus.loaded, sites);
  } on Object catch (error) {
    return PublishedContentLoad(
      PublishedContentStatus.failed,
      const <HeritageSite>[],
      detail: error.runtimeType.toString(),
    );
  }
}
