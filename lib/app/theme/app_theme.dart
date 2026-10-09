import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PalEyesTokens.green800,
      brightness: Brightness.light,
      primary: PalEyesTokens.green800,
      onPrimary: PalEyesTokens.inkOnDark,
      primaryContainer: PalEyesTokens.green100,
      onPrimaryContainer: PalEyesTokens.green900,
      secondary: PalEyesTokens.goldDeep,
      onSecondary: Colors.white,
      secondaryContainer: PalEyesTokens.goldWash,
      onSecondaryContainer: PalEyesTokens.ink,
      tertiary: PalEyesTokens.green600,
      tertiaryContainer: PalEyesTokens.cream,
      onTertiaryContainer: PalEyesTokens.ink,
      surfaceContainerHighest: PalEyesTokens.cream,
      error: PalEyesTokens.alert,
      surface: PalEyesTokens.paper,
      onSurface: PalEyesTokens.ink,
      onSurfaceVariant: PalEyesTokens.inkMuted,
      outline: PalEyesTokens.lineStrong,
      outlineVariant: PalEyesTokens.line,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: PalEyesTokens.ivory,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: PalEyesTokens.green900,
        foregroundColor: PalEyesTokens.inkOnDark,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: PalEyesTokens.paper,
        shadowColor: PalEyesTokens.green950.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
          side: const BorderSide(color: AppColors.approvedOutline),
        ),
      ),
      inputDecorationTheme: _inputs(
        fill: PalEyesTokens.paper,
        border: PalEyesTokens.line,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 8,
        backgroundColor: AppColors.approvedIvory,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.heritageGold.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) => TextStyle(
            fontFamily: PalEyesTokens.fontBody,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PalEyesTokens.green600,
      brightness: Brightness.dark,
      primary: PalEyesTokens.goldSoft,
      onPrimary: PalEyesTokens.green950,
      secondary: PalEyesTokens.gold,
      tertiary: PalEyesTokens.green500,
      error: const Color(0xFFFF9A8A),
      surface: PalEyesTokens.nightSurface,
      onSurface: PalEyesTokens.inkOnDark,
      onSurfaceVariant: PalEyesTokens.inkOnDarkMuted,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: PalEyesTokens.nightBase,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: PalEyesTokens.green950,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: PalEyesTokens.nightSurface,
        shadowColor: Colors.black.withValues(alpha: 0.28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: _inputs(
        fill: PalEyesTokens.nightRaised,
        border: Colors.white.withValues(alpha: 0.10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 8,
        backgroundColor: PalEyesTokens.nightSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.heritageGold.withValues(alpha: 0.20),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    const display = PalEyesTokens.fontDisplay;
    final textTheme = const TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      displayMedium: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        height: 1.28,
      ),
      displaySmall: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        height: 1.34,
      ),
      headlineMedium: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        height: 1.36,
      ),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, height: 1.4),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, height: 1.42),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, height: 1.46),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, height: 1.46),
      bodyLarge: TextStyle(height: 1.75),
      bodyMedium: TextStyle(height: 1.7),
      bodySmall: TextStyle(height: 1.6),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: PalEyesTokens.fontBody,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      focusColor: AppColors.heritageGold.withValues(alpha: 0.24),
      hoverColor: AppColors.heritageGold.withValues(alpha: 0.08),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.55),
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: PalEyesTokens.fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
          textStyle: const TextStyle(
            fontFamily: PalEyesTokens.fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: PalEyesTokens.fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.secondaryContainer,
        checkmarkColor: scheme.onSecondaryContainer,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.60)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        labelStyle: TextStyle(
          fontFamily: PalEyesTokens.fontBody,
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: PalEyesTokens.fontBody,
          color: Colors.white,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputs({
    required Color fill,
    required Color border,
  }) {
    OutlineInputBorder outline(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: outline(border),
      enabledBorder: outline(border),
      focusedBorder: outline(AppColors.heritageGold),
      errorBorder: outline(AppColors.royalRed),
      focusedErrorBorder: outline(AppColors.royalRed),
      floatingLabelStyle: const TextStyle(
        fontFamily: PalEyesTokens.fontBody,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
