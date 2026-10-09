import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/map/domain/map_category_filter.dart';
import 'package:pal_eyes/features/places/data/draft_heritage_site_repository.dart';

void main() {
  final sites = const DraftHeritageSiteRepository().listSites();

  test('the "all" category is the identity filter', () {
    expect(mapCategories.first.apply(sites).length, sites.length);
  });

  test('every category filters by the governed site-type vocabulary', () {
    for (final category in mapCategories.skip(1)) {
      final filtered = category.apply(sites);
      expect(
        filtered.every((s) => category.typeKeywords.any(s.siteTypeAr.contains)),
        isTrue,
        reason: category.key,
      );
      expect(filtered.length, lessThan(sites.length), reason: category.key);
    }
  });

  test('categories are not decorative: each matches catalog sites', () {
    for (final category in mapCategories.skip(1)) {
      expect(category.apply(sites), isNotEmpty, reason: category.key);
    }
  });

  test('category keys are unique', () {
    final keys = mapCategories.map((c) => c.key).toSet();
    expect(keys.length, mapCategories.length);
  });
}
