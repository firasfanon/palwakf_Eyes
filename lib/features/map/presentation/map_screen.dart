import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  HeritageSite? _selected;
  bool _showGuide = true;

  @override
  Widget build(BuildContext context) {
    final allSites = ref.watch(foundationSitesProvider);
    final mappedSites = ref.watch(mappedSitesProvider);
    final compact = MediaQuery.sizeOf(context).width < 720;
    final governorates = _governorateCounts(allSites);

    return Material(
      color: AppColors.midnight,
      child: Stack(
        children: <Widget>[
          Semantics(
            label:
                'خريطة فلسطين. تعرض فقط المواقع ذات الإحداثيات العامة المعتمدة.',
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(31.9, 35.22),
                initialZoom: 8.3,
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ps.paleyes.app',
                ),
                MarkerLayer(
                  markers: mappedSites
                      .map(
                        (site) => Marker(
                          point: LatLng(site.latitude!, site.longitude!),
                          width: 64,
                          height: 64,
                          child: Tooltip(
                            message: site.nameAr,
                            child: Semantics(
                              button: true,
                              label: 'افتح معلومات ${site.nameAr} على الخريطة',
                              child: _MapMarker(
                                selected: _selected?.slug == site.slug,
                                onTap: () => setState(() {
                                  _selected = site;
                                }),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: compact
                        ? MediaQuery.sizeOf(context).width - 28
                        : 470,
                  ),
                  child: PalEyesGlassPanel(
                    dark: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.sovereignGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: AppColors.softGold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'أطلس فلسطين',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const Text(
                                    'ابدأ من المكان، ثم اتبع الحكاية.',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: _showGuide
                                  ? 'إخفاء دليل الخريطة'
                                  : 'إظهار دليل الخريطة',
                              onPressed: () => setState(() {
                                _showGuide = !_showGuide;
                              }),
                              icon: Icon(
                                _showGuide
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                              ),
                            ),
                          ],
                        ),
                        if (_showGuide) ...<Widget>[
                          const SizedBox(height: 14),
                          const Text(
                            'تعرض الخريطة العامة المواقع التي اكتمل اعتماد موضعها فقط. يمكنك استكشاف بقية المواقع من الأطلس حتى قبل ظهورها هنا.',
                            style: TextStyle(height: 1.55),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              Chip(
                                avatar: const Icon(
                                  Icons.location_on_outlined,
                                  size: 17,
                                ),
                                label: Text(
                                  '${mappedSites.length} على الخريطة',
                                ),
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.account_balance_outlined,
                                  size: 17,
                                ),
                                label: Text('${allSites.length} في الأطلس'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () =>
                                      context.go(RoutePaths.discover),
                                  icon: const Icon(Icons.explore_outlined),
                                  label: const Text('استكشف المواقع'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton.filledTonal(
                                tooltip: 'كيف نعتمد الإحداثيات؟',
                                onPressed: () =>
                                    context.go(RoutePaths.methodology),
                                icon: const Icon(Icons.info_outline_rounded),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 10 : 18,
                  10,
                  compact ? 10 : 18,
                  compact ? 84 : 18,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: PalEyesGlassPanel(
                    dark: false,
                    padding: const EdgeInsets.all(14),
                    child: _selected != null
                        ? _SelectedSiteCard(
                            site: _selected!,
                            onClose: () => setState(() {
                              _selected = null;
                            }),
                          )
                        : mappedSites.isEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const PalEyesPublicStatePanel(
                                kind: PublicContentStateKind.empty,
                                title: 'الخريطة العامة تنتظر أول موضع معتمد',
                                message:
                                    'المواقع موجودة في الأطلس، لكننا لا نضع نقطة على الخريطة قبل اكتمال التحقق الجغرافي.',
                              ),
                              const SizedBox(height: 12),
                              _GovernorateJourneys(governorates: governorates),
                            ],
                          )
                        : _GovernorateJourneys(governorates: governorates),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<(String, int)> _governorateCounts(List<HeritageSite> sites) {
    final counts = <String, int>{};
    for (final site in sites) {
      counts[site.governorateAr] = (counts[site.governorateAr] ?? 0) + 1;
    }
    final result = counts.entries
        .map((entry) => (entry.key, entry.value))
        .toList(growable: false);
    result.sort((a, b) => b.$2.compareTo(a.$2));
    return result.take(6).toList(growable: false);
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? AppColors.heritageGold
            : AppColors.sovereignBlue,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.location_on_rounded),
    );
  }
}

class _SelectedSiteCard extends StatelessWidget {
  const _SelectedSiteCard({required this.site, required this.onClose});

  final HeritageSite site;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 26,
          child: Icon(
            site.siteTypeAr.contains('كنيسة')
                ? Icons.church_outlined
                : Icons.account_balance_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                site.nameAr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text('${site.localityAr} • ${site.governorateAr}'),
            ],
          ),
        ),
        TextButton(
          onPressed: () => context.go(RoutePaths.place(site.slug)),
          child: const Text('افتح الصفحة'),
        ),
        IconButton(
          tooltip: 'إغلاق',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _GovernorateJourneys extends StatelessWidget {
  const _GovernorateJourneys({required this.governorates});

  final List<(String, int)> governorates;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: governorates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final item = governorates[index];
          return ActionChip(
            avatar: const Icon(Icons.location_city_outlined, size: 18),
            label: Text('${item.$1} • ${item.$2}'),
            onPressed: () => context.go(RoutePaths.discover),
          );
        },
      ),
    );
  }
}
