import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/content/content_review_status.dart';
import 'package:pal_eyes/core/widgets/content_status_badge.dart';
import 'package:pal_eyes/features/map/presentation/map_screen.dart';
import 'package:pal_eyes/features/places/application/heritage_sites_provider.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';

void main() {
  testWidgets(
    'content status badge does not overflow when constrained to 60 pixels',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 60,
                child: ContentStatusBadge(
                  status: ContentReviewStatus.draft,
                  compact: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);

      // The full Arabic label remains available through Semantics,
      // while the visual badge collapses to the icon at extreme widths.
      expect(find.text('مسودة خاضعة للتدقيق'), findsNothing);
    },
  );

  testWidgets(
    'content status badge keeps its label when sufficient width is available',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: ContentStatusBadge(
                  status: ContentReviewStatus.draft,
                  compact: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('مسودة خاضعة للتدقيق'), findsOneWidget);
    },
  );

  testWidgets(
    'map compact bottom panel is scrollable without overflow at 390x844',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

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
            foundationSitesProvider.overrideWithValue(const <HeritageSite>[]),
            mappedSitesProvider.overrideWithValue(const <HeritageSite>[]),
          ],
          child: const MaterialApp(home: MapScreen()),
        ),
      );

      await tester.pump();

      expect(tester.takeException(), isNull);

      expect(
        find.byKey(const ValueKey<String>('map-compact-bottom-scroll')),
        findsOneWidget,
      );
    },
  );
}
