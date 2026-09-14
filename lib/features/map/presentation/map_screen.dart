import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/config/map_tile_provider_policy.dart';
import 'package:pal_eyes/core/widgets/map_tile_policy_surface.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  HeritageSite? _selected;
  int _categoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final allSites = ref.watch(foundationSitesProvider);
    final mappedSites = ref.watch(mappedSitesProvider);
    final environment = ref.watch(appEnvironmentProvider);
    final configuration = MapTileProviderPolicy.resolve(environment);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final panelWidth = compact ? 64.0 : 104.0;

        return ColoredBox(
          color: PalEyesVisualV1.parchment,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 8 : 12,
                    8,
                    compact ? 8 : 12,
                    8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(compact ? 20 : 28),
                    child: configuration.tilesEnabled
                        ? _MapCanvas(
                            configuration: configuration,
                            sites: mappedSites,
                            selected: _selected,
                            onSelected: (site) =>
                                setState(() => _selected = site),
                          )
                        : _DisabledMapCanvas(configuration: configuration),
                  ),
                ),
              ),
              Positioned(
                left: compact ? 18 : 28,
                top: compact ? 20 : 30,
                bottom: compact ? 112 : 38,
                width: panelWidth,
                child: _CategoryRail(
                  key: compact
                      ? const ValueKey<String>('map-compact-category-rail')
                      : null,
                  compact: compact,
                  selectedIndex: _categoryIndex,
                  onSelected: (index) => setState(() => _categoryIndex = index),
                ),
              ),
              PositionedDirectional(
                top: compact ? 20 : 30,
                end: compact ? 18 : 28,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: compact ? 236 : 360),
                  child: PalEyesParchmentPanel(
                    padding: EdgeInsets.all(compact ? 14 : 18),
                    radius: compact ? 16 : 20,
                    color: PalEyesVisualV1.paper.withValues(alpha: 0.94),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.map_outlined,
                              color: PalEyesVisualV1.olive,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'أطلس فلسطين',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: PalEyesVisualV1.warmInk,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (!compact) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            'تعرض فقط المواقع ذات الإحداثيات العامة المعتمدة. المواقع غير المعتمدة تبقى محجوبة.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: PalEyesVisualV1.warmMuted,
                                  height: 1.5,
                                ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: <Widget>[
                            _CountPill('${mappedSites.length}', 'موقعًا'),
                            _CountPill('${allSites.length}', 'في الكتالوج'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selected != null)
                PositionedDirectional(
                  end: compact ? 18 : 28,
                  bottom: compact ? 102 : 38,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: compact ? 290 : 380),
                    child: _SelectedSiteCard(
                      site: _selected!,
                      onOpen: () =>
                          context.go(RoutePaths.place(_selected!.slug)),
                      onClose: () => setState(() => _selected = null),
                    ),
                  ),
                ),
              Positioned(
                left: compact ? 90 : 150,
                right: compact ? 18 : 28,
                bottom: compact ? 20 : 24,
                child: PalEyesMapAttributionBar(configuration: configuration),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.configuration,
    required this.sites,
    required this.selected,
    required this.onSelected,
  });

  final MapTileRuntimeConfiguration configuration;
  final List<HeritageSite> sites;
  final HeritageSite? selected;
  final ValueChanged<HeritageSite> onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.76,
            0.10,
            0.05,
            0,
            18,
            0.08,
            0.72,
            0.06,
            0,
            16,
            0.04,
            0.10,
            0.62,
            0,
            12,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(31.9, 35.22),
              initialZoom: 8.25,
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: configuration.urlTemplate,
                userAgentPackageName: configuration.userAgentPackageName,
                maxNativeZoom: configuration.maxNativeZoom,
              ),
              MarkerLayer(
                markers: sites
                    .map(
                      (site) => Marker(
                        point: LatLng(site.latitude!, site.longitude!),
                        width: 48,
                        height: 48,
                        child: Tooltip(
                          message: site.nameAr,
                          child: _MapMarker(
                            selected: selected?.slug == site.slug,
                            onTap: () => onSelected(site),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFE8D9B5).withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class _DisabledMapCanvas extends StatelessWidget {
  const _DisabledMapCanvas({required this.configuration});

  final MapTileRuntimeConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[PalEyesVisualV1.mapSea, Color(0xFFD6D6C4)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: Opacity(
              opacity: 0.75,
              child: Center(
                child: SizedBox(
                  width: 330,
                  child: PalestineMapArtwork(
                    foregroundColor: PalEyesVisualV1.oliveDark,
                    showMarkers: false,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PalEyesMapTileBlockedNotice(
                  configuration: configuration,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.compact,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final bool compact;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = <(IconData, String)>[
    (Icons.location_on_outlined, 'أماكن'),
    (Icons.location_city_outlined, 'قرى'),
    (Icons.account_balance_outlined, 'آثار'),
    (Icons.mosque_outlined, 'مقامات'),
    (Icons.water_drop_outlined, 'مياه'),
    (Icons.route_outlined, 'طرق'),
    (Icons.auto_stories_outlined, 'حكايات'),
    (Icons.description_outlined, 'وثائق'),
  ];

  @override
  Widget build(BuildContext context) {
    return PalEyesParchmentPanel(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 9, vertical: 10),
      radius: 18,
      color: PalEyesVisualV1.paper.withValues(alpha: 0.95),
      child: Material(
        color: Colors.transparent,
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            final item = items[index];
            final selected = selectedIndex == index;
            return Tooltip(
              message: item.$2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 7 : 8,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? PalEyesVisualV1.olive.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: compact
                      ? Icon(
                          item.$1,
                          size: 21,
                          color: selected
                              ? PalEyesVisualV1.oliveDark
                              : PalEyesVisualV1.warmMuted,
                        )
                      : Row(
                          children: <Widget>[
                            Icon(
                              item.$1,
                              size: 20,
                              color: selected
                                  ? PalEyesVisualV1.oliveDark
                                  : PalEyesVisualV1.warmMuted,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                item.$2,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: PalEyesVisualV1.warmInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'فتح الموقع في الأطلس',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 40 : 34,
          height: selected ? 40 : 34,
          decoration: BoxDecoration(
            color: selected
                ? PalEyesVisualV1.terracotta
                : PalEyesVisualV1.oliveDark,
            shape: BoxShape.circle,
            border: Border.all(color: PalEyesVisualV1.paper, width: 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            selected ? Icons.place_rounded : Icons.account_balance_outlined,
            size: selected ? 20 : 17,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SelectedSiteCard extends StatelessWidget {
  const _SelectedSiteCard({
    required this.site,
    required this.onOpen,
    required this.onClose,
  });

  final HeritageSite site;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return PalEyesParchmentPanel(
      padding: const EdgeInsets.all(16),
      radius: 20,
      color: PalEyesVisualV1.paper.withValues(alpha: 0.96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  site.nameAr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(
            '${site.localityAr} • ${site.governorateAr}',
            style: const TextStyle(
              color: PalEyesVisualV1.warmMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(site.summaryDraft, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('عودة إلى الأطلس'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: PalEyesVisualV1.parchmentDeep.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$value $label',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
