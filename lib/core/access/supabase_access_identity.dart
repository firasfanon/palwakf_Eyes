import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Parses `pal_eyes.user_roles` rows into roles. Unknown keys are ignored
/// (fail closed); inactive rows are filtered server-side and here.
Set<PalEyesRole> parseRoleRows(Object? rows) {
  final roles = <PalEyesRole>{};
  if (rows is! List<Object?>) return roles;
  for (final row in rows) {
    if (row is! Map<Object?, Object?>) continue;
    final active = row['is_active'];
    if (active is bool && !active) continue;
    final key = row['role_key'];
    if (key is! String) continue;
    final role = PalEyesRole.fromKey(key);
    if (role != null) roles.add(role);
  }
  return roles;
}

/// Binds a real Supabase session to [authenticatedAccessIdentityProvider].
///
/// Roles are read from `pal_eyes.user_roles` under the caller's own RLS
/// (`user_roles_self_read`). Any failure resolves to an authenticated
/// identity with no roles, which the router gate treats as insufficient.
final supabaseAccessBindingProvider = Provider<void>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapResultProvider);
  if (!bootstrap.isEnabled) return;

  final client = Supabase.instance.client;
  final controller = ref.read(authenticatedAccessIdentityProvider.notifier);

  Future<void> resolve(Session? session) async {
    final user = session?.user;
    if (user == null) {
      controller.signedOut();
      return;
    }
    try {
      final rows = await client
          .schema('pal_eyes')
          .from('user_roles')
          .select('role_key, is_active')
          .eq('user_id', user.id)
          .eq('is_active', true);
      controller.signedIn(userId: user.id, roles: parseRoleRows(rows));
    } on Object {
      controller.signedIn(userId: user.id, roles: const <PalEyesRole>{});
    }
  }

  final subscription = client.auth.onAuthStateChange.listen(
    (state) => unawaited(resolve(state.session)),
  );
  unawaited(resolve(client.auth.currentSession));
  ref.onDispose(subscription.cancel);
});
