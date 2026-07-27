import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/draft_content_banner.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/features/governorates/domain/governorate_coverage.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';

class GovernoratesScreen extends ConsumerWidget {
  const GovernoratesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverage = ref.watch(governorateCoverageProvider);

    return PalEyesPage(
      title: 'تغطية المحافظات الفلسطينية',
      icon: Icons.location_city_outlined,
      eyebrow: 'فلسطين جغرافياً',
      subtitle:
          'عرض كامل لـ16 محافظة كما وردت في نطاق المسودة، بما في ذلك المحافظات التي لم تُستخرج لها صفوف مواقع بعد.',
      header: const DraftContentBanner(
        title: 'التغطية الجغرافية مسودة وليست تعداداً نهائياً',
        message:
            'الأرقام أدناه ناتجة عن استخراج المسودة المرجعية. الصفر يعني فجوة توثيق ظاهرة، ولا يعني عدم وجود مواقع تاريخية في المحافظة.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CoverageSummary(coverage: coverage),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 3
                  : constraints.maxWidth >= 660
                  ? 2
                  : 1;
              const gap = 16.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: coverage
                    .map(
                      (item) => SizedBox(
                        width: width,
                        child: _GovernorateCard(item: item),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CoverageSummary extends StatelessWidget {
  const _CoverageSummary({required this.coverage});

  final List<GovernorateCoverage> coverage;

  @override
  Widget build(BuildContext context) {
    final siteCount = coverage.fold<int>(
      0,
      (total, item) => total + item.siteCount,
    );
    final expanded = coverage.fold<int>(
      0,
      (total, item) => total + item.expandedNarrativeCount,
    );
    final mapped = coverage.fold<int>(
      0,
      (total, item) => total + item.mappedSiteCount,
    );
    final gaps = coverage.where((item) => !item.hasExtractedSites).length;

    final metrics = <(String, String, IconData)>[
      ('المحافظات', '${coverage.length}', Icons.location_city_outlined),
      ('المواقع', '$siteCount', Icons.account_balance_outlined),
      ('الروايات الموسعة', '$expanded', Icons.auto_stories_outlined),
      ('إحداثيات متاحة', '$mapped', Icons.map_outlined),
      ('فجوات ظاهرة', '$gaps', Icons.warning_amber_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1000
            ? (constraints.maxWidth - 48) / 5
            : constraints.maxWidth >= 600
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(child: Icon(metric.$3)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(metric.$1),
                                Text(
                                  metric.$2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _GovernorateCard extends StatelessWidget {
  const _GovernorateCard({required this.item});

  final GovernorateCoverage item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: item.hasExtractedSites ? null : scheme.errorContainer,
      child: InkWell(
        onTap: item.hasExtractedSites
            ? () => context.go(RoutePaths.discover)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: item.hasExtractedSites
                        ? scheme.primaryContainer
                        : scheme.error,
                    foregroundColor: item.hasExtractedSites
                        ? scheme.onPrimaryContainer
                        : scheme.onError,
                    child: Icon(
                      item.hasExtractedSites
                          ? Icons.location_city_rounded
                          : Icons.report_problem_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.nameAr,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.localities.isEmpty
                    ? 'لم تُستخرج بلدات من المسودة.'
                    : item.localities.join(' • '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              if (!item.hasExtractedSites)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.info_outline_rounded, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'فجوة استخراج معلنة: لم تتضمن المصفوفة صفوف مواقع قابلة للتحويل لهذه المحافظة.',
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: <Widget>[
                    Chip(label: Text('${item.siteCount} مواقع')),
                    Chip(
                      label: Text(
                        '${item.expandedNarrativeCount} روايات موسعة',
                      ),
                    ),
                    Chip(label: Text('${item.mappedSiteCount} بإحداثيات')),
                    Chip(label: Text('${item.sourceMentionCount} ذكر مصدر')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
