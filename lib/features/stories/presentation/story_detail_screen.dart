import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/stories/data/editorial_story_catalog.dart';
import 'package:pal_eyes/features/stories/domain/editorial_story.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final story = editorialStoryBySlug(slug);
    if (story == null) {
      return PalEyesPage(
        title: 'القصة غير موجودة',
        subtitle: 'لم نعثر على قصة بهذا المعرّف.',
        child: PalEyesPublicStatePanel(
          kind: PublicContentStateKind.empty,
          title: 'هذه القصة غير متاحة',
          message: 'يمكنك العودة إلى مجلة المكان واختيار قصة أخرى.',
          actionLabel: 'العودة إلى القصص',
          onAction: () => context.go(RoutePaths.stories),
        ),
      );
    }

    final visual = _visualFor(story.visualKey);
    return PalEyesPage(
      title: story.title,
      eyebrow: story.eyebrow,
      subtitle: story.subtitle,
      icon: Icons.auto_stories_outlined,
      maxWidth: 980,
      header: PalEyesPublicDisclosure(
        summary:
            'هذه قصة تحريرية قيد التطوير، مبنية على مواقع ومراجع قابلة للتعقب.',
        details: const <String>[
          'لا تُستخدم الصور الخارجية قبل التحقق من الحقوق.',
          'تُراجع الأسماء والتواريخ والاقتباسات قبل الاعتماد.',
        ],
        actionLabel: 'تعرف إلى منهجية التحرير',
        onAction: () => context.go(RoutePaths.methodology),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PalEyesMediaStage(
            title: story.title,
            subtitle: story.summary,
            semanticLabel: 'عمل بصري تجريدي لقصة ${story.title}',
            icon: visual.icon,
            height: 360,
            gradient: visual.gradient,
          ),
          const SizedBox(height: 16),
          PalEyesReadingProgress(
            readingMinutes: story.readingMinutes,
            chapterCount: story.chapters.length,
          ),
          const SizedBox(height: 26),
          Text(
            'فصول القصة',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...story.chapters.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _ChapterCard(index: entry.$1 + 1, chapter: entry.$2),
            ),
          ),
          const SizedBox(height: 12),
          _RelatedPlaces(story: story),
          const SizedBox(height: 18),
          _StorySources(story: story),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.index, required this.chapter});

  final int index;
  final EditorialStoryChapter chapter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'الفصل $index. ${chapter.title}',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'الفصل $index',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                chapter.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              SelectableText(
                chapter.body,
                style: const TextStyle(height: 1.9, fontSize: 17),
              ),
              if (chapter.pullQuote != null) ...<Widget>[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                    border: BorderDirectional(
                      start: BorderSide(
                        width: 4,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  child: Text(
                    chapter.pullQuote!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.65,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedPlaces extends StatelessWidget {
  const _RelatedPlaces({required this.story});

  final EditorialStory story;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'المواقع التي تقود هذه القصة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: List<Widget>.generate(
                story.relatedPlaceSlugs.length,
                (index) => ActionChip(
                  avatar: const Icon(Icons.place_outlined, size: 18),
                  label: Text(story.relatedPlaceNames[index]),
                  onPressed: () => context.go(
                    RoutePaths.place(story.relatedPlaceSlugs[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorySources extends StatelessWidget {
  const _StorySources({required this.story});

  final EditorialStory story;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ما الذي يقود البحث؟',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'هذه ليست قائمة استشهاد نهائية؛ بل فئات المصادر التي تُراجع لبناء القصة.',
            ),
            const SizedBox(height: 12),
            ...story.sourceLabels.map(
              (source) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.library_books_outlined),
                title: Text(source),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => context.go(RoutePaths.sources),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('افتح مكتبة المصادر'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_StoryVisual _visualFor(String key) {
  return switch (key) {
    'water' => const _StoryVisual(
      icon: Icons.water_drop_outlined,
      gradient: LinearGradient(
        colors: <Color>[AppColors.sea, AppColors.deepBlue],
      ),
    ),
    'road' => const _StoryVisual(
      icon: Icons.route_outlined,
      gradient: LinearGradient(
        colors: <Color>[Color(0xFF8A6847), Color(0xFF4D3C2E)],
      ),
    ),
    _ => const _StoryVisual(
      icon: Icons.location_city_outlined,
      gradient: LinearGradient(
        colors: <Color>[AppColors.dusk, AppColors.sovereignBlue],
      ),
    ),
  };
}

class _StoryVisual {
  const _StoryVisual({required this.icon, required this.gradient});

  final IconData icon;
  final Gradient gradient;
}
