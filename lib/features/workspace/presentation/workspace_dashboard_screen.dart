import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/approved_reference_design.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/research/data/staging_research_corpus_v1.dart';

class WorkspaceDashboardScreen extends ConsumerWidget {
  const WorkspaceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sites = ref.watch(foundationSitesProvider);
    final mapped = ref.watch(mappedSitesProvider);
    final expanded = ref.watch(expandedNarrativeSitesProvider);
    final sources = ref.watch(draftSourceRegistryProvider);
    final coordinateGaps = sites.length - mapped.length;
    final stagingReferences =
        researchCorpusCompletedCount +
        researchCorpusInsufficientCount +
        researchCorpusLinkedCount;

    return Material(
      color: ApprovedReferenceDesign.pageBackground(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 72),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _ConsoleHeader(
                  onPublic: () => context.go(RoutePaths.home),
                  onReviews: () => context.go(RoutePaths.workspaceReviews),
                ),
                const SizedBox(height: 22),
                _MetricGrid(
                  items: <_Metric>[
                    _Metric(
                      'البحث المحكوم',
                      '$researchCorpusTotalCount',
                      'إجمالي عناصر corpus',
                    ),
                    _Metric(
                      'مكتمل بحثياً',
                      '$researchCorpusCompletedCount',
                      'REVIEW_DEFERRED',
                    ),
                    _Metric(
                      'دليل غير كافٍ',
                      '$researchCorpusInsufficientCount',
                      'Status-only',
                    ),
                    _Metric(
                      'بحوث مرتبطة',
                      '$researchCorpusLinkedCount',
                      'بدون تكرار Owner',
                    ),
                    _Metric(
                      'غير مكتمل',
                      '$researchCorpusIncompleteCount',
                      '001–003',
                    ),
                    _Metric(
                      'الكتالوج',
                      '${sites.length}',
                      '${expanded.length} روايات موسعة',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _SectionTitle(
                  eyebrow: 'سير العمل',
                  title: 'من البحث إلى قرار النشر — بلا قفز بين المراحل',
                  subtitle:
                      'كل مرحلة لها مخرج واضح. اكتمال البحث لا يعني اعتماد المحتوى، واعتماد الادعاء لا يعني اعتماد الوسائط.',
                ),
                const SizedBox(height: 16),
                _WorkflowBoard(
                  mappedCount: mapped.length,
                  stagingReferences: stagingReferences,
                  onReview: () => context.go(RoutePaths.workspaceReviews),
                  onRelease: () =>
                      context.go(RoutePaths.workspaceReleaseControl),
                ),
                const SizedBox(height: 30),
                _SectionTitle(
                  eyebrow: 'مركز الإدارة',
                  title: 'الوصول إلى كل طبقة تشغيلية من مكان واحد',
                  subtitle:
                      'المواقع والمصادر والادعاءات والحقوق والجغرافيا والعلاقات والمراجعات والإصدار.',
                ),
                const SizedBox(height: 16),
                _ModuleGrid(
                  modules: <_Module>[
                    _Module(
                      'المواقع',
                      Icons.place_outlined,
                      RoutePaths.workspacePlaces,
                      '${sites.length} كيان',
                    ),
                    _Module(
                      'الادعاءات',
                      Icons.fact_check_outlined,
                      RoutePaths.workspaceClaims,
                      '${expanded.length} رواية موسعة',
                    ),
                    _Module(
                      'المصادر',
                      Icons.library_books_outlined,
                      RoutePaths.workspaceSources,
                      '${sources.length} سجل',
                    ),
                    const _Module(
                      'حقوق الوسائط',
                      Icons.perm_media_outlined,
                      RoutePaths.workspaceMedia,
                      'SOURCE ≠ MEDIA',
                    ),
                    _Module(
                      'GIS والإحداثيات',
                      Icons.map_outlined,
                      RoutePaths.workspaceMapEditor,
                      '$coordinateGaps فجوة',
                    ),
                    const _Module(
                      'العلاقات',
                      Icons.account_tree_outlined,
                      RoutePaths.workspaceRelationships,
                      'Entity graph',
                    ),
                    const _Module(
                      'المراجعة',
                      Icons.rate_review_outlined,
                      RoutePaths.workspaceReviews,
                      'Independent review',
                    ),
                    const _Module(
                      'التحكم بالإصدار',
                      Icons.verified_outlined,
                      RoutePaths.workspaceReleaseControl,
                      'Publication gate',
                    ),
                    const _Module(
                      'سجل التدقيق',
                      Icons.receipt_long_outlined,
                      RoutePaths.workspaceAudit,
                      'Audit trail',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _AttentionPanel(
                  coordinateGaps: coordinateGaps,
                  sourceCount: sources.length,
                  onMap: () => context.go(RoutePaths.workspaceMapEditor),
                  onSources: () => context.go(RoutePaths.workspaceSources),
                  onResearch: () => context.go(RoutePaths.workspaceReviews),
                ),
                const SizedBox(height: 22),
                const _ReleaseGuard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsoleHeader extends StatelessWidget {
  const _ConsoleHeader({required this.onPublic, required this.onReviews});

  final VoidCallback onPublic;
  final VoidCallback onReviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ApprovedReferenceDesign.glassDecoration(context, radius: 22),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 16,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'PAL EYES • ADMIN / EDITORIAL CONSOLE',
                  style: TextStyle(
                    color: ApprovedReferenceDesign.gold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مركز إدارة البحث والمحتوى والنشر',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ApprovedReferenceDesign.foreground(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'واجهة تشغيلية واحدة تربط corpus البحثي بالتحرير والمراجعة والوسائط وGIS وقرار الإصدار.',
                  style: TextStyle(
                    color: ApprovedReferenceDesign.secondaryForeground(context),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: onReviews,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('قائمة المراجعة'),
              ),
              OutlinedButton.icon(
                onPressed: onPublic,
                icon: const Icon(Icons.public_rounded),
                label: const Text('معاينة الموقع العام'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.note);
  final String label;
  final String value;
  final String note;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});
  final List<_Metric> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1100
          ? 6
          : constraints.maxWidth >= 720
          ? 3
          : 2;
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: items
            .map(
              (item) => SizedBox(
                width: width,
                child: _MetricCard(item: item),
              ),
            )
            .toList(growable: false),
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});
  final _Metric item;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: ApprovedReferenceDesign.glassDecoration(context, radius: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: ApprovedReferenceDesign.gold,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.label,
          style: TextStyle(
            color: ApprovedReferenceDesign.foreground(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.note,
          style: TextStyle(
            color: ApprovedReferenceDesign.secondaryForeground(context),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        eyebrow,
        style: const TextStyle(
          color: ApprovedReferenceDesign.gold,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: ApprovedReferenceDesign.foreground(context),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        style: TextStyle(
          color: ApprovedReferenceDesign.secondaryForeground(context),
          height: 1.6,
        ),
      ),
    ],
  );
}

class _WorkflowBoard extends StatelessWidget {
  const _WorkflowBoard({
    required this.mappedCount,
    required this.stagingReferences,
    required this.onReview,
    required this.onRelease,
  });

  final int mappedCount;
  final int stagingReferences;
  final VoidCallback onReview;
  final VoidCallback onRelease;
  @override
  Widget build(BuildContext context) {
    final stages = <_WorkflowStage>[
      const _WorkflowStage(
        '1',
        'البحث',
        '$researchCorpusTotalCount',
        'Corpus مجمّد ومقبول',
      ),
      const _WorkflowStage(
        '2',
        'التحرير',
        '$researchCorpusCompletedCount',
        'REVIEW_DEFERRED',
      ),
      const _WorkflowStage(
        '3',
        'الفجوات',
        '${researchCorpusInsufficientCount + researchCorpusIncompleteCount}',
        'دليل غير كافٍ / غير مكتمل',
      ),
      const _WorkflowStage('4', 'المراجعة', '0', 'لا اعتماد نهائي بعد'),
      _WorkflowStage('5', 'الوسائط وGIS', '$mappedCount', 'مواضع مدققة'),
      _WorkflowStage('6', 'Staging', '$stagingReferences', 'مراجع وحزم معاينة'),
      const _WorkflowStage('7', 'قرار النشر', '0', 'محجوب حالياً'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ApprovedReferenceDesign.glassDecoration(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                for (var index = 0; index < stages.length; index++) ...<Widget>[
                  _WorkflowStageCard(stage: stages[index]),
                  if (index < stages.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: ApprovedReferenceDesign.gold,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('فتح المراجعة'),
              ),
              OutlinedButton.icon(
                onPressed: onRelease,
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('فحص بوابة الإصدار'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkflowStage {
  const _WorkflowStage(this.index, this.title, this.value, this.note);
  final String index;
  final String title;
  final String value;
  final String note;
}

class _WorkflowStageCard extends StatelessWidget {
  const _WorkflowStageCard({required this.stage});
  final _WorkflowStage stage;

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: ApprovedReferenceDesign.surfaceRaised,
      borderRadius: BorderRadius.circular(16),
      border: const Border.fromBorderSide(
        BorderSide(color: ApprovedReferenceDesign.line),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          stage.index,
          style: const TextStyle(
            color: ApprovedReferenceDesign.gold,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stage.title,
          style: const TextStyle(
            color: ApprovedReferenceDesign.cream,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stage.value,
          style: const TextStyle(
            color: ApprovedReferenceDesign.goldSoft,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stage.note,
          style: const TextStyle(
            color: ApprovedReferenceDesign.muted,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _Module {
  const _Module(this.title, this.icon, this.path, this.note);
  final String title;
  final IconData icon;
  final String path;
  final String note;
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.modules});
  final List<_Module> modules;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1100
          ? 3
          : constraints.maxWidth >= 700
          ? 2
          : 1;
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: modules
            .map(
              (module) => SizedBox(
                width: width,
                child: _ModuleCard(module: module),
              ),
            )
            .toList(growable: false),
      );
    },
  );
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.go(module.path),
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: ApprovedReferenceDesign.glassDecoration(context, radius: 18),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ApprovedReferenceDesign.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(module.icon, color: ApprovedReferenceDesign.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  module.title,
                  style: TextStyle(
                    color: ApprovedReferenceDesign.foreground(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.note,
                  style: TextStyle(
                    color: ApprovedReferenceDesign.secondaryForeground(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back_rounded,
            color: ApprovedReferenceDesign.gold,
          ),
        ],
      ),
    ),
  );
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({
    required this.coordinateGaps,
    required this.sourceCount,
    required this.onMap,
    required this.onSources,
    required this.onResearch,
  });
  final int coordinateGaps;
  final int sourceCount;
  final VoidCallback onMap;
  final VoidCallback onSources;
  final VoidCallback onResearch;
  @override
  Widget build(BuildContext context) {
    final items =
        <({IconData icon, String title, String note, VoidCallback action})>[
          (
            icon: Icons.warning_amber_rounded,
            title: '$researchCorpusInsufficientCount مواد بدليل غير كافٍ',
            note: 'تبقى status-only ولا تنتج رواية عامة.',
            action: onResearch,
          ),
          (
            icon: Icons.help_outline_rounded,
            title: '$researchCorpusIncompleteCount بحوث غير مكتملة',
            note: '001–003 لا تُروّج إلى staging.',
            action: onResearch,
          ),
          (
            icon: Icons.location_off_outlined,
            title: '$coordinateGaps فجوة إحداثيات',
            note: 'لا ظهور على الخريطة العامة قبل التحقق.',
            action: onMap,
          ),
          (
            icon: Icons.library_books_outlined,
            title: '$sourceCount مدخل مصدر تشغيلي',
            note: 'الهوية الببليوغرافية والمحددات تحتاج قابلية تتبع.',
            action: onSources,
          ),
        ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ApprovedReferenceDesign.glassDecoration(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SectionTitle(
            eyebrow: 'يحتاج انتباه',
            title: 'قائمة عمل مبنية على الفجوات الحقيقية',
            subtitle:
                'هذه ليست أخطاء UI؛ إنها عناصر تمنع الانتقال المنضبط إلى الاعتماد والنشر.',
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              leading: Icon(item.icon, color: ApprovedReferenceDesign.gold),
              title: Text(
                item.title,
                style: TextStyle(
                  color: ApprovedReferenceDesign.foreground(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                item.note,
                style: TextStyle(
                  color: ApprovedReferenceDesign.secondaryForeground(context),
                ),
              ),
              trailing: const Icon(Icons.arrow_back_rounded),
              onTap: item.action,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleaseGuard extends StatelessWidget {
  const _ReleaseGuard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: ApprovedReferenceDesign.red.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: ApprovedReferenceDesign.red.withValues(alpha: 0.34),
      ),
    ),
    child: const Wrap(
      spacing: 18,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Icon(Icons.lock_outline_rounded, color: ApprovedReferenceDesign.gold),
        Text(
          'BASELINE PROMOTION = NO',
          style: TextStyle(
            color: ApprovedReferenceDesign.cream,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'PUBLICATION = BLOCKED',
          style: TextStyle(
            color: ApprovedReferenceDesign.cream,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'DATABASE MUTATION = NO',
          style: TextStyle(
            color: ApprovedReferenceDesign.cream,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'PRODUCTION = NO',
          style: TextStyle(
            color: ApprovedReferenceDesign.cream,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
