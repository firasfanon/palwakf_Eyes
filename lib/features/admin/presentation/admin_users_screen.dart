import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/access/pal_eyes_auth_gateway.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';

const Map<PalEyesRole, String> _roleLabels = <PalEyesRole, String>{
  PalEyesRole.researcher: 'باحث',
  PalEyesRole.editor: 'محرر',
  PalEyesRole.sourceReviewer: 'مراجع مصادر',
  PalEyesRole.gisReviewer: 'مراجع GIS',
  PalEyesRole.rightsReviewer: 'مراجع حقوق',
  PalEyesRole.reviewManager: 'مدير مراجعة',
  PalEyesRole.releaseManager: 'مسؤول إصدار',
  PalEyesRole.systemAdmin: 'مدير النظام',
};

/// Role administration (system_admin only). Accounts are created by invitation
/// outside the app; this screen only grants or deactivates roles. The database
/// refuses self-administration and requires aal2 (MFA) for every change.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  Future<List<DirectoryUser>>? _users;
  String? _message;

  void _load(PalEyesAuthGateway gateway) {
    setState(() => _users = gateway.listUsers());
  }

  Future<void> _toggle(
    PalEyesAuthGateway gateway,
    DirectoryUser user,
    PalEyesRole role,
    bool active,
  ) async {
    try {
      await gateway.setRole(userId: user.userId, role: role, active: active);
      if (!mounted) return;
      setState(
        () => _message = 'تم تحديث دور ${_roleLabels[role]} لـ ${user.email}.',
      );
      _load(gateway);
    } on Object {
      if (!mounted) return;
      setState(
        () => _message =
            'رُفض التعديل من الخادم. تأكد من تفعيل التحقق بخطوتين (aal2) وأنك لا تعدّل دورك.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gateway = ref.watch(palEyesAuthGatewayProvider);
    final identity = ref.watch(palEyesAccessIdentityProvider);

    Widget content;
    if (!gateway.available) {
      content = _Banner(
        key: const Key('admin-users-blocked'),
        text: identity.isSynthetic
            ? 'معاينة داخلية بهوية اصطناعية: لا توجد خدمة هوية متصلة، لذلك لا تُعرض حسابات. (BLOCKED)'
            : 'خدمة الهوية غير مهيأة في هذا البناء. (BLOCKED)',
      );
    } else {
      _users ??= gateway.listUsers();
      content = FutureBuilder<List<DirectoryUser>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _Banner(
              text: 'تعذّر تحميل الدليل. هذه الصفحة لمدير النظام فقط.',
            );
          }
          final users = snapshot.data ?? const <DirectoryUser>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final user in users)
                Card(
                  key: Key('admin-user-${user.userId}'),
                  child: Padding(
                    padding: const EdgeInsets.all(PalEyesTokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.email,
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (user.userId == gateway.currentUserId)
                          Text(
                            'حسابك — لا يمكنك تعديل أدوارك.',
                            style: TextStyle(
                              color: PalEyesTokens.textMuted(context),
                            ),
                          ),
                        const SizedBox(height: PalEyesTokens.space2),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final role in PalEyesRole.values)
                              FilterChip(
                                label: Text(_roleLabels[role]!),
                                selected: user.roles.contains(role),
                                onSelected: user.userId == gateway.currentUserId
                                    ? null
                                    : (on) => _toggle(gateway, user, role, on),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    return PalEyesPage(
      title: 'المستخدمون والأدوار',
      subtitle:
          'الحسابات بالدعوة فقط. هنا تُمنح الأدوار أو تُعطّل، ولا تُحذف. كل تعديل يتطلب التحقق بخطوتين ويُسجّل.',
      icon: Icons.manage_accounts_outlined,
      eyebrow: 'الحوكمة والضبط',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          content,
          if (_message != null) ...<Widget>[
            const SizedBox(height: PalEyesTokens.space3),
            Semantics(liveRegion: true, child: Text(_message!)),
          ],
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, super.key});

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
