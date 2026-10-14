import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pal_eyes/app/theme/pal_eyes_design_tokens.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/core/supabase/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Public-preview status of one draft research narrative.
///
/// A preview is never a scholarly approval: `publication_status` stays
/// BLOCKED and `scholarly_verified` stays false in the database.
enum PreviewStatus { visible, hidden, ineligible }

class PreviewItem {
  const PreviewItem({
    required this.id,
    required this.title,
    required this.requestedVisible,
    required this.eligible,
    required this.publiclyVisible,
    required this.reason,
    this.copyReviewed = false,
    this.privacyChecked = false,
  });

  factory PreviewItem.fromJson(Map<String, dynamic> x) {
    final requested = x['requested_visible'] == true;
    final eligible = x['eligible'] == true;
    return PreviewItem(
      id: (x['narrative_id'] ?? '').toString(),
      title: (x['title'] ?? '').toString(),
      requestedVisible: requested,
      eligible: eligible,
      publiclyVisible: x.containsKey('publicly_visible')
          ? x['publicly_visible'] == true
          : requested && eligible,
      reason: (x['reason'] ?? '').toString(),
      copyReviewed: x['copy_reviewed'] == true,
      privacyChecked: x['privacy_checked'] == true,
    );
  }

  final String id;
  final String title;
  final bool requestedVisible;
  final bool eligible;
  final bool publiclyVisible;
  final String reason;
  final bool copyReviewed;
  final bool privacyChecked;

  PreviewStatus get status => publiclyVisible
      ? PreviewStatus.visible
      : eligible
      ? PreviewStatus.hidden
      : PreviewStatus.ineligible;
}

class PreviewSnapshot {
  const PreviewSnapshot({required this.items, required this.backendAvailable});

  const PreviewSnapshot.unavailable()
    : items = const <PreviewItem>[],
      backendAvailable = false;

  final List<PreviewItem> items;
  final bool backendAvailable;

  int get total => items.length;
  int get eligible => items.where((i) => i.eligible).length;
  int get visible => items.where((i) => i.publiclyVisible).length;
  int get ineligible => items.where((i) => !i.eligible).length;
}

class PreviewVisibilityResult {
  const PreviewVisibilityResult({
    required this.targets,
    required this.changed,
    required this.excluded,
    required this.withdrawn,
    required this.excludedIds,
    this.batchId,
  });

  factory PreviewVisibilityResult.fromJson(Map<String, dynamic> x) {
    int n(String k) => x[k] is num ? (x[k] as num).toInt() : 0;
    final ids = x['excluded_ids'];
    return PreviewVisibilityResult(
      targets: n('targets'),
      changed: n('changed'),
      excluded: n('excluded'),
      withdrawn: n('withdrawn'),
      excludedIds: ids is List
          ? ids.map((e) => e.toString()).toList(growable: false)
          : const <String>[],
      batchId: x['batch_id']?.toString(),
    );
  }

  final int targets;
  final int changed;
  final int excluded;
  final int withdrawn;
  final List<String> excludedIds;
  final String? batchId;
}

enum PreviewScope { all, selected }

/// Server boundary for the visibility controls. The only production
/// implementation talks to the governed RPCs; tests may override the
/// provider with an isolated synthetic gateway.
abstract interface class ResearchPreviewGateway {
  Future<List<PreviewItem>> load();

  Future<PreviewVisibilityResult> setVisibility({
    required bool visible,
    required PreviewScope scope,
    required int expectedCount,
    List<String>? ids,
  });
}

class SupabaseResearchPreviewGateway implements ResearchPreviewGateway {
  const SupabaseResearchPreviewGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PreviewItem>> load() async {
    final rows = await _client
        .schema('pal_eyes')
        .rpc<List<dynamic>>('get_research_preview_controls_v1');
    return rows
        .whereType<Map<dynamic, dynamic>>()
        .map((row) => PreviewItem.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<PreviewVisibilityResult> setVisibility({
    required bool visible,
    required PreviewScope scope,
    required int expectedCount,
    List<String>? ids,
  }) async {
    final result = await _client
        .schema('pal_eyes')
        .rpc<Map<String, dynamic>>(
          'set_research_preview_visibility_v1',
          params: <String, Object?>{
            'p_visible': visible,
            'p_scope': scope == PreviewScope.all ? 'ALL' : 'SELECTED',
            'p_ids': scope == PreviewScope.all ? null : ids,
            'p_expected_count': expectedCount,
          },
        );
    return PreviewVisibilityResult.fromJson(result);
  }
}

/// `null` when no live backend session exists (local foundation mode or
/// signed-out). The panel then states that controls are unavailable rather
/// than showing fabricated data.
final researchPreviewGatewayProvider = Provider<ResearchPreviewGateway?>((ref) {
  ref.watch(palEyesAccessIdentityProvider);
  if (!ref.watch(supabaseBootstrapResultProvider).isEnabled) return null;
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) return null;
  return SupabaseResearchPreviewGateway(client);
});

final previewSnapshotProvider = FutureProvider<PreviewSnapshot>((ref) async {
  final gateway = ref.watch(researchPreviewGatewayProvider);
  if (gateway == null) return const PreviewSnapshot.unavailable();
  return PreviewSnapshot(items: await gateway.load(), backendAvailable: true);
});

/// Maps fail-closed server error codes to Arabic operator messages.
String previewErrorMessage(Object error) {
  final text = error is PostgrestException
      ? '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'
      : error.toString();
  if (text.contains('PREVIEW_MFA_REQUIRED')) {
    return 'الإظهار للعامة يتطلب جلسة مؤكدة بالتحقق بخطوتين (aal2). فعّل التحقق من صفحة أمان الحساب ثم أعد المحاولة.';
  }
  if (text.contains('PREVIEW_EXPECTED_COUNT_MISMATCH')) {
    return 'تغيّرت قائمة الأبحاث منذ آخر تحميل؛ لم يُنفَّذ أي تغيير. أعد التحميل ثم كرر العملية.';
  }
  if (text.contains('PREVIEW_UNKNOWN_IDS') || text.contains('PREVIEW_IDS_REQUIRED')) {
    return 'تحتوي المجموعة المحددة على معرّفات غير معروفة؛ رُفضت العملية كاملة.';
  }
  if (text.contains('PREVIEW_WRITE_AUTHORITY_REQUIRED') ||
      text.contains('PREVIEW_INTERNAL_READ_AUTHORITY_REQUIRED')) {
    return 'لا تملك الصلاحية اللازمة لهذه العملية وفق قاعدة البيانات.';
  }
  return 'فشل التنفيذ ولم يُغيَّر شيء؛ راجع الاتصال أو الصلاحيات.';
}

class ResearchPreviewVisibilityPanel extends ConsumerStatefulWidget {
  const ResearchPreviewVisibilityPanel({super.key});

  @override
  ConsumerState<ResearchPreviewVisibilityPanel> createState() => _PanelState();
}

enum _Filter { all, visible, hidden, ineligible }

class _PanelState extends ConsumerState<ResearchPreviewVisibilityPanel> {
  final Set<String> _selected = <String>{};
  _Filter _filter = _Filter.all;
  bool _busy = false;
  String? _error;
  String? _notice;

  bool _canWrite(PalEyesAccessIdentity identity, PreviewSnapshot snap) =>
      snap.backendAvailable &&
      !identity.isSynthetic &&
      !identity.isAnonymous &&
      identity.hasAny(const <PalEyesRole>{
        PalEyesRole.editor,
        PalEyesRole.reviewManager,
        PalEyesRole.systemAdmin,
      });

  Future<bool> _confirm({
    required bool visible,
    required int targets,
    required int eligible,
  }) async {
    final excluded = visible ? targets - eligible : 0;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('preview-confirm-dialog'),
        title: Text(visible ? 'تأكيد الإظهار للعامة' : 'تأكيد الإخفاء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('عدد الأبحاث المستهدفة: $targets'),
            if (visible) Text('سيظهر منها المؤهل فقط: $eligible'),
            if (visible && excluded > 0)
              Text('سيُستثنى غير المؤهل: $excluded'),
            const SizedBox(height: 8),
            const Text(
              'هذه معاينة أولية فقط ولا تغيّر حالة المراجعة العلمية أو قرار النشر النهائي.',
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('preview-confirm-cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: const Key('preview-confirm-ok'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _change({
    required PreviewSnapshot snap,
    required bool visible,
    required PreviewScope scope,
    List<PreviewItem> targets = const <PreviewItem>[],
    bool confirm = true,
  }) async {
    final gateway = ref.read(researchPreviewGatewayProvider);
    if (gateway == null) return;
    final affected = scope == PreviewScope.all ? snap.items : targets;
    if (affected.isEmpty) return;
    if (confirm) {
      final ok = await _confirm(
        visible: visible,
        targets: affected.length,
        eligible: affected.where((i) => i.eligible).length,
      );
      if (!ok || !mounted) return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final ids = affected.map((i) => i.id).toSet().toList(growable: false);
      final result = await gateway.setVisibility(
        visible: visible,
        scope: scope,
        expectedCount: scope == PreviewScope.all ? snap.total : ids.length,
        ids: scope == PreviewScope.all ? null : ids,
      );
      if (!mounted) return;
      ref.invalidate(previewSnapshotProvider);
      final fresh = await ref.read(previewSnapshotProvider.future);
      if (!mounted) return;
      final targetIds = ids.toSet();
      final verified = fresh.items
          .where((i) => targetIds.contains(i.id))
          .every((i) => visible ? (!i.eligible || i.publiclyVisible) : !i.publiclyVisible);
      setState(() {
        _selected.clear();
        _notice = verified
            ? 'تم التنفيذ والتحقق: تغيّر ${result.changed}، استُثني ${result.excluded}'
                  '${result.withdrawn > 0 ? '، سُحب ${result.withdrawn} لفقدان الأهلية' : ''}.'
            : null;
        _error = verified
            ? null
            : 'نُفّذ الطلب لكن الحالة بعد إعادة التحميل لا تطابق المتوقع؛ راجع القائمة قبل أي إجراء آخر.';
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = previewErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final identity = ref.watch(palEyesAccessIdentityProvider);
    final data = ref.watch(previewSnapshotProvider);
    final theme = Theme.of(context);
    return Card(
      key: const Key('research-preview-controls'),
      child: Padding(
        padding: const EdgeInsets.all(PalEyesTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'إدارة ظهور الأبحاث للزوار',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: PalEyesTokens.space1),
            const Text(
              'المعاينة الأولية لا تعني الاعتماد العلمي النهائي؛ تبقى المراجعة العلمية وقرار النشر منفصلين.',
            ),
            const SizedBox(height: PalEyesTokens.space3),
            data.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                previewErrorMessage(e),
                key: const Key('preview-load-error'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (snap) => _body(context, snap, _canWrite(identity, snap), identity),
            ),
            if (_busy) const LinearProgressIndicator(key: Key('preview-busy')),
            if (_notice != null)
              Padding(
                padding: const EdgeInsets.only(top: PalEyesTokens.space2),
                child: Text(
                  _notice!,
                  key: const Key('preview-notice'),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: PalEyesTokens.space2),
                child: Text(
                  _error!,
                  key: const Key('preview-error'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    PreviewSnapshot snap,
    bool canWrite,
    PalEyesAccessIdentity identity,
  ) {
    if (!snap.backendAvailable) {
      return const Text(
        'التحكم بالظهور متاح فقط عبر جلسة موثقة متصلة بقاعدة البيانات؛ لا تُعرض بيانات تجريبية هنا.',
        key: Key('preview-backend-unavailable'),
      );
    }
    final shown = snap.items.where((i) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.visible:
          return i.status == PreviewStatus.visible;
        case _Filter.hidden:
          return i.status == PreviewStatus.hidden;
        case _Filter.ineligible:
          return i.status == PreviewStatus.ineligible;
      }
    }).toList(growable: false);
    final chosen = snap.items
        .where((i) => _selected.contains(i.id))
        .toList(growable: false);
    final enabled = canWrite && !_busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: PalEyesTokens.space2,
          runSpacing: PalEyesTokens.space2,
          children: <Widget>[
            _Metric(key: const Key('preview-metric-total'), label: 'الإجمالي', value: snap.total),
            _Metric(key: const Key('preview-metric-eligible'), label: 'المؤهلة', value: snap.eligible),
            _Metric(key: const Key('preview-metric-visible'), label: 'الظاهرة', value: snap.visible),
            _Metric(key: const Key('preview-metric-excluded'), label: 'المستثناة (غير مؤهلة)', value: snap.ineligible),
          ],
        ),
        const SizedBox(height: PalEyesTokens.space3),
        if (!canWrite)
          Padding(
            padding: const EdgeInsets.only(bottom: PalEyesTokens.space2),
            child: Text(
              identity.isSynthetic
                  ? 'هوية الفحص الاصطناعية لا تملك صلاحية التغيير.'
                  : 'العرض فقط: التغيير متاح للمحرر ومدير المراجعة ومدير النظام.',
              key: const Key('preview-read-only'),
            ),
          ),
        Wrap(
          spacing: PalEyesTokens.space2,
          runSpacing: PalEyesTokens.space2,
          children: <Widget>[
            FilledButton.icon(
              key: const Key('preview-show-all'),
              onPressed: enabled && snap.eligible > 0
                  ? () => _change(snap: snap, visible: true, scope: PreviewScope.all)
                  : null,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('إظهار جميع المؤهلة'),
            ),
            OutlinedButton.icon(
              key: const Key('preview-hide-all'),
              onPressed: enabled && snap.total > 0
                  ? () => _change(snap: snap, visible: false, scope: PreviewScope.all)
                  : null,
              icon: const Icon(Icons.visibility_off_outlined),
              label: const Text('إخفاء الكل'),
            ),
            FilledButton.tonalIcon(
              key: const Key('preview-show-selected'),
              onPressed: enabled && chosen.any((i) => i.eligible)
                  ? () => _change(
                      snap: snap,
                      visible: true,
                      scope: PreviewScope.selected,
                      targets: chosen,
                    )
                  : null,
              icon: const Icon(Icons.playlist_add_check),
              label: Text('إظهار المحدد (${chosen.length})'),
            ),
            OutlinedButton.icon(
              key: const Key('preview-hide-selected'),
              onPressed: enabled && chosen.isNotEmpty
                  ? () => _change(
                      snap: snap,
                      visible: false,
                      scope: PreviewScope.selected,
                      targets: chosen,
                    )
                  : null,
              icon: const Icon(Icons.playlist_remove),
              label: Text('إخفاء المحدد (${chosen.length})'),
            ),
            TextButton(
              key: const Key('preview-select-eligible'),
              onPressed: enabled
                  ? () => setState(() {
                      _selected
                        ..clear()
                        ..addAll(shown.where((i) => i.eligible).map((i) => i.id));
                    })
                  : null,
              child: const Text('تحديد المؤهلة المعروضة'),
            ),
            TextButton(
              key: const Key('preview-clear-selection'),
              onPressed: enabled && _selected.isNotEmpty
                  ? () => setState(_selected.clear)
                  : null,
              child: const Text('إلغاء التحديد'),
            ),
          ],
        ),
        const SizedBox(height: PalEyesTokens.space2),
        Wrap(
          spacing: PalEyesTokens.space2,
          children: <Widget>[
            for (final f in _Filter.values)
              ChoiceChip(
                key: Key('preview-filter-${f.name}'),
                label: Text(switch (f) {
                  _Filter.all => 'الكل',
                  _Filter.visible => 'ظاهر',
                  _Filter.hidden => 'محجوب',
                  _Filter.ineligible => 'غير مؤهل',
                }),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
          ],
        ),
        const SizedBox(height: PalEyesTokens.space2),
        if (shown.isEmpty)
          const Text('لا توجد أبحاث ضمن هذا التصنيف.', key: Key('preview-empty')),
        for (final item in shown)
          _PreviewRow(
            item: item,
            selected: _selected.contains(item.id),
            enabled: enabled,
            onSelected: (v) => setState(() {
              if (v) {
                _selected.add(item.id);
              } else {
                _selected.remove(item.id);
              }
            }),
            onToggle: () => _change(
              snap: snap,
              visible: !item.publiclyVisible,
              scope: PreviewScope.selected,
              targets: <PreviewItem>[item],
              confirm: false,
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, super.key});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PalEyesTokens.space3,
        vertical: PalEyesTokens.space2,
      ),
      decoration: BoxDecoration(
        color: PalEyesTokens.panel(context),
        borderRadius: BorderRadius.circular(PalEyesTokens.radiusSmall),
        border: Border.all(color: PalEyesTokens.border(context)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: PalEyesTokens.text(context),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    required this.onToggle,
  });

  final PreviewItem item;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (item.status) {
      PreviewStatus.visible => ('ظاهر', PalEyesTokens.success),
      PreviewStatus.hidden => ('محجوب', PalEyesTokens.textMuted(context)),
      PreviewStatus.ineligible => ('غير مؤهل', Theme.of(context).colorScheme.error),
    };
    final canToggle = enabled && (item.publiclyVisible || item.eligible);
    return Container(
      key: ValueKey<String>('preview-${item.id}'),
      margin: const EdgeInsets.only(bottom: PalEyesTokens.space2),
      padding: const EdgeInsets.all(PalEyesTokens.space2),
      decoration: BoxDecoration(
        color: PalEyesTokens.panel(context),
        borderRadius: BorderRadius.circular(PalEyesTokens.radiusSmall),
        border: Border.all(color: PalEyesTokens.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: selected,
            onChanged: enabled ? (v) => onSelected(v ?? false) : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: PalEyesTokens.space1),
                Wrap(
                  spacing: PalEyesTokens.space2,
                  runSpacing: PalEyesTokens.space1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Container(
                      key: ValueKey<String>('preview-status-${item.id}'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: PalEyesTokens.space2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(PalEyesTokens.radiusPill),
                      ),
                      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    ),
                    if (item.status == PreviewStatus.ineligible)
                      Text('السبب: ${item.reason}', key: ValueKey<String>('preview-reason-${item.id}')),
                    if (item.requestedVisible && !item.eligible)
                      const Text('مطلوب إظهاره لكنه محجوب لفقدان الأهلية'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey<String>('preview-toggle-${item.id}'),
            tooltip: item.publiclyVisible
                ? 'إخفاء هذا البحث'
                : item.eligible
                ? 'إظهار هذا البحث'
                : 'غير مؤهل للإظهار',
            onPressed: canToggle ? onToggle : null,
            icon: Icon(
              item.publiclyVisible ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ],
      ),
    );
  }
}
