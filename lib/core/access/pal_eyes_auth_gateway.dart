import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/access/supabase_access_identity.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:pal_eyes/features/operations/data/supabase_operational_data_backend.dart'
    show writeUserRoleGrant;
import 'package:supabase_flutter/supabase_flutter.dart';

enum SignInOutcome { signedIn, mfaRequired, invalidCredentials, unavailable }

class TotpEnrollment {
  const TotpEnrollment({
    required this.factorId,
    required this.secret,
    required this.uri,
  });

  final String factorId;
  final String secret;
  final String uri;
}

class DirectoryUser {
  const DirectoryUser({
    required this.userId,
    required this.email,
    required this.roles,
  });

  final String userId;
  final String email;
  final Set<PalEyesRole> roles;
}

/// Authentication boundary used by the UI. Invite-only: there is deliberately
/// no sign-up method. The Supabase implementation is the only production
/// path; tests override [palEyesAuthGatewayProvider] with a fake.
abstract interface class PalEyesAuthGateway {
  bool get available;
  String? get currentEmail;
  String? get currentUserId;
  String get assuranceLevel;

  Future<SignInOutcome> signIn({
    required String email,
    required String password,
  });
  Future<bool> verifyTotp(String code);
  Future<void> requestPasswordReset(String email);
  Future<void> signOut();
  Future<TotpEnrollment> enrollTotp();
  Future<bool> confirmTotpEnrollment({
    required String factorId,
    required String code,
  });
  Future<List<DirectoryUser>> listUsers();
  Future<void> setRole({
    required String userId,
    required PalEyesRole role,
    required bool active,
  });
}

class UnavailableAuthGateway implements PalEyesAuthGateway {
  const UnavailableAuthGateway();

  @override
  bool get available => false;
  @override
  String? get currentEmail => null;
  @override
  String? get currentUserId => null;
  @override
  String get assuranceLevel => 'aal0';

  Never _blocked() => throw StateError('AUTH_BACKEND_NOT_CONFIGURED');

  @override
  Future<SignInOutcome> signIn({
    required String email,
    required String password,
  }) async => SignInOutcome.unavailable;
  @override
  Future<bool> verifyTotp(String code) async => false;
  @override
  Future<void> requestPasswordReset(String email) async => _blocked();
  @override
  Future<void> signOut() async {}
  @override
  Future<TotpEnrollment> enrollTotp() async => _blocked();
  @override
  Future<bool> confirmTotpEnrollment({
    required String factorId,
    required String code,
  }) async => false;
  @override
  Future<List<DirectoryUser>> listUsers() async => _blocked();
  @override
  Future<void> setRole({
    required String userId,
    required PalEyesRole role,
    required bool active,
  }) async => _blocked();
}

class SupabaseAuthGateway implements PalEyesAuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  @override
  bool get available => true;
  @override
  String? get currentEmail => _client.auth.currentUser?.email;
  @override
  String? get currentUserId => _client.auth.currentUser?.id;
  @override
  String get assuranceLevel =>
      _client.auth.mfa.getAuthenticatorAssuranceLevel().currentLevel?.name ??
      'aal1';

  @override
  Future<SignInOutcome> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException {
      return SignInOutcome.invalidCredentials;
    }
    final level = _client.auth.mfa.getAuthenticatorAssuranceLevel();
    return level.nextLevel == AuthenticatorAssuranceLevels.aal2 &&
            level.currentLevel != AuthenticatorAssuranceLevels.aal2
        ? SignInOutcome.mfaRequired
        : SignInOutcome.signedIn;
  }

  @override
  Future<bool> verifyTotp(String code) async {
    final factors = await _client.auth.mfa.listFactors();
    if (factors.totp.isEmpty) return false;
    try {
      await _client.auth.mfa.challengeAndVerify(
        factorId: factors.totp.first.id,
        code: code.trim(),
      );
      return true;
    } on AuthException {
      return false;
    }
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email.trim());

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<TotpEnrollment> enrollTotp() async {
    final response = await _client.auth.mfa.enroll(
      factorType: FactorType.totp,
      friendlyName: 'pal-eyes-${DateTime.now().millisecondsSinceEpoch}',
    );
    final totp = response.totp;
    if (totp == null) throw StateError('TOTP_ENROLLMENT_FAILED');
    return TotpEnrollment(
      factorId: response.id,
      secret: totp.secret,
      uri: totp.uri,
    );
  }

  @override
  Future<bool> confirmTotpEnrollment({
    required String factorId,
    required String code,
  }) async {
    try {
      await _client.auth.mfa.challengeAndVerify(
        factorId: factorId,
        code: code.trim(),
      );
      return true;
    } on AuthException {
      return false;
    }
  }

  @override
  Future<List<DirectoryUser>> listUsers() async {
    final rows = await _client
        .schema('pal_eyes')
        .rpc<Object?>('admin_list_users');
    final users = <DirectoryUser>[];
    if (rows is! List<Object?>) return users;
    for (final row in rows) {
      if (row is! Map<Object?, Object?>) continue;
      final roles = row['roles'];
      users.add(
        DirectoryUser(
          userId: '${row['user_id']}',
          email: '${row['email'] ?? ''}',
          roles: parseRoleRows(
            roles is List<Object?>
                ? roles
                      .map(
                        (key) => <String, Object?>{
                          'role_key': key,
                          'is_active': true,
                        },
                      )
                      .toList(growable: false)
                : const <Object?>[],
          ),
        ),
      );
    }
    return users;
  }

  @override
  Future<void> setRole({
    required String userId,
    required PalEyesRole role,
    required bool active,
  }) async {
    // All table writes go through the single governed Supabase adapter.
    await writeUserRoleGrant(
      _client,
      userId: userId,
      roleKey: role.key,
      active: active,
    );
  }
}

final palEyesAuthGatewayProvider = Provider<PalEyesAuthGateway>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapResultProvider);
  return bootstrap.isEnabled
      ? SupabaseAuthGateway(Supabase.instance.client)
      : const UnavailableAuthGateway();
});
