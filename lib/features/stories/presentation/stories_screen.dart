import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/stories/data/editorial_story_catalog.dart';
import 'package:pal_eyes/features/stories/domain/editorial_story.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final stories = editorialStoryCatalog;
    return PalEyesPage(
      title: 'حكايات عن المكان',
      icon: Icons.auto_stories_outlined,
      eyebrow: 'الحكايات الفلسطينية',
      subtitle:
          'تجمع الحكايات بين المكان والذاكرة والمصادر الموثقة من دون تحويل الرواية إلى حقيقة غير مثبتة.',
      header: PalEyesPublicDisclosure(
        summary:
            'المحتوى التحريري هنا قيد المراجعة ولا يمثل نشرًا عامًا نهائيًا.',
        details: const <String>[
          'كل حكاية مرتبطة بمكان ومصدر.',
          'لا يتم عرض ادعاء غير موثق على أنه حقيقة.',
          'تُحفظ حدود المراجعة وحقوق الوسائط والمصادر.',
        ],
        actionLabel: 'منهجية التوثيق',
        onAction: () => context.go(RoutePaths.methodology),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _StoryFilters(
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1040
                  ? 3
                  : constraints.maxWidth >= 680
                  ? 2
                  : 1;
              const gap = 16.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: stories
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
          PalEyesParchmentPanel(
            color: PalEyesVisualV1.parchmentDeep.withValues(alpha: 0.45),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 18,
              runSpacing: 14,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'من قلب هذا المكان',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'اقرأ الحكاية من زاوية من عاش المكان أو حفظ ذاكرته.',
                        style: TextStyle(
                          color: PalEyesVisualV1.warmMuted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.places),
                      icon: const Icon(Icons.account_balance_outlined),
                      label: const Text('الأماكن'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.sources),
                      icon: const Icon(Icons.library_books_outlined),
                      label: const Text('المصادر'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryFilters extends StatelessWidget {
  const _StoryFilters({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = <String>['الكل', 'شهادات شفوية', 'قصص المكان', 'وثائق'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (var i = 0; i < labels.length; i++)
          ChoiceChip(
            label: Text(labels[i]),
            selected: selected == i,
            onSelected: (_) => onSelected(i),
            selectedColor: PalEyesVisualV1.olive,
            labelStyle: TextStyle(
              color: selected == i ? Colors.white : PalEyesVisualV1.warmInk,
              fontWeight: FontWeight.w800,
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
    return PalEyesParchmentPanel(
      onTap: () => context.go(RoutePaths.story(story.slug)),
      padding: const EdgeInsets.all(10),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PalEyesMediaPlaceholder(
            label: story.eyebrow,
            icon: _iconFor(story.visualKey),
            height: 210,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  story.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: PalEyesVisualV1.warmInk,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  story.summary,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PalEyesVisualV1.warmMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 17,
                      color: PalEyesVisualV1.olive,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${story.readingMinutes} دقيقة',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.place_outlined,
                      size: 17,
                      color: PalEyesVisualV1.olive,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${story.relatedPlaceNames.length} أماكن مرتبطة',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: PalEyesVisualV1.oliveDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String key) {
    return switch (key) {
      'water' => Icons.water_drop_outlined,
      'road' => Icons.route_outlined,
      _ => Icons.location_city_outlined,
    };
  }
}
