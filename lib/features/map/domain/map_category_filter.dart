import 'package:flutter/material.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

/// A real atlas filter: each category matches the governed `siteTypeAr`
/// vocabulary of the catalog. A site whose compound type spans several
/// categories (e.g. "كنيسة/مغارة") appears in each of them.
class MapCategory {
  const MapCategory({
    required this.key,
    required this.labelAr,
    required this.icon,
    required this.typeKeywords,
  });

  final String key;
  final String labelAr;
  final IconData icon;

  /// Empty means "all sites".
  final List<String> typeKeywords;

  bool matches(HeritageSite site) {
    if (typeKeywords.isEmpty) {
      return true;
    }
    final type = site.siteTypeAr;
    return typeKeywords.any(type.contains);
  }

  List<HeritageSite> apply(List<HeritageSite> sites) =>
      sites.where(matches).toList(growable: false);
}

const List<MapCategory> mapCategories = <MapCategory>[
  MapCategory(
    key: 'all',
    labelAr: 'الكل',
    icon: Icons.location_on_outlined,
    typeKeywords: <String>[],
  ),
  MapCategory(
    key: 'towns',
    labelAr: 'مدن وبلدات',
    icon: Icons.location_city_outlined,
    typeKeywords: <String>['بلدة', 'مدينة', 'حارة', 'عنقود', 'سوق'],
  ),
  MapCategory(
    key: 'antiquities',
    labelAr: 'آثار',
    icon: Icons.account_balance_outlined,
    typeKeywords: <String>[
      'تل',
      'خربة',
      'قلعة',
      'حصن',
      'قصر',
      'برج',
      'جدار',
      'مغارة',
    ],
  ),
  MapCategory(
    key: 'shrines',
    labelAr: 'مقامات ومساجد',
    icon: Icons.mosque_outlined,
    typeKeywords: <String>['مقام', 'مسجد', 'حرم', 'موقع مقدس'],
  ),
  MapCategory(
    key: 'churches',
    labelAr: 'كنائس وأديرة',
    icon: Icons.church_outlined,
    typeKeywords: <String>['كنيسة', 'دير'],
  ),
  MapCategory(
    key: 'water',
    labelAr: 'مياه',
    icon: Icons.water_drop_outlined,
    typeKeywords: <String>[
      'نبع',
      'عين',
      'قناة',
      'بركة',
      'خزان',
      'حمام',
      'ميناء',
    ],
  ),
  MapCategory(
    key: 'routes',
    labelAr: 'خانات وطرق',
    icon: Icons.route_outlined,
    typeKeywords: <String>['خان', 'طريق', 'جسر'],
  ),
];
