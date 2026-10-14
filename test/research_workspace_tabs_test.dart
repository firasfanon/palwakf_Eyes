import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/research/presentation/research_workspace_screen.dart';

void main() {
  testWidgets('research workspace tabs switch selection on desktop', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ResearchWorkspaceTabs(
                selectedIndex: selected,
                onSelected: (index) => setState(() => selected = index),
              );
            },
          ),
        ),
      ),
    );
    expect(find.byType(ChoiceChip), findsNWidgets(5));
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('research-workspace-tab-0')))
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('research-workspace-tab-2')));
    await tester.pump();
    expect(selected, 2);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('research-workspace-tab-2')))
          .selected,
      isTrue,
    );
  });

  testWidgets('research workspace tabs scroll horizontally at 390px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: ResearchWorkspaceTabs(
                  selectedIndex: selected,
                  onSelected: (index) => setState(() => selected = index),
                ),
              );
            },
          ),
        ),
      ),
    );
    expect(
      find.byKey(const Key('research-workspace-tabs-scroll')),
      findsOneWidget,
    );
    await tester.drag(
      find.byKey(const Key('research-workspace-tabs-scroll')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
