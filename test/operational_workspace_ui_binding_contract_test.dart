import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workspace screens consume the operational snapshot provider', () {
    final paths = <String>[
      'lib/features/workspace/presentation/workspace_today_screen.dart',
      'lib/features/workspace/presentation/site_editor_screen.dart',
      'lib/features/workspace/presentation/source_registry_workspace_screen.dart',
      'lib/features/workspace/presentation/claim_workspace_screen.dart',
      'lib/features/workspace/presentation/review_queue_screen.dart',
      'lib/features/workspace/presentation/gis_review_screen.dart',
      'lib/features/workspace/presentation/media_rights_screen.dart',
      'lib/features/workspace/presentation/release_control_screen.dart',
      'lib/features/workspace/presentation/audit_log_screen.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      expect(
        source.contains('operationalSnapshotProvider'),
        isTrue,
        reason: path,
      );
    }
  });

  test('writes are confined to the governed Supabase adapter', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      if (file.path.endsWith('supabase_operational_data_backend.dart')) {
        continue;
      }
      final source = file.readAsStringSync();
      for (final marker in <String>[
        '.insert(',
        '.update(',
        '.upsert(',
        '.delete(',
      ]) {
        expect(
          source.contains(marker),
          isFalse,
          reason: '${file.path}:$marker',
        );
      }
    }
  });
}
