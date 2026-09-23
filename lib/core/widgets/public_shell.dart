import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/application/app_settings.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/approved_reference_design.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

class PublicShell extends ConsumerWidget {
  const PublicShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentationMode = ref.watch(palEyesPresentationModeProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;
        return Scaffold(
          extendBodyBehindAppBar: location == RoutePaths.home,
          backgroundColor: ApprovedReferenceDesign.pageBackground(context),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              ApprovedReferenceDesign.headerHeight,
            ),
            child: _ReferenceHeader(
              location: location,
              wide: wide,
              internal: presentationMode.isInternal,
            ),
          ),
          drawer: wide
              ? null
              : _PublicDrawer(internal: presentationMode.isInternal),
          body: child,
        );
      },
    );
  }
}

class _ReferenceHeader extends ConsumerWidget {
  const _ReferenceHeader({
    required this.location,
    required this.wide,
    required this.internal,
  });
  final String location;
  final bool wide;
  final bool internal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final homeOverlay = location == RoutePaths.home;
    final background = dark
        ? ApprovedReferenceDesign.night.withValues(alpha: 0.97)
        : const Color(0xFFF7F0E4).withValues(alpha: 0.98);
    final foreground = homeOverlay
        ? ApprovedReferenceDesign.cream
        : dark
        ? ApprovedReferenceDesign.cream
        : const Color(0xFF25231E);

    return SafeArea(
      bottom: false,
      child: Container(
        height: ApprovedReferenceDesign.headerHeight,
        padding: EdgeInsets.symmetric(horizontal: wide ? 34 : 12),
        decoration: BoxDecoration(
          color: homeOverlay ? Colors.transparent : background,
          border: homeOverlay
              ? null
              : Border(
                  bottom: BorderSide(
                    color: ApprovedReferenceDesign.gold.withValues(alpha: 0.26),
                  ),
                ),
        ),
        child: Builder(
          builder: (scaffoldContext) => Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              InkWell(
                onTap: () => context.go(RoutePaths.home),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 6 : 0,
                    vertical: 8,
                  ),
                  child: homeOverlay
                      ? _ApprovedReferenceBrandMark(compact: !wide)
                      : PalEyesBrandMark(
                          compact: !wide,
                          foregroundColor: foreground,
                        ),
                ),
              ),
              if (wide) ...<Widget>[
                const SizedBox(width: 24),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _desktopItems
                        .map(
                          (item) => _HeaderNavButton(
                            item: item,
                            selected: _selected(location, item.path),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(width: 8),
                _MoreMenu(
                  foreground: foreground,
                  onSelected: (path) => context.go(path),
                ),
                const SizedBox(width: 10),
                _HeaderSearch(onTap: () => context.go(RoutePaths.discover)),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(localeControllerProvider.notifier).toggle(),
                  style: TextButton.styleFrom(foregroundColor: foreground),
                  icon: const Icon(Icons.language_rounded, size: 18),
                  label: const Text('AR'),
                ),
                IconButton.outlined(
                  tooltip: 'تبديل المظهر',
                  style: IconButton.styleFrom(
                    foregroundColor: homeOverlay
                        ? ApprovedReferenceDesign.goldSoft
                        : foreground,
                    backgroundColor: homeOverlay
                        ? Colors.black.withValues(alpha: 0.16)
                        : Colors.transparent,
                    side: BorderSide(
                      color: homeOverlay
                          ? ApprovedReferenceDesign.gold.withValues(alpha: 0.56)
                          : foreground.withValues(alpha: 0.28),
                    ),
                  ),
                  onPressed: () =>
                      ref.read(themeModeControllerProvider.notifier).toggle(),
                  icon: Icon(
                    homeOverlay
                        ? Icons.dark_mode_rounded
                        : dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ),
                if (internal) ...<Widget>[
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: () => context.go(RoutePaths.workspace),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ApprovedReferenceDesign.goldSoft,
                      side: const BorderSide(
                        color: ApprovedReferenceDesign.gold,
                      ),
                    ),
                    icon: const Icon(
                      Icons.dashboard_customize_outlined,
                      size: 18,
                    ),
                    label: const Text('مساحة العمل'),
                  ),
                  const SizedBox(width: 6),
                  IconButton.outlined(
                    tooltip: 'الحوكمة والإدارة',
                    onPressed: () => context.go(RoutePaths.admin),
                    style: IconButton.styleFrom(
                      foregroundColor: ApprovedReferenceDesign.goldSoft,
                      side: const BorderSide(
                        color: ApprovedReferenceDesign.gold,
                      ),
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 18),
                  ),
                ],
              ] else ...<Widget>[
                const Spacer(),
                IconButton(
                  tooltip: 'تبديل المظهر',
                  color: foreground,
                  onPressed: () =>
                      ref.read(themeModeControllerProvider.notifier).toggle(),
                  icon: Icon(
                    dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'القائمة',
                  color: foreground,
                  onPressed: Scaffold.of(scaffoldContext).openDrawer,
                  icon: const Icon(Icons.menu_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovedReferenceBrandMark extends StatelessWidget {
  const _ApprovedReferenceBrandMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.park_rounded,
          color: ApprovedReferenceDesign.gold,
          size: compact ? 34 : 42,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'بعيون فلسطينية',
              style: TextStyle(
                color: ApprovedReferenceDesign.cream,
                fontSize: compact ? 16 : 19,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            if (!compact)
              Text(
                'المكان · الذاكرة · الحكاية',
                style: TextStyle(
                  color: ApprovedReferenceDesign.cream.withValues(alpha: 0.62),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeaderSearch extends StatelessWidget {
  const _HeaderSearch({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(99),
    child: Container(
      width: 255,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: ApprovedReferenceDesign.goldSoft,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ابحث عن مكان، حكاية أو موضوع...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ApprovedReferenceDesign.cream.withValues(alpha: 0.72),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HeaderNavButton extends StatelessWidget {
  const _HeaderNavButton({required this.item, required this.selected});

  final _PublicItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).brightness == Brightness.dark
        ? ApprovedReferenceDesign.cream
        : const Color(0xFF2B2821);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => context.go(item.path),
        style: TextButton.styleFrom(
          foregroundColor: selected ? ApprovedReferenceDesign.gold : foreground,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          shape: const RoundedRectangleBorder(),
          side: BorderSide.none,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              item.label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 34 : 0,
              height: 2,
              color: ApprovedReferenceDesign.gold,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.foreground, required this.onSelected});

  final Color foreground;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'المزيد',
      onSelected: onSelected,
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: RoutePaths.timeline,
          child: ListTile(
            leading: Icon(Icons.history_toggle_off_outlined),
            title: Text('عبر الزمن'),
          ),
        ),
        PopupMenuItem<String>(
          value: RoutePaths.governorates,
          child: ListTile(
            leading: Icon(Icons.location_city_outlined),
            title: Text('المحافظات'),
          ),
        ),
        PopupMenuItem<String>(
          value: RoutePaths.sources,
          child: ListTile(
            leading: Icon(Icons.library_books_outlined),
            title: Text('المصادر'),
          ),
        ),
        PopupMenuItem<String>(
          value: RoutePaths.methodology,
          child: ListTile(
            leading: Icon(Icons.fact_check_outlined),
            title: Text('المنهجية'),
          ),
        ),
        PopupMenuItem<String>(
          value: RoutePaths.contribute,
          child: ListTile(
            leading: Icon(Icons.volunteer_activism_outlined),
            title: Text('ساهم في الذاكرة'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'المزيد',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, color: foreground, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PublicDrawer extends ConsumerWidget {
  const _PublicDrawer({required this.internal});

  final bool internal;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark
        ? ApprovedReferenceDesign.cream
        : const Color(0xFF2A2721);
    return Drawer(
      backgroundColor: ApprovedReferenceDesign.panelBackground(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            PalEyesBrandMark(foregroundColor: foreground),
            const SizedBox(height: 22),
            ..._desktopItems.map(
              (item) => Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(item.icon, color: ApprovedReferenceDesign.gold),
                  title: Text(item.label, style: TextStyle(color: foreground)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(item.path);
                  },
                ),
              ),
            ),
            const Divider(height: 28),
            ListTile(
              leading: const Icon(Icons.location_city_outlined),
              title: const Text('المحافظات'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(RoutePaths.governorates);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism_outlined),
              title: const Text('ساهم في الذاكرة'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(RoutePaths.contribute);
              },
            ),
            if (internal) ...<Widget>[
              const Divider(height: 28),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(RoutePaths.workspace);
                },
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('فتح مساحة العمل'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(RoutePaths.admin);
                },
                icon: const Icon(Icons.shield_outlined),
                label: const Text('لوحة الحوكمة والإدارة'),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(themeModeControllerProvider.notifier).toggle(),
              icon: Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              label: Text(dark ? 'الوضع الفاتح' : 'الوضع الداكن'),
            ),
          ],
        ),
      ),
    );
  }
}

bool _selected(String location, String path) =>
    path == RoutePaths.home ? location == path : location.startsWith(path);

class _PublicItem {
  const _PublicItem(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

const List<_PublicItem> _desktopItems = <_PublicItem>[
  _PublicItem(RoutePaths.home, 'الرئيسية', Icons.home_outlined),
  _PublicItem(RoutePaths.discover, 'استكشف', Icons.travel_explore_outlined),
  _PublicItem(RoutePaths.places, 'الأماكن', Icons.place_outlined),
  _PublicItem(RoutePaths.research, 'البحوث', Icons.menu_book_outlined),
  _PublicItem(RoutePaths.map, 'الخريطة', Icons.map_outlined),
  _PublicItem(RoutePaths.stories, 'الحكايات', Icons.auto_stories_outlined),
];
