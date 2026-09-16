import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';
import 'package:pal_eyes/core/widgets/content_status_badge.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/application/original_draft_visibility_policy.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/places/domain/historical_content.dart';
import 'package:pal_eyes/features/research/application/staging_research_corpus_provider.dart';
import 'package:pal_eyes/features/research/presentation/staging_research_package_card.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({required this.slug, super.key});
  final String slug;
  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final presentationMode = ref.watch(palEyesPresentationModeProvider);
    final site = ref.watch(heritageSiteBySlugProvider(widget.slug));
    if (site == null) {
      return const PalEyesPage(
        title: 'الموقع غير موجود',
        subtitle: 'لم يُعثر على سجل مطابق.',
        child: Center(child: Icon(Icons.location_off_outlined, size: 72)),
      );
    }

    if (presentationMode.isPublic) {
      return _PublicPlaceExperience(
        site: site,
        selected: _section,
        onSelected: (value) => setState(() => _section = value),
      );
    }

    return PalEyesPage(
      title: site.nameAr,
      icon: Icons.account_balance_outlined,
      eyebrow: site.pageCategory.labelAr,
      subtitle: <String>[
        site.nameEn,
        site.localityAr,
        site.governorateAr,
      ].where((value) => value.isNotEmpty).join(' • '),
      maxWidth: 1320,
      actions: <Widget>[
        IconButton.filledTonal(
          tooltip: site.hasPublicCoordinates
              ? 'فتح الموقع العام على الخريطة'
              : site.coordinateStatusAr,
          onPressed: site.hasPublicCoordinates
              ? () => context.go('${RoutePaths.map}?site=${site.slug}')
              : () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${site.coordinateStatusAr}. العرض العام محجوب حتى الاعتماد الجغرافي.',
                    ),
                  ),
                ),
          icon: Icon(
            site.hasPublicCoordinates
                ? Icons.map_outlined
                : Icons.location_off_outlined,
          ),
        ),
      ],
      header: PalEyesPublicDisclosure(
        summary: site.hasOriginalHistoricalDraft
            ? 'هذه الصفحة قيد الإعداد، وتفصل بين النص المحرر والمسودة التاريخية الأصلية.'
            : 'هذه بطاقة تعريف أولية، وتُستكمل قصتها ومراجعها مع تقدم البحث.',
        details: <String>[
          'الإحداثيات العامة: ${site.hasPublicCoordinates ? 'متاحة' : 'تنتظر الاعتماد'}.',
          'المراجع المرتبطة: ${site.sources.length}.',
          'الوسائط المعتمدة: ${site.approvedMediaCount}.',
        ],
        actionLabel: 'كيف نوثّق صفحات المواقع؟',
        onAction: () => context.go(RoutePaths.methodology),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PlaceHero(site: site),
          const SizedBox(height: 18),
          _PlaceMetrics(site: site),
          const SizedBox(height: 22),
          _DetailNavigation(
            selected: _section,
            onSelected: (value) => setState(() => _section = value),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_section) {
              0 => _OverviewSection(site: site),
              1 => _NarrativeSection(site: site),
              2 => _OriginalHistoricalDraftSection(site: site),
              3 => _SourcesSection(site: site),
              4 => _ResearchSection(site: site),
              _ => _MediaRightsSection(site: site),
            },
          ),
          const SizedBox(height: 24),
          PalEyesQuickPathBar(
            title: 'تابع من هذا الموقع',
            actions: <PublicJourneyAction>[
              PublicJourneyAction(
                label: 'مكتبة المصادر',
                icon: Icons.library_books_outlined,
                onPressed: () => context.go(RoutePaths.sources),
              ),
              PublicJourneyAction(
                label: 'القصص',
                icon: Icons.auto_stories_outlined,
                onPressed: () => context.go(RoutePaths.stories),
              ),
              PublicJourneyAction(
                label: 'منهجية التوثيق',
                icon: Icons.fact_check_outlined,
                onPressed: () => context.go(RoutePaths.methodology),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublicPlaceExperience extends ConsumerWidget {
  const _PublicPlaceExperience({
    required this.site,
    required this.selected,
    required this.onSelected,
  });

  final HeritageSite site;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(stagingResearchPackageBySiteIdProvider(site.id));
    final showResearchPreview = package != null;
    final horizontal = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _PublicPlaceHero(site: site)),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _PublicPlaceMetrics(site: site),
                    const SizedBox(height: 22),
                    _PublicDetailNavigation(
                      selected: selected,
                      onSelected: onSelected,
                      showResearchPreview: showResearchPreview,
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: switch (selected) {
                        0 => _PublicOverviewSection(site: site),
                        1 => _PublicNarrativeSection(site: site),
                        2 => _PublicTimelineSection(site: site),
                        3 => _PublicMediaSection(site: site),
                        4 => _PublicMapSection(site: site),
                        5 => _PublicSourcesSection(site: site),
                        6 when showResearchPreview =>
                          _PublicResearchPreviewSection(site: site),
                        _ => _PublicAboutMaterialSection(site: site),
                      },
                    ),
                    const SizedBox(height: 28),
                    PalEyesQuickPathBar(
                      title: 'واصل الاستكشاف',
                      actions: <PublicJourneyAction>[
                        PublicJourneyAction(
                          label: 'الأطلس',
                          icon: Icons.account_balance_outlined,
                          onPressed: () => context.go(RoutePaths.places),
                        ),
                        PublicJourneyAction(
                          label: 'عبر الزمن',
                          icon: Icons.timeline_outlined,
                          onPressed: () => context.go(RoutePaths.timeline),
                        ),
                        PublicJourneyAction(
                          label: 'الحكايات',
                          icon: Icons.auto_stories_outlined,
                          onPressed: () => context.go(RoutePaths.stories),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicPlaceHero extends StatelessWidget {
  const _PublicPlaceHero({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final period = site.periods.isEmpty
        ? 'تاريخ المكان'
        : site.periods.take(2).join(' • ');
    return PalEyesHeritageScene(
      height: MediaQuery.sizeOf(context).width < 720 ? 420 : 520,
      title: site.nameAr,
      eyebrow: site.siteTypeAr,
      subtitle: '${site.localityAr} • ${site.governorateAr} • $period',
    );
  }
}

class _PublicPlaceMetrics extends StatelessWidget {
  const _PublicPlaceMetrics({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final period = site.periods.isEmpty ? 'غير محدد' : site.periods.first;
    final metrics = <(IconData, String, String)>[
      (Icons.location_city_outlined, 'المحافظة', site.governorateAr),
      (Icons.account_balance_outlined, 'نوع المكان', site.siteTypeAr),
      (Icons.timeline_outlined, 'الفترة', period),
      (Icons.library_books_outlined, 'المصادر', '${site.sources.length}'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (item) => SizedBox(
                  width: width,
                  child: PalEyesParchmentPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    radius: 16,
                    child: Row(
                      children: <Widget>[
                        Icon(item.$1, color: PalEyesVisualV1.olive, size: 21),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  color: PalEyesVisualV1.warmMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.$3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
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
    );
  }
}

class _PublicDetailNavigation extends StatelessWidget {
  const _PublicDetailNavigation({
    required this.selected,
    required this.onSelected,
    required this.showResearchPreview,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  final bool showResearchPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PalEyesVisualV1.warmLine)),
      ),
      child: PalEyesTabStripV1(
        selectedIndex: selected.clamp(0, showResearchPreview ? 7 : 6),
        onSelected: onSelected,
        labels: <String>[
          'نبذة',
          'الحكاية',
          'عبر الزمن',
          'الصور',
          'الخريطة',
          'المصادر',
          if (showResearchPreview) 'البحث',
          'عن هذه المادة',
        ],
      ),
    );
  }
}

class _PublicOverviewSection extends StatelessWidget {
  const _PublicOverviewSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final periods = site.periods.isEmpty
        ? 'غير محدد'
        : site.periods.take(3).join(' • ');
    return Column(
      key: const ValueKey<String>('public-overview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final story = PalEyesParchmentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const PalEyesSectionTitleV1(
                    title: 'عن المكان',
                    subtitle:
                        'مدخل سريع إلى الموقع قبل الغوص في قصته وطبقاته التاريخية.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    site.summaryDraft,
                    style: const TextStyle(height: 1.9, fontSize: 17),
                  ),
                  if (site.isLimitedResearch) ...<Widget>[
                    const SizedBox(height: 16),
                    const _PublicInfoNote(
                      icon: Icons.info_outline_rounded,
                      text:
                          'المعلومات المتاحة عن هذا المكان محدودة حاليًا؛ نعرض ما نعرفه من دون ملء الفراغات بالتخمين.',
                    ),
                  ],
                ],
              ),
            );
            final facts = PalEyesParchmentPanel(
              color: PalEyesVisualV1.parchmentDeep.withValues(alpha: 0.48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'في لمحة',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  PalEyesFactRowV1(
                    icon: Icons.place_outlined,
                    label: 'المحلية',
                    value: site.localityAr,
                  ),
                  PalEyesFactRowV1(
                    icon: Icons.location_city_outlined,
                    label: 'المحافظة',
                    value: site.governorateAr,
                  ),
                  PalEyesFactRowV1(
                    icon: Icons.account_balance_outlined,
                    label: 'الفئة',
                    value: site.siteTypeAr,
                  ),
                  PalEyesFactRowV1(
                    icon: Icons.timeline_outlined,
                    label: 'الفترات',
                    value: periods,
                  ),
                ],
              ),
            );
            if (constraints.maxWidth >= 820) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 7, child: story),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: facts),
                ],
              );
            }
            return Column(
              children: <Widget>[story, const SizedBox(height: 14), facts],
            );
          },
        ),
        if (site.oralHistoryCount > 0) ...<Widget>[
          const SizedBox(height: 18),
          PalEyesParchmentPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.record_voice_over_outlined,
                  color: PalEyesVisualV1.olive,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ترتبط بالمكان ${site.oralHistoryCount} مادة من الذاكرة الشفوية. ستظهر الحكايات القابلة للعرض هنا عند تجهيزها.',
                    style: const TextStyle(height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PublicNarrativeSection extends StatelessWidget {
  const _PublicNarrativeSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    if (site.narrativeSections.isEmpty) {
      return const PalEyesParchmentPanel(
        key: ValueKey<String>('public-narrative-empty'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PalEyesSectionTitleV1(
              title: 'حكاية المكان ما زالت قصيرة',
              subtitle:
                  'لا تتوفر بعد مادة موثقة كافية لعرض قصة تاريخية تفصيلية.',
            ),
            SizedBox(height: 14),
            Text(
              'نحتفظ بالصفحة مفتوحة للاكتشاف، ونضيف الحكاية عندما تتوفر مادة قابلة للتوثيق والعرض.',
              style: TextStyle(height: 1.8),
            ),
          ],
        ),
      );
    }
    return Column(
      key: const ValueKey<String>('public-narrative'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PalEyesSectionTitleV1(
          title: 'حكاية المكان',
          subtitle:
              'اقرأ القصة على شكل فصول قصيرة، ثم انتقل إلى المصادر إذا أردت التعمق.',
        ),
        const SizedBox(height: 14),
        ...site.narrativeSections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PalEyesParchmentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    section.draftText,
                    style: const TextStyle(height: 1.9, fontSize: 16),
                  ),
                  if (section.sourceIds.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      'مرتبط بـ ${section.sourceIds.length} ${section.sourceIds.length == 1 ? 'مصدر' : 'مصادر'}',
                      style: const TextStyle(
                        color: PalEyesVisualV1.warmMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicTimelineSection extends StatelessWidget {
  const _PublicTimelineSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    if (site.timeline.isEmpty) {
      return PalEyesParchmentPanel(
        key: const ValueKey<String>('public-timeline-empty'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const PalEyesSectionTitleV1(
              title: 'عبر الزمن',
              subtitle: 'لم تُجهز بعد محطات زمنية تفصيلية لهذا المكان.',
            ),
            if (site.periods.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: site.periods
                    .map((period) => Chip(label: Text(period)))
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      key: const ValueKey<String>('public-timeline'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PalEyesSectionTitleV1(
          title: 'عبر الزمن',
          subtitle:
              'محطات تساعد على رؤية كيف تغير المكان عبر الفترات التاريخية.',
        ),
        const SizedBox(height: 16),
        ...site.timeline.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PalEyesParchmentPanel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(width: 4, height: 88, color: PalEyesVisualV1.olive),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          entry.period,
                          style: const TextStyle(
                            color: PalEyesVisualV1.oliveDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          entry.draftText,
                          style: const TextStyle(height: 1.75),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicMediaSection extends StatelessWidget {
  const _PublicMediaSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final visibleCount = site.approvedMediaCount > 0
        ? site.approvedMediaCount.clamp(1, 6)
        : 3;
    return Column(
      key: const ValueKey<String>('public-media'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PalEyesSectionTitleV1(
          title: 'صور المكان',
          subtitle: site.approvedMediaCount > 0
              ? 'مواد بصرية مرتبطة بالموقع.'
              : 'نعمل على إضافة صور ووثائق بصرية صالحة للعرض.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 520
                ? 2
                : 1;
            const gap = 12.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List<Widget>.generate(
                visibleCount,
                (index) => SizedBox(
                  width: width,
                  child: PalEyesMediaPlaceholder(
                    label: site.approvedMediaCount > index
                        ? 'صورة من المكان'
                        : 'مادة بصرية قيد الإعداد',
                    icon: site.approvedMediaCount > index
                        ? Icons.photo_outlined
                        : Icons.landscape_outlined,
                    height: 190,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PublicMapSection extends StatelessWidget {
  const _PublicMapSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    return PalEyesParchmentPanel(
      key: const ValueKey<String>('public-map'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PalEyesSectionTitleV1(
            title: 'المكان على الخريطة',
            subtitle: 'ابدأ من الجغرافيا ثم عد إلى الحكاية.',
          ),
          const SizedBox(height: 16),
          Text(
            '${site.localityAr} • ${site.governorateAr}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            site.hasPublicCoordinates
                ? 'يتوفر موضع عام لهذا المكان على الأطلس.'
                : 'نعرض التجمع والمحافظة الآن، ويُضاف الموضع الدقيق عندما تتوفر نقطة موثوقة للعرض.',
            style: const TextStyle(height: 1.75),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => context.go(
              site.hasPublicCoordinates
                  ? '${RoutePaths.map}?site=${site.slug}'
                  : RoutePaths.map,
            ),
            icon: const Icon(Icons.map_outlined),
            label: Text(
              site.hasPublicCoordinates
                  ? 'افتح هذا المكان على الخريطة'
                  : 'استكشف الأطلس',
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicSourcesSection extends StatelessWidget {
  const _PublicSourcesSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    if (site.sources.isEmpty) {
      return const PalEyesParchmentPanel(
        key: ValueKey<String>('public-sources-empty'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PalEyesSectionTitleV1(
              title: 'المصادر',
              subtitle: 'لم نضف بعد قائمة مصادر قابلة للعرض لهذه الصفحة.',
            ),
            SizedBox(height: 12),
            Text(
              'ستظهر هنا الكتب والدراسات والوثائق التي يمكن للقارئ الرجوع إليها.',
              style: TextStyle(height: 1.75),
            ),
          ],
        ),
      );
    }
    return Column(
      key: const ValueKey<String>('public-sources'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PalEyesSectionTitleV1(
          title: 'المصادر',
          subtitle: 'مراجع يمكنك الرجوع إليها لمعرفة المزيد عن المكان.',
        ),
        const SizedBox(height: 14),
        ...site.sources.map(
          (source) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PalEyesParchmentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    source.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    source.attribution,
                    style: const TextStyle(
                      color: PalEyesVisualV1.warmMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (source.note.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(source.note, style: const TextStyle(height: 1.7)),
                  ],
                  if (source.url.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    SelectableText(
                      source.url,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicResearchPreviewSection extends ConsumerWidget {
  const _PublicResearchPreviewSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(stagingResearchPackageBySiteIdProvider(site.id));
    if (package == null) {
      return const SizedBox.shrink();
    }
    return Column(
      key: const ValueKey<String>('public-research-preview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StagingResearchPackageCard(package: package),
        const SizedBox(height: 14),
        const PalEyesParchmentPanel(
          child: Text(
            'هذه المادة ظاهرة الآن لأغراض التطوير والتحقيق والتدقيق. ظهورها في الموقع لا يحولها إلى محتوى منشور نهائي، ويمكن تصحيحها أو توسيعها قبل قرار النشر.',
            style: TextStyle(height: 1.75),
          ),
        ),
      ],
    );
  }
}

class _PublicAboutMaterialSection extends ConsumerWidget {
  const _PublicAboutMaterialSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(stagingResearchPackageBySiteIdProvider(site.id));
    final String title;
    final String message;
    if (package?.isStatusOnly ?? site.isLimitedResearch) {
      title = 'المعلومات المتاحة محدودة حاليًا';
      message =
          'نعرف هوية المكان الأساسية، لكن المادة المتاحة لا تكفي بعد لعرض قصة تاريخية تفصيلية. لذلك نُبقي الفراغات ظاهرة بدل ملئها بالتخمين.';
    } else if (package?.isLinkedReference ?? false) {
      title = 'هذه الصفحة مرتبطة ببحث مستقل';
      message =
          'نعرض هنا ما يفيد تجربة المكان، بينما تبقى المادة البحثية التفصيلية في مسارها المتخصص.';
    } else {
      title = 'كيف أعددنا هذه الصفحة؟';
      message =
          'نبدأ من هوية المكان والمصادر المرتبطة به، ثم نبني الحكاية تدريجيًا. التفاصيل غير المحسومة لا تُقدَّم للقارئ بوصفها حقائق نهائية.';
    }
    return Column(
      key: const ValueKey<String>('public-about-material'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PalEyesParchmentPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(height: 1.8)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _PublicTrustChip(
                    icon: Icons.library_books_outlined,
                    label: site.sources.isEmpty
                        ? 'المصادر قيد الإضافة'
                        : '${site.sources.length} مصادر مرتبطة',
                  ),
                  _PublicTrustChip(
                    icon: Icons.auto_stories_outlined,
                    label: site.narrativeSections.isEmpty
                        ? 'القصة قيد الاستكمال'
                        : '${site.narrativeSections.length} فصول',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.methodology),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('تعرّف إلى منهجية التوثيق'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublicTrustChip extends StatelessWidget {
  const _PublicTrustChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PalEyesVisualV1.olive.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: PalEyesVisualV1.olive.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: PalEyesVisualV1.oliveDark),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PublicInfoNote extends StatelessWidget {
  const _PublicInfoNote({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PalEyesVisualV1.parchmentDeep.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: PalEyesVisualV1.olive),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(height: 1.7))),
        ],
      ),
    );
  }
}

class _PlaceHero extends StatelessWidget {
  const _PlaceHero({required this.site});

  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final period = site.periods.isEmpty
        ? 'الفترة التاريخية غير محددة'
        : site.periods.take(2).join(' • ');
    return PalEyesHeritageScene(
      height: MediaQuery.sizeOf(context).width < 720 ? 360 : 430,
      title: site.nameAr,
      eyebrow: site.pageCategory.labelAr,
      subtitle: '${site.localityAr} • ${site.governorateAr} • $period',
    );
  }
}

class _PlaceMetrics extends StatelessWidget {
  const _PlaceMetrics({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final metrics = <(IconData, String, String)>[
      (Icons.location_city_outlined, 'المحافظة', site.governorateAr),
      (Icons.account_balance_outlined, 'الفئة', site.siteTypeAr),
      (Icons.fact_check_outlined, 'التوثيق', '${site.documentationProgress}%'),
      (Icons.library_books_outlined, 'المصادر', '${site.sources.length} مصدر'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: PalEyesParchmentPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    radius: 16,
                    child: Row(
                      children: <Widget>[
                        Icon(metric.$1, color: PalEyesVisualV1.olive, size: 21),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                metric.$2,
                                style: const TextStyle(
                                  color: PalEyesVisualV1.warmMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                metric.$3,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
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
    );
  }
}

class _DetailNavigation extends StatelessWidget {
  const _DetailNavigation({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PalEyesVisualV1.warmLine)),
      ),
      child: PalEyesTabStripV1(
        selectedIndex: selected,
        onSelected: onSelected,
        labels: const <String>[
          'نبذة',
          'الحكاية المحررة',
          'المادة التاريخية الأصلية',
          'المراجع',
          'البحث',
          'الوسائط',
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.site});
  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final periods = site.periods.isEmpty
        ? 'غير محدد'
        : site.periods.take(3).join(' • ');
    return Column(
      key: const ValueKey<String>('overview'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final summary = PalEyesParchmentPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const PalEyesSectionTitleV1(
                    title: 'نبذة عن المكان',
                    subtitle:
                        'قراءة أولية من المادة المتاحة مع إبقاء كل فجوة توثيقية ظاهرة.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    site.summaryDraft,
                    style: const TextStyle(height: 1.85, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    site.pageCategory.descriptionAr,
                    style: const TextStyle(
                      color: PalEyesVisualV1.warmMuted,
                      height: 1.65,
                    ),
                  ),
                  if (site.specialHold != null) ...<Widget>[
                    const SizedBox(height: 14),
                    _Notice(
                      icon: Icons.warning_amber_rounded,
                      text: 'قيد خاص: ${site.specialHold}',
                    ),
                  ],
                ],
              ),
            );
            final facts = PalEyesParchmentPanel(
              color: PalEyesVisualV1.parchmentDeep.withValues(alpha: 0.48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'حقائق أساسية',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  PalEyesFactRowV1(
                    icon: Icons.location_city_outlined,
                    label: 'المحافظة',
                    value: site.governorateAr,
                  ),
                  PalEyesFactRowV1(
                    icon: Icons.place_outlined,
                    label: 'المحلية',
                    value: site.localityAr,
                  ),
                  PalEyesFactRowV1(
                    icon: Icons.account_balance_outlined,
                    label: 'الفئة',
                    value: site.siteTypeAr,
                  ),
                  PalEyesFactRowV1(
                    icon: Icons.timeline_outlined,
                    label: 'الفترات',
                    value: periods,
                  ),
                  PalEyesFactRowV1(
                    icon: site.hasPublicCoordinates
                        ? Icons.location_on_outlined
                        : Icons.location_off_outlined,
                    label: 'الإحداثيات',
                    value: site.hasPublicCoordinates
                        ? 'نقطة عامة'
                        : site.coordinateStatusAr,
                  ),
                ],
              ),
            );
            if (constraints.maxWidth >= 820) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 7, child: summary),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: facts),
                ],
              );
            }
            return Column(
              children: <Widget>[summary, const SizedBox(height: 14), facts],
            );
          },
        ),
        const SizedBox(height: 24),
        const PalEyesSectionTitleV1(
          title: 'معرض الصور',
          subtitle:
              'مواد بصرية منضبطة بحقوق الاستخدام والاعتماد قبل العرض العام.',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 220,
              child: PalEyesMediaPlaceholder(
                label: site.approvedMediaCount > index
                    ? 'صورة متاحة للمراجعة'
                    : 'صورة تنتظر الاعتماد',
                icon: site.approvedMediaCount > index
                    ? Icons.photo_outlined
                    : Icons.lock_outline_rounded,
                height: 155,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrativeSection extends StatelessWidget {
  const _NarrativeSection({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context) {
    if (site.narrativeSections.isEmpty) {
      return const _SectionCard(
        key: ValueKey<String>('narrative-empty'),
        title: 'لا توجد رواية معتمدة للتطوير بعد',
        icon: Icons.science_outlined,
        child: Text(
          'تبقى الصفحة محدودة بالهوية وفجوات التوثيق. لا تُستخدم مواد المسودة القديمة أو ادعاءات البحث المفتوحة بديلاً عن التحقق.',
        ),
      );
    }
    return Column(
      key: const ValueKey<String>('narrative'),
      children: site.narrativeSections
          .map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SectionCard(
                title: section.title,
                icon: Icons.menu_book_rounded,
                trailing: ContentStatusBadge(
                  status: section.status,
                  compact: true,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      section.draftText,
                      style: const TextStyle(height: 1.75),
                    ),
                    const SizedBox(height: 16),
                    _Notice(
                      icon: Icons.link_rounded,
                      text:
                          "${section.evidenceNote}\n"
                          "الادعاء: ${section.claimId ?? 'غير محدد'} • "
                          "المصادر: ${section.sourceIds.length}",
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _OriginalHistoricalDraftSection extends StatelessWidget {
  const _OriginalHistoricalDraftSection({required this.site});

  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final draft = site.originalHistoricalDraft;

    if (draft == null) {
      return const _SectionCard(
        key: ValueKey<String>('original-draft-missing'),
        title: 'لا توجد مسودة تاريخية أصلية مرتبطة',
        icon: Icons.inventory_2_outlined,
        child: Text(
          'لم يُعثر على مادة أصلية مرتبطة بهذا السجل داخل ملف المصدر المرجعي.',
        ),
      );
    }

    if (!OriginalDraftVisibilityPolicy.canRenderOriginalDraft) {
      return const _SectionCard(
        key: ValueKey<String>('original-draft-public-block'),
        title: 'المسودة الأصلية محجوبة في النسخة العامة',
        icon: Icons.lock_outline_rounded,
        child: Text(
          'هذه الطبقة مخصصة للتطوير والمراجعة الداخلية، ولم تحصل على اعتماد '
          'النشر العام.',
        ),
      );
    }

    final sectionCards = draft.narrativeSections
        .map((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: const Icon(Icons.history_edu_outlined),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('نص أصلي غير متحقق بالكامل'),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: <Widget>[
                  SelectableText(
                    section.draftText,
                    style: const TextStyle(height: 1.8),
                  ),
                  const SizedBox(height: 14),
                  _Notice(
                    icon: Icons.fact_check_outlined,
                    text: section.evidenceNote,
                  ),
                ],
              ),
            ),
          );
        })
        .toList(growable: false);

    return Column(
      key: const ValueKey<String>('original-historical-draft'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionCard(
          title: 'المادة التاريخية الأصلية',
          icon: Icons.history_edu_outlined,
          trailing: const Chip(
            avatar: Icon(Icons.developer_mode_outlined, size: 16),
            label: Text('بيئة التطوير فقط'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _Notice(
                icon: Icons.warning_amber_rounded,
                text:
                    'هذه المادة مستخرجة حرفياً من الملف المرجعي المرفق. '
                    'لم تعتمد جميع ادعاءاتها أو إحالاتها أو حقوق إعادة '
                    'استخدامها، ولا يجوز نشرها بوصفها رواية نهائية.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  Chip(
                    label: Text(
                      draft.hasExpandedNarrative
                          ? 'رواية أصلية موسعة'
                          : 'بطاقة فهرسة أصلية',
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${draft.narrativeSections.length} أقسام أصلية',
                    ),
                  ),
                  Chip(
                    label: Text('${draft.sourceMentionCount} إحالات مصدر خام'),
                  ),
                  const Chip(label: Text('النشر العام: محجوب')),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'الملخص الأصلي',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              SelectableText(
                draft.summaryDraft,
                style: const TextStyle(height: 1.75),
              ),
              const SizedBox(height: 16),
              SelectableText(
                'المصدر: ${draft.referenceFileName}\n'
                'SHA-256: ${draft.referenceFileSha256}\n'
                'الأسطر: ${draft.referenceLineCount} • '
                'الحجم: ${draft.referenceSizeBytes} بايت',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (sectionCards.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          ...sectionCards,
        ] else ...<Widget>[
          const SizedBox(height: 14),
          const _SectionCard(
            title: 'بطاقة فهرسة أصلية',
            icon: Icons.inventory_2_outlined,
            child: Text(
              'الملف الأصلي يتضمن ملخصاً أولياً لهذا الموقع دون رواية '
              'موسعة مقسمة إلى أقسام.',
            ),
          ),
        ],
        if (draft.sources.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _SectionCard(
            title: 'إحالات واردة في المسودة الأصلية',
            icon: Icons.bookmarks_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: draft.sources
                  .map((source) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _Notice(
                        icon: Icons.menu_book_outlined,
                        text:
                            '${source.title}\n${source.attribution}\n${source.note}',
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
        if (draft.timeline.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _SectionCard(
            title: 'الإشارات الزمنية في المسودة',
            icon: Icons.timeline_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: draft.timeline
                  .map((entry) => Chip(label: Text(entry.period)))
                  .toList(growable: false),
            ),
          ),
        ],
      ],
    );
  }
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context) {
    if (site.sources.isEmpty) {
      return const _SectionCard(
        key: ValueKey<String>('sources-empty'),
        title: 'لا توجد مصادر معتمدة للصفحة بعد',
        icon: Icons.library_books_outlined,
        child: Text(
          "تستمر عملية اكتشاف المصادر في مساحة الباحث. لا يُعرض ذكر مصدر خام بوصفه مرجعاً متحققاً.",
        ),
      );
    }
    return Column(
      key: const ValueKey<String>('sources'),
      children: site.sources
          .map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SourceCard(source: source),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});
  final HistoricalSourceReference source;
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: source.title,
      icon: Icons.library_books_outlined,
      trailing: ContentStatusBadge(status: source.status, compact: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            source.attribution,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(source.note),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              if (source.sourceClass.isNotEmpty)
                Chip(label: Text(source.sourceClass)),
              Chip(label: Text('النص: ${source.textReuseStatus}')),
              Chip(label: Text('الصور: ${source.imageReuseStatus}')),
              Chip(label: Text('النشر: ${source.publicReleaseStatus}')),
            ],
          ),
          if (source.url.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            SelectableText(
              source.url,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResearchSection extends ConsumerWidget {
  const _ResearchSection({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(stagingResearchPackageBySiteIdProvider(site.id));
    return _SectionCard(
      key: const ValueKey<String>('research'),
      title: 'البحث الموازي',
      icon: Icons.science_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (package != null) ...<Widget>[
            StagingResearchPackageCard(package: package),
            const SizedBox(height: 16),
          ],
          Text(
            '${site.heldClaimCount} ادعاءً أو مجموعة ادعاءات ما زالت في طابور البحث. لا تظهر هذه المواد داخل الحكاية المحررة.',
          ),
          const SizedBox(height: 12),
          Text(
            'نتائج P0 لهذا الموقع: ${site.p0ClaimCount}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          if (site.p0Findings.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            ...site.p0Findings.map(
              (finding) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Notice(
                  icon: Icons.pending_actions_outlined,
                  text: finding,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MediaRightsSection extends StatelessWidget {
  const _MediaRightsSection({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      key: const ValueKey<String>('media-rights'),
      title: 'الوسائط والحقوق',
      icon: Icons.policy_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('الأصول المعتمدة لهذا الموقع: ${site.approvedMediaCount}'),
          const SizedBox(height: 10),
          const Text(
            'لا تُستخدم صورة أو خريطة أو ملف خارجي قبل إدخاله في Controlled Asset Intake مع SHA-256 وصاحب الحقوق والترخيص أو الإذن.',
          ),
          const SizedBox(height: 12),
          const _Notice(
            icon: Icons.image_not_supported_outlined,
            text:
                'يستخدم التصميم بديلاً بصرياً محايداً إلى حين اعتماد أصل وسائط على مستوى الملف.',
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    super.key,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final header = <Widget>[
      Icon(icon),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    ];
    if (trailing != null) {
      header.add(trailing!);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: header),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
