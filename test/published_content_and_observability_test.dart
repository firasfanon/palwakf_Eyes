import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/core/observability/error_reporting.dart';
import 'package:pal_eyes/features/places/data/published_content_source.dart';

void main() {
  group('published content source', () {
    test('defaults to the governed catalog unless explicitly published', () {
      expect(publicContentSourceFrom(''), PublicContentSource.catalog);
      expect(publicContentSourceFrom('catalog'), PublicContentSource.catalog);
      expect(
        publicContentSourceFrom('PUBLISHED'),
        PublicContentSource.published,
      );
    });

    test(
      'no backend means empty and notConfigured, never the catalog',
      () async {
        final load = await loadPublishedSites(null);
        expect(load.status, PublishedContentStatus.notConfigured);
        expect(load.sites, isEmpty);
      },
    );

    test('backend failure is fail-closed', () async {
      final load = await loadPublishedSites(
        () async => throw StateError('network down'),
      );
      expect(load.status, PublishedContentStatus.failed);
      expect(load.sites, isEmpty);
    });

    test(
      'maps public view rows without inventing coordinates or drafts',
      () async {
        final load = await loadPublishedSites(
          () async => <Map<String, Object?>>[
            <String, Object?>{
              'id': 'site-1',
              'slug': 'synthetic-published',
              'name_ar': 'موقع منشور اصطناعي',
              'name_en': 'Synthetic',
              'governorate_ar': 'القدس',
              'locality_ar': 'القدس القديمة',
              'site_type_ar': 'مسجد',
              'editorial_draft': 'نص معتمد للنشر',
              'coordinate_status': 'PUBLIC_APPROVED',
            },
            <String, Object?>{'id': 'broken', 'slug': ''},
          ],
        );
        expect(load.status, PublishedContentStatus.loaded);
        expect(load.sites, hasLength(1));
        final site = load.sites.single;
        expect(site.status, ContentReviewStatus.published);
        expect(site.publicationBlocked, isFalse);
        expect(site.latitude, isNull);
        expect(site.longitude, isNull);
        expect(site.originalHistoricalDraft, isNull);
        expect(
          PublishedSiteRepository(load.sites).findBySlug('synthetic-published'),
          isNotNull,
        );
      },
    );
  });

  group('error reporting seam', () {
    tearDown(ErrorReporting.reset);

    test('captures framework errors into a bounded buffer', () {
      for (var i = 0; i < ErrorReporting.capacity + 5; i++) {
        ErrorReporting.capture(StateError('e$i'), null, 'test');
      }
      expect(ErrorReporting.recent, hasLength(ErrorReporting.capacity));
      expect(
        ErrorReporting.recent.last.message,
        contains('e${ErrorReporting.capacity + 4}'),
      );
    });

    test('no third-party vendor is wired before decision D6', () {
      const config = ErrorReporterConfig.fromCompileTime();
      expect(config.mode, 'buffer');
      expect(kReleaseMode, isFalse);
    });
  });
}
