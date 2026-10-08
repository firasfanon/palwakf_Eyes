import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/features/research/presentation/public_research_library_screen.dart';

Future<void> _pumpLibrary(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: PublicResearchLibraryScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('public research library renders the governed corpus on desktop', (
    tester,
  ) async {
    await _pumpLibrary(tester, const Size(1440, 1000));

    expect(find.text('مكتبة البحوث'), findsOneWidget);
    expect(find.text('بحثًا بسرد كامل'), findsOneWidget);
    expect(find.text('ابحث باسم المكان أو المحافظة أو رقم الحزمة'), findsOneWidget);
    expect(find.textContaining('سوق القطانين'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('public research library remains bounded at 390px RTL', (
    tester,
  ) async {
    await _pumpLibrary(tester, const Size(390, 844));

    expect(find.text('مكتبة البحوث'), findsOneWidget);
    expect(find.text('بحوث كاملة'), findsOneWidget);
    expect(find.textContaining('RCP-V1-005'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('production library stays fail closed', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            const AppEnvironment(
              supabaseUrl: '',
              supabasePublishableKey: '',
              environmentName: 'production',
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PublicResearchLibraryScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('مكتبة البحوث مفصولة عن بيئة الإنتاج'),
      findsOneWidget,
    );
    expect(find.textContaining('RCP-V1-005'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
