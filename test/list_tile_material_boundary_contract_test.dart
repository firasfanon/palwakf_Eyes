import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ListTile and ExpansionTile surfaces own painted Material canvases', () {
    final directListTileBoundaries = <String, int>{
      'lib/core/widgets/public_shell.dart': 1,
      'lib/core/widgets/workspace_shell.dart': 1,
    };

    for (final entry in directListTileBoundaries.entries) {
      final source = File(entry.key).readAsStringSync();

      expect(
        RegExp(
          r'type:\s*MaterialType\.transparency,\s*child:\s*ListTile\(',
          multiLine: true,
        ).hasMatch(source),
        isFalse,
        reason: '${entry.key} must not use MaterialType.transparency',
      );

      expect(
        RegExp(
          r'Material\(\s*color:\s*Colors\.transparent,\s*child:\s*ListTile\(',
          multiLine: true,
        ).allMatches(source).length,
        greaterThanOrEqualTo(entry.value),
        reason: '${entry.key} must give direct ListTiles their own canvas',
      );
    }

    final interactiveSources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
          final source = file.readAsStringSync();
          return source.contains('ListTile(') ||
              source.contains('ExpansionTile(');
        });

    for (final file in interactiveSources) {
      final source = file.readAsStringSync();
      expect(
        source.contains('ColoredBox('),
        isFalse,
        reason:
            '${file.path} must not place ListTile/ExpansionTile below ColoredBox',
      );
    }

    final workspace = File(
      'lib/core/widgets/workspace_shell.dart',
    ).readAsStringSync();
    expect(workspace.contains('ExpansionTile('), isTrue);
    expect(
      RegExp(
        r'return\s+Material\(\s*color:\s*Theme\.of\(context\)'
        r'\.colorScheme\.surface,\s*child:\s*ListView\(',
        multiLine: true,
      ).hasMatch(workspace),
      isTrue,
    );

    final map = File(
      'lib/features/map/presentation/map_screen.dart',
    ).readAsStringSync();
    expect(map.contains('ListTile('), isFalse);
    expect(map.contains('return ColoredBox('), isTrue);
    expect(map.contains('color: PalEyesVisualV1.parchment'), isTrue);
  });
}
