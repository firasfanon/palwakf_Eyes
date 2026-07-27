import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class SourceRegistryWorkspaceScreen extends ConsumerStatefulWidget {
  const SourceRegistryWorkspaceScreen({super.key});

  @override
  ConsumerState<SourceRegistryWorkspaceScreen> createState() =>
      _SourceRegistryWorkspaceScreenState();
}

class _SourceRegistryWorkspaceScreenState
    extends ConsumerState<SourceRegistryWorkspaceScreen> {
  String query = '';

  Future<void> _addSource() async {
    final title = TextEditingController();
    final attribution = TextEditingController();
    final url = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مصدر إلى السجل'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: attribution,
                decoration: const InputDecoration(
                  labelText: 'المؤلف أو المؤسسة',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: url,
                decoration: const InputDecoration(labelText: 'الرابط'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل المصدر'),
          ),
        ],
      ),
    );

    if (confirmed == true && title.text.trim().isNotEmpty) {
      await ref
          .read(operationalWorkspaceStoreProvider)
          .addSource(
            title: title.text.trim(),
            attribution: attribution.text.trim(),
            sourceType: 'مرجع جديد',
            url: url.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل المصدر بانتظار المراجعة.')),
        );
      }
    }
    title.dispose();
    attribution.dispose();
    url.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(operationalSnapshotProvider);
    final store = ref.watch(operationalWorkspaceStoreProvider);

    return PalEyesTaskPage(
      title: 'سجل المصادر',
      subtitle: 'مصادر قابلة للبحث مع حالة بيانات وحقوق وروابط تشغيلية.',
      icon: Icons.library_books_outlined,
      notice:
          'وضع التشغيل: ${store.backendMode.labelAr}. المصدر الجديد غير منشور افتراضياً.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: _addSource,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة مصدر'),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل سجل المصادر: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          final rows = data.sources
              .where((source) {
                final needle = query.trim();
                return needle.isEmpty ||
                    source.title.contains(needle) ||
                    source.attribution.contains(needle) ||
                    source.sourceType.contains(needle);
              })
              .take(100)
              .toList(growable: false);

          return Column(
            children: <Widget>[
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  labelText: 'ابحث بالعنوان أو المؤسسة أو النوع',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixText: '${data.sources.length} مصدر',
                ),
              ),
              const SizedBox(height: 16),
              if (rows.isEmpty)
                PalEyesEmptyState(
                  title: 'لا توجد نتائج',
                  message: 'غيّر عبارة البحث أو أضف مصدراً جديداً.',
                  actionLabel: 'إضافة مصدر',
                  onAction: _addSource,
                  icon: Icons.search_off_outlined,
                )
              else
                ...rows.map(
                  (source) => Card(
                    child: PalEyesWorkflowStatus(
                      label: source.title,
                      status:
                          '${source.attribution} • ${source.workflowStatus} • حقوق: ${source.rightsStatus} • نشر: ${source.publicReleaseStatus}',
                      icon: Icons.menu_book_outlined,
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
