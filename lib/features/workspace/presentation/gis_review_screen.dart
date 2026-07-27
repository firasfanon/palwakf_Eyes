import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';

class GisReviewScreen extends ConsumerWidget {
  const GisReviewScreen({super.key});

  Future<void> _addCandidate(BuildContext context, WidgetRef ref) async {
    final snapshot = await ref
        .read(operationalWorkspaceStoreProvider)
        .initialize();
    final site = snapshot.sites.firstWhere(
      (item) => !item.publicCoordinatesApproved,
      orElse: () => snapshot.sites.first,
    );
    await ref
        .read(operationalWorkspaceStoreProvider)
        .addCoordinateCandidate(
          siteId: site.id,
          siteNameAr: site.nameAr,
          latitude: 0,
          longitude: 0,
          sourceId: '',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء مرشح إحداثيات محجوب عن الخريطة العامة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(operationalSnapshotProvider);

    return PalEyesTaskPage(
      title: 'مراجعة الخرائط والإحداثيات',
      subtitle: 'مرشح → مصدر → مراجعة GIS → قرار داخلي → قرار عام.',
      icon: Icons.edit_location_alt_outlined,
      notice:
          'لا تظهر الإحداثيات المرشحة في الخريطة العامة، ولا تُرقّى تلقائياً.',
      actions: <Widget>[
        FilledButton.icon(
          onPressed: () => _addCandidate(context, ref),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('مرشح إحداثيات'),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل مراجعات GIS: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          return Column(
            children: <Widget>[
              ...data.coordinateCandidates
                  .take(50)
                  .map(
                    (candidate) => Card(
                      child: PalEyesWorkflowStatus(
                        label: candidate.siteNameAr,
                        status:
                            '${candidate.latitude}, ${candidate.longitude} • ${candidate.verificationStatus} • ${candidate.promotionStatus} • عام: ${candidate.publicMapUse}',
                        icon: Icons.my_location_outlined,
                      ),
                    ),
                  ),
              if (data.coordinateCandidates.isEmpty)
                PalEyesEmptyState(
                  title: '${data.coordinateGapCount} فجوة إحداثيات عامة',
                  message:
                      'أنشئ مرشحاً واربطه بمصدر قبل بدء المراجعة الجغرافية.',
                  actionLabel: 'إنشاء مرشح',
                  onAction: () => _addCandidate(context, ref),
                  icon: Icons.location_off_outlined,
                ),
            ],
          );
        },
      ),
    );
  }
}
