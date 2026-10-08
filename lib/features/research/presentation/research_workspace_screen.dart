import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/draft_content_banner.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/research/domain/governed_research_backlog_item.dart';
import 'package:pal_eyes/features/research/presentation/research_package_workbench.dart';

class ResearchWorkspaceScreen extends ConsumerStatefulWidget {
  const ResearchWorkspaceScreen({super.key});
  @override
  ConsumerState<ResearchWorkspaceScreen> createState() =>
      _ResearchWorkspaceScreenState();
}

class _ResearchWorkspaceScreenState
    extends ConsumerState<ResearchWorkspaceScreen> {
  static const int _pageSize = 30;
  final TextEditingController _controller = TextEditingController();
  String _tier = 'الكل';
  int _visible = _pageSize;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backlog = ref.watch(governedResearchBacklogProvider);
    final query = _controller.text.trim().toLowerCase();
    final filtered = backlog
        .where((item) {
          final haystack = <String>[
            item.claimId,
            item.siteNameAr,
            item.governorateAr,
            item.claimText,
            ...item.categories,
          ].join(' ').toLowerCase();
          return (query.isEmpty || haystack.contains(query)) &&
              (_tier == 'الكل' || item.priorityTier == _tier);
        })
        .toList(growable: false);
    final visible = filtered.take(_visible).toList(growable: false);

    return PalEyesPage(
      title: 'مساحة الباحث',
      icon: Icons.science_outlined,
      subtitle:
          'مختبر داخلي لإدارة البحث والادعاءات وحزم المعرفة. منفصل عن مكتبة القراءة العامة وعن سلطة الحوكمة.',
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: () => context.go(RoutePaths.research),
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('مكتبة البحوث العامة'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.go(RoutePaths.admin),
          icon: const Icon(Icons.shield_outlined),
          label: const Text('الحوكمة'),
        ),
      ],
      header: const DraftContentBanner(
        title: '211 ادعاءً في Research Backlog',
        message:
            'أُغلقت مرحلة التحقق الأولى عند حد اعتماد الصفحات. يستمر البحث الميداني والقانوني وGIS والحقوق كمسارات إثراء متوازية.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _Metrics(),
          const SizedBox(height: 18),
          const ResearchPackageWorkbench(),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {
                      _visible = _pageSize;
                    }),
                    decoration: const InputDecoration(
                      labelText: 'البحث في الادعاءات المفتوحة',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _tier,
                    decoration: const InputDecoration(labelText: 'الأولوية'),
                    items:
                        const <String>[
                              'الكل',
                              'P0_IMMEDIATE',
                              'P1_HIGH',
                              'P2_MEDIUM',
                              'P3_LONG_TAIL',
                            ]
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _tier = value;
                          _visible = _pageSize;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text('${filtered.length} نتيجة')),
              Chip(label: Text('${visible.length} ظاهرة')),
              const Chip(label: Text('القبول التلقائي: محظور')),
              const Chip(label: Text('النشر: محظور')),
            ],
          ),
          const SizedBox(height: 14),
          ...visible.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BacklogCard(item: item),
            ),
          ),
          if (visible.length < filtered.length)
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () => setState(() {
                  _visible += _pageSize;
                }),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(
                  'إظهار المزيد (${filtered.length - visible.length})',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics();
  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String, String)>[
      (
        Icons.menu_book_outlined,
        '${ContentCatalogMetrics.reviewedEditorialRecordCount}',
        'مواد معتمدة للتطوير',
      ),
      (
        Icons.pending_actions_outlined,
        '${ContentCatalogMetrics.heldClaimBacklogCount}',
        'ادعاءات بحث مفتوحة',
      ),
      (
        Icons.priority_high_rounded,
        '${ContentCatalogMetrics.p0ExecutedClaimCount}',
        'ادعاءات P0 منفذة',
      ),
      (
        Icons.perm_media_outlined,
        '${ContentCatalogMetrics.approvedMediaAssetCount}',
        'وسائط معتمدة',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 600 ? constraints.maxWidth : 270.0;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(child: Icon(item.$1)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.$2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                Text(item.$3),
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

class _BacklogCard extends StatelessWidget {
  const _BacklogCard({required this.item});
  final GovernedResearchBacklogItem item;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text(item.priorityTier)),
                Chip(label: Text('الدرجة ${item.priorityScore}')),
                Chip(label: Text(item.governorateAr)),
                if (item.requiresFieldEvidence)
                  const Chip(label: Text('يحتاج دليلاً ميدانياً/جغرافياً')),
                if (item.requiresLiveWebRefresh)
                  const Chip(label: Text('يحتاج تحديثاً حياً')),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.siteNameAr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(item.claimText, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 10),
            Text(
              'الحالة: ${item.researchStatus} • ${item.claimId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
