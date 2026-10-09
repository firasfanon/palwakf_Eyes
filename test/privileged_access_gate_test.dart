import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/app.dart';
import 'package:pal_eyes/app/router/app_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/access/supabase_access_identity.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/presentation/public_experience_mode.dart';
import 'package:pal_eyes/core/widgets/governance_shell.dart';
import 'package:pal_eyes/core/widgets/workspace_shell.dart';
import 'package:pal_eyes/features/common/presentation/access_restricted_screen.dart';

const _production = AppEnvironment(
  supabaseUrl: '',
  supabasePublishableKey: '',
  environmentName: 'production',
);

const _staging = AppEnvironment(
  supabaseUrl: '',
  supabasePublishableKey: '',
  environmentName: 'staging',
);

PalEyesAccessIdentity _session(Set<PalEyesRole> roles) => PalEyesAccessIdentity(
  source: PalEyesIdentitySource.authenticatedSession,
  userId: 'synthetic-test-user',
  roles: roles,
);

const List<String> _privilegedSamples = <String>[
  '/workspace',
  '/workspace/',
  '/WORKSPACE',
  '//workspace',
  '/workspace/places/editor',
  '/workspace/release-control',
  '/workspace/publication',
  '/workspace/audit',
  '/admin',
  '/admin/',
  '/admin/governance',
  '/admin/governance/rights?tab=x',
  '/admin/governance/system-status#top',
];

void main() {
  group('access policy (pure)', () {
    test('every registered workspace and governance route is privileged', () {
      for (final route in <String>[
        ...RoutePaths.workspaceRoutes,
        ...RoutePaths.governanceRoutes,
        RoutePaths.admin,
      ]) {
        expect(
          PalEyesAccessPolicy.areaFor(route),
          isNot(PalEyesAccessArea.public),
          reason: route,
        );
      }
    });

    test('public routes stay public and look-alike paths are not privileged', () {
      for (final route in <String>[
        ...RoutePaths.publicRoutes,
        RoutePaths.accessRestricted,
        '/places/workspace',
        '/workspaces-guide',
        '/administration',
      ]) {
        expect(
          PalEyesAccessPolicy.areaFor(route),
          PalEyesAccessArea.public,
          reason: route,
        );
      }
    });

    test('anonymous visitor is denied every privileged path', () {
      for (final path in _privilegedSamples) {
        final decision = PalEyesAccessPolicy.decide(
          path: path,
          identity: const PalEyesAccessIdentity.anonymous(),
        );
        expect(decision.allowed, isFalse, reason: path);
        expect(
          decision.outcome,
          PalEyesAccessOutcome.signInRequired,
          reason: path,
        );
      }
    });

    test('authenticated account without roles is denied', () {
      for (final path in _privilegedSamples) {
        final decision = PalEyesAccessPolicy.decide(
          path: path,
          identity: _session(const <PalEyesRole>{}),
        );
        expect(
          decision.outcome,
          PalEyesAccessOutcome.insufficientRole,
          reason: path,
        );
      }
    });

    test('researcher reaches workspace but not release control or admin', () {
      final researcher = _session(const <PalEyesRole>{PalEyesRole.researcher});
      bool allowed(String path) =>
          PalEyesAccessPolicy.decide(path: path, identity: researcher).allowed;

      expect(allowed('/workspace'), isTrue);
      expect(allowed('/workspace/research'), isTrue);
      expect(allowed('/workspace/release-control'), isFalse);
      expect(allowed('/workspace/publication'), isFalse);
      expect(allowed('/admin'), isFalse);
      expect(allowed('/admin/governance/rights'), isFalse);
    });

    test('release manager reaches release control and governance', () {
      final release = _session(const <PalEyesRole>{PalEyesRole.releaseManager});
      for (final path in <String>[
        '/workspace',
        '/workspace/release-control',
        '/admin',
        '/admin/governance/audit',
      ]) {
        expect(
          PalEyesAccessPolicy.decide(path: path, identity: release).allowed,
          isTrue,
          reason: path,
        );
      }
    });

    test('synthetic inspector exists only in non-production internal mode', () {
      expect(
        PalEyesAccessPolicy.baselineIdentity(
          environment: _production,
          presentationMode: PalEyesPresentationMode.internalInspector,
        ).isAnonymous,
        isTrue,
      );
      expect(
        PalEyesAccessPolicy.baselineIdentity(
          environment: _staging,
          presentationMode: PalEyesPresentationMode.publicExperience,
        ).isAnonymous,
        isTrue,
      );
      expect(
        PalEyesAccessPolicy.baselineIdentity(
          environment: _staging,
          presentationMode: PalEyesPresentationMode.internalInspector,
        ).isSynthetic,
        isTrue,
      );
    });

    test('redirect targets the restricted page with a reason', () {
      expect(
        palEyesAccessRedirect(
          uri: Uri.parse('/admin/governance'),
          identity: const PalEyesAccessIdentity.anonymous(),
        ),
        '/access-restricted?reason=sign-in',
      );
      expect(
        palEyesAccessRedirect(
          uri: Uri.parse('/admin'),
          identity: _session(const <PalEyesRole>{PalEyesRole.editor}),
        ),
        '/access-restricted?reason=role',
      );
      expect(
        palEyesAccessRedirect(
          uri: Uri.parse('/research'),
          identity: const PalEyesAccessIdentity.anonymous(),
        ),
        isNull,
      );
    });

    test('role rows parse fail-closed', () {
      expect(
        parseRoleRows(<Map<String, dynamic>>[
          <String, dynamic>{'role_key': 'editor', 'is_active': true},
          <String, dynamic>{'role_key': 'system_admin', 'is_active': false},
          <String, dynamic>{'role_key': 'super_user', 'is_active': true},
          <String, dynamic>{'role_key': 42},
        ]),
        <PalEyesRole>{PalEyesRole.editor},
      );
      expect(parseRoleRows(null), isEmpty);
      expect(parseRoleRows('editor'), isEmpty);
    });
  });

  group('router gate (widget)', () {
    Future<ProviderContainer> pumpApp(
      WidgetTester tester, {
      List<Override> overrides = const <Override>[],
    }) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PalEyesApp()),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(
        tester.element(find.byType(PalEyesApp)),
      );
    }

    Future<void> go(
      WidgetTester tester,
      ProviderContainer container,
      String path,
    ) async {
      container.read(appRouterProvider).go(path);
      await tester.pumpAndSettle();
    }

    testWidgets('public visitor cannot open workspace or governance', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      for (final path in <String>[
        '/workspace',
        '/workspace/release-control',
        '/admin',
        '/admin/governance/rights',
      ]) {
        await go(tester, container, path);
        expect(find.byType(AccessRestrictedScreen), findsOneWidget, reason: path);
        expect(find.byType(WorkspaceShell), findsNothing, reason: path);
        expect(find.byType(GovernanceShell), findsNothing, reason: path);
        expect(
          container.read(appRouterProvider).routerDelegate.currentConfiguration.uri.path,
          RoutePaths.accessRestricted,
          reason: path,
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('production build ignores internal presentation request', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        overrides: [
          appEnvironmentProvider.overrideWithValue(_production),
          palEyesPresentationModeProvider.overrideWithValue(
            PalEyesPresentationMode.internalInspector,
          ),
        ],
      );
      await go(tester, container, '/workspace');
      expect(find.byType(AccessRestrictedScreen), findsOneWidget);
      expect(find.byType(WorkspaceShell), findsNothing);
    });

    testWidgets('authenticated editor is refused governance but not workspace', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      container
          .read(authenticatedAccessIdentityProvider.notifier)
          .signedIn(
            userId: 'synthetic-editor',
            roles: const <PalEyesRole>{PalEyesRole.editor},
          );
      await tester.pumpAndSettle();

      await go(tester, container, '/admin');
      expect(find.byType(AccessRestrictedScreen), findsOneWidget);
      expect(find.text('هذه المنطقة مخصصة لفريق العمل'), findsOneWidget);
      expect(
        container.read(appRouterProvider).routerDelegate.currentConfiguration.uri.queryParameters['reason'],
        'role',
      );

      await go(tester, container, '/workspace');
      expect(find.byType(WorkspaceShell), findsOneWidget);
      expect(find.byType(AccessRestrictedScreen), findsNothing);

      // Signing out while inside the workspace re-evaluates the gate.
      container.read(authenticatedAccessIdentityProvider.notifier).signedOut();
      await tester.pumpAndSettle();
      expect(find.byType(WorkspaceShell), findsNothing);
      expect(find.byType(AccessRestrictedScreen), findsOneWidget);
    });

    testWidgets('non-production internal inspector sees synthetic zone label', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        overrides: [
          appEnvironmentProvider.overrideWithValue(_staging),
          palEyesPresentationModeProvider.overrideWithValue(
            PalEyesPresentationMode.internalInspector,
          ),
        ],
      );
      await go(tester, container, '/admin/governance');
      expect(find.byType(GovernanceShell), findsOneWidget);
      expect(find.byKey(const Key('zone-strip-governance')), findsOneWidget);
      expect(find.textContaining('هوية اصطناعية'), findsOneWidget);
    });
  });
}
