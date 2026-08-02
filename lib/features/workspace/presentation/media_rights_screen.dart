import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';

class MediaRightsScreen extends ConsumerWidget {
  const MediaRightsScreen({super.key});

  Future<void> _registerAsset(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final owner = TextEditingController();
    final snapshot =
        await ref.read(operationalWorkspaceStoreProvider).initialize();
    if (!context.mounted) {
      title.dispose();
      owner.dispose();
      return;
    }
    final site = snapshot.sites.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل مادة وسائط'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'عنوان المادة'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: owner,
              decoration: const InputDecoration(labelText: 'المالك أو المصدر'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );

    if (confirmed == true && title.text.trim().isNotEmpty) {
      await ref.read(operationalWorkspaceStoreProvider).registerMediaAsset(
            siteId: site.id,
            title: title.text.trim(),
            assetType: 'image',
            ownerLabel: owner.text.trim().isEmpty ? 'غير محدد' : owner.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل الوسائط وحظر النشر حتى مراجعة الحقوق.')),
        );
      }
    }
    title.dispose();
    owner.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(operationalSnapshotProvider);

    return PalEyesTaskPage(
      title: 'الوسائط والحقوق',
      subtitle: 'تسجيل الوسائط منفصل عن اعتماد استخدامها أو نشرها.',
      icon: Icons.perm_media_outlined,
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => _registerAsset(context, ref),
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('تسجيل مادة'),
        ),
      ],
      notice:
          'الوضع الافتراضي لأي مادة جديدة: الاستخدام الداخلي محجوب والنشر العام محجوب.',
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل سجل الوسائط: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          if (data.mediaAssets.isEmpty) {
            return PalEyesEmptyState(
              title: 'لا توجد وسائط مسجلة',
              message:
                  'ابدأ بتسجيل ملف ووصفه وتحديد مالكه قبل أي مراجعة حقوق.',
              actionLabel: 'تسجيل مادة',
              onAction: () => _registerAsset(context, ref),
              icon: Icons.photo_library_outlined,
            );
          }

          return Column(
            children: data.mediaAssets.map((asset) {
              return Card(
                child: PalEyesWorkflowStatus(
                  label: asset.title,
                  status:
                      '${asset.assetType} • مالك: ${asset.ownerLabel} • حقوق: ${asset.rightsStatus} • داخلي: ${asset.internalUseStatus} • عام: ${asset.publicUseStatus}',
                  icon: Icons.image_outlined,
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}
