import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pal_eyes/app/router/route_paths.dart';
import 'package:pal_eyes/core/config/app_environment.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_page.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';

/// Creates a governed internal draft, not a public or approved record.
class NewPlaceDraftScreen extends ConsumerStatefulWidget {
  const NewPlaceDraftScreen({super.key});

  @override
  ConsumerState<NewPlaceDraftScreen> createState() =>
      _NewPlaceDraftScreenState();
}

class _NewPlaceDraftScreenState extends ConsumerState<NewPlaceDraftScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _governorate = TextEditingController();
  final _locality = TextEditingController();
  final _draft = TextEditingController();
  final _locator = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _name,
      _governorate,
      _locality,
      _draft,
      _locator,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate() || _saving) return;
    final env = ref.read(appEnvironmentProvider);
    final store = ref.read(operationalWorkspaceStoreProvider);
    if (env.environmentName != 'staging' ||
        store.backendMode.name != 'supabase') {
      setState(
        () => _error = 'إنشاء المسودات متاح في بيئة Staging المتصلة فقط.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await store.createSiteDraft(
        nameAr: _name.text,
        governorateAr: _governorate.text,
        localityAr: _locality.text,
        editorialDraft: _draft.text,
        sourceLocator: _locator.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حُفظت المسودة داخل Staging بحالة محظورة من النشر. '
            'تبقى جميع الأدلة خاضعة للتدقيق والمراجعة.',
          ),
        ),
      );
      context.go(RoutePaths.workspaceSiteEditor);
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'تعذر حفظ المسودة. تحقّق من صلاحيات التحرير والاتصال. '
              'إذا كان هناك احتمال بحفظ جزئي، حدّث قائمة المواقع قبل إعادة المحاولة. '
              'التشخيص: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final env = ref.watch(appEnvironmentProvider);
    final store = ref.watch(operationalWorkspaceStoreProvider);
    final allowed =
        env.environmentName == 'staging' &&
        store.backendMode.name == 'supabase' &&
        (store.actor.roles.contains('editor') ||
            store.actor.roles.contains('system_admin'));
    return PalEyesPage(
      title: 'إنشاء مسودة بحثية داخلية',
      subtitle:
          'تُحفظ المسودة في قاعدة Staging للمراجعة والتوثيق، ولا تنشر على الموقع العام.',
      icon: Icons.library_add_outlined,
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'حالة المحتوى: GOVERNED_DRAFT / BLOCKED. '
                  'تُسجل هوية المحرر ومعلومات المصدر، ويظل اعتماد الأدلة والنشر منفصلين.',
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (!allowed)
              const Text(
                'التحرير غير متاح: تتطلب هذه الصفحة اتصال Staging ودور editor أو system_admin.',
                key: Key('staging-draft-blocked'),
              ),
            TextFormField(
              key: const Key('draft-name'),
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'اسم الموقع أو الموضوع',
              ),
              validator: (value) =>
                  (value?.trim().length ?? 0) < 2 ? 'أدخل اسمًا واضحًا.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _governorate,
              decoration: const InputDecoration(
                labelText: 'المحافظة (إن عُرفت)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('draft-locality'),
              controller: _locality,
              decoration: const InputDecoration(
                labelText: 'البلدة أو الموضع البحثي',
              ),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? 'أدخل الموضع الجغرافي أو نطاق البحث.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('draft-source-locator'),
              controller: _locator,
              decoration: const InputDecoration(
                labelText: 'مرجع الوثيقة أو مسار المصدر (إن وجد)',
                helperText:
                    'يمكن تركه فارغًا؛ ستُسجّل المراجع كمعلّقة للتحقق البشري.',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('draft-narrative'),
              controller: _draft,
              minLines: 6,
              maxLines: 14,
              decoration: const InputDecoration(
                labelText: 'النص البحثي الأولي',
                alignLabelWithHint: true,
                helperText:
                    '30 حرفًا على الأقل. النص قابل للتحرير والتدقيق، وغير معتمد للنشر.',
              ),
              validator: (value) => (value?.trim().length ?? 0) < 30
                  ? 'أدخل نصًا أوليًا من 30 حرفًا على الأقل.'
                  : null,
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _error!,
                key: const Key('draft-save-error'),
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                key: const Key('draft-save'),
                onPressed: allowed && !_saving ? _save : null,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'جارٍ الحفظ…' : 'حفظ مسودة غير منشورة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
