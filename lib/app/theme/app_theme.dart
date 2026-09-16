import 'package:flutter/material.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.sovereignBlue,
      brightness: Brightness.light,
      primary: AppColors.sovereignBlue,
      secondary: AppColors.heritageGold,
      tertiary: AppColors.olive,
      error: AppColors.royalRed,
      surface: AppColors.warmCanvas,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.approvedIvory,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.midnight,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withValues(alpha: 0.92),
        shadowColor: AppColors.approvedNavy.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.approvedOutline),
        ),
      ),
      inputDecorationTheme: _inputs(
        fill: AppColors.approvedIvory.withValues(alpha: 0.98),
        border: AppColors.sovereignBlue.withValues(alpha: 0.10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 8,
        backgroundColor: AppColors.approvedIvory,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.heritageGold.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) => TextStyle(
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
      seedColor: AppColors.heritageGold,
      brightness: Brightness.dark,
      primary: AppColors.softGold,
      secondary: AppColors.heritageGold,
      tertiary: AppColors.oliveLight,
      error: const Color(0xFFFF8E8E),
      surface: AppColors.midnight,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF071724),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF061522),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF0D2233),
        shadowColor: Colors.black.withValues(alpha: 0.28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      inputDecorationTheme: _inputs(
        fill: const Color(0xFF10283A),
        border: Colors.white.withValues(alpha: 0.10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 8,
        backgroundColor: const Color(0xFF0A1E2E),
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.heritageGold.withValues(alpha: 0.20),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final textTheme = const TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.w900,
        height: 1.16,
        letterSpacing: -0.6,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w900,
        height: 1.20,
        letterSpacing: -0.4,
      ),
      displaySmall: TextStyle(fontWeight: FontWeight.w900, height: 1.24),
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, height: 1.28),
      headlineMedium: TextStyle(fontWeight: FontWeight.w900, height: 1.30),
      headlineSmall: TextStyle(fontWeight: FontWeight.w900, height: 1.32),
      titleLarge: TextStyle(fontWeight: FontWeight.w900, height: 1.38),
      titleMedium: TextStyle(fontWeight: FontWeight.w800, height: 1.42),
      bodyLarge: TextStyle(height: 1.72),
      bodyMedium: TextStyle(height: 1.65),
      labelLarge: TextStyle(fontWeight: FontWeight.w800),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
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
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
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
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.60)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(color: Colors.white),
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
      floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }
}
