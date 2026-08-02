import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/direct_flutter_maturity_r9.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/draft_content_profile.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/places/presentation/widgets/site_card.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  static const int _pageSize = 12;

  final TextEditingController _queryController = TextEditingController();
  String _searchMode = 'الكل';
  String _governorate = 'الكل';
  String _period = 'الكل';
  String _siteType = 'الكل';
  String _contentProfile = 'الكل';
  String _sort = 'الأبرز';
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _visibleCount = _pageSize;
    });
  }

  void _resetFilters() {
    _queryController.clear();
    setState(() {
      _searchMode = 'الكل';
      _governorate = 'الكل';
      _period = 'الكل';
      _siteType = 'الكل';
      _contentProfile = 'الكل';
      _sort = 'الأبرز';
      _visibleCount = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(foundationSitesProvider);
    final governorates = _values(sites.map((site) => site.governorateAr));
    final periods = _values(sites.expand((site) => site.periods));
    final siteTypes = _values(sites.map((site) => site.siteTypeAr));
    final contentProfiles = <String>[
      'الكل',
      DraftContentProfile.catalogSummary.labelAr,
      DraftContentProfile.expandedNarrative.labelAr,
    ];

    final filtered = sites
        .where((site) {
          return _matchesSearchMode(site) &&
              (_governorate == 'الكل' || site.governorateAr == _governorate) &&
              (_period == 'الكل' || site.periods.contains(_period)) &&
              (_siteType == 'الكل' || site.siteTypeAr == _siteType) &&
              (_contentProfile == 'الكل' ||
                  site.contentProfile.labelAr == _contentProfile);
        })
        .toList(growable: true);

    _sortSites(filtered);

    final visible = filtered.take(_visibleCount).toList(growable: false);
    final activeFilterCount = <bool>[
      _searchMode != 'الكل',
      _governorate != 'الكل',
      _period != 'الكل',
      _siteType != 'الكل',
      _contentProfile != 'الكل',
      _sort != 'الأبرز',
    ].where((value) => value).length;

    return PalEyesPage(
      title: 'استكشف فلسطين',
      icon: Icons.explore_outlined,
      eyebrow: 'ابحث بطريقتك',
      subtitle:
          'ابدأ باسم مكان، أو فترة، أو نوع موقع، ثم انتقل إلى الخريطة أو القصة أو المصدر.',
      header: PalEyesPublicDisclosure(
        summary:
            'المواد المعروضة قيد الإعداد، ونوضح داخل كل صفحة مستوى اكتمالها ومصادرها.',
        details: const <String>[
          'لا نعرض إحداثيات عامة قبل اعتمادها.',
          'المراجع والوسائط تمر بمراجعة مستقلة.',
          'يمكن أن تتغير الصياغة مع تقدم البحث.',
        ],
        actionLabel: 'كيف نوثّق المحتوى؟',
        onAction: () => context.go(RoutePaths.methodology),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PalEyesPublicIdentityStrip(
            active: PalEyesPublicPillar.atlas,
            onAtlas: () => context.go(RoutePaths.places),
            onMuseum: () => context.go(RoutePaths.places),
            onMagazine: () => context.go(RoutePaths.stories),
          ),
          const SizedBox(height: 16),
          PalEyesQuickPathBar(
            title: 'اختر مدخلك',
            actions: <PublicJourneyAction>[
              PublicJourneyAction(
                label: 'من الخريطة',
                icon: Icons.map_outlined,
                onPressed: () => context.go(RoutePaths.map),
              ),
              PublicJourneyAction(
                label: 'من قصة',
                icon: Icons.auto_stories_outlined,
                onPressed: () => context.go(RoutePaths.stories),
              ),
              PublicJourneyAction(
                label: 'من مصدر',
                icon: Icons.library_books_outlined,
                onPressed: () => context.go(RoutePaths.sources),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PalEyesPublicSearchPanel(
            controller: _queryController,
            hintText: 'الأقصى، سبسطية، ماء، عثماني، كنيسة…',
            activeFilterCount: activeFilterCount,
            onChanged: (_) => _refresh(),
            onClear: () {
              _queryController.clear();
              _refresh();
            },
            filters: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'الكل',
                        label: Text('في كل شيء'),
                        icon: Icon(Icons.all_inclusive_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'الاسم',
                        label: Text('الاسم'),
                        icon: Icon(Icons.badge_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'المكان',
                        label: Text('المكان'),
                        icon: Icon(Icons.place_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'الفترة',
                        label: Text('الفترة'),
                        icon: Icon(Icons.timeline_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'المصدر',
                        label: Text('المصدر'),
                        icon: Icon(Icons.library_books_outlined),
                      ),
                    ],
                    selected: <String>{_searchMode},
                    onSelectionChanged: (selection) {
                      _searchMode = selection.first;
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _FilterGrid(
                  governorates: governorates,
                  periods: periods,
                  siteTypes: siteTypes,
                  contentProfiles: contentProfiles,
                  governorate: _governorate,
                  period: _period,
                  siteType: _siteType,
                  contentProfile: _contentProfile,
                  sort: _sort,
                  onGovernorateChanged: (value) {
                    _governorate = value;
                    _refresh();
                  },
                  onPeriodChanged: (value) {
                    _period = value;
                    _refresh();
                  },
                  onSiteTypeChanged: (value) {
                    _siteType = value;
                    _refresh();
                  },
                  onContentProfileChanged: (value) {
                    _contentProfile = value;
                    _refresh();
                  },
                  onSortChanged: (value) {
                    _sort = value;
                    _refresh();
                  },
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('ابدأ من جديد'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: <Widget>[
              Text(
                'ما وجدناه لك',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.travel_explore_rounded, size: 18),
                label: Text('${filtered.length} من ${sites.length} موقعاً'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            PalEyesPublicStatePanel(
              kind: PublicContentStateKind.empty,
              title: 'لم نجد نتيجة بهذه المواصفات',
              message:
                  'جرّب كلمة أقصر، أو أزل أحد الفلاتر، أو ابدأ من الخريطة والقصص.',
              actionLabel: 'إزالة الفلاتر',
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
                          height: 420,
                          child: RepaintBoundary(child: SiteCard(site: site)),
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
                  _visibleCount += _pageSize;
                }),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(
                  'إظهار المزيد (${filtered.length - visible.length} متبقية)',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _values(Iterable<String> values) {
    final result = <String>{
      'الكل',
      ...values.where((value) => value.isNotEmpty),
    }.toList(growable: false);
    result.sort();
    return result;
  }

  bool _matchesSearchMode(HeritageSite site) {
    final query = HeritageSite.normalizeArabicSearch(_queryController.text);
    if (query.isEmpty) {
      return true;
    }

    final values = switch (_searchMode) {
      'الاسم' => <String>[site.nameAr, site.nameEn],
      'المكان' => <String>[site.localityAr, site.governorateAr],
      'الفترة' => site.periods,
      'المصدر' =>
        site.sources
            .expand((source) => <String>[source.title, source.attribution])
            .toList(growable: false),
      _ => <String>[
        site.nameAr,
        site.nameEn,
        site.localityAr,
        site.governorateAr,
        site.siteTypeAr,
        site.summaryDraft,
        ...site.periods,
        ...site.narrativeSections.map((section) => section.title),
        ...site.sources.map((source) => source.title),
      ],
    };

    return HeritageSite.normalizeArabicSearch(values.join(' ')).contains(query);
  }

  void _sortSites(List<HeritageSite> sites) {
    switch (_sort) {
      case 'الاسم':
        sites.sort((a, b) => a.nameAr.compareTo(b.nameAr));
        return;
      case 'المحافظة':
        sites.sort((a, b) {
          final result = a.governorateAr.compareTo(b.governorateAr);
          return result == 0 ? a.nameAr.compareTo(b.nameAr) : result;
        });
        return;
      case 'الأكثر مادة':
        sites.sort(
          (a, b) => (b.claimCount + b.sources.length).compareTo(
            a.claimCount + a.sources.length,
          ),
        );
        return;
      default:
        sites.sort((a, b) {
          final featured = b.featured.toString().compareTo(
            a.featured.toString(),
          );
          return featured == 0
              ? b.documentationProgress.compareTo(a.documentationProgress)
              : featured;
        });
    }
  }
}

class _FilterGrid extends StatelessWidget {
  const _FilterGrid({
    required this.governorates,
    required this.periods,
    required this.siteTypes,
    required this.contentProfiles,
    required this.governorate,
    required this.period,
    required this.siteType,
    required this.contentProfile,
    required this.sort,
    required this.onGovernorateChanged,
    required this.onPeriodChanged,
    required this.onSiteTypeChanged,
    required this.onContentProfileChanged,
    required this.onSortChanged,
  });

  final List<String> governorates;
  final List<String> periods;
  final List<String> siteTypes;
  final List<String> contentProfiles;
  final String governorate;
  final String period;
  final String siteType;
  final String contentProfile;
  final String sort;
  final ValueChanged<String> onGovernorateChanged;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onSiteTypeChanged;
  final ValueChanged<String> onContentProfileChanged;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 5
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            SizedBox(
              width: width,
              child: _Filter(
                label: 'المحافظة',
                value: governorate,
                items: governorates,
                onChanged: onGovernorateChanged,
              ),
            ),
            SizedBox(
              width: width,
              child: _Filter(
                label: 'الفترة',
                value: period,
                items: periods,
                onChanged: onPeriodChanged,
              ),
            ),
            SizedBox(
              width: width,
              child: _Filter(
                label: 'نوع المكان',
                value: siteType,
                items: siteTypes,
                onChanged: onSiteTypeChanged,
              ),
            ),
            SizedBox(
              width: width,
              child: _Filter(
                label: 'حجم المادة',
                value: contentProfile,
                items: contentProfiles,
                onChanged: onContentProfileChanged,
              ),
            ),
            SizedBox(
              width: width,
              child: _Filter(
                label: 'ترتيب النتائج',
                value: sort,
                items: const <String>[
                  'الأبرز',
                  'الاسم',
                  'المحافظة',
                  'الأكثر مادة',
                ],
                onChanged: onSortChanged,
              ),
            ),
          ],
        );
      },
    );
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
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}
