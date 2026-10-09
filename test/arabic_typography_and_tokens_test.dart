import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/application/app_settings.dart';
import 'package:pal_eyes/app/theme/app_colors.dart';
import 'package:pal_eyes/app/theme/app_theme.dart';
import 'package:pal_eyes/app/theme/approved_reference_design.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';

void main() {
  test('Arabic fonts are bundled and declared, never CDN-dependent', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: IBMPlexSansArabic'));
    expect(pubspec, contains('family: Amiri'));
    for (final asset in RegExp(
      r'asset: (assets/fonts/[^\s]+\.ttf)',
    ).allMatches(pubspec).map((m) => m.group(1)!)) {
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: asset);
      expect(file.lengthSync(), greaterThan(100000), reason: asset);
    }
    expect(
      File('assets/fonts/ibm_plex_sans_arabic/OFL.txt').existsSync(),
      isTrue,
    );
    expect(File('assets/fonts/amiri/OFL.txt').existsSync(), isTrue);
    expect(File('assets/fonts/FONT_PROVENANCE.md').existsSync(), isTrue);
  });

  test('themes resolve Arabic body and display families in both modes', () {
    for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
      expect(theme.textTheme.bodyMedium?.fontFamily, PalEyesTokens.fontBody);
      expect(theme.textTheme.labelLarge?.fontFamily, PalEyesTokens.fontBody);
      expect(
        theme.textTheme.displayLarge?.fontFamily,
        PalEyesTokens.fontDisplay,
      );
      expect(
        theme.textTheme.headlineMedium?.fontFamily,
        PalEyesTokens.fontDisplay,
      );
    }
  });

  test('unified tokens: one editorial palette, no navy authority', () {
    expect(AppColors.sovereignBlue, PalEyesTokens.green800);
    expect(AppColors.approvedNavy, PalEyesTokens.green800);
    expect(AppColors.heritageGold, PalEyesTokens.gold);
    expect(AppColors.approvedIvory, PalEyesTokens.ivory);
    expect(ApprovedReferenceDesign.gold, PalEyesTokens.gold);
    expect(ApprovedReferenceDesign.night, PalEyesTokens.nightBase);
    expect(AppTheme.light().scaffoldBackgroundColor, PalEyesTokens.ivory);
    expect(AppTheme.light().colorScheme.primary, PalEyesTokens.green800);
    for (final legacyNavy in <int>[
      0xFF0B2742,
      0xFF08243D,
      0xFF041A2D,
      0xFF071A2B,
    ]) {
      expect(
        File('lib/app/theme/app_colors.dart').readAsStringSync(),
        isNot(contains(legacyNavy.toRadixString(16).toUpperCase())),
      );
    }
  });

  test('default appearance is the light ivory editorial theme', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeModeControllerProvider), ThemeMode.light);
  });

  testWidgets('research library Arabic renders with the bundled family', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Text('مكتبة البحوث')),
        ),
      ),
    );
    final style = DefaultTextStyle.of(
      tester.element(find.text('مكتبة البحوث')),
    ).style;
    expect(style.fontFamily, PalEyesTokens.fontBody);
  });
}
