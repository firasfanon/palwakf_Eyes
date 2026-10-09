import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/app.dart';
import 'package:pal_eyes/app/router/app_router.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/access/pal_eyes_auth_gateway.dart';
import 'package:pal_eyes/core/widgets/workspace_shell.dart';
import 'package:pal_eyes/features/admin/presentation/admin_users_screen.dart';
import 'package:pal_eyes/features/common/presentation/access_restricted_screen.dart';

class FakeGateway implements PalEyesAuthGateway {
  FakeGateway({
    required this.onSignedIn,
    this.outcome = SignInOutcome.signedIn,
    this.totpOk = true,
    this.refuseRoleChange = false,
  });

  final void Function() onSignedIn;
  SignInOutcome outcome;
  bool totpOk;
  bool refuseRoleChange;
  final List<String> calls = <String>[];
  String? _email;

  @override
  bool get available => true;
  @override
  String? get currentEmail => _email;
  @override
  String? get currentUserId => 'admin-self';
  @override
  String get assuranceLevel => 'aal1';

  @override
  Future<SignInOutcome> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn:$email');
    _email = email;
    if (outcome == SignInOutcome.signedIn) onSignedIn();
    return outcome;
  }

  @override
  Future<bool> verifyTotp(String code) async {
    calls.add('verify:$code');
    if (totpOk) onSignedIn();
    return totpOk;
  }

  @override
  Future<void> requestPasswordReset(String email) async =>
      calls.add('reset:$email');
  @override
  Future<void> signOut() async => calls.add('signOut');
  @override
  Future<TotpEnrollment> enrollTotp() async =>
      const TotpEnrollment(factorId: 'f1', secret: 'JBSWY3DP', uri: 'otpauth://x');
  @override
  Future<bool> confirmTotpEnrollment({
    required String factorId,
    required String code,
  }) async => code == '123456';
  @override
  Future<List<DirectoryUser>> listUsers() async => const <DirectoryUser>[
    DirectoryUser(
      userId: 'admin-self',
      email: 'admin@synthetic.example.invalid',
      roles: <PalEyesRole>{PalEyesRole.systemAdmin},
    ),
    DirectoryUser(
      userId: 'other',
      email: 'editor@synthetic.example.invalid',
      roles: <PalEyesRole>{PalEyesRole.editor},
    ),
  ];
  @override
  Future<void> setRole({
    required String userId,
    required PalEyesRole role,
    required bool active,
  }) async {
    calls.add('setRole:$userId:${role.key}:$active');
    if (refuseRoleChange) throw StateError('42501');
  }
}

Future<(ProviderContainer, FakeGateway)> _pump(
  WidgetTester tester, {
  Set<PalEyesRole> roles = const <PalEyesRole>{PalEyesRole.editor},
  SignInOutcome outcome = SignInOutcome.signedIn,
  bool refuseRoleChange = false,
}) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  late ProviderContainer container;
  final gateway = FakeGateway(
    outcome: outcome,
    refuseRoleChange: refuseRoleChange,
    onSignedIn: () => container
        .read(authenticatedAccessIdentityProvider.notifier)
        .signedIn(userId: 'admin-self', roles: roles),
  );
  container = ProviderContainer(
    overrides: [palEyesAuthGatewayProvider.overrideWithValue(gateway)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PalEyesApp()),
  );
  await tester.pumpAndSettle();
  return (container, gateway);
}

Future<void> _go(WidgetTester tester, ProviderContainer c, String path) async {
  c.read(appRouterProvider).go(path);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign-in is honest when no identity backend is configured', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PalEyesApp()),
    );
    await _go(tester, container, '/sign-in');
    expect(find.byKey(const Key('sign-in-unavailable')), findsOneWidget);
    expect(find.byKey(const Key('sign-in-email')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invite-only: no sign-up affordance anywhere on sign-in', (
    tester,
  ) async {
    final (c, _) = await _pump(tester);
    await _go(tester, c, '/sign-in');
    expect(find.textContaining('إنشاء حساب'), findsNothing);
    expect(find.textContaining('تسجيل جديد'), findsNothing);
    expect(find.text('الحسابات بالدعوة فقط. لا يوجد تسجيل عام.'), findsOneWidget);
  });

  testWidgets('valid credentials open the workspace for a role holder', (
    tester,
  ) async {
    final (c, g) = await _pump(tester);
    await _go(tester, c, '/sign-in');
    await tester.enterText(
      find.byKey(const Key('sign-in-email')),
      'editor@synthetic.example.invalid',
    );
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'x');
    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();
    expect(g.calls.first, 'signIn:editor@synthetic.example.invalid');
    expect(find.byType(WorkspaceShell), findsOneWidget);
    expect(find.byKey(const Key('workspace-sign-out')), findsOneWidget);
  });

  testWidgets('wrong credentials show a neutral error and stay outside', (
    tester,
  ) async {
    final (c, _) = await _pump(
      tester,
      outcome: SignInOutcome.invalidCredentials,
    );
    await _go(tester, c, '/sign-in');
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'a@b.c');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'x');
    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sign-in-error')), findsOneWidget);
    expect(find.byType(WorkspaceShell), findsNothing);
  });

  testWidgets('MFA-enrolled account must pass the TOTP step', (tester) async {
    final (c, g) = await _pump(tester, outcome: SignInOutcome.mfaRequired);
    await _go(tester, c, '/sign-in');
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'a@b.c');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'x');
    await tester.tap(find.byKey(const Key('sign-in-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sign-in-totp')), findsOneWidget);
    expect(find.byType(WorkspaceShell), findsNothing);
    await tester.enterText(find.byKey(const Key('sign-in-totp')), '123456');
    await tester.tap(find.byKey(const Key('sign-in-verify')));
    await tester.pumpAndSettle();
    expect(g.calls, contains('verify:123456'));
    expect(find.byType(WorkspaceShell), findsOneWidget);
  });

  testWidgets('password reset is neutral about account existence', (
    tester,
  ) async {
    final (c, g) = await _pump(tester);
    await _go(tester, c, '/sign-in');
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'x@y.z');
    await tester.tap(find.text('نسيت كلمة المرور'));
    await tester.pumpAndSettle();
    expect(g.calls, contains('reset:x@y.z'));
    expect(find.byKey(const Key('sign-in-reset-sent')), findsOneWidget);
  });

  testWidgets('user administration is system-admin only', (tester) async {
    final (c, _) = await _pump(
      tester,
      roles: const <PalEyesRole>{
        PalEyesRole.reviewManager,
        PalEyesRole.releaseManager,
      },
    );
    c
        .read(authenticatedAccessIdentityProvider.notifier)
        .signedIn(
          userId: 'rm',
          roles: const <PalEyesRole>{
            PalEyesRole.reviewManager,
            PalEyesRole.releaseManager,
          },
        );
    await tester.pumpAndSettle();
    await _go(tester, c, '/admin/users');
    expect(find.byType(AccessRestrictedScreen), findsOneWidget);
    expect(find.byType(AdminUsersScreen), findsNothing);
  });

  testWidgets('system admin manages others but never own roles', (
    tester,
  ) async {
    final (c, g) = await _pump(
      tester,
      roles: const <PalEyesRole>{PalEyesRole.systemAdmin},
    );
    c
        .read(authenticatedAccessIdentityProvider.notifier)
        .signedIn(
          userId: 'admin-self',
          roles: const <PalEyesRole>{PalEyesRole.systemAdmin},
        );
    await tester.pumpAndSettle();
    await _go(tester, c, '/admin/users');
    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.text('حسابك — لا يمكنك تعديل أدوارك.'), findsOneWidget);

    final ownCard = find.byKey(const Key('admin-user-admin-self'));
    final ownChips = find.descendant(
      of: ownCard,
      matching: find.byType(FilterChip),
    );
    for (final element in ownChips.evaluate()) {
      expect((element.widget as FilterChip).onSelected, isNull);
    }

    final otherResearcher = find.descendant(
      of: find.byKey(const Key('admin-user-other')),
      matching: find.widgetWithText(FilterChip, 'باحث'),
    );
    await tester.ensureVisible(otherResearcher);
    await tester.tap(otherResearcher);
    await tester.pumpAndSettle();
    expect(g.calls, contains('setRole:other:researcher:true'));
  });

  testWidgets('server refusal of a role change is surfaced, not hidden', (
    tester,
  ) async {
    final (c, _) = await _pump(
      tester,
      roles: const <PalEyesRole>{PalEyesRole.systemAdmin},
      refuseRoleChange: true,
    );
    c
        .read(authenticatedAccessIdentityProvider.notifier)
        .signedIn(
          userId: 'admin-self',
          roles: const <PalEyesRole>{PalEyesRole.systemAdmin},
        );
    await tester.pumpAndSettle();
    await _go(tester, c, '/admin/users');
    final chip = find.descendant(
      of: find.byKey(const Key('admin-user-other')),
      matching: find.widgetWithText(FilterChip, 'باحث'),
    );
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.textContaining('رُفض التعديل من الخادم'), findsOneWidget);
  });

  testWidgets('sign-out from the workspace returns to the gate', (
    tester,
  ) async {
    final (c, g) = await _pump(tester);
    c
        .read(authenticatedAccessIdentityProvider.notifier)
        .signedIn(
          userId: 'editor',
          roles: const <PalEyesRole>{PalEyesRole.editor},
        );
    await tester.pumpAndSettle();
    await _go(tester, c, '/workspace');
    await tester.tap(find.byKey(const Key('workspace-sign-out')));
    await tester.pumpAndSettle();
    expect(g.calls, contains('signOut'));
  });

  testWidgets('TOTP enrollment confirms with a valid code', (tester) async {
    final (c, _) = await _pump(tester);
    c
        .read(authenticatedAccessIdentityProvider.notifier)
        .signedIn(
          userId: 'editor',
          roles: const <PalEyesRole>{PalEyesRole.editor},
        );
    await tester.pumpAndSettle();
    await _go(tester, c, '/workspace/security');
    await tester.tap(find.byKey(const Key('security-enroll')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('security-secret')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('security-code')), '123456');
    await tester.tap(find.byKey(const Key('security-confirm')));
    await tester.pumpAndSettle();
    expect(find.textContaining('تم تفعيل التحقق بخطوتين'), findsOneWidget);
  });
}
