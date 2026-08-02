import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/application/app_settings.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class PublicShell extends ConsumerWidget {
  const PublicShell({
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
        final wide = constraints.maxWidth >= 1080;
        final compact = constraints.maxWidth < 620;
        final mobileSelected = _selectedIndex(_mobileItems);

        return FocusTraversalGroup(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 76,
              titleSpacing: compact ? 12 : 20,
              flexibleSpace: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.sovereignGradient,
                ),
                child: PalEyesPattern(opacity: 0.035),
              ),
              title: Semantics(
                button: true,
                label: 'العودة إلى الصفحة الرئيسية',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.go(RoutePaths.home),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: PalEyesBrandMark(compact: compact),
                  ),
                ),
              ),
              actions: <Widget>[
                if (wide)
                  ..._primaryItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _NavButton(
                        item: item,
                        selected: _isSelected(item.path),
                        onPressed: () => context.go(item.path),
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'البحث في الأطلس',
                  onPressed: () => context.go(RoutePaths.discover),
                  icon: const Icon(Icons.search_rounded),
                ),
                if (!compact)
                  IconButton(
                    tooltip: 'تبديل التباين والسمة',
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
                if (wide)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: PopupMenuButton<String>(
                      tooltip: 'المزيد',
                      icon: const Icon(Icons.more_horiz_rounded),
                      onSelected: (location) => context.go(location),
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        ..._secondaryItems.map(
                          (item) => PopupMenuItem<String>(
                            value: item.path,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(item.icon),
                              title: Text(item.label),
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: RoutePaths.workspace,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.dashboard_customize_outlined,
                            ),
                            title: Text('مساحة الفريق'),
                            subtitle: Text('للباحثين والمحررين'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'القائمة',
                      onPressed: Scaffold.of(context).openEndDrawer,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
              ],
            ),
            endDrawer: wide
                ? null
                : Drawer(
                    child: SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(14),
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: AppColors.sovereignGradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                PalEyesBrandMark(),
                                SizedBox(height: 14),
                                Text(
                                  'أطلس ومتحف ومجلة سردية تقودك من المكان إلى القصة والمصدر.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'اكتشف فلسطين',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          ..._primaryItems.map(
                            (item) => _DrawerItem(
                              item: item,
                              selected: _isSelected(item.path),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.go(item.path);
                              },
                            ),
                          ),
                          const Divider(height: 28),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'اقرأ وتعمّق',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          ..._secondaryItems.map(
                            (item) => _DrawerItem(
                              item: item,
                              selected: _isSelected(item.path),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.go(item.path);
                              },
                            ),
                          ),
                          const Divider(height: 28),
                          ListTile(
                            leading: const Icon(Icons.contrast_rounded),
                            title: const Text('تبديل التباين والسمة'),
                            onTap: () => ref
                                .read(themeModeControllerProvider.notifier)
                                .toggle(),
                          ),
                          ListTile(
                            leading: const Icon(Icons.translate_rounded),
                            title: const Text('تبديل اللغة'),
                            onTap: () => ref
                                .read(localeControllerProvider.notifier)
                                .toggle(),
                          ),
                          const Divider(height: 28),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go(RoutePaths.workspace);
                            },
                            icon: const Icon(
                              Icons.dashboard_customize_outlined,
                            ),
                            label: const Text('مساحة الفريق'),
                          ),
                        ],
                      ),
                    ),
                  ),
            body: Semantics(
              container: true,
              label: 'المحتوى الرئيسي',
              child: child,
            ),
            bottomNavigationBar: constraints.maxWidth < 720
                ? NavigationBar(
                    selectedIndex: mobileSelected,
                    onDestinationSelected: (index) =>
                        context.go(_mobileItems[index].path),
                    destinations: _mobileItems
                        .map(
                          (item) => NavigationDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: item.label,
                          ),
                        )
                        .toList(growable: false),
                  )
                : null,
          ),
        );
      },
    );
  }

  bool _isSelected(String path) {
    return path == RoutePaths.home
        ? location == RoutePaths.home
        : location.startsWith(path);
  }

  int _selectedIndex(List<_PublicItem> items) {
    final index = items.indexWhere((item) => _isSelected(item.path));
    return index < 0 ? 0 : index;
  }

  static const List<_PublicItem> _primaryItems = <_PublicItem>[
    _PublicItem(
      path: RoutePaths.home,
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _PublicItem(
      path: RoutePaths.discover,
      label: 'استكشف',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
    ),
    _PublicItem(
      path: RoutePaths.places,
      label: 'الأطلس',
      icon: Icons.account_balance_outlined,
      selectedIcon: Icons.account_balance_rounded,
    ),
    _PublicItem(
      path: RoutePaths.map,
      label: 'الخريطة',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    _PublicItem(
      path: RoutePaths.stories,
      label: 'القصص',
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
    ),
  ];

  static const List<_PublicItem> _mobileItems = <_PublicItem>[
    _PublicItem(
      path: RoutePaths.home,
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _PublicItem(
      path: RoutePaths.discover,
      label: 'استكشف',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
    ),
    _PublicItem(
      path: RoutePaths.map,
      label: 'الخريطة',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    _PublicItem(
      path: RoutePaths.stories,
      label: 'القصص',
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
    ),
  ];

  static const List<_PublicItem> _secondaryItems = <_PublicItem>[
    _PublicItem(
      path: RoutePaths.timeline,
      label: 'الخط الزمني',
      icon: Icons.timeline_outlined,
      selectedIcon: Icons.timeline_rounded,
    ),
    _PublicItem(
      path: RoutePaths.governorates,
      label: 'المحافظات',
      icon: Icons.location_city_outlined,
      selectedIcon: Icons.location_city_rounded,
    ),
    _PublicItem(
      path: RoutePaths.sources,
      label: 'مكتبة المصادر',
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books_rounded,
    ),
    _PublicItem(
      path: RoutePaths.contribute,
      label: 'ساهم معنا',
      icon: Icons.volunteer_activism_outlined,
      selectedIcon: Icons.volunteer_activism_rounded,
    ),
    _PublicItem(
      path: RoutePaths.methodology,
      label: 'كيف نوثّق؟',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
  ];
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _PublicItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: selected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(item.label),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _PublicItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(selected ? item.selectedIcon : item.icon),
        title: Text(
          item.label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PublicItem {
  const _PublicItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
