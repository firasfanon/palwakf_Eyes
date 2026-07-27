import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/draft_content_banner.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/places/presentation/widgets/site_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _timelineIndex = 5;

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(foundationSitesProvider);
    final featured = ref.watch(featuredSitesProvider);
    final mapped = ref.watch(mappedSitesProvider);
    final expanded = ref.watch(expandedNarrativeSitesProvider);
    final siteOfTheDay = expanded.isNotEmpty ? expanded.first : sites.first;
    final horizontal = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _OpeningHero(
            mappedCount: mapped.length,
            onDiscover: () => context.go(RoutePaths.discover),
            onMap: () => context.go(RoutePaths.map),
            onGovernorates: () => context.go(RoutePaths.governorates),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 34, horizontal, 72),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _ProductGatewaysSection(),
                    const SizedBox(height: 42),
                    _MapGateway(
                      mappedCount: mapped.length,
                      onMap: () => context.go(RoutePaths.map),
                      onGovernorates: () => context.go(RoutePaths.governorates),
                    ),
                    const SizedBox(height: 58),
                    PalEyesSectionHeader(
                      key: const Key('home-stories-section'),
                      eyebrow: 'قصص من المكان',
                      icon: Icons.auto_stories_outlined,
                      title: 'اقرأ فلسطين كقصة متصلة، لا كقائمة مواقع',
                      subtitle:
                          'مسارات تحريرية تجمع الماء والعمران والذاكرة والطبقات التاريخية في رواية بصرية مرتبطة بالمكان.',
                      actionLabel: 'جميع القصص',
                      onAction: () => context.go(RoutePaths.stories),
                    ),
                    const SizedBox(height: 20),
                    _EditorialStories(
                      onStory: () => context.go(RoutePaths.stories),
                    ),
                    const SizedBox(height: 58),
                    const PalEyesSectionHeader(
                      eyebrow: 'اختر مدخلك',
                      icon: Icons.category_outlined,
                      title: 'استكشف حسب نوع الذاكرة والمكان',
                      subtitle:
                          'من المدن القديمة إلى المياه التاريخية والذاكرة الشفوية؛ كل فئة تفتح مساراً مختلفاً داخل الكتالوج.',
                    ),
                    const SizedBox(height: 20),
                    _CategoryGrid(
                      onOpen: () => context.go(RoutePaths.discover),
                    ),
                    const SizedBox(height: 58),
                    PalEyesSectionHeader(
                      eyebrow: 'الزمن الفلسطيني',
                      icon: Icons.timeline_outlined,
                      title: 'طبقات تاريخية تتقاطع فوق المكان نفسه',
                      subtitle:
                          'اختر فترة لتتغير زاوية القراءة، مع إبقاء الانتقال بين العصور ظاهراً بدلاً من اختزال الموقع في حقبة واحدة.',
                      actionLabel: 'الخط الزمني الكامل',
                      onAction: () => context.go(RoutePaths.timeline),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                        child: Column(
                          children: <Widget>[
                            PalEyesTimelineBand(
                              periods: const <String>[
                                'الكنعاني',
                                'الروماني',
                                'البيزنطي',
                                'الإسلامي المبكر',
                                'المملوكي',
                                'العثماني',
                                'الانتداب البريطاني',
                                'الفلسطيني المعاصر',
                              ],
                              selectedIndex: _timelineIndex,
                              onSelected: (index) => setState(() {
                                _timelineIndex = index;
                              }),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.layers_outlined,
                                    color: AppColors.heritageGold,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _timelineDescription(_timelineIndex),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 58),
                    PalEyesSectionHeader(
                      eyebrow: 'موقع اليوم',
                      icon: Icons.place_outlined,
                      title: 'اقترب من موقع واحد بكل طبقاته',
                      subtitle:
                          'صفحة الموقع تجمع الملخص والرواية والمصادر والفترة وحالة التوثيق في تجربة قراءة واحدة.',
                      actionLabel: 'جميع المواقع',
                      onAction: () => context.go(RoutePaths.places),
                    ),
                    const SizedBox(height: 20),
                    _SiteOfTheDay(site: siteOfTheDay),
                    const SizedBox(height: 58),
                    const PalEyesSectionHeader(
                      key: Key('home-evidence-section'),
                      eyebrow: 'المصدر خلف الرواية',
                      icon: Icons.fact_check_outlined,
                      title: 'كل رواية تبدأ من دليل، وتنتهي بمراجعة بشرية',
                      subtitle:
                          'نعرض للزائر المسار المبسط من اكتشاف المصدر إلى ربط الادعاء ومراجعة الحقوق ثم الاعتماد.',
                    ),
                    const SizedBox(height: 20),
                    _EvidenceJourney(
                      onMethodology: () => context.go(RoutePaths.methodology),
                      onSources: () => context.go(RoutePaths.sources),
                    ),
                    const SizedBox(height: 58),
                    _OralMemorySection(
                      onStories: () => context.go(RoutePaths.stories),
                    ),
                    const SizedBox(height: 58),
                    _ContributionSection(
                      onContribute: () => context.go(RoutePaths.contribute),
                    ),
                    if (featured.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 58),
                      PalEyesSectionHeader(
                        eyebrow: 'مختارات الكتالوج',
                        icon: Icons.bookmarks_outlined,
                        title: 'مواقع تستحق قراءة أعمق',
                        subtitle:
                            'مجموعة مختارة من الكتالوج الكامل، مع إبقاء حالة كل مادة ومصادرها وفجواتها واضحة.',
                        actionLabel: 'استكشف 79 موقعاً',
                        onAction: () => context.go(RoutePaths.places),
                      ),
                      const SizedBox(height: 20),
                      _FeaturedGrid(sites: featured.take(6).toList()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _timelineDescription(int index) {
    return const <String>[
      'قراءة البدايات العمرانية والزراعية المبكرة وربطها بالمشهد الطبيعي.',
      'تتبع الطرق والمدن والمنشآت التي أعادت تشكيل الجغرافيا المحلية.',
      'قراءة الأديرة والكنائس والتحولات العمرانية في المراكز الفلسطينية.',
      'تحولات المكان مع الفتح الإسلامي ونشوء أنماط عمرانية وروحية جديدة.',
      'شبكات الطرق والخانات والمقامات والمياه في المشهد المملوكي.',
      'السجلات والطابو والأوقاف والعمران المحلي في الفترة العثمانية.',
      'التحولات الإدارية والعمرانية والخرائط خلال الانتداب البريطاني.',
      'الذاكرة الحية، التحولات المعاصرة، والحاجة إلى توثيق ما يزال قائماً.',
    ][index];
  }
}

class _OpeningHero extends StatelessWidget {
  const _OpeningHero({
    required this.mappedCount,
    required this.onDiscover,
    required this.onMap,
    required this.onGovernorates,
  });

  final int mappedCount;
  final VoidCallback onDiscover;
  final VoidCallback onMap;
  final VoidCallback onGovernorates;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final horizontal = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.sovereignGradient),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: PalEyesPattern(opacity: 0.045)),
          PositionedDirectional(
            start: -120,
            bottom: -150,
            child: Container(
              width: 370,
              height: 370,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.olive.withValues(alpha: 0.14),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  compact ? 34 : 64,
                  horizontal,
                  compact ? 44 : 70,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final copy = _HeroCopy(
                      onDiscover: onDiscover,
                      onMap: onMap,
                      onGovernorates: onGovernorates,
                    );
                    final visual = _HeroVisual(mappedCount: mappedCount);
                    if (constraints.maxWidth >= 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(flex: 6, child: copy),
                          const SizedBox(width: 42),
                          Expanded(flex: 4, child: visual),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        copy,
                        const SizedBox(height: 34),
                        visual,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.onDiscover,
    required this.onMap,
    required this.onGovernorates,
  });

  final VoidCallback onDiscover;
  final VoidCallback onMap;
  final VoidCallback onGovernorates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const DraftContentBanner(
          key: Key('home-governed-draft-banner'),
          title: 'مسودة خاضعة للتدقيق',
          message:
              'كل موقع ورواية ومصدر ظاهر في هذه النسخة مادة تطويرية تحتاج مراجعة تاريخية وببليوغرافية وحقوقية.',
        ),
        const SizedBox(height: 26),
        Text(
          'فلسطين تُروى من المكان',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'المكان الفلسطيني كما ترويه الوثيقة والدليل والخريطة والذاكرة الشفوية.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.62,
          ),
        ),
        const SizedBox(height: 24),
        PalEyesGlassPanel(
          padding: const EdgeInsets.all(8),
          child: TextField(
            readOnly: true,
            onTap: onDiscover,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: false,
              hintText: 'ابحث عن موقع، مدينة، قرية، حقبة أو مصدر…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.softGold,
              ),
              suffixIcon: IconButton(
                tooltip: 'ابدأ الاستكشاف',
                onPressed: onDiscover,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            FilledButton.icon(
              onPressed: onDiscover,
              icon: const Icon(Icons.explore_rounded),
              label: const Text('استكشف المواقع'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.38)),
              ),
              onPressed: onMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('افتح الخريطة'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: onGovernorates,
              icon: const Icon(Icons.location_city_outlined),
              label: const Text('المحافظات'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.mappedCount});

  final int mappedCount;

  @override
  Widget build(BuildContext context) {
    return PalEyesGlassPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 330,
                  child: const PalestineMapArtwork(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: <Widget>[
                    _HeroStat(
                      value: '${ContentCatalogMetrics.extractedSiteCount}',
                      label: 'موقعاً',
                    ),
                    const SizedBox(height: 10),
                    const _HeroStat(
                      value: '${ContentCatalogMetrics.governedDraftPageCount}',
                      label: 'صفحة محكومة',
                    ),
                    const SizedBox(height: 10),
                    const _HeroStat(
                      value:
                          '${ContentCatalogMetrics.reviewedEditorialRecordCount}',
                      label: 'مادة مراجعة',
                    ),
                    const SizedBox(height: 10),
                    _HeroStat(value: '$mappedCount', label: 'مواضع عامة'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGateway extends StatelessWidget {
  const _MapGateway({
    required this.mappedCount,
    required this.onMap,
    required this.onGovernorates,
  });

  final int mappedCount;
  final VoidCallback onMap;
  final VoidCallback onGovernorates;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[Color(0xFFEEE5D4), Color(0xFFD9C59C)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const PalEyesPattern(
                color: AppColors.sovereignBlue,
                opacity: 0.045,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final text = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const PalEyesSectionHeader(
                      eyebrow: 'الخريطة بوابة السرد',
                      icon: Icons.map_outlined,
                      title: 'ادخل فلسطين من جغرافيتها',
                      subtitle:
                          'اختر محافظة أو موقعاً، ثم انتقل من النقطة على الخريطة إلى الرواية والمصدر والفترة التاريخية.',
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        Chip(
                          avatar: const Icon(Icons.location_on_outlined),
                          label: Text('$mappedCount مواضع مدققة'),
                        ),
                        const Chip(
                          avatar: Icon(Icons.location_off_outlined),
                          label: Text('76 فجوة إحداثيات معلنة'),
                        ),
                        const Chip(
                          avatar: Icon(Icons.location_city_outlined),
                          label: Text('16 محافظة'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: onMap,
                          icon: const Icon(Icons.travel_explore_rounded),
                          label: const Text('استكشف الخريطة'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onGovernorates,
                          icon: const Icon(Icons.location_city_outlined),
                          label: const Text('تصفح المحافظات'),
                        ),
                      ],
                    ),
                  ],
                );
                final map = const SizedBox(
                  height: 320,
                  child: PalestineMapArtwork(
                    foregroundColor: AppColors.sovereignBlue,
                  ),
                );
                if (constraints.maxWidth >= 840) {
                  return Row(
                    children: <Widget>[
                      Expanded(flex: 6, child: text),
                      const SizedBox(width: 30),
                      Expanded(flex: 4, child: map),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[text, const SizedBox(height: 24), map],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialStories extends StatelessWidget {
  const _EditorialStories({required this.onStory});

  final VoidCallback onStory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lead = PalEyesVisualCard(
          icon: Icons.water_drop_outlined,
          label: 'قصة رئيسية',
          title: 'الماء والطريق إلى القدس',
          description:
              'من الينابيع والقنوات إلى برك سليمان: شبكة مائية تكشف كيف صاغت الجغرافيا طرق الحج والعمران والحياة اليومية.',
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[Color(0xFF123B5D), Color(0xFF2F6E7E)],
          ),
          dark: true,
          onTap: onStory,
          footer: const Row(
            children: <Widget>[
              Icon(Icons.place_outlined, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text(
                'برك سليمان • أرطاس • القدس',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
        final secondary = Column(
          children: <Widget>[
            Expanded(
              child: PalEyesVisualCard(
                icon: Icons.layers_outlined,
                label: 'طبقات',
                title: 'مدن فوق مدن',
                description:
                    'سبسطية وتل السلطان وغزة القديمة بوصفها أمكنة تتراكم فيها الحضارات ولا تلغي إحداها الأخرى.',
                gradient: AppColors.earthGradient,
                dark: true,
                onTap: onStory,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PalEyesVisualCard(
                icon: Icons.record_voice_over_outlined,
                label: 'ذاكرة حية',
                title: 'ما يقوله أهل المكان',
                description:
                    'روايات شفوية وصور عائلية وأسماء محلية تحفظ ما لا تقوله الخرائط وحدها.',
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.dusk, Color(0xFF3E334A)],
                ),
                dark: true,
                onTap: onStory,
              ),
            ),
          ],
        );
        if (constraints.maxWidth >= 860) {
          return SizedBox(
            height: 480,
            child: Row(
              children: <Widget>[
                Expanded(flex: 6, child: lead),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: secondary),
              ],
            ),
          );
        }
        return Column(
          children: <Widget>[
            SizedBox(height: 360, child: lead),
            const SizedBox(height: 16),
            SizedBox(height: 450, child: secondary),
          ],
        );
      },
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    const categories = <(IconData, String, String, String)>[
      (
        Icons.location_city_outlined,
        'المدن والبلدات',
        'النسيج العمراني والأسواق والبيوت والذاكرة المحلية.',
        'عمران',
      ),
      (
        Icons.account_balance_outlined,
        'المواقع الأثرية',
        'تلال وقصور وقلاع وطبقات مادية متعاقبة.',
        'آثار',
      ),
      (
        Icons.mosque_outlined,
        'المساجد والمقامات',
        'المكان الديني وعلاقته بالطرق والأوقاف والمجتمع.',
        'تراث ديني',
      ),
      (
        Icons.church_outlined,
        'الكنائس والأديرة',
        'عمارة دينية وطرق حج وذاكرة مسيحية فلسطينية.',
        'تراث ديني',
      ),
      (
        Icons.water_drop_outlined,
        'المياه والطرق',
        'عيون وبرك وقنوات وخانات ومسارات تاريخية.',
        'بنية مكانية',
      ),
      (
        Icons.record_voice_over_outlined,
        'الذاكرة الشفوية',
        'شهادات وأسماء وحكايات تحتاج موافقة وتفريغاً ومراجعة.',
        'ذاكرة حية',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 640
            ? 2
            : 1;
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: categories
              .map(
                (item) => SizedBox(
                  width: width,
                  height: 245,
                  child: PalEyesVisualCard(
                    icon: item.$1,
                    title: item.$2,
                    description: item.$3,
                    label: item.$4,
                    onTap: onOpen,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _SiteOfTheDay extends StatelessWidget {
  const _SiteOfTheDay({required this.site});

  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.sovereignGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: PalEyesPattern(opacity: 0.045),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final visual = Container(
                  height: 310,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: <Color>[Color(0xFFD7C4A0), Color(0xFF8E7854)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: <Widget>[
                      const Positioned.fill(
                        child: PalEyesPattern(
                          color: AppColors.sovereignBlue,
                          opacity: 0.08,
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.account_balance_rounded,
                          size: 108,
                          color: AppColors.sovereignBlue.withValues(
                            alpha: 0.74,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sovereignBlue,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            site.governorateAr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      site.nameAr,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${site.localityAr} • ${site.siteTypeAr}',
                      style: const TextStyle(
                        color: AppColors.softGold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      site.summaryDraft,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ...site.periods
                            .take(3)
                            .map(
                              (period) => Chip(
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                label: Text(period),
                              ),
                            ),
                        Chip(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          labelStyle: const TextStyle(color: Colors.white),
                          label: Text('${site.sourceMentionCount} مصادر'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.go(RoutePaths.place(site.slug)),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('اقرأ الرواية الفلسطينية'),
                    ),
                  ],
                );
                if (constraints.maxWidth >= 820) {
                  return Row(
                    children: <Widget>[
                      Expanded(flex: 5, child: copy),
                      const SizedBox(width: 28),
                      Expanded(flex: 5, child: visual),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[visual, const SizedBox(height: 24), copy],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceJourney extends StatelessWidget {
  const _EvidenceJourney({
    required this.onMethodology,
    required this.onSources,
  });

  final VoidCallback onMethodology;
  final VoidCallback onSources;

  @override
  Widget build(BuildContext context) {
    const steps = <(IconData, String, String)>[
      (Icons.place_outlined, 'المكان', 'تحديد السجل والاسم والسياق الجغرافي.'),
      (
        Icons.auto_stories_outlined,
        'الرواية',
        'صياغة مسودة تفصل الدليل عن التفسير.',
      ),
      (
        Icons.library_books_outlined,
        'المصدر',
        'ربط الادعاءات بالمرجع والصفحة أو المقطع.',
      ),
      (
        Icons.verified_outlined,
        'المراجعة',
        'تدقيق تاريخي وتحريري وحقوقي بقرار بشري.',
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 820 ? 4 : 2;
                const gap = 14.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: steps
                      .asMap()
                      .entries
                      .map(
                        (entry) => SizedBox(
                          width: width,
                          child: _JourneyStep(
                            number: entry.key + 1,
                            icon: entry.value.$1,
                            title: entry.value.$2,
                            description: entry.value.$3,
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: onMethodology,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('كيف نوثق المواقع؟'),
                ),
                OutlinedButton.icon(
                  onPressed: onSources,
                  icon: const Icon(Icons.library_books_outlined),
                  label: const Text('افتح سجل المصادر'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final int number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                child: Text(
                  '$number',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const Spacer(),
              Icon(icon, color: AppColors.heritageGold),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(description),
        ],
      ),
    );
  }
}

class _OralMemorySection extends StatelessWidget {
  const _OralMemorySection({required this.onStories});

  final VoidCallback onStories;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[Color(0xFF30283A), Color(0xFF111E2B)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: PalEyesPattern(opacity: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.softGold,
                      size: 42,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '«كان الطريق القديم يمر من هنا…»',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الذاكرة الشفوية تعيد الأسماء والحكايات والعلاقات الاجتماعية إلى المكان، لكنها لا تعتمد قبل موافقة الراوي والتفريغ والمراجعة.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: <Widget>[
                        Icon(
                          Icons.pending_actions_outlined,
                          color: AppColors.softGold,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'مادة قيد التفريغ والمراجعة',
                          style: TextStyle(
                            color: AppColors.softGold,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white24),
                      ),
                      onPressed: onStories,
                      icon: const Icon(Icons.headphones_outlined),
                      label: const Text('استكشف الذاكرة الشفوية'),
                    ),
                  ],
                );
                final waveform = const _WaveformArtwork();
                if (constraints.maxWidth >= 820) {
                  return Row(
                    children: <Widget>[
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 28),
                      Expanded(flex: 4, child: waveform),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    copy,
                    const SizedBox(height: 26),
                    waveform,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformArtwork extends StatelessWidget {
  const _WaveformArtwork();

  @override
  Widget build(BuildContext context) {
    const heights = <double>[
      24,
      56,
      86,
      42,
      112,
      68,
      132,
      48,
      96,
      62,
      120,
      40,
      78,
      52,
      106,
      32,
    ];
    return SizedBox(
      height: 210,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: heights
              .map(
                (height) => Container(
                  width: 7,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.heritageGradient,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _ContributionSection extends StatelessWidget {
  const _ContributionSection({required this.onContribute});

  final VoidCallback onContribute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'المعرفة الفلسطينية لا تكتمل من دون أهل المكان',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'أضف وثيقة أو صورة، صحح اسماً، اقترح موقعاً، أو شارك رواية شفوية. تحفظ كل مساهمة كمسودة قبل المراجعة.',
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const <Widget>[
                  Chip(
                    avatar: Icon(Icons.description_outlined),
                    label: Text('وثيقة أو مصدر'),
                  ),
                  Chip(
                    avatar: Icon(Icons.photo_outlined),
                    label: Text('صورة تاريخية'),
                  ),
                  Chip(
                    avatar: Icon(Icons.edit_location_alt_outlined),
                    label: Text('تصحيح موقع أو اسم'),
                  ),
                  Chip(
                    avatar: Icon(Icons.record_voice_over_outlined),
                    label: Text('رواية شفوية'),
                  ),
                ],
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onContribute,
            icon: const Icon(Icons.volunteer_activism_outlined),
            label: const Text('ابدأ مساهمة'),
          );
          if (constraints.maxWidth >= 800) {
            return Row(
              children: <Widget>[
                Expanded(child: copy),
                const SizedBox(width: 28),
                action,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[copy, const SizedBox(height: 22), action],
          );
        },
      ),
    );
  }
}

class _ProductGatewaysSection extends StatelessWidget {
  const _ProductGatewaysSection();

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData, String)>[
      (
        'الأماكن',
        'المواقع التاريخية والأثرية',
        Icons.account_balance_outlined,
        RoutePaths.places,
      ),
      ('الخريطة', 'استكشاف المكان بصرياً', Icons.map_outlined, RoutePaths.map),
      (
        'الخط الزمني',
        'تصفح فلسطين عبر الحقب',
        Icons.timeline_outlined,
        RoutePaths.timeline,
      ),
      (
        'القصص والذاكرة',
        'سرد موضوعي وذاكرة شفوية',
        Icons.auto_stories_outlined,
        RoutePaths.stories,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PalEyesSectionHeader(
          eyebrow: 'بوابات الاستكشاف',
          icon: Icons.explore_outlined,
          title: 'ابدأ من المكان أو الخريطة أو الزمن أو القصة',
          subtitle:
              'أربع بوابات واضحة تقود إلى المحتوى دون إغراق الصفحة بالأرقام الداخلية.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 900
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 560
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items
                  .map((item) {
                    return SizedBox(
                      width: width,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.go(item.$4),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(child: Icon(item.$3)),
                                const SizedBox(height: 14),
                                Text(
                                  item.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(item.$2),
                                const SizedBox(height: 12),
                                const Row(
                                  children: <Widget>[
                                    Text(
                                      'استكشف',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_back_rounded),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid({required this.sites});

  final List<HeritageSite> sites;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1020
            ? 3
            : constraints.maxWidth >= 660
            ? 2
            : 1;
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: sites
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
    );
  }
}
