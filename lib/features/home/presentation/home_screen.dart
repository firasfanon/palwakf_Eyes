import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/approved_reference_design.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _activeEra = 5;

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(foundationSitesProvider);
    final mapped = ref.watch(mappedSitesProvider);
    final featured = ref.watch(featuredSitesProvider);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontal = viewportWidth < 620
        ? 12.0
        : viewportWidth < 980
        ? 20.0
        : 44.0;

    return ColoredBox(
      color: ApprovedReferenceDesign.pageBackground(context),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _ReferenceHero(
              siteCount: sites.length,
              mappedCount: mapped.length,
              onDiscover: () => context.go(RoutePaths.discover),
              onMap: () => context.go(RoutePaths.map),
              onStories: () => context.go(RoutePaths.stories),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 72),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ApprovedReferenceDesign.maxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ProductGatewaysSection(
                        onStories: () => context.go(RoutePaths.stories),
                        onMap: () => context.go(RoutePaths.map),
                        onPlaces: () => context.go(RoutePaths.places),
                        onMemory: () => context.go(RoutePaths.stories),
                        onSources: () => context.go(RoutePaths.sources),
                      ),
                      const SizedBox(height: 18),
                      _FeatureTriad(
                        activeEra: _activeEra,
                        onEraAdvance: () => setState(() {
                          _activeEra = (_activeEra + 1) % 8;
                        }),
                        onTimeline: () => context.go(RoutePaths.timeline),
                        onMap: () => context.go(RoutePaths.map),
                        onFeatured: featured.isEmpty
                            ? () => context.go(RoutePaths.places)
                            : () => context.go(
                                RoutePaths.place(featured.first.slug),
                              ),
                      ),
                      const SizedBox(height: 5),
                      KeyedSubtree(
                        key: const Key('home-stories-section'),
                        child: _StoryStrip(
                          onStories: () => context.go(RoutePaths.stories),
                          onAbout: () => context.go(RoutePaths.methodology),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceHero extends StatelessWidget {
  const _ReferenceHero({
    required this.siteCount,
    required this.mappedCount,
    required this.onDiscover,
    required this.onMap,
    required this.onStories,
  });

  final int siteCount;
  final int mappedCount;
  final VoidCallback onDiscover;
  final VoidCallback onMap;
  final VoidCallback onStories;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 980;
    if (!desktop) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          children: <Widget>[
            _HeroImage(height: width < 560 ? 265 : 330),
            const SizedBox(height: 18),
            _HeroCopy(
              siteCount: siteCount,
              mappedCount: mappedCount,
              onDiscover: onDiscover,
              onMap: onMap,
              onStories: onStories,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 462,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(
            child: ColoredBox(color: ApprovedReferenceDesign.night),
          ),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 1010,
            child: _HeroImage(height: 462, radius: 0),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ApprovedReferenceDesign.heroFade(),
                ),
              ),
            ),
          ),
          Positioned(
            right: 130,
            top: 105,
            width: 500,
            child: _HeroCopy(
              siteCount: siteCount,
              mappedCount: mappedCount,
              onDiscover: onDiscover,
              onMap: onMap,
              onStories: onStories,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.height, this.radius = 22});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Image.asset(
          ApprovedReferenceDesign.hero,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => PalEyesHeritageScene(
            height: height,
            compact: MediaQuery.sizeOf(context).width < 760,
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.siteCount,
    required this.mappedCount,
    required this.onDiscover,
    required this.onMap,
    required this.onStories,
  });

  final int siteCount;
  final int mappedCount;
  final VoidCallback onDiscover;
  final VoidCallback onMap;
  final VoidCallback onStories;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'فلسطين..\nأكثر من مكان',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: ApprovedReferenceDesign.cream,
            fontSize: compact ? 42 : 60,
            height: 1.05,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'حكايات الناس، وذاكرة الأرض، في رحلة بصرية تفاعلية.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: ApprovedReferenceDesign.cream.withValues(alpha: 0.88),
          ),
        ),
        const SizedBox(height: 22),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: compact ? double.infinity : 390,
            child: Semantics(
              button: true,
              label: 'اكتشف المكان في فلسطين',
              child: InkWell(
                onTap: onDiscover,
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: ApprovedReferenceDesign.cream,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: ApprovedReferenceDesign.gold.withValues(
                        alpha: 0.45,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'اكتشف المكان في فلسطين...',
                          style: TextStyle(
                            color: ApprovedReferenceDesign.night,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search_rounded,
                        color: ApprovedReferenceDesign.night,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              <String>['القدس', 'الخليل', 'نابلس', 'غزة', 'يافا', 'بيت لحم']
                  .map((label) => _CityChip(label: label, onTap: onDiscover))
                  .toList(growable: false),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: onStories,
              style: OutlinedButton.styleFrom(
                foregroundColor: ApprovedReferenceDesign.cream,
                side: BorderSide(
                  color: ApprovedReferenceDesign.cream.withValues(alpha: 0.32),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('شاهد الحكايات'),
            ),
            TextButton.icon(
              onPressed: onMap,
              style: TextButton.styleFrom(
                foregroundColor: ApprovedReferenceDesign.goldSoft,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                'استكشف الخريطة • $mappedCount/$siteCount موضعاً مدققاً',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    onPressed: onTap,
    label: Text(label),
    labelStyle: const TextStyle(
      color: ApprovedReferenceDesign.cream,
      fontWeight: FontWeight.w800,
    ),
    backgroundColor: ApprovedReferenceDesign.surface.withValues(alpha: 0.82),
    side: const BorderSide(color: ApprovedReferenceDesign.line),
  );
}

class _ProductGatewaysSection extends StatelessWidget {
  const _ProductGatewaysSection({
    required this.onStories,
    required this.onMap,
    required this.onPlaces,
    required this.onMemory,
    required this.onSources,
  });

  final VoidCallback onStories;
  final VoidCallback onMap;
  final VoidCallback onPlaces;
  final VoidCallback onMemory;
  final VoidCallback onSources;

  @override
  Widget build(BuildContext context) {
    final items = <({String asset, String label, VoidCallback onTap})>[
      (
        asset: ApprovedReferenceDesign.gatewayAssets[0],
        label: 'القصص والذاكرة',
        onTap: onStories,
      ),
      (
        asset: ApprovedReferenceDesign.gatewayAssets[1],
        label: 'الخريطة',
        onTap: onMap,
      ),
      (
        asset: ApprovedReferenceDesign.gatewayAssets[2],
        label: 'الأماكن',
        onTap: onPlaces,
      ),
      (
        asset: ApprovedReferenceDesign.gatewayAssets[3],
        label: 'الخط الزمني',
        onTap: onMemory,
      ),
      (
        asset: ApprovedReferenceDesign.gatewayAssets[4],
        label: 'المصادر',
        onTap: onSources,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 282,
                child: _ImageActionCard(item: items[index]),
              ),
            ),
          );
        }
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * 4) / 5;
        return Row(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            for (var index = 0; index < items.length; index++) ...<Widget>[
              if (index > 0) const SizedBox(width: 12),
              SizedBox(
                width: width,
                child: _ImageActionCard(item: items[index]),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ImageActionCard extends StatelessWidget {
  const _ImageActionCard({required this.item});

  final ({String asset, String label, VoidCallback onTap}) item;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: Semantics(
        button: true,
        label: item.label,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 2.38,
              child: Image.asset(
                item.asset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTriad extends StatelessWidget {
  const _FeatureTriad({
    required this.activeEra,
    required this.onEraAdvance,
    required this.onTimeline,
    required this.onMap,
    required this.onFeatured,
  });

  final int activeEra;
  final VoidCallback onEraAdvance;
  final VoidCallback onTimeline;
  final VoidCallback onMap;
  final VoidCallback onFeatured;

  static const List<String> _eras = <String>[
    'القديم',
    'الروماني',
    'البيزنطي',
    'الإسلامي',
    'المملوكي',
    'العثماني',
    'الانتداب',
    'المعاصر',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panels = <Widget>[
          _ReferencePanel(
            asset: ApprovedReferenceDesign.timeline,
            label: 'رحلة عبر الزمن • ${_eras[activeEra]}',
            onTap: onEraAdvance,
            secondaryAction: onTimeline,
          ),
          _ReferencePanel(
            asset: ApprovedReferenceDesign.map,
            label: 'اكتشف فلسطين على الخريطة',
            onTap: onMap,
          ),
          _ReferencePanel(
            asset: ApprovedReferenceDesign.featured,
            label: 'مكان مميز هذا الأسبوع',
            onTap: onFeatured,
          ),
        ];
        if (constraints.maxWidth < 980) {
          return Column(
            children: <Widget>[
              for (var index = 0; index < panels.length; index++) ...<Widget>[
                if (index > 0) const SizedBox(height: 14),
                SizedBox(height: 255, child: panels[index]),
              ],
            ],
          );
        }
        return SizedBox(
          height: 259,
          child: Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 525, child: panels[0]),
              const SizedBox(width: 14),
              Expanded(flex: 470, child: panels[1]),
              const SizedBox(width: 14),
              Expanded(flex: 417, child: panels[2]),
            ],
          ),
        );
      },
    );
  }
}

class _ReferencePanel extends StatelessWidget {
  const _ReferencePanel({
    required this.asset,
    required this.label,
    required this.onTap,
    this.secondaryAction,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          onLongPress: secondaryAction,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryStrip extends StatelessWidget {
  const _StoryStrip({required this.onStories, required this.onAbout});

  final VoidCallback onStories;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final cards = ApprovedReferenceDesign.storyAssets
        .map(
          (asset) => _HoverLift(
            child: InkWell(
              onTap: onStories,
              borderRadius: BorderRadius.circular(18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 920) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'قصص من المكان',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ApprovedReferenceDesign.goldSoft,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 145,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: cards.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) =>
                      SizedBox(width: 184, child: cards[index]),
                ),
              ),
              const SizedBox(height: 14),
              _MemoryCta(onTap: onAbout),
            ],
          );
        }
        return Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 140,
              child: _StoryDiscoveryControl(onTap: onStories),
            ),
            const SizedBox(width: 14),
            ...<Widget>[
              for (var index = 0; index < cards.length; index++) ...<Widget>[
                if (index > 0) const SizedBox(width: 12),
                SizedBox(width: 164, height: 128, child: cards[index]),
              ],
            ],
            const SizedBox(width: 20),
            Expanded(child: _MemoryCta(onTap: onAbout)),
          ],
        );
      },
    );
  }
}

class _StoryDiscoveryControl extends StatelessWidget {
  const _StoryDiscoveryControl({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'قصص من المكان',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: ApprovedReferenceDesign.cream,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اكتشف المزيد من القصص',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ApprovedReferenceDesign.muted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              IconButton.outlined(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_back_rounded),
                color: ApprovedReferenceDesign.gold,
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward_rounded),
                color: ApprovedReferenceDesign.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemoryCta extends StatelessWidget {
  const _MemoryCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _HoverLift(
    child: Semantics(
      button: true,
      label: 'معاً نحفظ الذاكرة لأجيال قادمة',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            ApprovedReferenceDesign.memoryCta,
            fit: BoxFit.cover,
            height: 128,
            width: double.infinity,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    ),
  );
}

class _HoverLift extends StatefulWidget {
  const _HoverLift({required this.child});

  final Widget child;

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.018 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: ApprovedReferenceDesign.gold.withValues(
                  alpha: _hovered ? 0.16 : 0,
                ),
                blurRadius: 28,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
