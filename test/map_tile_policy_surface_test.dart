import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/config/map_tile_provider_policy.dart';
import 'package:pal_eyes/core/widgets/map_tile_policy_surface.dart';

void main() {
  testWidgets('OSM attribution and issue links remain visibly rendered', (
    WidgetTester tester,
  ) async {
    final configuration = MapTileProviderPolicy.resolve(
      const AppEnvironment.local(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PalEyesMapAttributionBar(configuration: configuration),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('map-tile-attribution-visible')),
      findsOneWidget,
    );
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    expect(find.text('أبلغ عن مشكلة في الخريطة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('production fail-closed state renders without tile links', (
    WidgetTester tester,
  ) async {
    final configuration = MapTileProviderPolicy.resolve(
      const AppEnvironment(
        supabaseUrl: '',
        supabasePublishableKey: '',
        environmentName: 'production',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              PalEyesMapTileBlockedNotice(configuration: configuration),
              PalEyesMapAttributionBar(configuration: configuration),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('map-tile-production-fail-closed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('map-tile-provider-disabled')),
      findsOneWidget,
    );
    expect(find.text('لا تُرسل طلبات بلاطات في هذه البيئة.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
