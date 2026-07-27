import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class WorkspaceTodayScreen extends ConsumerWidget {
  const WorkspaceTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(operationalSnapshotProvider);
    final store = ref.watch(operationalWorkspaceStoreProvider);

    return PalEyesTaskPage(
      title: 'اليوم',
      subtitle: 'أولويات تشغيلية حقيقية من طبقة البيانات المحكومة.',
      icon: Icons.today_outlined,
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: () => store.refresh(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('تحديث'),
        ),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.workspaceReviews),
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('قائمة المراجعة'),
        ),
      ],
      notice:
          'وضع التشغيل: ${store.backendMode.labelAr}. مرشح الإصدار لا ينشر المحتوى تلقائياً.',
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل طبقة التشغيل: $error',
          icon: Icons.error_outline_rounded,
        ),
        data: (data) => _TodayData(data: data),
      ),
    );
  }
}

class _TodayData extends StatelessWidget {
  const _TodayData({required this.data});

  final OperationalSnapshot data;

  @override
  Widget build(BuildContext context) {
    final tasks = data.reviewTasks
        .where((task) => task.status == 'OPEN')
        .take(4)
        .toList(growable: false);

    return Column(
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 900
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 560
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: width,
                  child: PalEyesKpiCard(
                    label: 'مراجعات مفتوحة',
                    value: '${data.openReviewCount}',
                    icon: Icons.priority_high_rounded,
                    helper: 'تحرير، مصادر، GIS وحقوق',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: PalEyesKpiCard(
                    label: 'مصادر تحتاج عملاً',
                    value: '${data.missingSourceMetadataCount}',
                    icon: Icons.library_books_outlined,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: PalEyesKpiCard(
                    label: 'فجوات إحداثيات عامة',
                    value: '${data.coordinateGapCount}',
                    icon: Icons.location_off_outlined,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: PalEyesKpiCard(
                    label: 'وسائط حقوقها معلقة',
                    value: '${data.pendingRightsCount}',
                    icon: Icons.gavel_outlined,
                    helper: 'الافتراضي: النشر محجوب',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        if (tasks.isEmpty)
          PalEyesEmptyState(
            title: 'لا توجد مراجعات مفتوحة',
            message: 'أرسل موقعاً أو ادعاءً إلى المراجعة لإنشاء مهمة جديدة.',
            actionLabel: 'فتح محرر الموقع',
            onAction: () => context.go(RoutePaths.workspaceSiteEditor),
            icon: Icons.task_alt_outlined,
          )
        else
          ...tasks.map(
            (task) => PalEyesActionCard(
              title: task.title,
              subtitle:
                  '${task.reviewType} • ${task.assigneeLabel} • ${task.status}',
              icon: task.reviewType == 'GIS'
                  ? Icons.map_outlined
                  : Icons.fact_check_outlined,
              badge: task.priority,
              onTap: () => context.go(RoutePaths.workspaceReviews),
            ),
          ),
      ],
    );
  }
}
