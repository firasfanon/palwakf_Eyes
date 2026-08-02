import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/direct_flutter_maturity_r9.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/stories/data/editorial_story_catalog.dart';
import 'package:pal_eyes/features/stories/domain/editorial_story.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = editorialStoryCatalog.first;
    final remaining = editorialStoryCatalog.skip(1).toList(growable: false);

    return PalEyesPage(
      title: 'مجلة المكان الفلسطيني',
      icon: Icons.auto_stories_outlined,
      eyebrow: 'قصص طويلة من الأطلس',
      subtitle:
          'اقرأ المكان بوصفه شبكة من الماء والمدينة والطريق والذاكرة، لا بوصفه بطاقة منفردة.',
      header: PalEyesPublicDisclosure(
        summary:
            'القصص تحريرية وتجريبية، وتربط المواقع بالمصادر دون تقديم البحث المفتوح كحقيقة نهائية.',
        details: const <String>[
          'كل قصة تشير إلى المواقع والمراجع التي تقودها.',
          'الاقتباسات والصور تخضع لمسار حقوق مستقل.',
          'يمكن تحديث الفصول مع وصول مصادر وشهادات جديدة.',
        ],
        actionLabel: 'استكشف منهجية القصص',
        onAction: () => context.go(RoutePaths.methodology),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PalEyesEditorialPrelude(
            eyebrow: 'العدد الأول • مجلة المكان',
            title: 'ثلاث قصص تقرأ فلسطين عبر الماء والطريق والمدينة',
            description:
                'المجلة لا تعيد سرد بطاقات المواقع؛ بل تبني مسارات طويلة '
                'تصل الجغرافيا بالمصدر والذاكرة المحلية.',
            icon: Icons.auto_stories_outlined,
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[AppColors.dusk, AppColors.sovereignBlue],
            ),
            metrics: const <PalEyesEditorialMetric>[
              PalEyesEditorialMetric(
                value: '3',
                label: 'قصص طويلة',
                icon: Icons.auto_stories_outlined,
              ),
              PalEyesEditorialMetric(
                value: '12',
                label: 'فصلاً',
                icon: Icons.menu_book_outlined,
              ),
              PalEyesEditorialMetric(
                value: '9',
                label: 'مواقع مرتبطة',
                icon: Icons.place_outlined,
              ),
              PalEyesEditorialMetric(
                value: 'قيد التدقيق',
                label: 'حالة التحرير',
                icon: Icons.fact_check_outlined,
              ),
            ],
            primaryLabel: 'تصفح الأطلس',
            onPrimary: () => context.go(RoutePaths.places),
            secondaryLabel: 'مكتبة المصادر',
            onSecondary: () => context.go(RoutePaths.sources),
          ),
          const SizedBox(height: 26),
          _FeaturedStory(story: featured),
          const SizedBox(height: 34),
          Text(
            'قصص أخرى',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 820 ? 2 : 1;
              const gap = 16.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: remaining
                    .map(
                      (story) => SizedBox(
                        width: width,
                        child: _StoryCard(story: story),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 34),
          PalEyesQuickPathBar(
            title: 'تابع الرحلة',
            actions: <PublicJourneyAction>[
              PublicJourneyAction(
                label: 'تصفح الأطلس',
                icon: Icons.account_balance_outlined,
                onPressed: () => context.go(RoutePaths.places),
              ),
              PublicJourneyAction(
                label: 'افتح الخريطة',
                icon: Icons.map_outlined,
                onPressed: () => context.go(RoutePaths.map),
              ),
              PublicJourneyAction(
                label: 'مكتبة المصادر',
                icon: Icons.library_books_outlined,
                onPressed: () => context.go(RoutePaths.sources),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedStory extends StatelessWidget {
  const _FeaturedStory({required this.story});

  final EditorialStory story;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(story.visualKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PalEyesMediaStage(
          title: story.title,
          subtitle: story.subtitle,
          semanticLabel: 'عمل بصري تجريدي لقصة ${story.title}',
          icon: visual.icon,
          height: 370,
          gradient: visual.gradient,
          footer: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              Chip(
                avatar: const Icon(Icons.schedule_rounded, size: 17),
                label: Text('${story.readingMinutes} دقائق'),
              ),
              Chip(
                avatar: const Icon(Icons.menu_book_rounded, size: 17),
                label: Text('${story.chapters.length} فصول'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          story.summary,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(height: 1.65),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.icon(
            onPressed: () => context.go(RoutePaths.story(story.slug)),
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('ابدأ القراءة'),
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final EditorialStory story;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(story.visualKey);
    return Semantics(
      button: true,
      label: 'اقرأ قصة ${story.title}',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.go(RoutePaths.story(story.slug)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: visual.gradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: <Widget>[
                      PositionedDirectional(
                        end: 20,
                        top: 18,
                        child: Icon(
                          visual.icon,
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      PositionedDirectional(
                        start: 16,
                        bottom: 14,
                        child: Chip(label: Text(story.eyebrow)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  story.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  story.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.55),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const Icon(Icons.schedule_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text('${story.readingMinutes} دقائق'),
                    const Spacer(),
                    const Text(
                      'اقرأ القصة',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_back_rounded),
                  ],
                ),
              ],
            ),
          ),
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
