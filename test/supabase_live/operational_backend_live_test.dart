// Live E2E of the app's real SupabaseOperationalDataBackend against a LOCAL
// Supabase stack (`supabase start` in CI). Skipped unless the CI job exports
// PAL_EYES_LIVE_SUPABASE_URL; refuses any non-loopback URL.
@Tags(<String>['supabase-live'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/operations/data/supabase_operational_data_backend.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final String _url = Platform.environment['PAL_EYES_LIVE_SUPABASE_URL'] ?? '';
final String _anon = Platform.environment['PAL_EYES_LIVE_ANON_KEY'] ?? '';
final String _password = Platform.environment['PAL_EYES_LIVE_PASSWORD'] ?? '';
final String _domain = Platform.environment['PAL_EYES_LIVE_DOMAIN'] ?? '';

bool get _configured =>
    _url.isNotEmpty && _anon.isNotEmpty && _password.isNotEmpty;

Future<SupabaseClient> _signedIn(String alias) async {
  final client = SupabaseClient(
    _url,
    _anon,
    authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
  );
  await client.auth.signInWithPassword(
    email: '$alias@$_domain',
    password: _password,
  );
  return client;
}

OperationalActor _actor(SupabaseClient client, Set<String> roles) =>
    OperationalActor(
      id: client.auth.currentUser!.id,
      displayName: client.auth.currentUser!.email ?? 'synthetic',
      roles: roles,
    );

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
    if (_configured) {
      final host = Uri.parse(_url).host;
      if (host != '127.0.0.1' && host != 'localhost') {
        fail('REFUSED_NON_LOCAL_SUPABASE=$_url');
      }
    }
  });

  test(
    'editor draft, source and review flow persists through the real backend',
    () async {
      final editor = await _signedIn('editor');
      final backend = SupabaseOperationalDataBackend(editor);
      final actor = _actor(editor, <String>{'editor'});

      final before = await backend.loadSnapshot();
      expect(before.sites, hasLength(79));
      final site = before.sites.first;

      final saved = await backend.saveSiteDraft(
        actor: actor,
        siteId: site.id,
        editorialDraft: 'مسودة اصطناعية من اختبار Dart الحي',
      );
      final after = saved.sites.firstWhere((s) => s.id == site.id);
      expect(after.editorialDraft, 'مسودة اصطناعية من اختبار Dart الحي');
      expect(after.versionNumber, site.versionNumber + 1);
      expect(after.publicationStatus, 'BLOCKED');

      final submitted = await backend.submitSiteForReview(
        actor: actor,
        siteId: site.id,
      );
      expect(
        submitted.reviewTasks.where((t) => t.entityId == site.id),
        isNotEmpty,
      );
      expect(
        submitted.auditEvents.map((e) => e.action),
        containsAll(<String>['SITE_DRAFT_SAVED', 'SITE_SUBMITTED_FOR_REVIEW']),
      );
      await editor.auth.signOut();
    },
    skip: _configured ? false : 'PAL_EYES_LIVE_SUPABASE_URL not set',
  );

  test(
    'researcher cannot take a review decision through the real backend',
    () async {
      final researcher = await _signedIn('researcher');
      final backend = SupabaseOperationalDataBackend(researcher);
      final snapshot = await backend.loadSnapshot();
      final open = snapshot.reviewTasks.firstWhere((t) => t.status == 'OPEN');
      await expectLater(
        backend.decideReviewTask(
          actor: _actor(researcher, <String>{'researcher'}),
          taskId: open.id,
          decision: 'ACCEPT',
          note: 'محاولة غير مخولة',
        ),
        throwsA(isA<PostgrestException>()),
      );
      await researcher.auth.signOut();
    },
    skip: _configured ? false : 'PAL_EYES_LIVE_SUPABASE_URL not set',
  );

  test(
    'release candidate needs MFA even for a release manager',
    () async {
      final manager = await _signedIn('release-manager-dart');
      final backend = SupabaseOperationalDataBackend(manager);
      await expectLater(
        backend.createReleaseCandidate(
          actor: _actor(manager, <String>{'release_manager'}),
          title: 'مرشح اصطناعي بلا عامل ثانٍ',
          siteIds: const <String>[],
          gates: const <String, bool>{'all': true},
        ),
        throwsA(isA<PostgrestException>()),
      );
      await manager.auth.signOut();
    },
    skip: _configured ? false : 'PAL_EYES_LIVE_SUPABASE_URL not set',
  );
}
