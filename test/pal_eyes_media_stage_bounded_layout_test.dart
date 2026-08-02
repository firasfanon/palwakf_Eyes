import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/widgets/public_experience_maturity.dart';

void main() {
  testWidgets(
    'media stage has finite height inside a desktop scrollable column',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PalEyesMediaStage(
                    title: 'حين صنعت المياه طريقاً إلى القدس',
                    subtitle: 'قصة مكانية فلسطينية متعددة الفصول.',
                    semanticLabel: 'عمل بصري تجريدي للقصة',
                    height: 370,
                    footer: Wrap(
                      children: <Widget>[
                        Chip(label: Text('8 دقائق')),
                        Chip(label: Text('4 فصول')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size stageSize = tester.getSize(find.byType(PalEyesMediaStage));

      expect(stageSize.width.isFinite, isTrue);
      expect(stageSize.height.isFinite, isTrue);
      expect(stageSize.height, 370);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('media stage remains bounded at a 390 pixel mobile width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: PalEyesMediaStage(
                title: 'برك سليمان',
                subtitle: 'بيت لحم • موقع مائي تاريخي',
                semanticLabel: 'عمل بصري تجريدي للموقع',
                height: 340,
                footer: Wrap(
                  children: <Widget>[
                    Chip(label: Text('حكاية موسعة')),
                    Chip(label: Text('3 مراجع')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Size stageSize = tester.getSize(find.byType(PalEyesMediaStage));

    expect(stageSize.width.isFinite, isTrue);
    expect(stageSize.height.isFinite, isTrue);
    expect(stageSize.height, 340);
    expect(tester.takeException(), isNull);
  });
}
