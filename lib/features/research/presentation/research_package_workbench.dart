import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/features/research/application/research_knowledge_workspace_provider.dart';
import 'package:pal_eyes/features/research/domain/research_package_v1.dart';

class ResearchPackageWorkbench extends ConsumerWidget {
  const ResearchPackageWorkbench({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(qattaninResearchPackagePilotProvider);
    final metrics = ref.watch(researchKnowledgeWorkspaceMetricsProvider);
    final specialistPending = package.reviews.any(
      (review) =>
          review.stage == ResearchReviewStage.specialistExpert &&
          review.decision == ResearchReviewDecision.pending,
    );

    return Card(
      key: const Key('research-package-workbench'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CircleAvatar(child: Icon(Icons.account_tree_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'نموذج المعرفة البحثية — تشغيل تجريبي',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilot سوق القطانين • ${package.packageId} • لا نشر ولا إنتاج',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text('${metrics.sectionCount} قسمًا')),
                Chip(label: Text('${metrics.claimCount} ادعاء')),
                Chip(label: Text('${metrics.sourceCount} مصدر')),
                Chip(label: Text('${metrics.locatorCount} موضع استشهاد')),
                Chip(label: Text('${metrics.conflictCount} تعارض/تفسير')),
                Chip(
                  label: Text(
                    metrics.pilotReady
                        ? 'التحقق البنيوي: PASS'
                        : 'مشكلات التحقق: ${metrics.validationIssueCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _GateRow(
              icon: Icons.person_outline,
              title: 'الاعتماد البشري التجريبي',
              value: 'ACCEPT — غير إنتاجي فقط',
              passed: true,
            ),
            _GateRow(
              icon: Icons.school_outlined,
              title: 'الدين التخصصي',
              value: specialistPending ? 'مفتوح قبل النشر/الإنتاج' : 'مغلق',
              passed: !specialistPending,
            ),
            const _GateRow(
              icon: Icons.public_off_outlined,
              title: 'النشر والإنتاج',
              value: 'مغلق — fail closed',
              passed: false,
            ),
            const SizedBox(height: 16),
            Text(
              'اكتمال المسودة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...package.sections.map(
              (section) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 15,
                  child: Text(section.order.toString()),
                ),
                title: Text(section.title),
                subtitle: Text(
                  '${section.paragraphs.length} فقرة • '
                  '${section.paragraphs.fold<int>(0, (sum, p) => sum + p.claimIds.length)} روابط ادعاء',
                ),
                trailing: const Icon(Icons.check_circle_outline),
              ),
            ),
            const Divider(height: 28),
            Text(
              'مؤشرات الأدلة والحقوق',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'التعارضات المفتوحة: ${metrics.openConflictCount} • '
              'وسائط جاهزة للنشر: ${metrics.rightsReadyCount}/${package.mediaRights.length} • '
              'دين المراجعة التخصصية: ${metrics.specialistDebtCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _GateRow extends StatelessWidget {
  const _GateRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.passed,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: passed
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
