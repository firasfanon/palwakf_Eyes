import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';

abstract final class ApprovedReferenceDesign {
  static const Color night = PalEyesTokens.nightBase;
  static const Color nightDeep = PalEyesTokens.green950;
  static const Color surface = PalEyesTokens.nightSurface;
  static const Color surfaceRaised = PalEyesTokens.nightRaised;
  static const Color surfaceSoft = PalEyesTokens.green800;
  static const Color gold = PalEyesTokens.gold;
  static const Color goldSoft = PalEyesTokens.goldSoft;
  static const Color cream = PalEyesTokens.inkOnDark;
  static const Color muted = PalEyesTokens.inkOnDarkMuted;
  static const Color olive = PalEyesTokens.green500;
  static const Color red = PalEyesTokens.alert;
  static const Color green = PalEyesTokens.green500;
  static const Color line = PalEyesTokens.nightLine;

  static const double maxWidth = 1480;
  static const double radius = 22;
  static const double radiusSmall = 14;
  static const double headerHeight = 78;

  static const String assetRoot = 'assets/visual_reference_v1';
  static const String reference = '$assetRoot/approved_home_reference_v1.png';
  static const String hero = '$assetRoot/hero_city.jpg';
  static const String timeline = '$assetRoot/timeline_panel.jpg';
  static const String map = '$assetRoot/map_panel.jpg';
  static const String featured = '$assetRoot/featured_panel.jpg';
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
      : PalEyesTokens.ivory;

  static Color panelBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? surface
      : PalEyesTokens.paper;

  static Color foreground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? cream
      : PalEyesTokens.ink;
  static Color secondaryForeground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? muted
      : PalEyesTokens.inkMuted;

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
      border: Border.all(color: dark ? line : PalEyesTokens.line),
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
