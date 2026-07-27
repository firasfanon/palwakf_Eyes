import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';

class WorkspaceDashboardScreen extends ConsumerWidget {
  const WorkspaceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sites = ref.watch(foundationSitesProvider);
    final mapped = ref.watch(mappedSitesProvider);
    final expanded = ref.watch(expandedNarrativeSitesProvider);
    final registry = ref.watch(draftSourceRegistryProvider);
    final coverage = ref.watch(governorateCoverageProvider);
    final coordinateGaps = sites.length - mapped.length;
    final governorateGaps = coverage
        .where((item) => !item.hasExtractedSites)
        .length;

    return PalEyesPage(
      title: 'لوحة العمل اليومية',
      subtitle:
          'صورة تشغيلية سريعة لحالة المواقع والمصادر والإحداثيات والمراجعات، مع وصول مباشر إلى المهام الأكثر إلحاحاً.',
      icon: Icons.space_dashboard_outlined,
      eyebrow: 'مساحة العمل',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.workspaceNewPlace),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('إضافة موقع مسودة'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1040
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              const gap = 14.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              final metrics = <Widget>[
                PalEyesMetricTile(
                  icon: Icons.account_balance_outlined,
                  value: '${sites.length}',
                  label: 'المواقع المسودة',
                  note: 'الكتالوج الكامل',
                  emphasis: true,
                ),
                PalEyesMetricTile(
                  icon: Icons.auto_stories_outlined,
                  value: '${expanded.length}',
                  label: 'روايات موسعة',
                  note: 'تحتاج تدقيق الادعاءات',
                ),
                PalEyesMetricTile(
                  icon: Icons.library_books_outlined,
                  value: '${registry.length}',
                  label: 'مدخلات مصادر',
                  note: 'تحتاج مطابقة ببليوغرافية',
                ),
                PalEyesMetricTile(
                  icon: Icons.location_city_outlined,
                  value: '${coverage.length}',
                  label: 'محافظة',
                  note: '$governorateGaps فجوات استخراج',
                ),
                PalEyesMetricTile(
                  icon: Icons.location_off_outlined,
                  value: '$coordinateGaps',
                  label: 'فجوات إحداثيات',
                  note: '${mapped.length} مواضع مدققة',
                ),
                const PalEyesMetricTile(
                  icon: Icons.public_off_outlined,
                  value: '0',
                  label: 'مواد منشورة',
                  note: 'النشر التلقائي محجوب',
                ),
              ];
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: metrics
                    .map((item) => SizedBox(width: width, child: item))
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 36),
          const PalEyesSectionHeader(
            eyebrow: 'الأولوية الآن',
            icon: Icons.task_alt_outlined,
            title: 'مهام تغلق فجوات حقيقية',
            subtitle:
                'ترتيب العمل حسب أثره على قابلية التتبع وجودة الرواية، لا حسب سهولة الإنجاز.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 860
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              final cards = <Widget>[
                PalEyesVisualCard(
                  icon: Icons.location_on_outlined,
                  title: 'مراجعة الإحداثيات',
                  description:
                      '$coordinateGaps موقعاً تحتاج موضعاً مدققاً قبل ظهورها على الخريطة العامة.',
                  label: 'أولوية جغرافية',
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.sea, AppColors.deepBlue],
                  ),
                  dark: true,
                  onTap: () => context.go(RoutePaths.workspaceMapEditor),
                  footer: const _ActionFooter(label: 'فتح محرر الخريطة'),
                ),
                PalEyesVisualCard(
                  icon: Icons.library_books_outlined,
                  title: 'مطابقة سجل المصادر',
                  description:
                      '${registry.length} مدخلاً يحتاج عنواناً ومؤلفاً وطبعة وصفحة أو مقطعاً قابلاً للتتبع.',
                  label: 'أولوية معرفية',
                  gradient: AppColors.earthGradient,
                  dark: true,
                  onTap: () => context.go(RoutePaths.workspaceSources),
                  footer: const _ActionFooter(label: 'فتح سجل المصادر'),
                ),
                PalEyesVisualCard(
                  icon: Icons.fact_check_outlined,
                  title: 'تفكيك الروايات إلى ادعاءات',
                  description:
                      '${expanded.length} رواية موسعة تحتاج ربط كل ادعاء بالمصدر والدليل المناسب.',
                  label: 'أولوية تحريرية',
                  onTap: () => context.go(RoutePaths.workspaceClaims),
                  footer: const _ActionFooter(label: 'فتح الادعاءات'),
                ),
                PalEyesVisualCard(
                  icon: Icons.analytics_outlined,
                  title: 'تقارير الفجوات',
                  description:
                      '$governorateGaps محافظات بلا صفوف مستخرجة، مع فجوات وسائط وحقوق ومصادر تحتاج رؤية موحدة.',
                  label: 'أولوية متابعة',
                  onTap: () => context.go(RoutePaths.workspaceReports),
                  footer: const _ActionFooter(label: 'فتح التقارير'),
                ),
              ];
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards
                    .map(
                      (item) =>
                          SizedBox(width: width, height: 270, child: item),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 36),
          const PalEyesSectionHeader(
            eyebrow: 'وصول سريع',
            icon: Icons.flash_on_outlined,
            title: 'العمل اليومي في أربعة مسارات',
            subtitle:
                'المواقع، الوثائق، المراجعات والمساهمات دون إقحام تفاصيل الحوكمة في الصفحة اليومية.',
          ),
          const SizedBox(height: 16),
          _QuickActions(
            items: const <_QuickAction>[
              _QuickAction(
                icon: Icons.account_balance_outlined,
                label: 'جميع المواقع',
                path: RoutePaths.workspacePlaces,
              ),
              _QuickAction(
                icon: Icons.description_outlined,
                label: 'الوثائق والروايات',
                path: RoutePaths.workspaceNarratives,
              ),
              _QuickAction(
                icon: Icons.rate_review_outlined,
                label: 'قائمة المراجعة',
                path: RoutePaths.workspaceReviews,
              ),
              _QuickAction(
                icon: Icons.volunteer_activism_outlined,
                label: 'المساهمات',
                path: RoutePaths.workspaceContributions,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.tertiaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.shield_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'كل السجلات الحالية مسودات. لا توجد مادة معتمدة أو منشورة، ولا توجد كتابة حية إلى Supabase في هذه الدفعة.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.items});

  final List<_QuickAction> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 860
            ? (constraints.maxWidth - 42) / 4
            : constraints.maxWidth >= 540
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Card(
                    child: InkWell(
                      onTap: () => context.go(item.path),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(child: Icon(item.icon)),
                            const SizedBox(height: 14),
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            const Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(Icons.arrow_back_rounded),
                            ),
                          ],
                        ),
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

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}
