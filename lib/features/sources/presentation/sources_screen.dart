import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/data/content_catalog_metrics.dart';
import 'package:pal_eyes/features/sources/domain/draft_source_registry_entry.dart';

class SourcesScreen extends ConsumerStatefulWidget {
  const SourcesScreen({super.key});

  @override
  ConsumerState<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends ConsumerState<SourcesScreen> {
  static const int _pageSize = 20;

  final TextEditingController _queryController = TextEditingController();
  String _role = 'الكل';
  String _rights = 'الكل';
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presentationMode = ref.watch(palEyesPresentationModeProvider);
    final registry = ref.watch(draftSourceRegistryProvider);
    final query = _queryController.text.trim().toLowerCase();
    final filtered = registry
        .where((entry) {
          final haystack = <String>[
            entry.id,
            entry.title,
            entry.attribution,
            entry.sourceTypeAr,
            entry.note,
            entry.url,
          ].join(' ').toLowerCase();
          final roleMatches =
              _role == 'الكل' ||
              (_role == 'مصادر القصص والمواقع'
                  ? entry.isEditorialSource
                  : !entry.isEditorialSource);
          final rightsMatches =
              _rights == 'الكل' || entry.textReuseStatus == _rights;
          return (query.isEmpty || haystack.contains(query)) &&
              roleMatches &&
              rightsMatches;
        })
        .toList(growable: false);

    final visible = filtered.take(_visibleCount).toList(growable: false);
    final rightsValues = <String>{
      'الكل',
      ...registry
          .map((entry) => entry.textReuseStatus)
          .where((value) => value.isNotEmpty),
    }.toList()..sort();

    return PalEyesPage(
      title: 'مكتبة المصادر',
      icon: Icons.library_books_outlined,
      eyebrow: 'اعرف ما وراء الحكاية',
      subtitle:
          '${ContentCatalogMetrics.governedSourceRegistryCount} مرجعاً وبحثاً يقود صفحات المواقع والقصص.',
      header: presentationMode.isInternal
          ? PalEyesPublicDisclosure(
              summary:
                  'وجود المرجع في المكتبة لا يعني السماح بنسخ نصه أو صوره؛ لذلك نعرض بياناته ومسار استخدامه بوضوح.',
              details: const <String>[
                'الاستشهاد بالمعلومة يختلف عن إعادة نشر النص أو الصورة.',
                'تُراجع الطبعة والصفحة والرابط قبل اعتماد الاستشهاد.',
                'حقوق الوسائط تُحسم على مستوى كل ملف.',
              ],
              actionLabel: 'كيف نستخدم المصادر؟',
              onAction: () => context.go(RoutePaths.methodology),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PalEyesPublicSearchPanel(
            controller: _queryController,
            hintText: 'عنوان، مؤسسة، مؤلف، نوع مصدر…',
            activeFilterCount: <bool>[
              _role != 'الكل',
              _rights != 'الكل',
            ].where((value) => value).length,
            onChanged: (_) => setState(() {
              _visibleCount = _pageSize;
            }),
            onClear: () {
              _queryController.clear();
              setState(() {
                _visibleCount = _pageSize;
              });
            },
            filters: LayoutBuilder(
              builder: (context, constraints) {
                final vertical = constraints.maxWidth < 620;
                final role = _Filter(
                  label: 'كيف يُستخدم المصدر؟',
                  value: _role,
                  items: const <String>[
                    'الكل',
                    'مصادر القصص والمواقع',
                    'مصادر البحث الجاري',
                  ],
                  onChanged: (value) => setState(() {
                    _role = value;
                    _visibleCount = _pageSize;
                  }),
                );
                final rights = _Filter(
                  label: 'إمكانية استخدام النص',
                  value: _rights,
                  items: rightsValues,
                  onChanged: (value) => setState(() {
                    _rights = value;
                    _visibleCount = _pageSize;
                  }),
                );
                return vertical
                    ? Column(
                        children: <Widget>[
                          role,
                          const SizedBox(height: 12),
                          rights,
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(child: role),
                          const SizedBox(width: 12),
                          Expanded(child: rights),
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Text(
                'المراجع',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Chip(label: Text('${filtered.length} من ${registry.length}')),
            ],
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            const PalEyesPublicStatePanel(
              kind: PublicContentStateKind.empty,
              title: 'لا توجد مراجع مطابقة',
              message: 'جرّب عنواناً أقصر أو أزل أحد الفلاتر.',
            )
          else
            ...visible.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SourceCard(entry: entry),
              ),
            ),
          if (visible.length < filtered.length) ...<Widget>[
            const SizedBox(height: 12),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () => setState(() {
                  _visibleCount += _pageSize;
                }),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(
                  'إظهار المزيد (${filtered.length - visible.length} متبقية)',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.entry});

  final DraftSourceRegistryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'مصدر: ${entry.title}. ${entry.attribution}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const CircleAvatar(child: Icon(Icons.library_books_outlined)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(entry.attribution),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(entry.note),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: <Widget>[
                  Chip(label: Text(entry.sourceTypeAr)),
                  Chip(label: Text('${entry.mentionedSiteCount} مواقع مرتبطة')),
                  Chip(label: Text('النص: ${entry.textReuseStatus}')),
                ],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'عن هذا المصدر',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.image_outlined),
                    title: Text('الصور: ${entry.imageReuseStatus}'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.public_outlined),
                    title: Text('النشر: ${entry.publicReleaseStatus}'),
                  ),
                  if (entry.url.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.link_rounded),
                      title: SelectableText(entry.url),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
