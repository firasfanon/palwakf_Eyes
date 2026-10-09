import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';

/// Role keys mirror `pal_eyes.user_roles.role_key` in
/// supabase/migrations/202607190001_pal_eyes_operational_backend.sql.
enum PalEyesRole {
  researcher('researcher'),
  editor('editor'),
  sourceReviewer('source_reviewer'),
  gisReviewer('gis_reviewer'),
  rightsReviewer('rights_reviewer'),
  reviewManager('review_manager'),
  releaseManager('release_manager'),
  systemAdmin('system_admin');

  const PalEyesRole(this.key);

  final String key;

  static PalEyesRole? fromKey(String key) {
    for (final role in PalEyesRole.values) {
      if (role.key == key.trim()) return role;
    }
    return null;
  }
}

/// Route areas with distinct authority requirements.
enum PalEyesAccessArea {
  public,
  workspace,
  releaseControl,
  governance,
  userAdministration,
}

enum PalEyesIdentitySource {
  /// No session. Public visitor.
  anonymous,

  /// A real authenticated backend session whose roles were read from the
  /// backing service.
  authenticatedSession,

  /// Non-production internal inspector build: a synthetic identity used to
  /// review workspace and governance screens. Never available in production
  /// and never backed by real credentials or real data writes.
  syntheticInspector,
}

class PalEyesAccessIdentity {
  const PalEyesAccessIdentity({
    required this.source,
    this.userId,
    this.roles = const <PalEyesRole>{},
  });

  const PalEyesAccessIdentity.anonymous()
    : source = PalEyesIdentitySource.anonymous,
      userId = null,
      roles = const <PalEyesRole>{};

  const PalEyesAccessIdentity.syntheticInspector()
    : source = PalEyesIdentitySource.syntheticInspector,
      userId = 'synthetic-nonproduction-inspector',
      roles = const <PalEyesRole>{
        PalEyesRole.researcher,
        PalEyesRole.editor,
        PalEyesRole.sourceReviewer,
        PalEyesRole.gisReviewer,
        PalEyesRole.rightsReviewer,
        PalEyesRole.reviewManager,
        PalEyesRole.releaseManager,
        PalEyesRole.systemAdmin,
      };

  final PalEyesIdentitySource source;
  final String? userId;
  final Set<PalEyesRole> roles;

  bool get isAnonymous => source == PalEyesIdentitySource.anonymous;
  bool get isSynthetic => source == PalEyesIdentitySource.syntheticInspector;

  bool hasAny(Set<PalEyesRole> required) => roles.any(required.contains);
}

enum PalEyesAccessOutcome { allowed, signInRequired, insufficientRole }

class PalEyesAccessDecision {
  const PalEyesAccessDecision(this.area, this.outcome);

  final PalEyesAccessArea area;
  final PalEyesAccessOutcome outcome;

  bool get allowed => outcome == PalEyesAccessOutcome.allowed;
}

/// Pure, testable authorization policy for client routes.
///
/// The client gate is defence in depth only; the authoritative boundary is
/// row-level security in the backing service (see tools/rls_boundary).
abstract final class PalEyesAccessPolicy {
  static const Set<PalEyesRole> workspaceRoles = <PalEyesRole>{
    PalEyesRole.researcher,
    PalEyesRole.editor,
    PalEyesRole.sourceReviewer,
    PalEyesRole.gisReviewer,
    PalEyesRole.rightsReviewer,
    PalEyesRole.reviewManager,
    PalEyesRole.releaseManager,
    PalEyesRole.systemAdmin,
  };

  static const Set<PalEyesRole> releaseRoles = <PalEyesRole>{
    PalEyesRole.reviewManager,
    PalEyesRole.releaseManager,
    PalEyesRole.systemAdmin,
  };

  static const Set<PalEyesRole> governanceRoles = <PalEyesRole>{
    PalEyesRole.reviewManager,
    PalEyesRole.releaseManager,
    PalEyesRole.systemAdmin,
  };

  static PalEyesAccessArea areaFor(String path) {
    final normalized = _normalize(path);
    if (_within(normalized, RoutePaths.adminUsers)) {
      return PalEyesAccessArea.userAdministration;
    }
    if (_within(normalized, RoutePaths.admin)) {
      return PalEyesAccessArea.governance;
    }
    if (_within(normalized, RoutePaths.workspaceReleaseControl) ||
        _within(normalized, RoutePaths.workspacePublication)) {
      return PalEyesAccessArea.releaseControl;
    }
    if (_within(normalized, RoutePaths.workspace)) {
      return PalEyesAccessArea.workspace;
    }
    return PalEyesAccessArea.public;
  }

  static Set<PalEyesRole> requiredRoles(PalEyesAccessArea area) =>
      switch (area) {
        PalEyesAccessArea.public => const <PalEyesRole>{},
        PalEyesAccessArea.workspace => workspaceRoles,
        PalEyesAccessArea.releaseControl => releaseRoles,
        PalEyesAccessArea.governance => governanceRoles,
        PalEyesAccessArea.userAdministration => const <PalEyesRole>{
          PalEyesRole.systemAdmin,
        },
      };

  static PalEyesAccessDecision decide({
    required String path,
    required PalEyesAccessIdentity identity,
  }) {
    final area = areaFor(path);
    if (area == PalEyesAccessArea.public) {
      return PalEyesAccessDecision(area, PalEyesAccessOutcome.allowed);
    }
    if (identity.isAnonymous) {
      return PalEyesAccessDecision(area, PalEyesAccessOutcome.signInRequired);
    }
    return identity.hasAny(requiredRoles(area))
        ? PalEyesAccessDecision(area, PalEyesAccessOutcome.allowed)
        : PalEyesAccessDecision(area, PalEyesAccessOutcome.insufficientRole);
  }

  /// Resolves the synthetic inspector identity only where it is permitted.
  static PalEyesAccessIdentity baselineIdentity({
    required AppEnvironment environment,
    required PalEyesPresentationMode presentationMode,
  }) {
    if (environment.isProduction) {
      return const PalEyesAccessIdentity.anonymous();
    }
    return presentationMode.isInternal
        ? const PalEyesAccessIdentity.syntheticInspector()
        : const PalEyesAccessIdentity.anonymous();
  }

  static String _normalize(String path) {
    var value = path.trim().toLowerCase();
    final query = value.indexOf('?');
    if (query >= 0) value = value.substring(0, query);
    final fragment = value.indexOf('#');
    if (fragment >= 0) value = value.substring(0, fragment);
    value = value.replaceAll(RegExp('/{2,}'), '/');
    if (!value.startsWith('/')) value = '/$value';
    while (value.length > 1 && value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  static bool _within(String path, String prefix) =>
      path == prefix || path.startsWith('$prefix/');
}

/// Identity established by a real backend session (roles read from the
/// backing service). `null` means no authenticated session.
final authenticatedAccessIdentityProvider =
    NotifierProvider<
      AuthenticatedAccessIdentityController,
      PalEyesAccessIdentity?
    >(AuthenticatedAccessIdentityController.new);

class AuthenticatedAccessIdentityController
    extends Notifier<PalEyesAccessIdentity?> {
  @override
  PalEyesAccessIdentity? build() => null;

  void signedIn({required String userId, required Set<PalEyesRole> roles}) {
    state = PalEyesAccessIdentity(
      source: PalEyesIdentitySource.authenticatedSession,
      userId: userId,
      roles: Set<PalEyesRole>.unmodifiable(roles),
    );
  }

  void signedOut() => state = null;
}

/// Effective identity used by the router gate.
final palEyesAccessIdentityProvider = Provider<PalEyesAccessIdentity>((ref) {
  final authenticated = ref.watch(authenticatedAccessIdentityProvider);
  if (authenticated != null) return authenticated;
  return PalEyesAccessPolicy.baselineIdentity(
    environment: ref.watch(appEnvironmentProvider),
    presentationMode: ref.watch(palEyesPresentationModeProvider),
  );
});
