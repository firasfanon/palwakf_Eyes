import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controls = <_AdminControl>[
      _AdminControl(
        title: 'الحوكمة',
        description: 'السياسات، الحالات، بوابات الاعتماد والنشر.',
        icon: Icons.policy_outlined,
        route: RoutePaths.governance,
      ),
      _AdminControl(
        title: 'سير العمل',
        description: 'المسودة، المراجعة، الاعتماد، والإصدار.',
        icon: Icons.account_tree_outlined,
        route: RoutePaths.governanceWorkflows,
      ),
      _AdminControl(
        title: 'الحقوق والتراخيص',
        description: 'حقوق المصادر والصور والتسجيلات والاستخدام.',
        icon: Icons.gavel_outlined,
        route: RoutePaths.governanceRights,
      ),
      _AdminControl(
        title: 'سجل التدقيق',
        description: 'الأحداث والقرارات والتغييرات القابلة للتتبع.',
        icon: Icons.history_outlined,
        route: RoutePaths.governanceAudit,
      ),
      _AdminControl(
        title: 'حالة النظام',
        description: 'البيئة والتكاملات وRuntime وصحة الخدمات.',
        icon: Icons.monitor_heart_outlined,
        route: RoutePaths.governanceSystemStatus,
      ),
    ];

    return PalEyesPage(
      title: 'لوحة الإدارة والحوكمة',
      subtitle:
          'طبقة ضبط مستقلة عن تجربة الزائر وعن مساحة التحرير: صلاحيات، سياسات، تدقيق، حقوق وحالة النظام.',
      icon: Icons.admin_panel_settings_outlined,
      eyebrow: 'ADMIN • GOVERNANCE',
      maxWidth: 1320,
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: () => context.go(RoutePaths.workspace),
          icon: const Icon(Icons.edit_note_outlined),
          label: const Text('مساحة العمل'),
        ),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.home),
          icon: const Icon(Icons.public_rounded),
          label: const Text('الموقع العام'),
        ),
      ],
      header: const _AdminBoundaryBanner(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _AuthorityStrip(),
          const SizedBox(height: 24),
          const PalEyesSectionHeader(
            eyebrow: 'طبقة الإدارة',
            title: 'تحكم مؤسسي لا يختلط بالتحرير اليومي',
            subtitle:
                'جميع مسارات الحوكمة معروضة هنا بوضوح، بينما يبقى إنشاء المحتوى ومراجعته في Workspace.',
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1080
                  ? 3
                  : constraints.maxWidth >= 720
                  ? 2
                  : 1;
              const gap = 14.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: controls
                    .map(
                      (item) => SizedBox(
                        width: width,
                        child: _AdminControlCard(control: item),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'حدود السلطة الحالية',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'لا تمنح هذه الشاشة تلقائيًا صلاحية نشر أو Production أو تطبيق migration على Shared Supabase. كل بوابة مستقلة.',
                          style: TextStyle(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: null,
                    icon: Icon(Icons.lock_outline_rounded),
                    label: Text('Fail-closed'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBoundaryBanner extends StatelessWidget {
  const _AdminBoundaryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.shield_outlined),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ADMIN ≠ WORKSPACE ≠ PUBLIC. الزائر يقرأ ويستكشف؛ الفريق ينشئ ويراجع؛ الحوكمة تضبط السلطة والحقوق والإصدار.',
              style: TextStyle(fontWeight: FontWeight.w800, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorityStrip extends StatelessWidget {
  const _AuthorityStrip();

  @override
  Widget build(BuildContext context) {
    const metrics = <(IconData, String, String)>[
      (Icons.public_off_outlined, 'NO', 'نشر تلقائي'),
      (Icons.cloud_off_outlined, 'NO', 'Production mutation'),
      (Icons.storage_outlined, 'NO', 'Shared DB apply'),
      (Icons.visibility_outlined, 'READ', 'المعاينة الحالية'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: PalEyesMetricTile(
                    icon: metric.$1,
                    value: metric.$2,
                    label: metric.$3,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _AdminControlCard extends StatelessWidget {
  const _AdminControlCard({required this.control});

  final _AdminControl control;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(control.route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(child: Icon(control.icon)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      control.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      control.description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminControl {
  const _AdminControl({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
}
