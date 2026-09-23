import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/research/application/staging_research_corpus_provider.dart';
import 'package:pal_eyes/features/research/domain/staging_research_package_manifest.dart';

class PublicResearchLibraryScreen extends ConsumerStatefulWidget {
  const PublicResearchLibraryScreen({super.key});

  @override
  ConsumerState<PublicResearchLibraryScreen> createState() =>
      _PublicResearchLibraryScreenState();
}

class _PublicResearchLibraryScreenState
    extends ConsumerState<PublicResearchLibraryScreen> {
  final TextEditingController _search = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packages = ref.watch(frozenStagingResearchCorpusProvider);
    final sites = ref.watch(foundationSitesProvider);
    final summary = ref.watch(stagingResearchCorpusSummaryProvider);
    final byId = <String, HeritageSite>{
      for (final site in sites) site.id: site,
    };

    final items = packages
        .where((package) => package.catalogSiteId != null)
        .map(
          (package) => _ResearchLibraryItem(
            package: package,
            site: byId[package.catalogSiteId!],
          ),
        )
        .where((item) => item.site != null)
        .where(_matchesFilter)
        .where(_matchesSearch)
        .toList(growable: false)
      ..sort(
        (a, b) => a.package.censusRecordId.compareTo(
          b.package.censusRecordId,
        ),
      );

    return PalEyesPage(
      title: 'مكتبة البحوث',
      subtitle:
          'بوابة واحدة لاكتشاف البحوث المرتبطة بالأماكن، مع إبقاء حالة المراجعة واليقين والمصدر ظاهرة بوضوح.',
      icon: Icons.menu_book_outlined,
      eyebrow: 'البحث • الدليل • المكان',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.discover),
          icon: const Icon(Icons.travel_explore_outlined),
          label: const Text('استكشف فلسطين'),
        ),
      ],
      header: packages.isEmpty
          ? const _EnvironmentNotice()
          : _LibraryStatusStrip(summary: summary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (packages.isNotEmpty) ...<Widget>[
            _MetricGrid(summary: summary),
            const SizedBox(height: 22),
            _ResearchSearchBar(
              controller: _search,
              filter: _filter,
              onChanged: () => setState(() {}),
              onFilterChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: <Widget>[
                Text(
                  '${items.length} سجلًا مطابقًا',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'المراجعة التخصصية والنشر مرحلتان منفصلتان',
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const _EmptyResearchState()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1120
                      ? 3
                      : constraints.maxWidth >= 720
                      ? 2
                      : 1;
                  const gap = 14.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: items
                        .map(
                          (item) => SizedBox(
                            width: width,
                            child: _ResearchCard(item: item),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  bool _matchesFilter(_ResearchLibraryItem item) {
    return switch (_filter) {
      'content' => item.package.exposesResearchNarrativeReference,
      'status' => item.package.packageClass ==
          StagingResearchPackageClass.statusOnlyNoNarrative,
      'linked' => item.package.isLinkedReference,
      'incomplete' => item.package.packageClass ==
          StagingResearchPackageClass.notPromotedResearchIncomplete,
      _ => true,
    };
  }

  bool _matchesSearch(_ResearchLibraryItem item) {
    final query = HeritageSite.normalizeArabicSearch(_search.text);
    if (query.isEmpty) return true;
    final site = item.site!;
    final haystack = HeritageSite.normalizeArabicSearch(
      <String>[
        site.nameAr,
        site.nameEn,
        site.localityAr,
        site.governorateAr,
        site.siteTypeAr,
        item.package.packageId,
        item.package.censusRecordId,
        item.package.previewStatusLabelAr,
      ].join(' '),
    );
    return haystack.contains(query);
  }
}

class _ResearchLibraryItem {
  const _ResearchLibraryItem({required this.package, required this.site});

  final StagingResearchPackageManifest package;
  final HeritageSite? site;
}

class _LibraryStatusStrip extends StatelessWidget {
  const _LibraryStatusStrip({required this.summary});

  final ResearchCorpusSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
          alpha: 0.42,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          const Icon(Icons.fact_check_outlined),
          const Text(
            'مكتبة مراجعة غير إنتاجية',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            '${summary.contentPackages} بحثًا بسرد كامل • '
            '${summary.statusOnly} حالة دليل غير كافٍ • '
            '${summary.linked} بحوث مرتبطة • '
            '${summary.incomplete} غير مكتملة',
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.summary});

  final ResearchCorpusSummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = <(IconData, String, String, String?)>[
      (
        Icons.menu_book_outlined,
        '${summary.contentPackages}',
        'بحثًا بسرد كامل',
        'متاحة للمعاينة والتدقيق فقط',
      ),
      (
        Icons.rule_folder_outlined,
        '${summary.statusOnly}',
        'حالة دليل غير كافٍ',
        'دون اختلاق سرد',
      ),
      (
        Icons.account_tree_outlined,
        '${summary.linked}',
        'بحوث مرتبطة',
        'الملكية البحثية محفوظة',
      ),
      (
        Icons.pending_actions_outlined,
        '${summary.incomplete}',
        'غير مكتملة',
        'تبقى صريحة للمستخدم',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980 ? 4 : 2;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: PalEyesMetricTile(
                    icon: metric.$1,
                    value: metric.$2,
                    label: metric.$3,
                    note: metric.$4,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ResearchSearchBar extends StatelessWidget {
  const _ResearchSearchBar({
    required this.controller,
    required this.filter,
    required this.onChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final String filter;
  final VoidCallback onChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    const filters = <(String, String)>[
      ('all', 'الكل'),
      ('content', 'بحوث كاملة'),
      ('status', 'دليل غير كافٍ'),
      ('linked', 'مرتبطة'),
      ('incomplete', 'قيد التحقق'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                labelText: 'ابحث باسم المكان أو المحافظة أو رقم الحزمة',
                hintText: 'مثال: سوق القطانين، الخليل، RCP-V1-005',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters
                    .map(
                      (item) => FilterChip(
                        selected: filter == item.$1,
                        label: Text(item.$2),
                        onSelected: (_) => onFilterChanged(item.$1),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResearchCard extends StatelessWidget {
  const _ResearchCard({required this.item});

  final _ResearchLibraryItem item;

  @override
  Widget build(BuildContext context) {
    final site = item.site!;
    final package = item.package;
    final full = package.exposesResearchNarrativeReference;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(RoutePaths.researchItem(site.slug)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: <Widget>[
                  Chip(
                    avatar: Icon(
                      full
                          ? Icons.menu_book_outlined
                          : Icons.pending_actions_outlined,
                      size: 17,
                    ),
                    label: Text(full ? 'بحث كامل' : 'حالة بحث'),
                  ),
                  Chip(label: Text(package.packageId)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                site.nameAr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${site.localityAr} • ${site.governorateAr} • ${site.siteTypeAr}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                package.previewStatusDescriptionAr,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.55),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      package.previewStatusLabelAr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_back_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvironmentNotice extends StatelessWidget {
  const _EnvironmentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.lock_outline_rounded),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'مكتبة البحوث مفصولة عن بيئة الإنتاج حاليًا. لا تُعرض المسودات البحثية إلا في بيئة المراجعة غير الإنتاجية.',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResearchState extends StatelessWidget {
  const _EmptyResearchState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: <Widget>[
            Icon(Icons.search_off_rounded, size: 54),
            SizedBox(height: 12),
            Text('لا توجد نتائج مطابقة للبحث الحالي.'),
          ],
        ),
      ),
    );
  }
}
