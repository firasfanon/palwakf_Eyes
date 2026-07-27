import 'package:pal_eyes/features/places/data/dual_narrative_catalog.dart';
import 'package:pal_eyes/features/places/data/heritage_site_repository.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

class DraftHeritageSiteRepository implements HeritageSiteRepository {
  const DraftHeritageSiteRepository();

  @override
  List<HeritageSite> listSites() => dualNarrativeSiteCatalog;

  @override
  HeritageSite? findBySlug(String slug) {
    for (final HeritageSite site in dualNarrativeSiteCatalog) {
      if (site.slug == slug) {
        return site;
      }
    }
    return null;
  }
}
