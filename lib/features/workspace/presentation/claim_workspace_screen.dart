import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class ClaimWorkspaceScreen extends ConsumerStatefulWidget {
  const ClaimWorkspaceScreen({super.key});

  @override
  ConsumerState<ClaimWorkspaceScreen> createState() =>
      _ClaimWorkspaceScreenState();
}

class _ClaimWorkspaceScreenState extends ConsumerState<ClaimWorkspaceScreen> {
  String status = 'الكل';

  Future<void> _updateClaim(
    OperationalClaimRecord claim,
    String nextStatus,
  ) async {
    await ref
        .read(operationalWorkspaceStoreProvider)
        .updateClaimStatus(
          claimId: claim.id,
          workflowStatus: nextStatus,
          evidenceStatus: nextStatus == 'SUPPORTED'
              ? 'EVIDENCE_ATTACHED'
              : claim.evidenceStatus,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث الادعاء إلى $nextStatus.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(operationalSnapshotProvider);

    return PalEyesTaskPage(
      title: 'مساحة الادعاءات',
      subtitle: 'كل ادعاء وحدة عمل لها حالة بحث ودليل وقرار مستقل.',
      icon: Icons.fact_check_outlined,
      notice:
          'تحويل الادعاء إلى مدعوم لا ينقله تلقائياً إلى الرواية التحريرية أو النشر العام.',
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => PalEyesNotice(
          text: 'تعذر تحميل الادعاءات: $error',
          icon: Icons.error_outline,
        ),
        data: (data) {
          final visible = data.claims
              .where((claim) {
                return status == 'الكل' || claim.workflowStatus == status;
              })
              .take(80)
              .toList(growable: false);

          final statuses = <String>{
            'الكل',
            ...data.claims.map((claim) => claim.workflowStatus),
          }.toList(growable: false);

          return Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(
                  labelText: 'حالة الادعاء',
                  helperText: '${data.claims.length} ادعاء في السجل المحكوم',
                ),
                items: statuses
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => status = value ?? 'الكل'),
              ),
              const SizedBox(height: 16),
              ...visible.map(
                (claim) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${claim.priorityScore}'),
                    ),
                    title: Text(
                      claim.claimText,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${claim.siteNameAr} • ${claim.priorityTier} • ${claim.workflowStatus} • ${claim.evidenceStatus}',
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'تغيير الحالة',
                      onSelected: (value) => _updateClaim(claim, value),
                      itemBuilder: (context) => const <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'RESEARCHING',
                          child: Text('قيد البحث'),
                        ),
                        PopupMenuItem(
                          value: 'EVIDENCE_ATTACHED',
                          child: Text('أُرفق دليل'),
                        ),
                        PopupMenuItem(value: 'SUPPORTED', child: Text('مدعوم')),
                        PopupMenuItem(
                          value: 'PARTIALLY_SUPPORTED',
                          child: Text('مدعوم جزئياً'),
                        ),
                        PopupMenuItem(value: 'HOLD', child: Text('تعليق')),
                      ],
                    ),
                  ),
                ),
              ),
              if (visible.isEmpty)
                const PalEyesNotice(
                  text: 'لا توجد ادعاءات مطابقة للحالة المحددة.',
                  icon: Icons.search_off_outlined,
                ),
            ],
          );
        },
      ),
    );
  }
}
