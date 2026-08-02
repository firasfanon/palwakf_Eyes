import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/direct_flutter_maturity_r9.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/presentation/widgets/site_card.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});
  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  static const int _pageSize = 24;
  final TextEditingController _controller = TextEditingController();
  String _governorate = 'الكل';
  String _siteType = 'الكل';
  String _pageCategory = 'الكل';
  String _originalDraft = 'الكل';
  int _visibleLimit = _pageSize;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(foundationSitesProvider);
    final governorates = <String>{
      'الكل',
      ...sites.map((site) => site.governorateAr),
    }.toList()..sort();
    final siteTypes = <String>{
      'الكل',
      ...sites.map((site) => site.siteTypeAr),
    }.toList()..sort();
    final filtered = sites
        .where((site) {
          final categoryMatches = switch (_pageCategory) {
            'حكاية موسعة' => site.isGovernedDraft,
            'بطاقة تعريف أولية' => site.isLimitedResearch,
            _ => true,
          };
          final originalDraftMatches = switch (_originalDraft) {
            'حكاية تاريخية موسعة' => site.hasOriginalExpandedNarrative,
            'بطاقة أصلية' =>
              site.hasOriginalHistoricalDraft &&
                  !site.hasOriginalExpandedNarrative,
            _ => true,
          };
          return site.matches(_controller.text) &&
              (_governorate == 'الكل' || site.governorateAr == _governorate) &&
              (_siteType == 'الكل' || site.siteTypeAr == _siteType) &&
              categoryMatches &&
              originalDraftMatches;
        })
        .toList(growable: false);
    final visible = filtered.take(_visibleLimit).toList(growable: false);

    return PalEyesPage(
      title: 'أطلس المواقع الفلسطينية',
      icon: Icons.account_balance_outlined,
      eyebrow: 'المكان أولاً',
      subtitle:
          'تصفّح 79 موقعاً عبر المكان والفترة ونوع الذاكرة، ثم افتح الصفحة التي تقودك إلى القصة والمصدر.',
      actions: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () => context.go(RoutePaths.map),
          icon: const Icon(Icons.map_outlined),
          label: const Text('افتح الخريطة'),
        ),
      ],
      header: PalEyesPublicDisclosure(
        summary:
            'كل بطاقة توضح مستوى اكتمال المادة، ويمكن أن تتغير الصياغة أو المراجع مع تقدم البحث.',
        details: const <String>[
          'المسودة التاريخية الأصلية محفوظة ولا تختلط بالنص المحرر.',
          'الإحداثيات والوسائط لا تظهر للعامة قبل اعتمادها.',
        ],
        actionLabel: 'اقرأ منهجية التوثيق',
        onAction: () => context.go(RoutePaths.methodology),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PalEyesEditorialPrelude(
            eyebrow: 'الأطلس الفلسطيني',
            title: '79 موقعاً تقودك من الجغرافيا إلى الحكاية',
            description:
                'استكشف المدن والقرى والمياه والمقامات والطبقات الأثرية، '
                'ثم افتح صفحة الموقع لتقرأ الرواية والمصدر وحالة التحقق.',
            icon: Icons.account_balance_outlined,
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[AppColors.olive, AppColors.sovereignBlue],
            ),
            metrics: const <PalEyesEditorialMetric>[
              PalEyesEditorialMetric(
                value: '79',
                label: 'موقعاً',
                icon: Icons.place_outlined,
              ),
              PalEyesEditorialMetric(
                value: '47',
                label: 'حكاية موسعة',
                icon: Icons.menu_book_outlined,
              ),
              PalEyesEditorialMetric(
                value: '16',
                label: 'محافظة',
                icon: Icons.location_city_outlined,
              ),
              PalEyesEditorialMetric(
                value: '95',
                label: 'مرجعاً',
                icon: Icons.library_books_outlined,
              ),
            ],
            primaryLabel: 'ابدأ من الخريطة',
            onPrimary: () => context.go(RoutePaths.map),
            secondaryLabel: 'اقرأ القصص',
            onSecondary: () => context.go(RoutePaths.stories),
          ),
          const SizedBox(height: 18),
          const _CatalogSummary(),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    onChanged: (_) => _resetPage(),
                    decoration: const InputDecoration(
                      labelText: 'ابحث باسم الموقع أو البلدة أو المحافظة',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 1100
                          ? (constraints.maxWidth - 36) / 4
                          : constraints.maxWidth >= 720
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          SizedBox(
                            width: width,
                            child: _Filter(
                              label: 'المحافظة',
                              value: _governorate,
                              items: governorates,
                              onChanged: (value) => setState(() {
                                _governorate = value;
                                _visibleLimit = _pageSize;
                              }),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _Filter(
                              label: 'نوع الموقع',
                              value: _siteType,
                              items: siteTypes,
                              onChanged: (value) => setState(() {
                                _siteType = value;
                                _visibleLimit = _pageSize;
                              }),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _Filter(
                              label: 'نوع المادة',
                              value: _pageCategory,
                              items: const <String>[
                                'الكل',
                                'حكاية موسعة',
                                'بطاقة تعريف أولية',
                              ],
                              onChanged: (value) => setState(() {
                                _pageCategory = value;
                                _visibleLimit = _pageSize;
                              }),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _Filter(
                              label: 'عمق الحكاية',
                              value: _originalDraft,
                              items: const <String>[
                                'الكل',
                                'حكاية تاريخية موسعة',
                                'بطاقة أصلية',
                              ],
                              onChanged: (value) => setState(() {
                                _originalDraft = value;
                                _visibleLimit = _pageSize;
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text('${filtered.length} نتيجة')),
              Chip(label: Text('${visible.length} ظاهرة الآن')),
              const Chip(label: Text('47 حكاية موسعة')),
              const Chip(label: Text('95 مرجعاً في المكتبة')),
              const Chip(label: Text('16 محافظة')),
              const Chip(label: Text('الخريطة العامة تعرض المعتمد فقط')),
              const Chip(label: Text('المحتوى قيد التدقيق')),
            ],
          ),
          const SizedBox(height: 18),
          if (visible.isEmpty)
            PalEyesPublicStatePanel(
              kind: PublicContentStateKind.empty,
              title: 'لا توجد مواقع مطابقة',
              message: 'أزل أحد الفلاتر أو جرّب اسماً أقصر.',
              actionLabel: 'إعادة الضبط',
              onAction: _resetFilters,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 3
                    : constraints.maxWidth >= 690
                    ? 2
                    : 1;
                const gap = 16.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: visible
                      .map(
                        (site) => SizedBox(
                          width: width,
                          height: 440,
                          child: SiteCard(site: site),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          if (visible.length < filtered.length) ...<Widget>[
            const SizedBox(height: 20),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () => setState(() {
                  _visibleLimit += _pageSize;
                }),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(
                  'عرض المزيد (${filtered.length - visible.length} متبقية)',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _resetPage() => setState(() {
    _visibleLimit = _pageSize;
  });

  void _resetFilters() {
    _controller.clear();
    setState(() {
      _governorate = 'الكل';
      _siteType = 'الكل';
      _pageCategory = 'الكل';
      _originalDraft = 'الكل';
      _visibleLimit = _pageSize;
    });
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }
}

class _CatalogSummary extends StatelessWidget {
  const _CatalogSummary();
  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String, String)>[
      (
        Icons.account_balance_outlined,
        '${ContentCatalogMetrics.extractedSiteCount}',
        'موقعاً في الأطلس',
      ),
      (
        Icons.verified_outlined,
        '${ContentCatalogMetrics.governedDraftPageCount}',
        'صفحة بحكاية موسعة',
      ),
      (
        Icons.science_outlined,
        '${ContentCatalogMetrics.limitedResearchPageCount}',
        'بطاقة تعريف أولية',
      ),
      (
        Icons.menu_book_outlined,
        '${ContentCatalogMetrics.reviewedEditorialRecordCount}',
        'مادة تحريرية',
      ),
      (
        Icons.history_edu_outlined,
        '${ContentCatalogMetrics.expandedNarrativeCount}',
        'حكاية تاريخية موسعة',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 5
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
