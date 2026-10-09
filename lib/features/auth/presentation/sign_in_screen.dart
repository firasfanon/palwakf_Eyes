import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/access/pal_eyes_auth_gateway.dart';

/// Invite-only sign-in for internal team members. There is no sign-up path.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

enum _Stage { credentials, mfa, resetSent }

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  _Stage _stage = _Stage.credentials;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  /// Roles are resolved asynchronously from `pal_eyes.user_roles` after the
  /// session starts; wait for that before entering the gated workspace.
  Future<void> _enterWorkspace() async {
    for (var i = 0; i < 50; i++) {
      if (!mounted) return;
      if (ref.read(authenticatedAccessIdentityProvider) != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (mounted) context.go(RoutePaths.workspace);
  }

  Future<void> _submit(PalEyesAuthGateway gateway) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final outcome = await gateway.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case SignInOutcome.signedIn:
        await _enterWorkspace();
      case SignInOutcome.mfaRequired:
        setState(() => _stage = _Stage.mfa);
      case SignInOutcome.invalidCredentials:
        setState(() => _error = 'تعذّر الدخول. تحقق من البريد وكلمة المرور.');
      case SignInOutcome.unavailable:
        setState(() => _error = 'خدمة الهوية غير مهيأة في هذا البناء.');
    }
  }

  Future<void> _verify(PalEyesAuthGateway gateway) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await gateway.verifyTotp(_code.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      await _enterWorkspace();
    } else {
      setState(() => _error = 'رمز التحقق غير صحيح أو منتهي الصلاحية.');
    }
  }

  Future<void> _reset(PalEyesAuthGateway gateway) async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'أدخل البريد الإلكتروني أولاً.');
      return;
    }
    setState(() => _busy = true);
    try {
      await gateway.requestPasswordReset(_email.text);
    } on Object {
      // Neutral response: never reveal whether an account exists.
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _stage = _Stage.resetSent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gateway = ref.watch(palEyesAuthGatewayProvider);
    final identity = ref.watch(palEyesAccessIdentityProvider);
    final theme = Theme.of(context);

    Widget body;
    if (!gateway.available) {
      body = Column(
        key: const Key('sign-in-unavailable'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'تسجيل الدخول غير متاح في هذا البناء',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PalEyesTokens.space3),
          Text(
            'لم تُهيأ خدمة الهوية (Supabase) لهذا الإصدار. لا يوجد دخول بديل أو حسابات تجريبية.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PalEyesTokens.textMuted(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (identity.source == PalEyesIdentitySource.authenticatedSession) {
      body = Column(
        key: const Key('sign-in-already'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'أنت مسجّل الدخول',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PalEyesTokens.space2),
          Text(
            gateway.currentEmail ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PalEyesTokens.space5),
          FilledButton(
            onPressed: () => context.go(RoutePaths.workspace),
            child: const Text('فتح مساحة العمل'),
          ),
          const SizedBox(height: PalEyesTokens.space2),
          OutlinedButton(
            onPressed: () => gateway.signOut(),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      );
    } else {
      body = Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _stage == _Stage.mfa ? 'التحقق بخطوتين' : 'دخول فريق العمل',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PalEyesTokens.space2),
            Text(
              _stage == _Stage.mfa
                  ? 'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.'
                  : 'الحسابات بالدعوة فقط. لا يوجد تسجيل عام.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: PalEyesTokens.textMuted(context),
              ),
            ),
            const SizedBox(height: PalEyesTokens.space5),
            if (_stage == _Stage.credentials) ...<Widget>[
              TextFormField(
                key: const Key('sign-in-email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.username],
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
                validator: (v) => (v ?? '').contains('@')
                    ? null
                    : 'أدخل بريداً إلكترونياً صالحاً',
              ),
              const SizedBox(height: PalEyesTokens.space3),
              TextFormField(
                key: const Key('sign-in-password'),
                controller: _password,
                obscureText: true,
                autofillHints: const <String>[AutofillHints.password],
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                validator: (v) => (v ?? '').isEmpty ? 'أدخل كلمة المرور' : null,
                onFieldSubmitted: (_) => _submit(gateway),
              ),
              const SizedBox(height: PalEyesTokens.space4),
              FilledButton(
                key: const Key('sign-in-submit'),
                onPressed: _busy ? null : () => _submit(gateway),
                child: Text(_busy ? 'جارٍ التحقق…' : 'دخول'),
              ),
              TextButton(
                onPressed: _busy ? null : () => _reset(gateway),
                child: const Text('نسيت كلمة المرور'),
              ),
            ],
            if (_stage == _Stage.mfa) ...<Widget>[
              TextFormField(
                key: const Key('sign-in-totp'),
                controller: _code,
                keyboardType: TextInputType.number,
                autofillHints: const <String>[AutofillHints.oneTimeCode],
                textDirection: TextDirection.ltr,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'رمز التحقق'),
                onFieldSubmitted: (_) => _verify(gateway),
              ),
              FilledButton(
                key: const Key('sign-in-verify'),
                onPressed: _busy ? null : () => _verify(gateway),
                child: const Text('تحقق'),
              ),
            ],
            if (_stage == _Stage.resetSent)
              Text(
                'إن كان البريد مسجلاً لدينا فستصل رسالة لإعادة تعيين كلمة المرور.',
                key: const Key('sign-in-reset-sent'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: PalEyesTokens.space3),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  key: const Key('sign-in-error'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ColoredBox(
      color: PalEyesTokens.page(context),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PalEyesTokens.space5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: PalEyesTokens.panel(context),
                borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
                border: Border.all(color: PalEyesTokens.border(context)),
                boxShadow: PalEyesTokens.softShadow(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PalEyesTokens.space6),
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
