import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(operationalSnapshotProvider);

    return PalEyesTaskPage(
      title: 'سجل التدقيق',
      subtitle: 'خط زمني محفوظ للأفعال والقرارات والانتقالات التشغيلية.',
      icon: Icons.history_outlined,
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل سجل التدقيق: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          return Column(
            children: data.auditEvents.take(200).map((event) {
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.history_toggle_off),
                  ),
                  title: Text(
                    event.summary,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${event.actorLabel} • ${event.action} • ${event.entityType}:${event.entityId} • ${event.createdAt.toLocal()}',
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
