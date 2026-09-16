import 'package:flutter/material.dart';

abstract final class ApprovedReferenceDesign {
  static const Color night = Color(0xFF07110F);
  static const Color nightDeep = Color(0xFF030A09);
  static const Color surface = Color(0xFF0D1C19);
  static const Color surfaceRaised = Color(0xFF132521);
  static const Color surfaceSoft = Color(0xFF1A2C27);
  static const Color gold = Color(0xFFE0B866);
  static const Color goldSoft = Color(0xFFF1D39A);
  static const Color cream = Color(0xFFF7F0E4);
  static const Color muted = Color(0xFFBBB6AC);
  static const Color olive = Color(0xFF8D8A56);
  static const Color red = Color(0xFFC85B55);
  static const Color green = Color(0xFF7DA56A);
  static const Color line = Color(0x33FFFFFF);

  static const double maxWidth = 1480;
  static const double radius = 22;
  static const double radiusSmall = 14;
  static const double headerHeight = 78;

  static const String assetRoot = 'assets/visual_reference_v1';
  static const String reference = '$assetRoot/approved_home_reference_v1.png';
  static const String hero = '$assetRoot/hero_city.png';
  static const String timeline = '$assetRoot/timeline_panel.png';
  static const String map = '$assetRoot/map_panel.png';
  static const String featured = '$assetRoot/featured_panel.png';
  static const List<String> gatewayAssets = <String>[
    '$assetRoot/gateway_stories.png',
    '$assetRoot/gateway_map.png',
    '$assetRoot/gateway_places.png',
    '$assetRoot/gateway_memory.png',
    '$assetRoot/gateway_sources.png',
  ];

  static const List<String> storyAssets = <String>[
    '$assetRoot/story_1.png',
    '$assetRoot/story_2.png',
    '$assetRoot/story_3.png',
    '$assetRoot/story_4.png',
  ];

  static const String memoryCta = '$assetRoot/memory_cta.png';

  static Color pageBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? night
      : const Color(0xFFF6F0E4);

  static Color panelBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? surface
      : const Color(0xFFFCF9F2);

  static Color foreground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? cream
      : const Color(0xFF27251F);
  static Color secondaryForeground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? muted
      : const Color(0xFF6E675D);

  static BoxDecoration glassDecoration(
    BuildContext context, {
    double radius = 18,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: dark
          ? surface.withValues(alpha: 0.88)
          : Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: dark ? line : const Color(0xFFD8CBB7)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.28 : 0.08),
          blurRadius: 30,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static LinearGradient heroFade() => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Colors.transparent,
      night.withValues(alpha: 0.30),
      night.withValues(alpha: 0.92),
    ],
    stops: const <double>[0.0, 0.58, 1.0],
  );
}
