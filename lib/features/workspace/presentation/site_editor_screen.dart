import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class SiteEditorScreen extends ConsumerStatefulWidget {
  const SiteEditorScreen({super.key});

  @override
  ConsumerState<SiteEditorScreen> createState() => _SiteEditorScreenState();
}

class _SiteEditorScreenState extends ConsumerState<SiteEditorScreen> {
  int _step = 0;
  String? _selectedSiteId;
  String? _draftText;
  bool _dirty = false;
  bool _saving = false;

  static const _steps = <(String, IconData)>[
    ('الهوية', Icons.badge_outlined),
    ('الموقع الجغرافي', Icons.map_outlined),
    ('المادة الأصلية', Icons.history_edu_outlined),
    ('الرواية المحكومة', Icons.edit_note_outlined),
    ('المصادر', Icons.library_books_outlined),
    ('الخط الزمني', Icons.timeline_outlined),
    ('الوسائط والحقوق', Icons.perm_media_outlined),
    ('المراجعة', Icons.fact_check_outlined),
    ('المعاينة', Icons.preview_outlined),
  ];

  Future<void> _save(OperationalSiteRecord site) async {
    setState(() => _saving = true);
    try {
      await ref.read(operationalWorkspaceStoreProvider).saveSiteDraft(
            siteId: site.id,
            editorialDraft: _draftText ?? site.editorialDraft,
          );
      if (mounted) {
        setState(() {
          _dirty = false;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ المسودة وإنشاء إصدار جديد.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر الحفظ: $error')),
        );
      }
    }
  }

  Future<void> _submit(OperationalSiteRecord site) async {
    await ref
        .read(operationalWorkspaceStoreProvider)
        .submitSiteForReview(site.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الموقع إلى قائمة المراجعة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(operationalSnapshotProvider);
    final store = ref.watch(operationalWorkspaceStoreProvider);

    return PalEyesTaskPage(
      title: 'محرر الموقع',
      subtitle: 'حفظ نسخ، إرسال للمراجعة، ومعاينة دون نشر مباشر.',
      icon: Icons.edit_location_alt_outlined,
      notice:
          'وضع التشغيل: ${store.backendMode.labelAr}. المادة الأصلية محفوظة كطبقة غير قابلة للاستبدال.',
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل محرر المواقع: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          if (data.sites.isEmpty) {
            return const PalEyesNotice(
              text: 'لا توجد مواقع في طبقة التشغيل.',
              icon: Icons.location_off_outlined,
            );
          }

          final selectedId = _selectedSiteId ?? data.sites.first.id;
          final site = data.sites.firstWhere(
            (item) => item.id == selectedId,
            orElse: () => data.sites.first,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: site.id,
                decoration: InputDecoration(
                  labelText: 'الموقع الجاري تحريره',
                  helperText:
                      'إصدار ${site.versionNumber} • ${site.workflowStatus} • نشر: ${site.publicationStatus}',
                ),
                items: data.sites
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.nameAr),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSiteId = value;
                    _draftText = null;
                    _dirty = false;
                  });
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _saving ? null : () => _save(site),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_dirty ? 'حفظ المسودة' : 'محفوظ'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() => _step = 8),
                    icon: const Icon(Icons.preview_outlined),
                    label: const Text('معاينة'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _submit(site),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('إرسال للمراجعة'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _steps.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _steps[index];
                    return ChoiceChip(
                      selected: index == _step,
                      avatar: Icon(item.$2, size: 18),
                      label: Text('${index + 1}. ${item.$1}'),
                      onSelected: (_) => setState(() => _step = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _EditorStep(
                    key: ValueKey<String>('${site.id}-$_step'),
                    index: _step,
                    site: site,
                    draftValue: _draftText ?? site.editorialDraft,
                    onChanged: (value) {
                      setState(() {
                        _draftText = value;
                        _dirty = true;
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditorStep extends StatelessWidget {
  const _EditorStep({
    required this.index,
    required this.site,
    required this.draftValue,
    required this.onChanged,
    super.key,
  });

  final int index;
  final OperationalSiteRecord site;
  final String draftValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (index == 8) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            site.nameAr,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const PalEyesNotice(
            text: 'هذه معاينة داخلية. لا تعني اعتماد المادة أو نشرها.',
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 14),
          Text(
            draftValue.isEmpty
                ? 'لا توجد رواية محكومة بعد.'
                : draftValue,
            style: const TextStyle(height: 1.7),
          ),
        ],
      );
    }

    if (index == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'المادة التاريخية الأصلية',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          PalEyesNotice(
            text:
                'النوع: ${site.originalDraftProfile}. هذه الطبقة محفوظة ولا تُستبدل من محرر الرواية المحكومة.',
            icon: Icons.history_edu_outlined,
          ),
        ],
      );
    }

    if (index == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'الرواية المحكومة',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: draftValue,
            onChanged: onChanged,
            minLines: 10,
            maxLines: 18,
            decoration: const InputDecoration(
              labelText: 'النص التحريري المحكوم',
              helperText: 'الحفظ ينشئ إصداراً جديداً ولا ينشر النص.',
            ),
          ),
        ],
      );
    }

    final details = switch (index) {
      0 => 'الاسم: ${site.nameAr}\nالنوع: ${site.siteTypeAr}\nالحالة: ${site.workflowStatus}',
      1 => 'المحافظة: ${site.governorateAr}\nالتجمع: ${site.localityAr}\nالإحداثيات: ${site.coordinateStatus}',
      4 => 'عدد المصادر المرتبطة: ${site.sourceCount}',
      5 => 'الخط الزمني يظل مسودة حتى ربط الأحداث بالمصادر.',
      6 => 'الوسائط العامة المعتمدة: 0. الحقوق محجوبة افتراضياً.',
      7 => 'الادعاءات المعلقة: ${site.heldClaimCount}\nمرحلة الصفحة: ${site.pageCategory}',
      _ => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _steps[index].$1,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        SelectableText(details, style: const TextStyle(height: 1.8)),
      ],
    );
  }

  static const _steps = <(String, IconData)>[
    ('الهوية', Icons.badge_outlined),
    ('الموقع الجغرافي', Icons.map_outlined),
    ('المادة الأصلية', Icons.history_edu_outlined),
    ('الرواية المحكومة', Icons.edit_note_outlined),
    ('المصادر', Icons.library_books_outlined),
    ('الخط الزمني', Icons.timeline_outlined),
    ('الوسائط والحقوق', Icons.perm_media_outlined),
    ('المراجعة', Icons.fact_check_outlined),
    ('المعاينة', Icons.preview_outlined),
  ];
}
