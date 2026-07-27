import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/places/data/dual_narrative_catalog.dart';
import 'package:pal_eyes/features/places/presentation/widgets/site_card.dart';

void main() {
  testWidgets(
    'site card fits the immersive home boundary with public story badge',
    (tester) async {
      final site = dualNarrativeSiteCatalog.firstWhere(
        (item) => item.hasOriginalExpandedNarrative,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 364,
                height: 402,
                child: SiteCard(site: site),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('حكاية موسعة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
