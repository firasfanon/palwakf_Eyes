import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/application/app_settings.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_canonical_visual_v1.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class PublicShell extends ConsumerWidget {
  const PublicShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1040;
        final compact = constraints.maxWidth < 620;
        final mobileSelected = _selectedIndex(_mobileItems);

        return FocusTraversalGroup(
          child: Scaffold(
            backgroundColor: PalEyesVisualV1.parchment,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: compact ? 64 : 74,
              elevation: 0,
              scrolledUnderElevation: 1,
              surfaceTintColor: Colors.transparent,
              backgroundColor: PalEyesVisualV1.paper,
              foregroundColor: PalEyesVisualV1.warmInk,
              titleSpacing: compact ? 12 : 22,
              title: Semantics(
                button: true,
                label: 'العودة إلى الصفحة الرئيسية',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.go(RoutePaths.home),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: PalEyesBrandMark(
                      compact: compact,
                      foregroundColor: PalEyesVisualV1.warmInk,
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                if (wide)
                  ..._desktopItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: _NavButton(
                        item: item,
                        selected: _isSelected(item.path),
                        onPressed: () => context.go(item.path),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'البحث',
                  onPressed: () => context.go(RoutePaths.discover),
                  icon: const Icon(Icons.search_rounded),
                ),
                if (wide)
                  PopupMenuButton<String>(
                    tooltip: 'المزيد',
                    icon: const Icon(Icons.menu_rounded),
                    onSelected: (value) {
                      if (value == '__theme__') {
                        ref.read(themeModeControllerProvider.notifier).toggle();
                      } else if (value == '__locale__') {
                        ref.read(localeControllerProvider.notifier).toggle();
                      } else {
                        context.go(value);
                      }
                    },
                    itemBuilder: (context) => const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: RoutePaths.governorates,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.location_city_outlined),
                          title: Text('المحافظات'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: RoutePaths.sources,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.library_books_outlined),
                          title: Text('المصادر'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: RoutePaths.contribute,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.volunteer_activism_outlined),
                          title: Text('ساهم معنا'),
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: RoutePaths.workspace,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.dashboard_customize_outlined),
                          title: Text('مساحة الفريق'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: '__theme__',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.contrast_rounded),
                          title: Text('تبديل السمة'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: '__locale__',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.translate_rounded),
                          title: Text('تبديل اللغة'),
                        ),
                      ),
                    ],
                  )
                else
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'القائمة',
                      onPressed: Scaffold.of(context).openEndDrawer,
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
                SizedBox(width: compact ? 4 : 14),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: PalEyesVisualV1.warmLine),
              ),
            ),
            endDrawer: wide
                ? null
                : Drawer(
                    backgroundColor: PalEyesVisualV1.paper,
                    child: SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: <Widget>[
                          const PalEyesParchmentPanel(
                            color: PalEyesVisualV1.parchment,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                PalEyesBrandMark(
                                  foregroundColor: PalEyesVisualV1.warmInk,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'أطلس وحكايات وذاكرة للمكان الفلسطيني.',
                                  style: TextStyle(
                                    color: PalEyesVisualV1.warmMuted,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._drawerItems.map(
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
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: const Icon(Icons.contrast_rounded),
                              title: const Text('تبديل السمة'),
                              onTap: () => ref
                                  .read(themeModeControllerProvider.notifier)
                                  .toggle(),
                            ),
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
            bottomNavigationBar: constraints.maxWidth < 760
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

  static const List<_PublicItem> _desktopItems = <_PublicItem>[
    _PublicItem(
      RoutePaths.home,
      'الرئيسية',
      Icons.home_outlined,
      Icons.home_rounded,
    ),
    _PublicItem(
      RoutePaths.places,
      'الأماكن',
      Icons.account_balance_outlined,
      Icons.account_balance_rounded,
    ),
    _PublicItem(
      RoutePaths.map,
      'الخريطة',
      Icons.map_outlined,
      Icons.map_rounded,
    ),
    _PublicItem(
      RoutePaths.stories,
      'الحكايات',
      Icons.auto_stories_outlined,
      Icons.auto_stories_rounded,
    ),
    _PublicItem(
      RoutePaths.timeline,
      'الذاكرة',
      Icons.timeline_outlined,
      Icons.timeline_rounded,
    ),
    _PublicItem(
      RoutePaths.sources,
      'المصادر',
      Icons.menu_book_outlined,
      Icons.menu_book_rounded,
    ),
    _PublicItem(
      RoutePaths.methodology,
      'عن المشروع',
      Icons.info_outline_rounded,
      Icons.info_rounded,
    ),
  ];

  static const List<_PublicItem> _mobileItems = <_PublicItem>[
    _PublicItem(
      RoutePaths.home,
      'الرئيسية',
      Icons.home_outlined,
      Icons.home_rounded,
    ),
    _PublicItem(
      RoutePaths.places,
      'الأماكن',
      Icons.account_balance_outlined,
      Icons.account_balance_rounded,
    ),
    _PublicItem(
      RoutePaths.map,
      'الخريطة',
      Icons.map_outlined,
      Icons.map_rounded,
    ),
    _PublicItem(
      RoutePaths.stories,
      'الحكايات',
      Icons.auto_stories_outlined,
      Icons.auto_stories_rounded,
    ),
    _PublicItem(
      RoutePaths.discover,
      'استكشف',
      Icons.explore_outlined,
      Icons.explore_rounded,
    ),
  ];

  static const List<_PublicItem> _drawerItems = <_PublicItem>[
    ..._desktopItems,
    _PublicItem(
      RoutePaths.discover,
      'استكشف',
      Icons.explore_outlined,
      Icons.explore_rounded,
    ),
    _PublicItem(
      RoutePaths.governorates,
      'المحافظات',
      Icons.location_city_outlined,
      Icons.location_city_rounded,
    ),
    _PublicItem(
      RoutePaths.contribute,
      'ساهم معنا',
      Icons.volunteer_activism_outlined,
      Icons.volunteer_activism_rounded,
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? PalEyesVisualV1.oliveDark
            : PalEyesVisualV1.warmInk,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: const RoundedRectangleBorder(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(item.label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 26 : 0,
            height: 2,
            color: PalEyesVisualV1.olive,
          ),
        ],
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
    return ListTile(
      selected: selected,
      selectedColor: PalEyesVisualV1.oliveDark,
      selectedTileColor: PalEyesVisualV1.olive.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(selected ? item.selectedIcon : item.icon),
      title: Text(
        item.label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onTap: onTap,
    );
  }
}

class _PublicItem {
  const _PublicItem(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
