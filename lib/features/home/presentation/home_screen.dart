import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/approved_reference_design.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/research/application/staging_research_corpus_provider.dart';
import 'package:pal_eyes/features/sources/domain/draft_source_registry_entry.dart';
import 'package:pal_eyes/features/stories/data/editorial_story_catalog.dart';
import 'package:pal_eyes/features/stories/domain/editorial_story.dart';

/// Public homepage — editorial Palestinian cultural-research atlas.
///
/// Refines the existing homepage (same sections, same routes, same data
/// providers) into live, accessible widgets: no text baked into images,
/// no invented records, no provisional public map points.
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
    final sources = ref.watch(draftSourceRegistryProvider);
    final packages = ref.watch(frozenStagingResearchCorpusProvider);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontal = viewportWidth < 620
        ? 12.0
        : viewportWidth < 980
        ? 20.0
        : 44.0;

    final siteById = <String, HeritageSite>{
      for (final site in sites) site.id: site,
    };
    final research =
        packages
            .where((package) => siteById.containsKey(package.catalogSiteId))
            .toList(growable: false)
          ..sort((a, b) => a.censusRecordId.compareTo(b.censusRecordId));
    final researchItems = research
        .take(3)
        .map(
          (package) => _ResearchTeaser(
            site: siteById[package.catalogSiteId]!,
            statusLabel: package.previewStatusLabelAr,
          ),
        )
        .toList(growable: false);

    return ColoredBox(
      color: ApprovedReferenceDesign.pageBackground(context),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _ReferenceHero(
              onSearch: (query) => context.go(RoutePaths.discoverQuery(query)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontal, 22, horizontal, 40),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: PalEyesTokens.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ProductGatewaysSection(
                        onPlaces: () => context.go(RoutePaths.places),
                        onResearch: () => context.go(RoutePaths.research),
                        onStories: () => context.go(RoutePaths.stories),
                        onMap: () => context.go(RoutePaths.map),
                      ),
                      const SizedBox(height: 22),
                      _FeatureTriad(
                        story: editorialStoryCatalog.first,
                        source: _featuredSource(sources),
                        sites: sites,
                        mappedCount: mapped.length,
                        onStory: () => context.go(
                          RoutePaths.story(editorialStoryCatalog.first.slug),
                        ),
                        onSources: () => context.go(RoutePaths.sources),
                        onMap: () => context.go(RoutePaths.map),
                      ),
                      const SizedBox(height: 22),
                      _RecentResearchSection(
                        items: researchItems,
                        onAll: () => context.go(RoutePaths.research),
                        onOpen: (slug) =>
                            context.go(RoutePaths.researchItem(slug)),
                      ),
                      const SizedBox(height: 26),
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
          SliverToBoxAdapter(
            child: _TimelineBand(
              activeEra: _activeEra,
              horizontal: horizontal,
              onEra: (index) => setState(() => _activeEra = index),
              onTimeline: () => context.go(RoutePaths.timeline),
            ),
          ),
          SliverToBoxAdapter(child: _HomeFooter(horizontal: horizontal)),
        ],
      ),
    );
  }

  /// Picks a real governed source record. Never fabricates an archival
  /// document; when no archival record exists the card says so.
  DraftSourceRegistryEntry? _featuredSource(
    List<DraftSourceRegistryEntry> sources,
  ) {
    for (final source in sources) {
      if (source.sourceTypeAr.contains('architectural_record')) return source;
    }
    for (final source in sources) {
      if (source.isEditorialSource) return source;
    }
    return sources.isEmpty ? null : sources.first;
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

const List<String> _heroLocations = <String>[
  'القدس',
  'الخليل',
  'نابلس',
  'يافا',
  'غزة',
  'بيت لحم',
  'اللد',
  'الرملة',
];

class _ReferenceHero extends StatelessWidget {
  const _ReferenceHero({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 980) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
              child: SizedBox(
                height: width < 560 ? 300 : 360,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const _HeroImage(),
                    const _HeroScrim(),
                    PositionedDirectional(
                      start: 18,
                      end: 18,
                      bottom: 18,
                      child: _HeroTitle(compact: width < 560),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'حكايات الناس وذاكرة الأرض في رحلة بصرية تفاعلية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: PalEyesTokens.text(context),
              ),
            ),
            const SizedBox(height: 14),
            _HeroSearch(onSearch: onSearch, onDark: false),
            const SizedBox(height: 12),
            _LocationChips(onSearch: onSearch, onDark: false),
          ],
        ),
      );
    }

    return SizedBox(
      height: 560,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _HeroImage(),
          const _HeroScrim(),
          Align(
            alignment: const Alignment(0, 0.28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _HeroTitle(compact: false, centered: true),
                    const SizedBox(height: 12),
                    Text(
                      'حكايات الناس وذاكرة الأرض في رحلة بصرية تفاعلية',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: PalEyesTokens.inkOnDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _HeroSearch(onSearch: onSearch, onDark: true),
                    const SizedBox(height: 14),
                    _LocationChips(onSearch: onSearch, onDark: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ApprovedReferenceDesign.hero,
      fit: BoxFit.cover,
      alignment: const Alignment(0.2, 0),
      filterQuality: FilterQuality.high,
      semanticLabel: 'مشهد للقدس القديمة وقبة الصخرة عند الغروب',
      errorBuilder: (context, error, stackTrace) => PalEyesHeritageScene(
        height: 360,
        compact: MediaQuery.sizeOf(context).width < 760,
      ),
    );
  }
}

class _HeroScrim extends StatelessWidget {
  const _HeroScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              PalEyesTokens.green950.withValues(alpha: 0.62),
              PalEyesTokens.green950.withValues(alpha: 0.18),
              PalEyesTokens.green950.withValues(alpha: 0.48),
              PalEyesTokens.green950.withValues(alpha: 0.86),
            ],
            stops: const <double>[0, 0.32, 0.62, 1],
          ),
        ),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle({required this.compact, this.centered = false});

  final bool compact;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.displayLarge?.copyWith(
      fontSize: compact ? 40 : 64,
      height: 1.18,
      color: PalEyesTokens.inkOnDark,
      shadows: <Shadow>[
        Shadow(
          color: PalEyesTokens.green950.withValues(alpha: 0.55),
          blurRadius: 18,
        ),
      ],
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: const <InlineSpan>[
          TextSpan(text: 'فلسطين..\n'),
          TextSpan(
            text: 'أكثر من مكان',
            style: TextStyle(color: PalEyesTokens.goldSoft),
          ),
        ],
      ),
      textAlign: centered ? TextAlign.center : TextAlign.start,
    );
  }
}

class _HeroSearch extends StatelessWidget {
  const _HeroSearch({required this.onSearch, required this.onDark});

  final ValueChanged<String> onSearch;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ابحث في الأماكن والحكايات والبحوث',
      child: Material(
        color: PalEyesTokens.paper,
        shape: StadiumBorder(
          side: BorderSide(
            color: onDark
                ? PalEyesTokens.goldSoft.withValues(alpha: 0.6)
                : PalEyesTokens.lineStrong,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSearch(''),
          child: SizedBox(
            height: 58,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                const Icon(Icons.search_rounded, color: PalEyesTokens.inkMuted),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'اكتشف المكان في فلسطين: مكان، حكاية أو بحث…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: PalEyesTokens.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: PalEyesTokens.green900,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore_rounded,
                      color: PalEyesTokens.goldSoft,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationChips extends StatelessWidget {
  const _LocationChips({required this.onSearch, required this.onDark});

  final ValueChanged<String> onSearch;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: onDark ? WrapAlignment.center : WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: _heroLocations
          .map(
            (label) => ActionChip(
              onPressed: () => onSearch(label),
              tooltip: 'ابحث عن $label',
              label: Text(label),
              labelStyle: TextStyle(
                color: onDark ? PalEyesTokens.inkOnDark : PalEyesTokens.ink,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: onDark
                  ? PalEyesTokens.green950.withValues(alpha: 0.55)
                  : PalEyesTokens.paper,
              side: BorderSide(
                color: onDark
                    ? PalEyesTokens.goldSoft.withValues(alpha: 0.45)
                    : PalEyesTokens.line,
              ),
              shape: const StadiumBorder(),
            ),
          )
          .toList(growable: false),
    );
  }
}

// ---------------------------------------------------------------------------
// Four entry points
// ---------------------------------------------------------------------------

class _Gateway {
  const _Gateway({
    required this.title,
    required this.subtitle,
    required this.semantic,
    required this.icon,
    required this.asset,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String semantic;
  final IconData icon;
  final String asset;
  final VoidCallback onTap;
}

class _ProductGatewaysSection extends StatelessWidget {
  const _ProductGatewaysSection({
    required this.onPlaces,
    required this.onResearch,
    required this.onStories,
    required this.onMap,
  });

  final VoidCallback onPlaces;
  final VoidCallback onResearch;
  final VoidCallback onStories;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final items = <_Gateway>[
      _Gateway(
        title: 'الأماكن',
        subtitle: 'اكتشف المدن والقرى والمواقع',
        semantic: 'الأماكن: اكتشف المدن والقرى والمواقع',
        icon: Icons.account_balance_outlined,
        asset: ApprovedReferenceDesign.gatewayAssets[2],
        onTap: onPlaces,
      ),
      _Gateway(
        title: 'البحوث',
        subtitle: 'دراسات ومراجع موثقة',
        semantic: 'البحوث: دراسات ومراجع موثقة',
        icon: Icons.menu_book_outlined,
        asset: ApprovedReferenceDesign.gatewayAssets[4],
        onTap: onResearch,
      ),
      _Gateway(
        title: 'الحكايات',
        subtitle: 'قصص الناس والأماكن',
        semantic: 'القصص والذاكرة: قصص الناس والأماكن',
        icon: Icons.auto_stories_outlined,
        asset: ApprovedReferenceDesign.gatewayAssets[0],
        onTap: onStories,
      ),
      _Gateway(
        title: 'الخريطة التفاعلية',
        subtitle: 'استكشف فلسطين بصرياً',
        semantic: 'الخريطة التفاعلية: استكشف فلسطين بصرياً',
        icon: Icons.map_outlined,
        asset: ApprovedReferenceDesign.gatewayAssets[1],
        onTap: onMap,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        const gap = 14.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  height: columns == 1 ? 112 : 128,
                  child: _GatewayCard(item: item),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _GatewayCard extends StatelessWidget {
  const _GatewayCard({required this.item});

  final _Gateway item;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: Semantics(
        button: true,
        label: item.semantic,
        excludeSemantics: true,
        child: Material(
          color: PalEyesTokens.green900,
          borderRadius: BorderRadius.circular(PalEyesTokens.radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: item.onTap,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Photographic half of the reference crop only; the baked
                // caption half is never shown.
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  end: 0,
                  width: 190,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.5,
                      child: Image.asset(
                        item.asset,
                        fit: BoxFit.cover,
                        height: 140,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: <Color>[
                        PalEyesTokens.green900,
                        PalEyesTokens.green900.withValues(alpha: 0.92),
                        PalEyesTokens.green900.withValues(alpha: 0.05),
                      ],
                      stops: const <double>[0, 0.45, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PalEyesTokens.gold.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Icon(item.icon, color: PalEyesTokens.goldSoft),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: PalEyesTokens.inkOnDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: PalEyesTokens.inkOnDarkMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const PositionedDirectional(
                  end: 14,
                  bottom: 12,
                  child: _ArrowBadge(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: PalEyesTokens.gold,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        size: 18,
        color: PalEyesTokens.green950,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Story · source record · map
// ---------------------------------------------------------------------------

class _FeatureTriad extends StatelessWidget {
  const _FeatureTriad({
    required this.story,
    required this.source,
    required this.sites,
    required this.mappedCount,
    required this.onStory,
    required this.onSources,
    required this.onMap,
  });

  final EditorialStory story;
  final DraftSourceRegistryEntry? source;
  final List<HeritageSite> sites;
  final int mappedCount;
  final VoidCallback onStory;
  final VoidCallback onSources;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final panels = <Widget>[
      _FeaturedStoryCard(story: story, onTap: onStory),
      _SourceRecordCard(source: source, onTap: onSources),
      _MapTeaserCard(sites: sites, mappedCount: mappedCount, onTap: onMap),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (var index = 0; index < panels.length; index++) ...<Widget>[
                if (index > 0) const SizedBox(height: 14),
                SizedBox(
                  height: const <double>[300, 320, 280][index],
                  child: panels[index],
                ),
              ],
            ],
          );
        }
        return SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 13, child: panels[0]),
              const SizedBox(width: 14),
              Expanded(flex: 11, child: panels[1]),
              const SizedBox(width: 14),
              Expanded(flex: 11, child: panels[2]),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.onDark = false});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onDark
            ? PalEyesTokens.gold.withValues(alpha: 0.22)
            : PalEyesTokens.goldWash,
        borderRadius: BorderRadius.circular(PalEyesTokens.radiusPill),
        border: Border.all(
          color: onDark
              ? PalEyesTokens.goldSoft.withValues(alpha: 0.6)
              : PalEyesTokens.goldSoft,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onDark ? PalEyesTokens.goldSoft : PalEyesTokens.goldDeep,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeaturedStoryCard extends StatelessWidget {
  const _FeaturedStoryCard({required this.story, required this.onTap});

  final EditorialStory story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: Material(
        color: PalEyesTokens.green900,
        borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                ApprovedReferenceDesign.hero,
                fit: BoxFit.cover,
                alignment: const Alignment(0.55, 0),
                excludeFromSemantics: true,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: <Color>[
                      PalEyesTokens.green950.withValues(alpha: 0.95),
                      PalEyesTokens.green950.withValues(alpha: 0.7),
                      PalEyesTokens.green950.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: ClipRect(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const _Pill(label: 'قصة من فلسطين', onDark: true),
                              const SizedBox(height: 12),
                              Text(
                                story.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: PalEyesTokens.inkOnDark),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 380,
                                ),
                                child: Text(
                                  story.summary,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: PalEyesTokens.inkOnDarkMuted,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PalEyesTokens.goldSoft,
                        side: const BorderSide(color: PalEyesTokens.gold),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text('اقرأ القصة • ${story.readingMinutes} دقائق'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PalEyesTokens.panel(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
        side: BorderSide(color: PalEyesTokens.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}

class _SourceRecordCard extends StatelessWidget {
  const _SourceRecordCard({required this.source, required this.onTap});

  final DraftSourceRegistryEntry? source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = source;
    return _PaperCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _Pill(label: 'من السجل المصدري'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 84,
                          decoration: BoxDecoration(
                            color: PalEyesTokens.cream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PalEyesTokens.lineStrong),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: PalEyesTokens.goldDeep,
                            semanticLabel: 'صورة الوثيقة غير معروضة',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                entry?.title ?? 'لا يوجد سجل مصدري متاح',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: PalEyesTokens.text(context),
                                ),
                              ),
                              if (entry != null) ...<Widget>[
                                const SizedBox(height: 4),
                                Text(
                                  entry.attribution,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: PalEyesTokens.textMuted(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا تُعرض صورة أي وثيقة قبل التحقق من أصلها وحقوقها. هذا سجل مرجعي حقيقي قيد المراجعة، وليس وثيقة أرشيفية معتمدة للنشر.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PalEyesTokens.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: PalEyesTokens.goldWash,
              foregroundColor: PalEyesTokens.goldDeep,
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 44),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('سجل المصادر'),
          ),
        ],
      ),
    );
  }
}

class _MapTeaserCard extends StatelessWidget {
  const _MapTeaserCard({
    required this.sites,
    required this.mappedCount,
    required this.onTap,
  });

  final List<HeritageSite> sites;
  final int mappedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byType = <String, int>{};
    for (final site in sites) {
      final key = site.siteTypeAr.trim().isEmpty ? 'غير مصنف' : site.siteTypeAr;
      byType[key] = (byType[key] ?? 0) + 1;
    }
    final top = byType.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    const dots = <Color>[
      PalEyesTokens.gold,
      PalEyesTokens.green500,
      PalEyesTokens.terracotta,
      PalEyesTokens.sea,
    ];

    return _PaperCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ClipRect(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'استكشف على الخريطة',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: PalEyesTokens.text(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${sites.length} موقعاً في الأطلس • $mappedCount بإحداثيات عامة معتمدة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: PalEyesTokens.textMuted(context),
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < top.length && i < 4; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: dots[i],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${top[i].key} (${top[i].value})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: PalEyesTokens.text(context),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: PalEyesTokens.green800,
                    foregroundColor: PalEyesTokens.inkOnDark,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 44),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('فتح الخريطة'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            flex: 2,
            child: Center(
              child: PalestineMapArtwork(
                compact: true,
                showMarkers: false,
                foregroundColor: PalEyesTokens.green600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent research
// ---------------------------------------------------------------------------

class _ResearchTeaser {
  const _ResearchTeaser({required this.site, required this.statusLabel});

  final HeritageSite site;
  final String statusLabel;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: PalEyesTokens.text(context),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: PalEyesTokens.accentText(context),
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _RecentResearchSection extends StatelessWidget {
  const _RecentResearchSection({
    required this.items,
    required this.onAll,
    required this.onOpen,
  });

  final List<_ResearchTeaser> items;
  final VoidCallback onAll;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const Key('home-research-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(
          title: 'أحدث البحوث',
          actionLabel: 'مكتبة البحوث',
          onAction: onAll,
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          _PaperCard(
            onTap: onAll,
            child: Text(
              'تظهر البحوث هنا بعد اكتمال المراجعة التخصصية واعتماد النشر.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PalEyesTokens.textMuted(context),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              const gap = 14.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: width,
                        child: _PaperCard(
                          onTap: () => onOpen(item.site.slug),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: PalEyesTokens.green100,
                                  borderRadius: BorderRadius.circular(
                                    PalEyesTokens.radiusSmall,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_book_outlined,
                                  color: PalEyesTokens.green700,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _Pill(label: item.statusLabel),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.site.nameAr,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: PalEyesTokens.text(context),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      <String>[
                                        item.site.governorateAr,
                                        item.site.siteTypeAr,
                                      ].where((v) => v.isNotEmpty).join(' • '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: PalEyesTokens.textMuted(
                                              context,
                                            ),
                                          ),
                                    ),
                                  ],
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
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stories strip (existing approved story imagery)
// ---------------------------------------------------------------------------

class _StoryStrip extends StatelessWidget {
  const _StoryStrip({required this.onStories, required this.onAbout});

  final VoidCallback onStories;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final cards = ApprovedReferenceDesign.storyAssets
        .map(
          (asset) => _HoverLift(
            child: Material(
              color: PalEyesTokens.green900,
              borderRadius: BorderRadius.circular(PalEyesTokens.radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onStories,
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
        final heading = Text(
          'قصص من المكان',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: PalEyesTokens.text(context),
          ),
        );
        if (constraints.maxWidth < 920) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              heading,
              const SizedBox(height: 12),
              SizedBox(
                height: 145,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: heading),
                TextButton.icon(
                  onPressed: onStories,
                  style: TextButton.styleFrom(
                    foregroundColor: PalEyesTokens.accentText(context),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('كل الحكايات'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 136,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (
                    var index = 0;
                    index < cards.length;
                    index++
                  ) ...<Widget>[
                    if (index > 0) const SizedBox(width: 12),
                    Expanded(child: cards[index]),
                  ],
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _MemoryCta(onTap: onAbout)),
                ],
              ),
            ),
          ],
        );
      },
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
      child: Material(
        color: PalEyesTokens.cream,
        borderRadius: BorderRadius.circular(PalEyesTokens.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Image.asset(
            ApprovedReferenceDesign.memoryCta,
            fit: BoxFit.cover,
            height: 136,
            width: double.infinity,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Timeline band
// ---------------------------------------------------------------------------

class _TimelineBand extends StatelessWidget {
  const _TimelineBand({
    required this.activeEra,
    required this.horizontal,
    required this.onEra,
    required this.onTimeline,
  });

  final int activeEra;
  final double horizontal;
  final ValueChanged<int> onEra;
  final VoidCallback onTimeline;

  static const List<String> _eras = <String>[
    'القديم',
    'الروماني',
    'البيزنطي',
    'الإسلامي المبكر',
    'المملوكي',
    'العثماني',
    'الانتداب',
    'المعاصر',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 760;
    return Container(
      key: const Key('home-timeline-band'),
      decoration: const BoxDecoration(
        gradient: PalEyesTokens.structureGradient,
      ),
      padding: EdgeInsets.fromLTRB(horizontal, 30, horizontal, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PalEyesTokens.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                spacing: 12,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'رحلة عبر الزمن',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: PalEyesTokens.inkOnDark,
                        ),
                      ),
                      Text(
                        'تعرّف على المراحل التاريخية التي شكّلت فلسطين عبر العصور.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: PalEyesTokens.inkOnDarkMuted,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: onTimeline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PalEyesTokens.goldSoft,
                      side: const BorderSide(color: PalEyesTokens.gold),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('استكشف الخط الزمني'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _eras.length,
                  separatorBuilder: (_, _) => Center(
                    child: Container(
                      width: narrow ? 18 : 34,
                      height: 1,
                      color: PalEyesTokens.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final selected = index == activeEra;
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: 'العصر ${_eras[index]}',
                      excludeSemantics: true,
                      child: InkWell(
                        onTap: () => onEra(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: selected ? 18 : 12,
                                height: selected ? 18 : 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? PalEyesTokens.gold
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: PalEyesTokens.gold,
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _eras[index],
                                style: TextStyle(
                                  color: selected
                                      ? PalEyesTokens.goldSoft
                                      : PalEyesTokens.inkOnDark,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------

class _HomeFooter extends StatelessWidget {
  const _HomeFooter({required this.horizontal});

  final double horizontal;

  @override
  Widget build(BuildContext context) {
    final links = <(String, String)>[
      ('المنهجية', RoutePaths.methodology),
      ('المصادر', RoutePaths.sources),
      ('ساهم في الذاكرة', RoutePaths.contribute),
      ('المحافظات', RoutePaths.governorates),
    ];
    return Container(
      color: PalEyesTokens.green950,
      padding: EdgeInsets.fromLTRB(horizontal, 22, horizontal, 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PalEyesTokens.maxContentWidth,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: <Widget>[
              const PalEyesBrandMark(foregroundColor: PalEyesTokens.inkOnDark),
              Wrap(
                spacing: 4,
                children: links
                    .map(
                      (link) => TextButton(
                        onPressed: () => context.go(link.$2),
                        style: TextButton.styleFrom(
                          foregroundColor: PalEyesTokens.inkOnDarkMuted,
                        ),
                        child: Text(link.$1),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
          boxShadow: PalEyesTokens.softShadow(strength: _hovered ? 2 : 0.6),
        ),
        child: widget.child,
      ),
    );
  }
}
