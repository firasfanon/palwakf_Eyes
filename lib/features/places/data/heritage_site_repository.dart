import 'package:pal_eyes/features/places/domain/heritage_site.dart';

abstract interface class HeritageSiteRepository {
  List<HeritageSite> listSites();

  HeritageSite? findBySlug(String slug);
}
