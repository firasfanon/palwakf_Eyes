import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';

/// Shown when a visitor requests a workspace or governance route without the
/// required authenticated role. Deliberately reveals nothing about the
/// requested internal screen.
class AccessRestrictedScreen extends StatelessWidget {
  const AccessRestrictedScreen({required this.reason, super.key});

  /// `sign-in` or `role`.
  final String reason;

  @override
  Widget build(BuildContext context) {
    final signIn = reason != 'role';
    final theme = Theme.of(context);
    return ColoredBox(
      color: PalEyesTokens.page(context),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PalEyesTokens.space5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              key: const Key('access-restricted-panel'),
              decoration: BoxDecoration(
                color: PalEyesTokens.panel(context),
                borderRadius: BorderRadius.circular(PalEyesTokens.radiusLarge),
                border: Border.all(color: PalEyesTokens.border(context)),
                boxShadow: PalEyesTokens.softShadow(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PalEyesTokens.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 44,
                      color: PalEyesTokens.accentText(context),
                      semanticLabel: 'منطقة مقيدة',
                    ),
                    const SizedBox(height: PalEyesTokens.space4),
                    Text(
                      'هذه المنطقة مخصصة لفريق العمل',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: PalEyesTokens.text(context),
                      ),
                    ),
                    const SizedBox(height: PalEyesTokens.space3),
                    Text(
                      signIn
                          ? 'يتطلب الوصول إلى مساحة العمل والحوكمة جلسة دخول موثقة بدور مخوّل. لا تُعرض أي أدوات داخلية للزوار.'
                          : 'حسابك الحالي لا يحمل الدور المطلوب لهذه الصفحة. تواصل مع مسؤول النظام لمراجعة الصلاحيات.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: PalEyesTokens.textMuted(context),
                      ),
                    ),
                    const SizedBox(height: PalEyesTokens.space5),
                    FilledButton.icon(
                      onPressed: () => context.go(RoutePaths.home),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('العودة إلى الموقع العام'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
