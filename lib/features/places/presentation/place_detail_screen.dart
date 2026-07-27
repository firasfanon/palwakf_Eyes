import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/content_status_badge.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/application/original_draft_visibility_policy.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/places/domain/historical_content.dart';

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
    final site = ref.watch(heritageSiteBySlugProvider(widget.slug));
    if (site == null) {
      return const PalEyesPage(
        title: 'الموقع غير موجود',
        subtitle: 'لم يُعثر على سجل مطابق.',
        child: Center(child: Icon(Icons.location_off_outlined, size: 72)),
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

class _PlaceHero extends StatelessWidget {
  const _PlaceHero({required this.site});

  final HeritageSite site;

  @override
  Widget build(BuildContext context) {
    final period = site.periods.isEmpty
        ? 'الفترة التاريخية قيد التحديد'
        : site.periods.take(2).join(' • ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PalEyesMediaStage(
          title: site.nameAr,
          subtitle: '${site.localityAr} • ${site.governorateAr} • $period',
          semanticLabel:
              'عمل بصري تجريدي يمثل ${site.nameAr} إلى حين اعتماد وسائط مرخصة.',
          icon: _iconForSiteType(site.siteTypeAr),
          height: 340,
          footer: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ContentStatusBadge(status: site.status),
              Chip(label: Text(site.siteTypeAr)),
              Chip(
                avatar: const Icon(Icons.library_books_outlined, size: 17),
                label: Text('${site.sources.length} مراجع'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              site.summaryDraft,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(height: 1.75),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForSiteType(String type) {
    if (type.contains('كنيسة') || type.contains('دير')) {
      return Icons.church_outlined;
    }
    if (type.contains('مسجد') || type.contains('مقام')) {
      return Icons.mosque_outlined;
    }
    if (type.contains('ماء') || type.contains('عين') || type.contains('برك')) {
      return Icons.water_drop_outlined;
    }
    if (type.contains('مدينة') || type.contains('بلدة')) {
      return Icons.location_city_outlined;
    }
    return Icons.account_balance_outlined;
  }
}

class _PlaceMetrics extends StatelessWidget {
  const _PlaceMetrics({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context) {
    final metrics = <(IconData, String, String)>[
      (
        site.isGovernedDraft
            ? Icons.verified_outlined
            : Icons.hourglass_top_outlined,
        'مستوى الاكتمال',
        site.isGovernedDraft ? 'حكاية موسعة قيد التدقيق' : 'بطاقة تعريف أولية',
      ),
      (
        Icons.menu_book_outlined,
        'فصول الحكاية',
        '${site.narrativeSections.length}',
      ),
      (Icons.library_books_outlined, 'المراجع', '${site.sources.length}'),
      (
        Icons.pending_actions_outlined,
        'أسئلة قيد البحث',
        '${site.heldClaimCount}',
      ),
      (
        site.hasPublicCoordinates
            ? Icons.location_on_outlined
            : Icons.location_off_outlined,
        'الخريطة',
        site.hasPublicCoordinates ? 'موضع معتمد' : 'ينتظر التحقق',
      ),
      (
        Icons.perm_media_outlined,
        'الصور والوسائط',
        '${site.approvedMediaCount} معتمدة',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Icon(metric.$1),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  metric.$2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(metric.$3),
                              ],
                            ),
                          ),
                        ],
                      ),
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
    const labels = <String>[
      'نظرة عامة',
      'الحكاية المحررة',
      'المادة التاريخية الأصلية',
      'المصادر',
      'أسئلة البحث',
      'الوسائط والحقوق',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: List<Widget>.generate(
          labels.length,
          (index) => ChoiceChip(
            selected: selected == index,
            onSelected: (_) => onSelected(index),
            label: Text(labels[index]),
          ),
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      key: const ValueKey<String>('overview'),
      title: site.pageCategory.labelAr,
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            site.pageCategory.descriptionAr,
            style: const TextStyle(height: 1.7),
          ),
          const SizedBox(height: 14),
          Text(site.summaryDraft, style: const TextStyle(height: 1.7)),
          if (site.specialHold != null) ...<Widget>[
            const SizedBox(height: 14),
            _Notice(
              icon: Icons.warning_amber_rounded,
              text: 'حجز هوية: ${site.specialHold}',
            ),
          ],
          if (site.parentSiteIds.isNotEmpty ||
              site.constituentSiteIds.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (site.parentSiteIds.isNotEmpty)
                  Chip(label: Text('سجل أب: ${site.parentSiteIds.join('، ')}')),
                if (site.constituentSiteIds.isNotEmpty)
                  Chip(
                    label: Text('مكونات: ${site.constituentSiteIds.length}'),
                  ),
              ],
            ),
          ],
        ],
      ),
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

class _ResearchSection extends StatelessWidget {
  const _ResearchSection({required this.site});
  final HeritageSite site;
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      key: const ValueKey<String>('research'),
      title: 'البحث الموازي',
      icon: Icons.science_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
