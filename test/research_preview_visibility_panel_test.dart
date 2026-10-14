import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/core/access/pal_eyes_access.dart';
import 'package:pal_eyes/features/research/presentation/research_preview_visibility_panel.dart';
import 'package:pal_eyes/features/research/presentation/research_workspace_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Isolated synthetic gateway used ONLY inside widget tests. It mirrors the
/// server contract: ineligible items are excluded from show commands.
class _FakeGateway implements ResearchPreviewGateway {
  _FakeGateway(this.items, {this.failWith, this.lieAboutResult = false});

  List<PreviewItem> items;
  final Object? failWith;
  final bool lieAboutResult;
  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<List<PreviewItem>> load() async => items;

  @override
  Future<PreviewVisibilityResult> setVisibility({
    required bool visible,
    required PreviewScope scope,
    required int expectedCount,
    List<String>? ids,
  }) async {
    calls.add(<String, Object?>{
      'visible': visible,
      'scope': scope,
      'expected': expectedCount,
      'ids': ids,
    });
    if (failWith != null) throw failWith!;
    final target = scope == PreviewScope.all
        ? items.map((i) => i.id).toSet()
        : ids!.toSet();
    var changed = 0;
    var excluded = 0;
    final excludedIds = <String>[];
    if (!lieAboutResult) {
      items = items.map((i) {
        if (!target.contains(i.id)) return i;
        if (visible && !i.eligible) {
          excluded++;
          excludedIds.add(i.id);
          return i;
        }
        if (i.publiclyVisible != visible) changed++;
        return PreviewItem(
          id: i.id,
          title: i.title,
          requestedVisible: visible,
          eligible: i.eligible,
          publiclyVisible: visible && i.eligible,
          reason: i.reason,
        );
      }).toList();
    }
    return PreviewVisibilityResult(
      targets: target.length,
      changed: changed,
      excluded: excluded,
      withdrawn: 0,
      excludedIds: excludedIds,
    );
  }
}

const _editor = PalEyesAccessIdentity(
  source: PalEyesIdentitySource.authenticatedSession,
  userId: 'synthetic-editor',
  roles: <PalEyesRole>{PalEyesRole.editor},
);
const _researcher = PalEyesAccessIdentity(
  source: PalEyesIdentitySource.authenticatedSession,
  userId: 'synthetic-researcher',
  roles: <PalEyesRole>{PalEyesRole.researcher},
);

List<PreviewItem> _items() => const <PreviewItem>[
  PreviewItem(
    id: 'n-a',
    title: 'البحث الأول',
    requestedVisible: false,
    eligible: false,
    publiclyVisible: false,
    reason: 'حقوق المصادر غير مُجازة',
  ),
  PreviewItem(
    id: 'n-b',
    title: 'البحث الثاني',
    requestedVisible: true,
    eligible: true,
    publiclyVisible: true,
    reason: 'مؤهل للمعاينة العامة',
  ),
  PreviewItem(
    id: 'n-c',
    title: 'البحث الثالث',
    requestedVisible: false,
    eligible: true,
    publiclyVisible: false,
    reason: 'مؤهل للمعاينة العامة',
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required PalEyesAccessIdentity identity,
  required ResearchPreviewGateway? gateway,
  Size size = const Size(1440, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        palEyesAccessIdentityProvider.overrideWith((ref) => identity),
        researchPreviewGatewayProvider.overrideWith((ref) => gateway),
      ],
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ResearchPreviewVisibilityPanel(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'shows total / eligible / visible / excluded and per-item status',
    (tester) async {
      await _pump(tester, identity: _editor, gateway: _FakeGateway(_items()));
      expect(find.text('الإجمالي: 3'), findsOneWidget);
      expect(find.text('المؤهلة: 2'), findsOneWidget);
      expect(find.text('الظاهرة: 1'), findsOneWidget);
      expect(find.text('المستثناة (غير مؤهلة): 1'), findsOneWidget);
      expect(find.text('البحث الأول'), findsOneWidget);
      expect(find.text('السبب: حقوق المصادر غير مُجازة'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('preview-status-n-b')),
          matching: find.text('ظاهر'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('preview-status-n-c')),
          matching: find.text('محجوب'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('preview-status-n-a')),
          matching: find.text('غير مؤهل'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('without a live backend session no data is fabricated', (
    tester,
  ) async {
    await _pump(tester, identity: _editor, gateway: null);
    expect(
      find.byKey(const Key('preview-backend-unavailable')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('preview-show-all')), findsNothing);
  });

  testWidgets('synthetic inspector and researcher cannot trigger writes', (
    tester,
  ) async {
    for (final identity in <PalEyesAccessIdentity>[
      const PalEyesAccessIdentity.syntheticInspector(),
      _researcher,
    ]) {
      final gw = _FakeGateway(_items());
      await _pump(tester, identity: identity, gateway: gw);
      for (final key in <String>[
        'preview-show-all',
        'preview-hide-all',
        'preview-show-selected',
        'preview-hide-selected',
      ]) {
        final button = tester.widget<ButtonStyleButton>(find.byKey(Key(key)));
        expect(button.onPressed, isNull, reason: key);
      }
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey<String>('preview-toggle-n-c')),
            )
            .onPressed,
        isNull,
      );
      expect(find.byKey(const Key('preview-read-only')), findsOneWidget);
      expect(gw.calls, isEmpty);
    }
  });

  testWidgets(
    'show-all asks for confirmation, sends ALL with total, verifies',
    (tester) async {
      final gw = _FakeGateway(_items());
      await _pump(tester, identity: _editor, gateway: gw);
      await tester.tap(find.byKey(const Key('preview-show-all')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('preview-confirm-dialog')), findsOneWidget);
      expect(find.text('عدد الأبحاث المستهدفة: 3'), findsOneWidget);
      expect(find.text('سيُستثنى غير المؤهل: 1'), findsOneWidget);
      await tester.tap(find.byKey(const Key('preview-confirm-ok')));
      await tester.pumpAndSettle();
      expect(gw.calls.single['scope'], PreviewScope.all);
      expect(gw.calls.single['expected'], 3);
      expect(gw.calls.single['ids'], isNull);
      expect(gw.calls.single['visible'], isTrue);
      expect(find.byKey(const Key('preview-notice')), findsOneWidget);
      expect(find.text('الظاهرة: 2'), findsOneWidget);
      expect(find.text('المستثناة (غير مؤهلة): 1'), findsOneWidget);
    },
  );

  testWidgets('cancelling the confirmation sends nothing', (tester) async {
    final gw = _FakeGateway(_items());
    await _pump(tester, identity: _editor, gateway: gw);
    await tester.tap(find.byKey(const Key('preview-hide-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preview-confirm-cancel')));
    await tester.pumpAndSettle();
    expect(gw.calls, isEmpty);
    expect(find.text('الظاهرة: 1'), findsOneWidget);
  });

  testWidgets('hide-all sends ALL and leaves nothing visible', (tester) async {
    final gw = _FakeGateway(_items());
    await _pump(tester, identity: _editor, gateway: gw);
    await tester.tap(find.byKey(const Key('preview-hide-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preview-confirm-ok')));
    await tester.pumpAndSettle();
    expect(gw.calls.single['visible'], isFalse);
    expect(gw.calls.single['scope'], PreviewScope.all);
    expect(find.text('الظاهرة: 0'), findsOneWidget);
  });

  testWidgets(
    'single toggle shows one eligible item; ineligible toggle disabled',
    (tester) async {
      final gw = _FakeGateway(_items());
      await _pump(tester, identity: _editor, gateway: gw);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey<String>('preview-toggle-n-a')),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('preview-toggle-n-c')),
      );
      await tester.pumpAndSettle();
      expect(gw.calls.single['scope'], PreviewScope.selected);
      expect(gw.calls.single['ids'], <String>['n-c']);
      expect(gw.calls.single['expected'], 1);
      expect(find.text('الظاهرة: 2'), findsOneWidget);
    },
  );

  testWidgets(
    'selected set: choose eligible, hide selected with confirmation',
    (tester) async {
      final gw = _FakeGateway(_items());
      await _pump(tester, identity: _editor, gateway: gw);
      await tester.tap(find.byKey(const Key('preview-select-eligible')));
      await tester.pumpAndSettle();
      expect(find.text('إخفاء المحدد (2)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('preview-hide-selected')));
      await tester.pumpAndSettle();
      expect(find.text('عدد الأبحاث المستهدفة: 2'), findsOneWidget);
      await tester.tap(find.byKey(const Key('preview-confirm-ok')));
      await tester.pumpAndSettle();
      final ids = gw.calls.single['ids']! as List<String>;
      expect(ids.toSet(), <String>{'n-b', 'n-c'});
      expect(gw.calls.single['expected'], 2);
      expect(find.text('الظاهرة: 0'), findsOneWidget);
    },
  );

  testWidgets('MFA rejection is explained in Arabic and nothing changes', (
    tester,
  ) async {
    final gw = _FakeGateway(
      _items(),
      failWith: PostgrestException(
        message: 'PREVIEW_MFA_REQUIRED',
        code: '42501',
      ),
    );
    await _pump(tester, identity: _editor, gateway: gw);
    await tester.tap(find.byKey(const ValueKey<String>('preview-toggle-n-c')));
    await tester.pumpAndSettle();
    expect(find.textContaining('التحقق بخطوتين'), findsOneWidget);
    expect(find.text('الظاهرة: 1'), findsOneWidget);
  });

  testWidgets('stale expected count is explained', (tester) async {
    final gw = _FakeGateway(
      _items(),
      failWith: PostgrestException(
        message: 'PREVIEW_EXPECTED_COUNT_MISMATCH',
        code: '22023',
      ),
    );
    await _pump(tester, identity: _editor, gateway: gw);
    await tester.tap(find.byKey(const Key('preview-hide-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preview-confirm-ok')));
    await tester.pumpAndSettle();
    expect(find.textContaining('تغيّرت قائمة الأبحاث'), findsOneWidget);
  });

  testWidgets('post-refresh verification flags a mismatching server state', (
    tester,
  ) async {
    final gw = _FakeGateway(_items(), lieAboutResult: true);
    await _pump(tester, identity: _editor, gateway: gw);
    await tester.tap(find.byKey(const ValueKey<String>('preview-toggle-n-c')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('preview-error')), findsOneWidget);
    expect(find.byKey(const Key('preview-notice')), findsNothing);
  });

  testWidgets('filters narrow the list by status', (tester) async {
    await _pump(tester, identity: _editor, gateway: _FakeGateway(_items()));
    await tester.tap(find.byKey(const Key('preview-filter-ineligible')));
    await tester.pumpAndSettle();
    expect(find.text('البحث الأول'), findsOneWidget);
    expect(find.text('البحث الثاني'), findsNothing);
  });

  testWidgets('desktop 1440px layout renders without exceptions', (
    tester,
  ) async {
    await _pump(tester, identity: _editor, gateway: _FakeGateway(_items()));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('research-preview-controls')), findsOneWidget);
  });

  testWidgets('mobile 390px RTL layout renders without overflow', (
    tester,
  ) async {
    await _pump(
      tester,
      identity: _editor,
      gateway: _FakeGateway(_items()),
      size: const Size(390, 844),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('preview-show-all')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('preview-confirm-cancel')));
    await tester.pumpAndSettle();
  });

  testWidgets('panel is integrated into /workspace/research screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: ResearchWorkspaceScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('research-workspace-tab-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('research-preview-controls')), findsOneWidget);
    expect(
      find.byKey(const Key('preview-backend-unavailable')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
