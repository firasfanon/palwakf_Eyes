import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/application/app_settings.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class WorkspaceShell extends ConsumerWidget {
  const WorkspaceShell({
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
        final compact = constraints.maxWidth < 620;
        final sidebar = _WorkspaceSidebar(location: location);
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 74,
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.sovereignGradient,
              ),
              child: PalEyesPattern(opacity: 0.03),
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
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const PalEyesBrandMark(compact: true),
                if (!compact) ...<Widget>[
                  const SizedBox(width: 16),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    location.startsWith(RoutePaths.governance)
                        ? 'الحوكمة والنظام'
                        : 'مساحة العمل',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ],
            ),
            actions: <Widget>[
              if (compact)
                IconButton(
                  tooltip: 'الموقع العام',
                  onPressed: () => context.go(RoutePaths.home),
                  icon: const Icon(Icons.public_rounded),
                )
              else
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
              if (!compact)
                IconButton(
                  tooltip: 'تبديل اللغة',
                  onPressed: () =>
                      ref.read(localeControllerProvider.notifier).toggle(),
                  icon: const Icon(Icons.translate_rounded),
                ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: wide ? null : Drawer(child: SafeArea(child: sidebar)),
          body: wide
              ? Row(
                  textDirection: Directionality.of(context),
                  children: <Widget>[
                    SizedBox(width: 306, child: sidebar),
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

class _WorkspaceSidebar extends StatelessWidget {
  const _WorkspaceSidebar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.sovereignGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Stack(
              children: <Widget>[
                Positioned.fill(child: PalEyesPattern(opacity: 0.045)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'مركز العمل اليومي',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'المواقع، التوثيق، المساهمات والمراجعات في مسار واحد واضح.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ..._groups.map(
            (group) => _NavigationGroupTile(
              group: group,
              location: location,
            ),
          ),
        ],
      ),
    );
  }

  static const List<_WorkspaceGroup> _groups = <_WorkspaceGroup>[
    _WorkspaceGroup(
      title: 'الرئيسية والعمل اليومي',
      icon: Icons.space_dashboard_outlined,
      initiallyExpanded: true,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.workspace,
          label: 'لوحة العمل',
          icon: Icons.dashboard_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceToday,
          label: 'اليوم',
          icon: Icons.today_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceTasks,
          label: 'مهامي والإشعارات',
          icon: Icons.task_alt_outlined,
        ),
      ],
    ),
    _WorkspaceGroup(
      title: 'المواقع والأماكن',
      icon: Icons.account_balance_outlined,
      initiallyExpanded: true,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.workspacePlaces,
          label: 'جميع المواقع',
          icon: Icons.location_on_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceSiteEditor,
          label: 'محرر الموقع',
          icon: Icons.edit_location_alt_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceNewPlace,
          label: 'إضافة موقع',
          icon: Icons.add_location_alt_outlined,
        ),
      ],
    ),
    _WorkspaceGroup(
      title: 'التوثيق والمعرفة',
      icon: Icons.menu_book_outlined,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.workspaceNarratives,
          label: 'الوثائق التاريخية',
          icon: Icons.description_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceClaims,
          label: 'الادعاءات والاستشهادات',
          icon: Icons.fact_check_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceSourceRegistry,
          label: 'سجل المصادر',
          icon: Icons.library_books_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceSources,
          label: 'المصادر والأدلة',
          icon: Icons.library_books_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceMedia,
          label: 'الوسائط',
          icon: Icons.perm_media_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceOralHistory,
          label: 'الذاكرة الشفوية',
          icon: Icons.record_voice_over_outlined,
        ),
      ],
    ),
    _WorkspaceGroup(
      title: 'الجغرافيا والاستكشاف',
      icon: Icons.map_outlined,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.workspaceMapEditor,
          label: 'محرر الخريطة',
          icon: Icons.edit_location_alt_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceRelationships,
          label: 'العلاقات والأسماء',
          icon: Icons.hub_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceGeography,
          label: 'المحافظات والأسماء',
          icon: Icons.location_city_outlined,
        ),
      ],
    ),
    _WorkspaceGroup(
      title: 'المجتمع والمساهمات',
      icon: Icons.groups_outlined,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.workspaceContributions,
          label: 'المساهمات والبلاغات',
          icon: Icons.volunteer_activism_outlined,
        ),
      ],
    ),
    _WorkspaceGroup(
      title: 'المراجعة والنشر والجودة',
      icon: Icons.verified_outlined,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.workspaceReviews,
          label: 'قائمة المراجعة',
          icon: Icons.rate_review_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceReleaseControl,
          label: 'المعاينة ومرشح الإصدار',
          icon: Icons.rocket_launch_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceAudit,
          label: 'سجل التدقيق',
          icon: Icons.history_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspacePublication,
          label: 'النشر والجودة',
          icon: Icons.publish_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.workspaceReports,
          label: 'التقارير والفجوات',
          icon: Icons.analytics_outlined,
        ),
      ],
    ),
    _WorkspaceGroup(
      title: 'الحوكمة والنظام',
      icon: Icons.admin_panel_settings_outlined,
      governance: true,
      items: <_WorkspaceItem>[
        _WorkspaceItem(
          path: RoutePaths.governance,
          label: 'نظرة الحوكمة',
          icon: Icons.policy_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.governanceWorkflows,
          label: 'سير العمل',
          icon: Icons.account_tree_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.governanceRights,
          label: 'الحقوق والتراخيص',
          icon: Icons.gavel_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.governanceAudit,
          label: 'سجل التدقيق',
          icon: Icons.history_outlined,
        ),
        _WorkspaceItem(
          path: RoutePaths.governanceSystemStatus,
          label: 'حالة النظام',
          icon: Icons.monitor_heart_outlined,
        ),
      ],
    ),
  ];
}

class _NavigationGroupTile extends StatelessWidget {
  const _NavigationGroupTile({
    required this.group,
    required this.location,
  });

  final _WorkspaceGroup group;
  final String location;

  @override
  Widget build(BuildContext context) {
    final active = group.items.any((item) => _selected(item.path));
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ExpansionTile(
        initiallyExpanded: group.initiallyExpanded || active,
        leading: Icon(group.icon),
        title: Text(
          group.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: group.governance
                ? Theme.of(context).colorScheme.secondary
                : null,
          ),
        ),
        children: group.items
            .map(
              (item) => Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: true,
                  selected: _selected(item.path),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  onTap: () {
                    final scaffold = Scaffold.maybeOf(context);
                    if (scaffold?.hasDrawer ?? false) {
                      Navigator.of(context).pop();
                    }
                    context.go(item.path);
                  },
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  bool _selected(String path) {
    if (path == RoutePaths.workspace || path == RoutePaths.governance) {
      return location == path;
    }
    return location.startsWith(path);
  }
}

class _WorkspaceGroup {
  const _WorkspaceGroup({
    required this.title,
    required this.icon,
    required this.items,
    this.initiallyExpanded = false,
    this.governance = false,
  });

  final String title;
  final IconData icon;
  final List<_WorkspaceItem> items;
  final bool initiallyExpanded;
  final bool governance;
}

class _WorkspaceItem {
  const _WorkspaceItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}
