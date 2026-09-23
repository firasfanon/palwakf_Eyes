import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';
import 'package:pal_eyes/features/places/presentation/place_detail_screen.dart';
import 'package:pal_eyes/features/research/presentation/public_research_detail_screen.dart';
import 'package:pal_eyes/features/research/presentation/staging_research_narrative_panel.dart';
import 'package:pal_eyes/features/research/presentation/staging_research_package_card.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    'production public place experience hides research preview internals',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
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
            home: Scaffold(body: PlaceDetailScreen(slug: 'swq-lqtnyn-4bbdf0')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('نبذة'), findsWidgets);
      expect(find.text('الحكاية'), findsWidgets);
      expect(find.text('عبر الزمن'), findsWidgets);
      expect(find.text('الصور'), findsWidgets);
      expect(find.text('الخريطة'), findsWidgets);
      expect(find.text('المصادر'), findsWidgets);
      expect(find.text('عن هذه المادة'), findsWidgets);
      expect(find.text('صفحة مسودة محكومة'), findsNothing);
      expect(find.text('المادة التاريخية الأصلية'), findsNothing);
      expect(find.text('البحث'), findsNothing);
      expect(find.byType(StagingResearchPackageCard), findsNothing);
      expect(find.byType(StagingResearchNarrativePanel), findsNothing);
      expect(find.textContaining('RCP-V1-'), findsNothing);
      expect(find.textContaining('PAL-EYES-CENSUS-'), findsNothing);
    },
  );

  testWidgets('development public place exposes governed research preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: PlaceDetailScreen(slug: 'swq-lqtnyn-4bbdf0')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اقرأ البحث الكامل'), findsOneWidget);
    expect(find.text('مكتبة البحوث'), findsOneWidget);
    expect(find.text('البحث'), findsOneWidget);
    expect(find.textContaining('RCP-V1-005'), findsWidgets);
    expect(
      find.text('اعتماد تجريبي غير إنتاجي — الدين التخصصي مفتوح'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('development research detail owns the full governed narrative surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PublicResearchDetailScreen(slug: 'swq-lqtnyn-4bbdf0'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StagingResearchPackageCard), findsOneWidget);
    expect(find.byType(StagingResearchNarrativePanel), findsOneWidget);
    expect(find.text('معاينة البحث — غير إنتاجية'), findsOneWidget);
    expect(find.textContaining('RCP-V1-005'), findsWidgets);
    expect(find.textContaining('PAL-EYES-CENSUS-005'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('internal inspector preserves governance-facing place surfaces', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          palEyesPresentationModeProvider.overrideWithValue(
            PalEyesPresentationMode.internalInspector,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PlaceDetailScreen(slug: 'swq-lqtnyn-4bbdf0')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الحكاية المحررة'), findsOneWidget);
    expect(find.text('المادة التاريخية الأصلية'), findsOneWidget);
    expect(find.text('البحث'), findsOneWidget);
    expect(find.text('الوسائط'), findsOneWidget);
  });
}
