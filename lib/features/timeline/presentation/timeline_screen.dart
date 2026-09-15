import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';
import 'package:pal_eyes/core/widgets/draft_content_banner.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/places/domain/historical_content.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  static const int _pageSize = 24;
  String _governorate = 'الكل';
  String _period = 'الكل';
  int _visibleCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    final presentationMode = ref.watch(palEyesPresentationModeProvider);
    final sites = ref.watch(foundationSitesProvider);
    final items = <_TimelineItem>[
      for (final site in sites)
        for (final entry in site.timeline)
          _TimelineItem(site: site, entry: entry),
    ];

    final governorates = <String>{
      'الكل',
      ...sites.map((site) => site.governorateAr),
    }.toList()..sort();
    final periods = <String>{
      'الكل',
      ...items.map((item) => item.entry.period),
    }.toList()..sort();

    final filtered = items
        .where((item) {
          final governorateMatches =
              _governorate == 'الكل' || item.site.governorateAr == _governorate;
          final periodMatches =
              _period == 'الكل' || item.entry.period == _period;
          return governorateMatches && periodMatches;
        })
        .toList(growable: false);

    final visible = filtered.take(_visibleCount).toList(growable: false);
    final canShowMore = visible.length < filtered.length;

    return PalEyesPage(
      title: 'نحالين عبر الزمن',
      icon: Icons.timeline_outlined,
      eyebrow: 'الذاكرة البصرية',
      subtitle:
          'تتبع تحولات المكان الفلسطيني عبر الفترات التاريخية، واربط كل لحظة بالموقع والحكاية.',
      header: presentationMode.isInternal
          ? const DraftContentBanner(compact: true)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PeriodRail(
            periods: periods
                .where((p) => p != 'الكل')
                .take(5)
                .toList(growable: false),
            selected: _period,
            onSelected: (value) => setState(() {
              _period = value;
              _visibleCount = _pageSize;
            }),
          ),
          const SizedBox(height: 18),
          const _MemoryWindow(),
          const SizedBox(height: 18),
          _MetricStrip(sites: sites, items: items),
          const SizedBox(height: 28),
          PalEyesParchmentPanel(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final governorateFilter = _TimelineFilter(
                  label: 'المحافظة',
                  value: _governorate,
                  items: governorates,
                  onChanged: (value) => setState(() {
                    _governorate = value;
                    _visibleCount = _pageSize;
                  }),
                );
                final periodFilter = _TimelineFilter(
                  label: 'الفترة',
                  value: _period,
                  items: periods,
                  onChanged: (value) => setState(() {
                    _period = value;
                    _visibleCount = _pageSize;
                  }),
                );
                if (constraints.maxWidth < 620) {
                  return Column(
                    children: <Widget>[
                      governorateFilter,
                      const SizedBox(height: 12),
                      periodFilter,
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: governorateFilter),
                    const SizedBox(width: 12),
                    Expanded(child: periodFilter),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 26),
          PalEyesSectionTitleV1(
            title: 'نافذة زمنية من المكان',
            subtitle:
                '${visible.length} عنصرًا من ${filtered.length} ضمن هذا المسار الزمني.',
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            const PalEyesParchmentPanel(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('لا توجد مواد زمنية مطابقة للفلاتر الحالية.'),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 2 : 1;
                const gap = 14.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: visible
                      .map(
                        (item) => SizedBox(
                          width: width,
                          child: _TimelineCard(item: item),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          if (canShowMore) ...<Widget>[
            const SizedBox(height: 18),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () => setState(() => _visibleCount += _pageSize),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text('عرض المزيد (${filtered.length - visible.length})'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodRail extends StatelessWidget {
  const _PeriodRail({
    required this.periods,
    required this.selected,
    required this.onSelected,
  });
  final List<String> periods;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = periods.isEmpty
        ? const <String>['1920', '1948', '1967', '2000', 'اليوم']
        : periods;
    return PalEyesParchmentPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < labels.length; i++) ...<Widget>[
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(labels[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: <Widget>[
                      Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: selected == labels[i]
                              ? PalEyesVisualV1.oliveDark
                              : PalEyesVisualV1.warmInk,
                        ),
                      ),
                      const SizedBox(height: 7),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: selected == labels[i] ? 12 : 8,
                        height: selected == labels[i] ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected == labels[i]
                              ? PalEyesVisualV1.olive
                              : PalEyesVisualV1.warmLine,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i != labels.length - 1)
              Expanded(
                child: Container(height: 1, color: PalEyesVisualV1.warmLine),
              ),
          ],
        ],
      ),
    );
  }
}

class _MemoryWindow extends StatelessWidget {
  const _MemoryWindow();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).width < 700 ? 300 : 360,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(<double>[
                        0.33,
                        0.33,
                        0.33,
                        0,
                        0,
                        0.33,
                        0.33,
                        0.33,
                        0,
                        0,
                        0.33,
                        0.33,
                        0.33,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: PalEyesHeritageScene(
                        height: 360,
                        compact: true,
                        darkOverlay: false,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PalEyesHeritageScene(
                      height: 360,
                      compact: true,
                      darkOverlay: false,
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              start: 16,
              top: 16,
              child: _WindowLabel('الماضي القريب'),
            ),
            PositionedDirectional(
              end: 16,
              top: 16,
              child: _WindowLabel('الذاكرة الحية'),
            ),
            Center(
              child: Container(
                width: 2,
                color: PalEyesVisualV1.paper.withValues(alpha: 0.92),
              ),
            ),
            Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PalEyesVisualV1.paper,
                  shape: BoxShape.circle,
                  border: Border.all(color: PalEyesVisualV1.warmLine),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: PalEyesVisualV1.oliveDark,
                ),
              ),
            ),
            const PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 14,
              child: Text(
                'تتبع هذه النافذة تحولات المكان بصريًا من دون ادعاء اكتمال السجل التاريخي.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: <Shadow>[
                    Shadow(color: Colors.black54, blurRadius: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowLabel extends StatelessWidget {
  const _WindowLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.sites, required this.items});
  final List<HeritageSite> sites;
  final List<_TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final metrics = <(IconData, String, String)>[
      (Icons.account_balance_outlined, '${sites.length}', 'المواقع في التسلسل'),
      (Icons.timeline_outlined, '${items.length}', 'محطات زمنية'),
      (
        Icons.location_city_outlined,
        '${sites.map((s) => s.governorateAr).toSet().length}',
        'محافظات',
      ),
      (
        Icons.menu_book_outlined,
        '${sites.fold<int>(0, (n, s) => n + s.narrativeSections.length)}',
        'أقسام سردية',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (m) => SizedBox(
                  width: width,
                  child: PalEyesParchmentPanel(
                    radius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: <Widget>[
                        Icon(m.$1, color: PalEyesVisualV1.olive),
                        const SizedBox(height: 8),
                        Text(
                          m.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          m.$3,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: PalEyesVisualV1.warmMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

class _TimelineFilter extends StatelessWidget {
  const _TimelineFilter({
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

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.item});
  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    return PalEyesParchmentPanel(
      onTap: () => context.go(RoutePaths.place(item.site.slug)),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PalEyesVisualV1.olive.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: PalEyesVisualV1.oliveDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.entry.period,
                      style: const TextStyle(
                        color: PalEyesVisualV1.oliveDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      item.site.nameAr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_rounded,
                color: PalEyesVisualV1.warmMuted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.entry.title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            item.entry.draftText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.65),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(
                label: Text(
                  '${item.site.localityAr} • ${item.site.governorateAr}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({required this.site, required this.entry});
  final HeritageSite site;
  final HistoricalTimelineEntry entry;
}
