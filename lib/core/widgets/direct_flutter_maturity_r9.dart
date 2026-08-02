import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

enum PalEyesPublicPillar { atlas, museum, magazine }

extension PalEyesPublicPillarLabel on PalEyesPublicPillar {
  String get label => switch (this) {
    PalEyesPublicPillar.atlas => 'أطلس المكان',
    PalEyesPublicPillar.museum => 'متحف الحكاية',
    PalEyesPublicPillar.magazine => 'مجلة الذاكرة',
  };

  String get description => switch (this) {
    PalEyesPublicPillar.atlas => 'ابدأ من الموقع والمحافظة والفترة التاريخية.',
    PalEyesPublicPillar.museum => 'افتح صفحة المكان واقرأ طبقاته ومصادره.',
    PalEyesPublicPillar.magazine => 'اتبع قصة طويلة تصل المواقع ببعضها.',
  };

  IconData get icon => switch (this) {
    PalEyesPublicPillar.atlas => Icons.account_balance_outlined,
    PalEyesPublicPillar.museum => Icons.museum_outlined,
    PalEyesPublicPillar.magazine => Icons.auto_stories_outlined,
  };
}

class PalEyesPublicIdentityStrip extends StatelessWidget {
  const PalEyesPublicIdentityStrip({
    required this.active,
    this.onAtlas,
    this.onMuseum,
    this.onMagazine,
    super.key,
  });

  final PalEyesPublicPillar active;
  final VoidCallback? onAtlas;
  final VoidCallback? onMuseum;
  final VoidCallback? onMagazine;

  @override
  Widget build(BuildContext context) {
    final actions = <PalEyesPublicPillar, VoidCallback?>{
      PalEyesPublicPillar.atlas: onAtlas,
      PalEyesPublicPillar.museum: onMuseum,
      PalEyesPublicPillar.magazine: onMagazine,
    };

    return Semantics(
      container: true,
      label: 'مسارات التجربة العامة: أطلس، متحف، ومجلة سردية.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 850 ? 3 : 1;
          const gap = 12.0;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: PalEyesPublicPillar.values
                .map(
                  (pillar) => SizedBox(
                    width: width,
                    child: _PublicPillarCard(
                      pillar: pillar,
                      selected: pillar == active,
                      onTap: actions[pillar],
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _PublicPillarCard extends StatelessWidget {
  const _PublicPillarCard({
    required this.pillar,
    required this.selected,
    required this.onTap,
  });

  final PalEyesPublicPillar pillar;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? Colors.white : scheme.onSurface;
    return Semantics(
      selected: selected,
      button: onTap != null,
      label: '${pillar.label}. ${pillar.description}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected ? AppColors.sovereignGradient : null,
            color: selected ? null : scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.heritageGold.withValues(alpha: 0.62)
                  : scheme.outlineVariant.withValues(alpha: 0.58),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.12)
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      pillar.icon,
                      color: selected ? AppColors.softGold : scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          pillar.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          pillar.description,
                          style: TextStyle(
                            color: foreground.withValues(alpha: 0.74),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_back_rounded,
                      color: foreground.withValues(alpha: 0.76),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PalEyesEditorialMetric {
  const PalEyesEditorialMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class PalEyesEditorialPrelude extends StatelessWidget {
  const PalEyesEditorialPrelude({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.metrics = const <PalEyesEditorialMetric>[],
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.gradient = AppColors.sovereignGradient,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<PalEyesEditorialMetric> metrics;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$eyebrow. $title. $description',
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.midnight.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: PalEyesPattern(opacity: 0.055)),
            PositionedDirectional(
              end: -20,
              top: -12,
              child: Icon(
                icon,
                size: 210,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final copy = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: AppColors.softGold,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.68,
                        ),
                      ),
                      if (primaryLabel != null ||
                          secondaryLabel != null) ...<Widget>[
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            if (primaryLabel != null && onPrimary != null)
                              FilledButton.icon(
                                onPressed: onPrimary,
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(primaryLabel!),
                              ),
                            if (secondaryLabel != null && onSecondary != null)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.38),
                                  ),
                                ),
                                onPressed: onSecondary,
                                icon: const Icon(Icons.explore_outlined),
                                label: Text(secondaryLabel!),
                              ),
                          ],
                        ),
                      ],
                    ],
                  );

                  final metricGrid = _EditorialMetricGrid(metrics: metrics);
                  if (constraints.maxWidth >= 860 && metrics.isNotEmpty) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(flex: 6, child: copy),
                        const SizedBox(width: 28),
                        Expanded(flex: 4, child: metricGrid),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      copy,
                      if (metrics.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 22),
                        metricGrid,
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialMetricGrid extends StatelessWidget {
  const _EditorialMetricGrid({required this.metrics});

  final List<PalEyesEditorialMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 360 ? 2 : 1;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(metric.icon, size: 20, color: AppColors.softGold),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                metric.value,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              Text(
                                metric.label,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.68),
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

class PalEyesContentCompass extends StatelessWidget {
  const PalEyesContentCompass({
    required this.labels,
    required this.icons,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(labels.length == icons.length);

  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'أقسام صفحة المكان',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(
                labels.length,
                (index) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    selected: selectedIndex == index,
                    avatar: Icon(icons[index], size: 18),
                    label: Text(labels[index]),
                    onSelected: (_) => onSelected(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PalEyesChapterRail extends StatelessWidget {
  const PalEyesChapterRail({
    required this.titles,
    this.currentIndex = 0,
    this.onSelected,
    super.key,
  });

  final List<String> titles;
  final int currentIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'دليل فصول القصة. ${titles.length} فصول.',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: titles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final selected = index == currentIndex;
                return ActionChip(
                  onPressed: onSelected == null
                      ? null
                      : () => onSelected!(index),
                  avatar: CircleAvatar(
                    radius: 13,
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: selected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    child: Text('${index + 1}'),
                  ),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      titles[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PalEyesReadingFrame extends StatelessWidget {
  const PalEyesReadingFrame({
    required this.child,
    this.maxWidth = 760,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class PalEyesMapEmptyExperience extends StatelessWidget {
  const PalEyesMapEmptyExperience({
    required this.siteCount,
    required this.governorateCount,
    required this.onAtlas,
    required this.onMethodology,
    super.key,
  });

  final int siteCount;
  final int governorateCount;
  final VoidCallback onAtlas;
  final VoidCallback onMethodology;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label:
          'الخريطة العامة تنتظر أول موضع معتمد. يمكن استكشاف $siteCount موقعاً في الأطلس.',
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[Color(0xFFF7F1E5), Color(0xFFE8DCC8)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.sovereignBlue.withValues(alpha: 0.10),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final visual = SizedBox(
                width: 190,
                height: 180,
                child: const PalestineMapArtwork(
                  compact: true,
                  showMarkers: false,
                  foregroundColor: AppColors.sovereignBlue,
                ),
              );
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Chip(
                    avatar: Icon(Icons.verified_user_outlined, size: 17),
                    label: Text('الخريطة لا تعرض إلا الموضع المعتمد'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'لا نقاط مؤقتة على الخريطة العامة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.sovereignBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'بدلاً من وضع إحداثيات غير مكتملة، يبقى الأطلس متاحاً '
                    'للقراءة حسب المحافظة والحكاية والمصدر إلى حين إغلاق '
                    'التحقق الجغرافي.',
                    style: TextStyle(height: 1.58),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      Chip(label: Text('$siteCount موقعاً في الأطلس')),
                      Chip(label: Text('$governorateCount محافظة')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: onAtlas,
                        icon: const Icon(Icons.account_balance_outlined),
                        label: const Text('افتح الأطلس'),
                      ),
                      TextButton.icon(
                        onPressed: onMethodology,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('كيف نعتمد الموضع؟'),
                      ),
                    ],
                  ),
                ],
              );

              if (constraints.maxWidth >= 760) {
                return Row(
                  children: <Widget>[
                    visual,
                    const SizedBox(width: 22),
                    Expanded(child: copy),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(child: visual),
                  const SizedBox(height: 12),
                  copy,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
