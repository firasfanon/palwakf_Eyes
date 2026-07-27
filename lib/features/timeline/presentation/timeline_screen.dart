import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/content_status_badge.dart';
import 'package:pal_eyes/core/widgets/draft_content_banner.dart';
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
  static const int _pageSize = 40;

  String _governorate = 'الكل';
  String _period = 'الكل';
  int _visibleCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(foundationSitesProvider);
    final items = <_TimelineItem>[
      for (final site in sites)
        for (final entry in site.timeline)
          _TimelineItem(site: site, entry: entry),
    ];

    final governorates = <String>{
      'الكل',
      ...sites.map((site) => site.governorateAr),
    }.toList(growable: false)..sort();
    final periods = <String>{
      'الكل',
      ...items.map((item) => item.entry.period),
    }.toList(growable: false)..sort();

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
      title: 'الخط الزمني للمواقع',
      icon: Icons.timeline_outlined,
      eyebrow: 'طبقات الزمن',
      subtitle:
          'فترات مستخرجة من مسودات المواقع؛ التسميات والتواريخ خاضعة للمراجعة التاريخية ولا تمثل خطاً زمنياً منشوراً.',
      header: const DraftContentBanner(compact: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final governorateFilter = _TimelineFilter(
                    label: 'المحافظة',
                    value: _governorate,
                    items: governorates,
                    onChanged: (value) {
                      setState(() {
                        _governorate = value;
                        _visibleCount = _pageSize;
                      });
                    },
                  );
                  final periodFilter = _TimelineFilter(
                    label: 'الفترة',
                    value: _period,
                    items: periods,
                    onChanged: (value) {
                      setState(() {
                        _period = value;
                        _visibleCount = _pageSize;
                      });
                    },
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
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Text(
                'المواد الزمنية',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Chip(
                label: Text('${visible.length} ظاهرة من ${filtered.length}'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: Text('لا توجد مواد زمنية مطابقة للفلاتر.'),
                ),
              ),
            )
          else
            ...visible.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TimelineCard(item: item),
              ),
            ),
          if (canShowMore) ...<Widget>[
            const SizedBox(height: 10),
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
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go(RoutePaths.place(item.site.slug)),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CircleAvatar(child: Icon(Icons.timeline_rounded)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.entry.period,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.site.nameAr}: ${item.entry.title}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item.site.localityAr} • ${item.site.governorateAr}',
                    ),
                    const SizedBox(height: 8),
                    Text(item.entry.draftText),
                    const SizedBox(height: 10),
                    ContentStatusBadge(
                      status: item.entry.status,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({required this.site, required this.entry});

  final HeritageSite site;
  final HistoricalTimelineEntry entry;
}
