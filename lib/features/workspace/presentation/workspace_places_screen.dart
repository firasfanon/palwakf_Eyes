import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/content_status_badge.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/draft_content_profile.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

class WorkspacePlacesScreen extends ConsumerStatefulWidget {
  const WorkspacePlacesScreen({super.key});

  @override
  ConsumerState<WorkspacePlacesScreen> createState() =>
      _WorkspacePlacesScreenState();
}

class _WorkspacePlacesScreenState
    extends ConsumerState<WorkspacePlacesScreen> {
  static const int _pageSize = 30;

  final TextEditingController _queryController = TextEditingController();
  String _governorate = 'الكل';
  String _profile = 'الكل';
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

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(foundationSitesProvider);
    final governorates = <String>{
      'الكل',
      ...sites.map((site) => site.governorateAr),
    }.toList(growable: false)
      ..sort();
    final profiles = <String>[
      'الكل',
      DraftContentProfile.catalogSummary.labelAr,
      DraftContentProfile.expandedNarrative.labelAr,
    ];

    final filtered = sites.where((site) {
      final queryMatches = site.matches(_queryController.text);
      final governorateMatches =
          _governorate == 'الكل' || site.governorateAr == _governorate;
      final profileMatches =
          _profile == 'الكل' || site.contentProfile.labelAr == _profile;
      return queryMatches && governorateMatches && profileMatches;
    }).toList(growable: false);

    final visible = filtered.take(_visibleCount).toList(growable: false);
    final canShowMore = visible.length < filtered.length;

    return PalEyesPage(
      title: 'إدارة المواقع',
      subtitle:
          'قائمة تشغيلية لجميع المواقع الـ79، مع بحث وفلاتر وتحميل تدريجي يمنع ازدحام الشاشة.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.workspaceNewPlace),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('إضافة موقع'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _queryController,
                    onChanged: (_) => _refresh(),
                    decoration: const InputDecoration(
                      labelText: 'البحث في المواقع',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final governorateFilter = _WorkspaceFilter(
                        label: 'المحافظة',
                        value: _governorate,
                        items: governorates,
                        onChanged: (value) {
                          _governorate = value;
                          _refresh();
                        },
                      );
                      final profileFilter = _WorkspaceFilter(
                        label: 'مستوى المادة',
                        value: _profile,
                        items: profiles,
                        onChanged: (value) {
                          _profile = value;
                          _refresh();
                        },
                      );
                      if (constraints.maxWidth < 620) {
                        return Column(
                          children: <Widget>[
                            governorateFilter,
                            const SizedBox(height: 12),
                            profileFilter,
                          ],
                        );
                      }
                      return Row(
                        children: <Widget>[
                          Expanded(child: governorateFilter),
                          const SizedBox(width: 12),
                          Expanded(child: profileFilter),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Text(
                'المواقع',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              Chip(
                label: Text(
                  '${visible.length} ظاهرة من ${filtered.length} نتيجة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('لا توجد مواقع مطابقة.')),
              ),
            )
          else
            ...visible.map(
              (site) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkspaceSiteRow(site: site),
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

class _WorkspaceFilter extends StatelessWidget {
  const _WorkspaceFilter({
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

class _WorkspaceSiteRow extends StatelessWidget {
  const _WorkspaceSiteRow({required this.site});

  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  site.nameAr,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '${site.siteTypeAr} • ${site.localityAr} • ${site.governorateAr}',
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: <Widget>[
                    ContentStatusBadge(
                      status: site.status,
                      compact: true,
                    ),
                    Chip(label: Text(site.contentProfile.labelAr)),
                    Chip(
                      avatar: Icon(
                        site.hasReviewCoordinates
                            ? Icons.location_on_outlined
                            : Icons.location_off_outlined,
                        size: 18,
                      ),
                      label: Text(
                        site.hasReviewCoordinates
                            ? 'إحداثيات للمراجعة'
                            : 'تحتاج إحداثيات',
                      ),
                    ),
                    Chip(
                      label: Text('${site.sourceMentionCount} ذكر مصدر'),
                    ),
                  ],
                ),
              ],
            );
            final actions = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go(RoutePaths.place(site.slug)),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('معاينة'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      context.go(RoutePaths.workspaceNarratives),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('تحرير'),
                ),
              ],
            );

            if (constraints.maxWidth >= 760) {
              return Row(
                children: <Widget>[
                  CircleAvatar(child: Icon(site.contentProfile.icon)),
                  const SizedBox(width: 14),
                  Expanded(child: details),
                  const SizedBox(width: 14),
                  actions,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                details,
                const SizedBox(height: 14),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}
