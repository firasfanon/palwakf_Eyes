import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/app.dart';

void main() {
  testWidgets(
    'immersive home renders the Palestinian place gateway',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: PalEyesApp()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('فلسطين تُروى من المكان'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-governed-draft-banner')),
        findsOneWidget,
      );

      final scrollable = find.byType(Scrollable).first;
      final storiesSection =
          find.byKey(const Key('home-stories-section'));

      await tester.scrollUntilVisible(
        storiesSection,
        520,
        scrollable: scrollable,
        maxScrolls: 20,
      );
      await tester.pumpAndSettle();

      expect(storiesSection, findsOneWidget);
      expect(find.text('قصص من المكان'), findsOneWidget);

      final evidenceSection =
          find.byKey(const Key('home-evidence-section'));

      await tester.scrollUntilVisible(
        evidenceSection,
        520,
        scrollable: scrollable,
        maxScrolls: 30,
      );
      await tester.pumpAndSettle();

      expect(evidenceSection, findsOneWidget);
      expect(
        find.text(
          'كل رواية تبدأ من دليل، وتنتهي بمراجعة بشرية',
        ),
        findsOneWidget,
      );
    },
  );
}
