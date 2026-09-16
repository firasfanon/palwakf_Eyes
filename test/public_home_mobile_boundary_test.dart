import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/app.dart';

void main() {
  testWidgets('public home stays inside 390x844 mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: PalEyesApp()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('فلسطين..\nأكثر من مكان'), findsOneWidget);

    final heroImage = find.byType(Image).first;
    final heroRect = tester.getRect(heroImage);
    expect(heroRect.left, greaterThanOrEqualTo(0));
    expect(heroRect.right, lessThanOrEqualTo(390));

    final titleRect = tester.getRect(find.text('فلسطين..\nأكثر من مكان'));
    expect(titleRect.left, greaterThanOrEqualTo(0));
    expect(titleRect.right, lessThanOrEqualTo(390));

    final discover = find.textContaining('اكتشف المكان في فلسطين');
    expect(discover, findsOneWidget);
    final discoverRect = tester.getRect(discover);
    expect(discoverRect.left, greaterThanOrEqualTo(0));
    expect(discoverRect.right, lessThanOrEqualTo(390));
  });
}
