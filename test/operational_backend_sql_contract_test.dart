import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('operational migration is fail-closed and role governed', () {
    final source = File(
      'supabase/migrations/202607190001_pal_eyes_operational_backend.sql',
    ).readAsStringSync();

    for (final table in <String>[
      'sites',
      'original_draft_layers',
      'sources',
      'editorial_records',
      'claims',
      'coordinate_candidates',
      'media_assets',
      'review_tasks',
      'release_candidates',
      'audit_events',
    ]) {
      expect(
        source.contains('create table if not exists pal_eyes.$table'),
        isTrue,
        reason: table,
      );
    }

    expect(source.contains('enable row level security'), isTrue);
    expect(source.contains('force row level security'), isTrue);
    expect(source.contains('pal_eyes.has_any_role'), isTrue);
    expect(source.contains("publication_status = 'PUBLISHED'"), isTrue);
    expect(source.contains('original_draft_layers'), isTrue);
    expect(source.contains('public_original_draft'), isFalse);
    expect(
      source.contains('grant insert on all tables in schema pal_eyes to anon'),
      isFalse,
    );
  });

  test('seed imports governed counts without public release', () {
    final source = File(
      'supabase/seed/202607190001_pal_eyes_r7_0_0_seed.sql',
    ).readAsStringSync();

    expect('insert into pal_eyes.sites'.allMatches(source), hasLength(79));
    expect(
      'insert into pal_eyes.original_draft_layers'.allMatches(source),
      hasLength(79),
    );
    expect('insert into pal_eyes.sources'.allMatches(source), hasLength(95));
    expect(
      'insert into pal_eyes.editorial_records'.allMatches(source),
      hasLength(92),
    );
    expect('insert into pal_eyes.claims'.allMatches(source), hasLength(211));
    expect(source.contains("publication_status,'BLOCKED'"), isFalse);
    expect(
      RegExp(
        r"insert into pal_eyes\.coordinate_candidates[^\n]*'BLOCKED'",
      ).allMatches(source),
      hasLength(4),
    );
    expect(source.contains('public_map_use=excluded.public_map_use'), isTrue);
    expect(source.contains('public_map_use=BLOCKED'), isFalse);
  });
}
