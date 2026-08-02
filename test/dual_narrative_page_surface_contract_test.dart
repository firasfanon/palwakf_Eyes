import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detail page exposes two explicitly separated narrative surfaces', () {
    final source = File(
      'lib/features/places/presentation/place_detail_screen.dart',
    ).readAsStringSync();

    expect(source.contains("'الحكاية المحررة'"), isTrue);
    expect(source.contains("'المادة التاريخية الأصلية'"), isTrue);
    expect(source.contains('_OriginalHistoricalDraftSection'), isTrue);
    expect(source.contains('بيئة التطوير فقط'), isTrue);
    expect(source.contains('النشر العام: محجوب'), isTrue);
  });

  test('original draft rendering is protected by the debug visibility policy', () {
    final policy = File(
      'lib/features/places/application/original_draft_visibility_policy.dart',
    ).readAsStringSync();
    final detail = File(
      'lib/features/places/presentation/place_detail_screen.dart',
    ).readAsStringSync();

    expect(policy.contains('kDebugMode'), isTrue);
    expect(policy.contains('publicReleaseApproved = false'), isTrue);
    expect(
      detail.contains(
        'OriginalDraftVisibilityPolicy.canRenderOriginalDraft',
      ),
      isTrue,
    );
  });

  test('repository reads the dual narrative catalog', () {
    final source = File(
      'lib/features/places/data/draft_heritage_site_repository.dart',
    ).readAsStringSync();

    expect(source.contains('dualNarrativeSiteCatalog'), isTrue);
    expect(source.contains('governedSiteCatalog'), isFalse);
  });
}
