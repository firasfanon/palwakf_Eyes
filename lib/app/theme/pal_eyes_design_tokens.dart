import 'package:flutter/material.dart';

/// Single source of truth for the PalEyes visual language.
///
/// Editorial Palestinian cultural-research atlas direction (2026-10-09):
/// warm ivory surfaces, deep dark green structure, restrained warm gold
/// accents. Public experience, workspace and governance all draw from these
/// tokens; legacy palettes (`AppColors`, `ApprovedReferenceDesign`,
/// `PalEyesVisualV1`) are thin aliases over them so every surface stays
/// coherent while older call sites migrate.
abstract final class PalEyesTokens {
  // Ivory / paper surfaces.
  static const Color ivory = Color(0xFFFBF7EF);
  static const Color cream = Color(0xFFF3EBDC);
  static const Color paper = Color(0xFFFFFDF8);
  static const Color line = Color(0xFFE5D9C3);
  static const Color lineStrong = Color(0xFFD3C29F);

  // Deep green structure.
  static const Color green950 = Color(0xFF09201A);
  static const Color green900 = Color(0xFF0E2A21);
  static const Color green800 = Color(0xFF15382C);
  static const Color green700 = Color(0xFF1E4A3A);
  static const Color green600 = Color(0xFF2C6049);
  static const Color green500 = Color(0xFF4A7A5F);
  static const Color green100 = Color(0xFFE3ECE4);

  // Warm gold accents.
  static const Color gold = Color(0xFFC9A14E);
  static const Color goldDeep = Color(0xFF8A6A27);
  static const Color goldSoft = Color(0xFFEBD5A2);
  static const Color goldWash = Color(0xFFF6EBD2);

  // Ink.
  static const Color ink = Color(0xFF1C2520);
  static const Color inkMuted = Color(0xFF59615A);
  static const Color inkOnDark = Color(0xFFF7F1E5);
  static const Color inkOnDarkMuted = Color(0xFFC3C2B2);

  // Semantic.
  static const Color terracotta = Color(0xFFA4502F);
  static const Color alert = Color(0xFFA43F35);
  static const Color sea = Color(0xFF2F6E7E);
  static const Color success = Color(0xFF2F7A52);

  /// Structural accent that marks governance (administrative authority)
  /// surfaces as distinct from editorial workspace surfaces.
  static const Color governanceAccent = Color(0xFF7B3B2A);

  // Dark mode surfaces (deep green, never navy).
  static const Color nightBase = Color(0xFF071A15);
  static const Color nightSurface = Color(0xFF0E261F);
  static const Color nightRaised = Color(0xFF15322A);
  static const Color nightLine = Color(0x33F7F1E5);

  // Typography.
  static const String fontBody = 'IBMPlexSansArabic';
  static const String fontDisplay = 'Amiri';

  // Spacing scale (logical px).
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;

  // Radii.
  static const double radiusSmall = 10;
  static const double radius = 16;
  static const double radiusLarge = 22;
  static const double radiusPill = 999;

  static const double maxContentWidth = 1480;

  static const LinearGradient structureGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[green950, green900, green800],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[goldSoft, gold],
  );

  static List<BoxShadow> softShadow({double strength = 1}) => <BoxShadow>[
    BoxShadow(
      color: green950.withValues(alpha: 0.07 * strength),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static Color page(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? nightBase : ivory;

  static Color panel(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? nightSurface : paper;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? nightLine : line;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? inkOnDark : ink;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? inkOnDarkMuted
      : inkMuted;

  /// Gold that keeps readable contrast on the current surface.
  static Color accentText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? goldSoft : goldDeep;
}
