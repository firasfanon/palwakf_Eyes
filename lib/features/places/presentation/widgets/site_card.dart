import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

class SiteCard extends StatelessWidget {
  const SiteCard({required this.site, this.compact = false, super.key});

  final HeritageSite site;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scene = _sceneFor(site.siteTypeAr);
    final period = site.periods.isEmpty
        ? 'فترة قيد التحديد'
        : site.periods.first;
    return Semantics(
      button: true,
      label:
          'افتح صفحة ${site.nameAr}. ${site.localityAr}. ${site.governorateAr}.',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.go(RoutePaths.place(site.slug)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: compact ? 92 : 132,
                decoration: BoxDecoration(gradient: scene.gradient),
                child: Stack(
                  children: <Widget>[
                    const Positioned.fill(child: PalEyesPattern(opacity: 0.06)),
                    PositionedDirectional(
                      end: 16,
                      top: 16,
                      child: Icon(
                        scene.icon,
                        size: compact ? 44 : 68,
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                    PositionedDirectional(
                      start: 14,
                      top: 14,
                      child: _OverlayLabel(text: site.siteTypeAr),
                    ),
                    PositionedDirectional(
                      start: 14,
                      end: 14,
                      bottom: 13,
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.place_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${site.localityAr} • ${site.governorateAr}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: compact
                      ? const EdgeInsets.all(15)
                      : const EdgeInsets.symmetric(
                          horizontal: 19,
                          vertical: 17,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        site.nameAr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (site.nameEn.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 3),
                        Text(
                          site.nameEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: <Widget>[
                          _CompactTag(
                            icon: site.hasExpandedNarrative
                                ? Icons.auto_stories_outlined
                                : Icons.article_outlined,
                            label: site.hasExpandedNarrative
                                ? 'حكاية موسعة'
                                : 'بطاقة تعريف',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          site.summaryDraft,
                          maxLines: compact ? 2 : 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.55,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: <Widget>[
                          _Meta(icon: Icons.timeline_outlined, label: period),
                          _Meta(
                            icon: Icons.library_books_outlined,
                            label: '${site.sources.length} مراجع',
                          ),
                          _Meta(
                            icon: Icons.menu_book_outlined,
                            label: '${site.narrativeSections.length} فصول',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'اكتشف الحكاية',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Icon(Icons.arrow_back_rounded, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _SiteScene _sceneFor(String type) {
    if (type.contains('كنيسة') || type.contains('دير')) {
      return const _SiteScene(
        icon: Icons.church_outlined,
        gradient: LinearGradient(
          colors: <Color>[AppColors.dusk, Color(0xFF3C3145)],
        ),
      );
    }
    if (type.contains('مسجد') || type.contains('مقام')) {
      return const _SiteScene(
        icon: Icons.mosque_outlined,
        gradient: LinearGradient(
          colors: <Color>[AppColors.olive, Color(0xFF35452F)],
        ),
      );
    }
    if (type.contains('ماء') || type.contains('عين') || type.contains('برك')) {
      return const _SiteScene(
        icon: Icons.water_drop_outlined,
        gradient: LinearGradient(
          colors: <Color>[AppColors.sea, AppColors.deepBlue],
        ),
      );
    }
    if (type.contains('مدينة') ||
        type.contains('بلدة') ||
        type.contains('عنقود')) {
      return const _SiteScene(
        icon: Icons.location_city_outlined,
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF8A6847), Color(0xFF4D3C2E)],
        ),
      );
    }
    return const _SiteScene(
      icon: Icons.account_balance_outlined,
      gradient: AppColors.sovereignGradient,
    );
  }
}

class _CompactTag extends StatelessWidget {
  const _CompactTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _SiteScene {
  const _SiteScene({required this.icon, required this.gradient});

  final IconData icon;
  final Gradient gradient;
}
