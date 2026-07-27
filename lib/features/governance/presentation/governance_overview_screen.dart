import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

class GovernanceOverviewScreen extends StatelessWidget {
  const GovernanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String, String, String)>[
      (
        Icons.account_tree_outlined,
        'سير العمل',
        'حالات المسودة والمراجعة والاعتماد.',
        RoutePaths.governanceWorkflows,
      ),
      (
        Icons.gavel_outlined,
        'الحقوق والتراخيص',
        'سياسات المصادر والوسائط والمقابلات.',
        RoutePaths.governanceRights,
      ),
      (
        Icons.history_outlined,
        'سجل التدقيق',
        'الأحداث والإصدارات والقرارات.',
        RoutePaths.governanceAudit,
      ),
      (
        Icons.monitor_heart_outlined,
        'حالة النظام',
        'البيئة والتكاملات وRuntime.',
        RoutePaths.governanceSystemStatus,
      ),
    ];

    return PalEyesPage(
      title: 'الحوكمة والنظام',
      subtitle: 'تفاصيل داخلية معزولة عن الصفحات العامة والعمل اليومي.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 850
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: items
                .map(
                  (item) => SizedBox(
                    width: width,
                    child: Card(
                      child: InkWell(
                        onTap: () => context.go(item.$4),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(child: Icon(item.$1)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item.$2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(item.$3),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_left_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
