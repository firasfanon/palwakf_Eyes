import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/research/application/staging_research_corpus_provider.dart';
import 'package:pal_eyes/features/research/presentation/staging_research_narrative_panel.dart';
import 'package:pal_eyes/features/research/presentation/staging_research_package_card.dart';

class PublicResearchDetailScreen extends ConsumerWidget {
  const PublicResearchDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final site = ref.watch(heritageSiteBySlugProvider(slug));
    if (site == null) {
      return const PalEyesPage(
        title: 'البحث غير موجود',
        subtitle: 'لم نعثر على مكان أو حزمة بحثية مطابقة لهذا المسار.',
        child: _NotFoundBody(),
      );
    }

    final package = ref.watch(stagingResearchPackageBySiteIdProvider(site.id));
    if (package == null) {
      return PalEyesPage(
        title: site.nameAr,
        subtitle:
            'لا توجد حزمة بحثية قابلة للعرض في البيئة الحالية. تبقى صفحة المكان متاحة.',
        icon: Icons.menu_book_outlined,
        actions: <Widget>[
          OutlinedButton.icon(
            onPressed: () => context.go(RoutePaths.place(site.slug)),
            icon: const Icon(Icons.place_outlined),
            label: const Text('صفحة المكان'),
          ),
        ],
        child: const _EnvironmentLockedBody(),
      );
    }

    return PalEyesPage(
      title: site.nameAr,
      subtitle:
          'بحث مرتبط بالمكان • ${site.localityAr} • ${site.governorateAr}',
      icon: Icons.menu_book_outlined,
      eyebrow: 'مكتبة البحوث',
      maxWidth: 1360,
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: () => context.go(RoutePaths.research),
          icon: const Icon(Icons.library_books_outlined),
          label: const Text('مكتبة البحوث'),
        ),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.place(site.slug)),
          icon: const Icon(Icons.place_outlined),
          label: const Text('صفحة المكان'),
        ),
      ],
      header: _ResearchIdentityStrip(
        packageId: package.packageId,
        status: package.previewStatusLabelAr,
        location: '${site.localityAr} • ${site.governorateAr}',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          final main = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StagingResearchPackageCard(package: package),
              const SizedBox(height: 18),
              if (package.exposesResearchNarrativeReference)
                StagingResearchNarrativePanel(siteId: site.id)
              else
                _StatusOnlyPanel(
                  title: package.previewStatusLabelAr,
                  description: package.previewStatusDescriptionAr,
                ),
            ],
          );
          final aside = _ResearchAside(
            packageId: package.packageId,
            censusId: package.censusRecordId,
            evidenceGate: package.evidenceGate,
            uncertainty: package.uncertaintyClass,
            source: package.sourceReference,
            relationSummary: package.relationSummary,
            placeName: site.nameAr,
            onPlace: () => context.go(RoutePaths.place(site.slug)),
            onLibrary: () => context.go(RoutePaths.research),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                main,
                const SizedBox(height: 18),
                aside,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 7, child: main),
              const SizedBox(width: 22),
              SizedBox(width: 330, child: aside),
            ],
          );
        },
      ),
    );
  }
}

class _ResearchIdentityStrip extends StatelessWidget {
  const _ResearchIdentityStrip({
    required this.packageId,
    required this.status,
    required this.location,
  });

  final String packageId;
  final String status;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Chip(
          avatar: const Icon(Icons.inventory_2_outlined, size: 17),
          label: Text(packageId),
        ),
        Chip(
          avatar: const Icon(Icons.fact_check_outlined, size: 17),
          label: Text(status),
        ),
        Chip(
          avatar: const Icon(Icons.location_on_outlined, size: 17),
          label: Text(location),
        ),
      ],
    );
  }
}

class _ResearchAside extends StatelessWidget {
  const _ResearchAside({
    required this.packageId,
    required this.censusId,
    required this.evidenceGate,
    required this.uncertainty,
    required this.source,
    required this.relationSummary,
    required this.placeName,
    required this.onPlace,
    required this.onLibrary,
  });

  final String packageId;
  final String censusId;
  final String evidenceGate;
  final String uncertainty;
  final String source;
  final String relationSummary;
  final String placeName;
  final VoidCallback onPlace;
  final VoidCallback onLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'بطاقة البحث',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _Fact(label: 'الحزمة', value: packageId),
                _Fact(label: 'سجل Census', value: censusId),
                _Fact(label: 'بوابة الدليل', value: evidenceGate),
                _Fact(label: 'عدم اليقين', value: uncertainty),
                if (relationSummary.isNotEmpty)
                  _Fact(label: 'علاقة الكيان', value: relationSummary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.source_outlined),
                    SizedBox(width: 8),
                    Text(
                      'المصدر والتتبّع',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SelectableText(
                  source,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'واصل من $placeName',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onPlace,
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('صفحة المكان'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onLibrary,
                  icon: const Icon(Icons.library_books_outlined),
                  label: const Text('كل البحوث'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          SelectableText(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusOnlyPanel extends StatelessWidget {
  const _StatusOnlyPanel({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.pending_actions_outlined, size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(height: 1.7)),
            const SizedBox(height: 12),
            const Text(
              'لا يُنشأ سرد بديل أو محتوى تخميني عندما لا تسمح حالة الدليل بذلك.',
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentLockedBody extends StatelessWidget {
  const _EnvironmentLockedBody();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.lock_outline_rounded, size: 34),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'محتوى البحث الكامل محكوم ببيئة المراجعة غير الإنتاجية حاليًا. لا يتم تسريبه إلى Production قبل بوابة نشر مستقلة.',
                style: TextStyle(height: 1.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => context.go(RoutePaths.research),
        icon: const Icon(Icons.library_books_outlined),
        label: const Text('العودة إلى مكتبة البحوث'),
      ),
    );
  }
}
