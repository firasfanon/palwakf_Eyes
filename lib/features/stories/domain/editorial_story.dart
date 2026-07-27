class EditorialStoryChapter {
  const EditorialStoryChapter({
    required this.title,
    required this.body,
    this.pullQuote,
  });

  final String title;
  final String body;
  final String? pullQuote;
}

class EditorialStory {
  const EditorialStory({
    required this.slug,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.visualKey,
    required this.readingMinutes,
    required this.chapters,
    required this.relatedPlaceSlugs,
    required this.relatedPlaceNames,
    required this.sourceLabels,
  });

  final String slug;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String summary;
  final String visualKey;
  final int readingMinutes;
  final List<EditorialStoryChapter> chapters;
  final List<String> relatedPlaceSlugs;
  final List<String> relatedPlaceNames;
  final List<String> sourceLabels;
}
