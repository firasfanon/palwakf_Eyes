import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/access/pal_eyes_auth_gateway.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

/// TOTP enrollment for internal accounts. Release authority and role
/// administration are refused by the database below aal2 (migration 0004).
class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  final _code = TextEditingController();
  TotpEnrollment? _enrollment;
  String? _message;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _start(PalEyesAuthGateway gateway) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final enrollment = await gateway.enrollTotp();
      if (!mounted) return;
      setState(() => _enrollment = enrollment);
    } on Object {
      if (!mounted) return;
      setState(() => _message = 'تعذّر بدء التسجيل. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm(PalEyesAuthGateway gateway) async {
    final enrollment = _enrollment;
    if (enrollment == null) return;
    setState(() => _busy = true);
    final ok = await gateway.confirmTotpEnrollment(
      factorId: enrollment.factorId,
      code: _code.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = ok
          ? 'تم تفعيل التحقق بخطوتين لهذه الجلسة والجلسات القادمة.'
          : 'الرمز غير صحيح. تأكد من وقت الجهاز وأعد المحاولة.';
      if (ok) _enrollment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gateway = ref.watch(palEyesAuthGatewayProvider);
    final identity = ref.watch(palEyesAccessIdentityProvider);
    final sensitive = identity.hasAny(const <PalEyesRole>{
      PalEyesRole.releaseManager,
      PalEyesRole.systemAdmin,
    });
    final theme = Theme.of(context);

    return PalEyesPage(
      title: 'أمان الحساب',
      subtitle:
          'التحقق بخطوتين (TOTP) مطلوب لصلاحيات الإصدار وإدارة الأدوار، وتفرضه قاعدة البيانات نفسها.',
      icon: Icons.verified_user_outlined,
      eyebrow: 'مساحة العمل',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!gateway.available)
            const _Notice(
              key: Key('security-unavailable'),
              text:
                  'خدمة الهوية غير مهيأة في هذا البناء؛ لا يمكن تسجيل عامل تحقق. (BLOCKED)',
            )
          else ...<Widget>[
            _Notice(
              text:
                  'مستوى الجلسة الحالي: ${gateway.assuranceLevel}${sensitive ? ' — دورك يتطلب aal2 لعمليات الإصدار والإدارة.' : ''}',
            ),
            const SizedBox(height: PalEyesTokens.space4),
            if (_enrollment == null)
              FilledButton.icon(
                key: const Key('security-enroll'),
                onPressed: _busy ? null : () => _start(gateway),
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('تسجيل تطبيق مصادقة'),
              )
            else ...<Widget>[
              Text(
                'أضف المفتاح التالي إلى تطبيق المصادقة ثم أدخل الرمز:',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: PalEyesTokens.space2),
              SelectableText(
                _enrollment!.secret,
                key: const Key('security-secret'),
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _enrollment!.uri)),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('نسخ رابط otpauth'),
                ),
              ),
              TextField(
                key: const Key('security-code'),
                controller: _code,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'رمز التحقق'),
              ),
              FilledButton(
                key: const Key('security-confirm'),
                onPressed: _busy ? null : () => _confirm(gateway),
                child: const Text('تأكيد'),
              ),
            ],
          ],
          if (_message != null) ...<Widget>[
            const SizedBox(height: PalEyesTokens.space3),
            Semantics(
              liveRegion: true,
              child: Text(_message!, key: const Key('security-message')),
            ),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(PalEyesTokens.space4),
    decoration: BoxDecoration(
      color: PalEyesTokens.goldWash,
      borderRadius: BorderRadius.circular(PalEyesTokens.radius),
      border: Border.all(color: PalEyesTokens.goldSoft),
    ),
    child: Text(text, style: const TextStyle(color: PalEyesTokens.ink)),
  );
}
