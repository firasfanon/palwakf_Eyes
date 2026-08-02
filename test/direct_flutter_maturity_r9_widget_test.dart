import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/theme/app_theme.dart';
import 'package:pal_eyes/core/widgets/direct_flutter_maturity_r9.dart';

void main() {
  testWidgets('public identity strip remains readable at 390 pixel RTL width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: PalEyesPublicIdentityStrip(
                active: PalEyesPublicPillar.atlas,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('أطلس المكان'), findsOneWidget);
    expect(find.text('متحف الحكاية'), findsOneWidget);
    expect(find.text('مجلة الذاكرة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'editorial prelude adapts from desktop to mobile without overflow',
    (WidgetTester tester) async {
      Future<void> pump(Size size) async {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(12),
                  child: PalEyesEditorialPrelude(
                    eyebrow: 'الأطلس الفلسطيني',
                    title: 'من المكان إلى الحكاية',
                    description:
                        'واجهة تحريرية تقود الزائر إلى الموقع والمصدر.',
                    icon: Icons.account_balance_outlined,
                    metrics: <PalEyesEditorialMetric>[
                      PalEyesEditorialMetric(
                        value: '79',
                        label: 'موقعاً',
                        icon: Icons.place_outlined,
                      ),
                      PalEyesEditorialMetric(
                        value: '95',
                        label: 'مرجعاً',
                        icon: Icons.library_books_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await pump(const Size(1180, 800));
      await pump(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'map empty experience delivers value before coordinates are public',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: PalEyesMapEmptyExperience(
                  siteCount: 79,
                  governorateCount: 16,
                  onAtlas: () {},
                  onMethodology: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا نقاط مؤقتة على الخريطة العامة'), findsOneWidget);
      expect(find.text('79 موقعاً في الأطلس'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('content compass and chapter rail stay horizontally bounded', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  PalEyesContentCompass(
                    labels: const <String>[
                      'نظرة عامة',
                      'الحكاية المحررة',
                      'المادة التاريخية الأصلية',
                      'المصادر',
                    ],
                    icons: const <IconData>[
                      Icons.info_outline_rounded,
                      Icons.menu_book_outlined,
                      Icons.history_edu_outlined,
                      Icons.library_books_outlined,
                    ],
                    selectedIndex: 0,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 12),
                  const PalEyesChapterRail(
                    titles: <String>[
                      'الماء والجغرافيا',
                      'الطريق والعمران',
                      'الذاكرة المحلية',
                      'المصدر والدليل',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نظرة عامة'), findsOneWidget);
    expect(find.text('الماء والجغرافيا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
