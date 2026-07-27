import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/core/widgets/pal_eyes_product_ux.dart';
import 'package:pal_eyes/features/operations/application/operational_providers.dart';

class ReleaseControlScreen extends ConsumerStatefulWidget {
  const ReleaseControlScreen({super.key});

  @override
  ConsumerState<ReleaseControlScreen> createState() =>
      _ReleaseControlScreenState();
}

class _ReleaseControlScreenState extends ConsumerState<ReleaseControlScreen> {
  bool previewChecked = false;
  bool editorialApproved = false;
  bool sourcesApproved = false;
  bool rightsApproved = false;
  bool mapApproved = false;

  bool get ready =>
      previewChecked &&
      editorialApproved &&
      sourcesApproved &&
      rightsApproved &&
      mapApproved;

  Future<void> _createCandidate() async {
    final snapshot = await ref
        .read(operationalWorkspaceStoreProvider)
        .initialize();
    final siteIds = snapshot.sites
        .where((site) => site.workflowStatus != 'LIMITED_RESEARCH')
        .take(10)
        .map((site) => site.id)
        .toList(growable: false);

    await ref
        .read(operationalWorkspaceStoreProvider)
        .createReleaseCandidate(
          title: 'مرشح إصدار داخلي ${DateTime.now().toIso8601String()}',
          siteIds: siteIds,
          gates: <String, bool>{
            'preview': previewChecked,
            'editorial': editorialApproved,
            'sources': sourcesApproved,
            'rights': rightsApproved,
            'map': mapApproved,
          },
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إنشاء مرشح إصدار مجمد. النشر العام ما زال محجوباً.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(operationalSnapshotProvider);

    return PalEyesTaskPage(
      title: 'المعاينة والاعتماد ومرشح الإصدار',
      subtitle: 'مرشح الإصدار كيان محفوظ، لكنه لا ينفذ النشر العام.',
      icon: Icons.rocket_launch_outlined,
      notice:
          'بوابة النشر مغلقة. إنشاء المرشح يجمد نسخة مراجعة فقط ويضيف حدث تدقيق.',
      actions: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.preview_outlined),
          label: const Text('فتح المعاينة'),
        ),
        FilledButton.icon(
          onPressed: ready ? _createCandidate : null,
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('إنشاء مرشح إصدار'),
        ),
      ],
      child: Column(
        children: <Widget>[
          _Gate(
            value: previewChecked,
            label: 'معاينة الصفحة العامة',
            onChanged: (value) => setState(() => previewChecked = value),
          ),
          _Gate(
            value: editorialApproved,
            label: 'اعتماد تحريري بشري',
            onChanged: (value) => setState(() => editorialApproved = value),
          ),
          _Gate(
            value: sourcesApproved,
            label: 'اعتماد المصادر والاستشهادات',
            onChanged: (value) => setState(() => sourcesApproved = value),
          ),
          _Gate(
            value: rightsApproved,
            label: 'اعتماد الحقوق',
            onChanged: (value) => setState(() => rightsApproved = value),
          ),
          _Gate(
            value: mapApproved,
            label: 'اعتماد الخريطة والإحداثيات',
            onChanged: (value) => setState(() => mapApproved = value),
          ),
          const SizedBox(height: 14),
          PalEyesNotice(
            text: ready
                ? 'كل بوابات المرشح مكتملة. النشر الفعلي ما زال محظوراً.'
                : 'مرشح الإصدار غير جاهز. أكمل البوابات البشرية المطلوبة.',
            icon: ready ? Icons.task_alt_rounded : Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 18),
          snapshot.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => PalEyesNotice(
              text: 'تعذر تحميل مرشحي الإصدار: $error',
              icon: Icons.error_outline,
            ),
            data: (data) {
              if (data.releaseCandidates.isEmpty) {
                return const PalEyesNotice(
                  text: 'لم يُنشأ أي مرشح إصدار حتى الآن.',
                  icon: Icons.inventory_2_outlined,
                );
              }
              return Column(
                children: data.releaseCandidates
                    .map((candidate) {
                      return Card(
                        child: PalEyesWorkflowStatus(
                          label: candidate.title,
                          status:
                              '${candidate.status} • ${candidate.siteIds.length} مواقع • إنشاء: ${candidate.createdBy}',
                          icon: Icons.inventory_2_outlined,
                        ),
                      );
                    })
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: value,
        onChanged: (value) => onChanged(value ?? false),
        secondary: Icon(
          value ? Icons.check_circle_outline : Icons.radio_button_unchecked,
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: const Text('قرار بشري محفوظ ضمن مرشح الإصدار فقط'),
      ),
    );
  }
}
