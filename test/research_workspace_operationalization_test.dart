import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/research/presentation/research_workspace_screen.dart';

Future<void> _pumpWorkspace(WidgetTester tester, {required Size size}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: ResearchWorkspaceScreen()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('research workspace operationalization renders on desktop', (
    tester,
  ) async {
    await _pumpWorkspace(tester, size: const Size(1440, 1000));

    expect(find.text('مساحة الباحث'), findsOneWidget);
    expect(find.text('نموذج المعرفة البحثية — تشغيل تجريبي'), findsOneWidget);
    expect(find.text('12 قسمًا'), findsOneWidget);
    expect(find.text('التحقق البنيوي: PASS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('research workspace operationalization renders at 390px RTL', (
    tester,
  ) async {
    await _pumpWorkspace(tester, size: const Size(390, 844));

    expect(find.text('مساحة الباحث'), findsOneWidget);
    expect(find.text('نموذج المعرفة البحثية — تشغيل تجريبي'), findsOneWidget);
    expect(find.text('ACCEPT — غير إنتاجي فقط'), findsOneWidget);
    expect(find.text('مفتوح قبل النشر/الإنتاج'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
