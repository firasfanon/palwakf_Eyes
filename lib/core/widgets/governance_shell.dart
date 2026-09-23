import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/application/app_settings.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class GovernanceShell extends ConsumerWidget {
  const GovernanceShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final nav = _GovernanceNavigation(location: location);
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            toolbarHeight: 76,
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.sovereignGradient),
              child: PalEyesPattern(opacity: 0.035),
            ),
            leading: wide
                ? null
                : Builder(
                    builder: (context) => IconButton(
                      tooltip: 'القائمة',
                      onPressed: Scaffold.of(context).openDrawer,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.shield_outlined),
                SizedBox(width: 10),
                Text(
                  'مركز الحوكمة والنظام',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.workspace),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('مساحة العمل'),
              ),
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.home),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.public_rounded),
                label: const Text('الموقع العام'),
              ),
              IconButton(
                tooltip: 'تبديل السمة',
                onPressed: () =>
                    ref.read(themeModeControllerProvider.notifier).toggle(),
                icon: const Icon(Icons.contrast_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: wide ? null : Drawer(child: SafeArea(child: nav)),
          body: wide
              ? Row(
                  textDirection: Directionality.of(context),
                  children: <Widget>[
                    SizedBox(width: 292, child: nav),
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                )
              : child,
        );
      },
    );
  }
}

class _GovernanceNavigation extends StatelessWidget {
  const _GovernanceNavigation({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    const items = <_GovernanceItem>[
      _GovernanceItem(
        RoutePaths.admin,
        'لوحة الإدارة',
        Icons.admin_panel_settings_outlined,
      ),
      _GovernanceItem(
        RoutePaths.governance,
        'نظرة الحوكمة',
        Icons.policy_outlined,
      ),
      _GovernanceItem(
        RoutePaths.governanceWorkflows,
        'سير العمل والاعتماد',
        Icons.account_tree_outlined,
      ),
      _GovernanceItem(
        RoutePaths.governanceRights,
        'الحقوق والتراخيص',
        Icons.gavel_outlined,
      ),
      _GovernanceItem(
        RoutePaths.governanceAudit,
        'سجل التدقيق',
        Icons.history_outlined,
      ),
      _GovernanceItem(
        RoutePaths.governanceSystemStatus,
        'حالة النظام',
        Icons.monitor_heart_outlined,
      ),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.sovereignGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Stack(
              children: <Widget>[
                Positioned.fill(child: PalEyesPattern(opacity: 0.05)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.verified_user_outlined, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'طبقة الضبط المؤسسي',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'الصلاحيات، المراجعة، الحقوق، التدقيق وحالة النظام — منفصلة عن العمل التحريري وعن تجربة الزائر.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                selected: _selected(item.path),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(item.icon),
                title: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  final scaffold = Scaffold.maybeOf(context);
                  if (scaffold?.hasDrawer ?? false) {
                    Navigator.of(context).pop();
                  }
                  context.go(item.path);
                },
              ),
            ),
          ),
          const Divider(height: 28),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('العودة إلى مساحة العمل'),
            onTap: () => context.go(RoutePaths.workspace),
          ),
          ListTile(
            leading: const Icon(Icons.public_rounded),
            title: const Text('فتح الموقع العام'),
            onTap: () => context.go(RoutePaths.home),
          ),
        ],
      ),
    );
  }

  bool _selected(String path) {
    if (path == RoutePaths.admin || path == RoutePaths.governance) {
      return location == path;
    }
    return location.startsWith(path);
  }
}

class _GovernanceItem {
  const _GovernanceItem(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
