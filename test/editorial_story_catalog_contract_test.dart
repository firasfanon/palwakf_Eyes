import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/dual_narrative_catalog.dart';
import 'package:pal_eyes/features/stories/data/editorial_story_catalog.dart';

void main() {
  test('editorial magazine exposes three traceable long-form stories', () {
    expect(editorialStoryCatalog, hasLength(3));
    expect(
      editorialStoryCatalog.every(
        (story) =>
            story.chapters.length >= 4 &&
            story.relatedPlaceSlugs.length == story.relatedPlaceNames.length &&
            story.sourceLabels.isNotEmpty &&
            story.readingMinutes >= 8,
      ),
      isTrue,
    );
  });


  test('every related story place resolves in the current atlas', () {
    final atlasSlugs = dualNarrativeSiteCatalog
        .map((site) => site.slug)
        .toSet();

    for (final story in editorialStoryCatalog) {
      expect(
        story.relatedPlaceSlugs.every(atlasSlugs.contains),
        isTrue,
        reason: story.slug,
      );
    }
  });

  test('story lookup is stable and fail-closed', () {
    expect(
      editorialStoryBySlug('water-memory-south-jerusalem')?.chapters,
      hasLength(4),
    );
    expect(editorialStoryBySlug('missing-story'), isNull);
  });
}
