import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_visual_system.dart';

void main() {
  testWidgets('visual card fits compact story height without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 362,
              height: 243,
              child: PalEyesVisualCard(
                icon: Icons.layers_outlined,
                label: 'طبقات',
                title: 'مدن فوق مدن',
                description:
                    'سبسطية وتل السلطان وغزة القديمة بوصفها أمكنة تتراكم فيها الحضارات ولا تلغي إحداها الأخرى.',
                dark: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مدن فوق مدن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
