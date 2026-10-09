import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final guard = File(
    'supabase/migrations/202610090003_pal_eyes_publication_fail_closed_guard.sql',
  );

  test('publication guard migration exists and is source-only', () {
    expect(guard.existsSync(), isTrue);
    final source = guard.readAsStringSync();
    expect(source, contains('SOURCE-ONLY CANDIDATE MIGRATION'));
    expect(source, contains("pal_eyes.has_any_role(array['release_manager', 'system_admin'])"));
    expect(source, contains('PUBLICATION_FAIL_CLOSED'));
    expect(source, contains('AUDIT_LOG_APPEND_ONLY'));
    expect(source, contains('revoke update, delete on pal_eyes.audit_events from authenticated'));
    for (final guarded in <String>[
      "('sites', 'publication_status', 'CANDIDATE,PUBLISHED')",
      "('sites', 'coordinate_status', 'PUBLIC_APPROVED')",
      "('sources', 'public_release_status', 'PUBLISHED')",
      "('editorial_records', 'publication_status', 'PUBLISHED')",
    ]) {
      expect(source, contains(guarded), reason: guarded);
    }
    expect(source.contains('grant insert'), isFalse);
    expect(source.contains(' to anon'), isFalse);
  });

  test('server boundary harness refuses non-local databases', () {
    final runner = File(
      'tools/rls_boundary/run_local_rls_boundary_tests.sh',
    ).readAsStringSync();
    expect(runner, contains('REFUSED_NON_LOCAL_DATABASE_HOST'));
    final probes = File(
      'tools/rls_boundary/rls_boundary_tests.sql',
    ).readAsStringSync();
    expect(probes, contains('synthetic.example.invalid'));
    expect(probes, contains('__probe_rollback__'));
    expect(
      RegExp(r"rls_test\.probe\('").allMatches(probes).length,
      greaterThanOrEqualTo(30),
    );
  });
}
