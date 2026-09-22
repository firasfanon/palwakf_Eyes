import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    OperationalReviewTask task,
    String decision,
  ) async {
    await ref.read(operationalWorkspaceStoreProvider).decideReviewTask(
          taskId: task.id,
          decision: decision,
          note: 'قرار من واجهة المراجعة التشغيلية.',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيل القرار: $decision')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(operationalSnapshotProvider);

    return PalEyesTaskPage(
      title: 'قائمة المراجعة',
      subtitle: 'مهام حقيقية قابلة للقرار مع سجل تدقيق لكل انتقال.',
      icon: Icons.rate_review_outlined,
      notice:
          'قرار سير العمل لا يساوي اعتمادًا تخصصيًا أو سياديًا. الاعتماد التجريبي ≠ اعتماد الخبير، وبوابة الإصدار والنشر مستقلة ومغلقة.',
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل قائمة المراجعة: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          final tasks = data.reviewTasks.take(100).toList(growable: false);
          if (tasks.isEmpty) {
            return const PalEyesNotice(
              text: 'لا توجد مهام مراجعة حالياً.',
              icon: Icons.task_alt_outlined,
            );
          }

          return Column(
            children: tasks.map((task) {
              final closed = task.status != 'OPEN' && task.status != 'IN_REVIEW';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: <Widget>[
                      PalEyesWorkflowStatus(
                        label: task.title,
                        status:
                            '${task.reviewType} • ${task.priority} • ${task.status} • ${task.assigneeLabel}',
                        icon: task.reviewType == 'GIS'
                            ? Icons.map_outlined
                            : Icons.fact_check_outlined,
                      ),
                      if (!closed)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Wrap(
                            spacing: 8,
                            children: <Widget>[
                              TextButton(
                                onPressed: () => _decide(
                                  context,
                                  ref,
                                  task,
                                  'RETURN_FOR_REVISION',
                                ),
                                child: const Text('إعادة للتعديل'),
                              ),
                              TextButton(
                                onPressed: () => _decide(
                                  context,
                                  ref,
                                  task,
                                  'HOLD',
                                ),
                                child: const Text('تعليق'),
                              ),
                              FilledButton(
                                onPressed: () => _decide(
                                  context,
                                  ref,
                                  task,
                                  'ACCEPT',
                                ),
                                child: const Text('قبول'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}
