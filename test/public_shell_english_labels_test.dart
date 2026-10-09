import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/localization/pal_eyes_localizations.dart';

Widget _probe(Locale locale, String arabic) => MaterialApp(
  locale: locale,
  supportedLocales: PalEyesLocalizations.supportedLocales,
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    PalEyesLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
  ],
  home: Builder(builder: (context) => Text(tr(context, arabic))),
);

void main() {
  testWidgets('Arabic locale keeps the Arabic source label', (tester) async {
    await tester.pumpWidget(_probe(const Locale('ar'), 'الأماكن'));
    expect(find.text('الأماكن'), findsOneWidget);
  });

  testWidgets('English locale shows the English chrome label', (tester) async {
    await tester.pumpWidget(_probe(const Locale('en'), 'الأماكن'));
    expect(find.text('Places'), findsOneWidget);
  });

  testWidgets('unknown labels fall back to Arabic, never invented', (
    tester,
  ) async {
    await tester.pumpWidget(_probe(const Locale('en'), 'نص غير مترجم'));
    expect(find.text('نص غير مترجم'), findsOneWidget);
  });

  test('every public navigation label has an English equivalent', () {
    for (final label in <String>[
      'الرئيسية',
      'استكشف',
      'الأماكن',
      'البحوث',
      'الخريطة',
      'الحكايات',
      'المزيد',
      'عبر الزمن',
      'المحافظات',
      'المصادر',
      'المنهجية',
      'ساهم في الذاكرة',
    ]) {
      expect(palEyesArabicToEnglish[label], isNotNull, reason: label);
    }
  });
}
