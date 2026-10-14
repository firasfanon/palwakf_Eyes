import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/widgets/workspace_shell.dart';

void main() {
  for (final width in <double>[320, 360, 390, 430, 619, 620, 768]) {
    for (final direction in <TextDirection>[
      TextDirection.rtl,
      TextDirection.ltr,
    ]) {
      testWidgets('workspace app bar fits width $width direction $direction', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Directionality(
                textDirection: direction,
                child: const WorkspaceShell(
                  location: '/workspace/research',
                  child: Center(child: Text('safe test content')),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
