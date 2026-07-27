import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all four product UX phases are routed', () {
    final routes = File('lib/app/router/route_paths.dart').readAsStringSync();
    final router = File('lib/app/router/app_router.dart').readAsStringSync();

    for (final marker in <String>[
      'workspaceToday',
      'workspaceSiteEditor',
      'workspaceSourceRegistry',
      'workspaceRelationships',
      'workspaceReleaseControl',
      'workspaceAudit',
    ]) {
      expect(routes.contains(marker), isTrue, reason: marker);
    }

    for (final marker in <String>[
      'WorkspaceTodayScreen',
      'SiteEditorScreen',
      'SourceRegistryWorkspaceScreen',
      'ClaimWorkspaceScreen',
      'ReviewQueueScreen',
      'GisReviewScreen',
      'MediaRightsScreen',
      'RelationshipsWorkspaceScreen',
      'ReleaseControlScreen',
      'AuditLogScreen',
    ]) {
      expect(router.contains(marker), isTrue, reason: marker);
    }
  });

  test('publication remains disabled until all local gates are checked', () {
    final source = File(
      'lib/features/workspace/presentation/release_control_screen.dart',
    ).readAsStringSync();

    expect(source.contains('bool get ready'), isTrue);
    expect(
      source.contains('onPressed: ready ? _createCandidate : null'),
      isTrue,
    );
    expect(source.contains('بوابة النشر مغلقة'), isTrue);
  });

  test('site editor has persistent primary actions', () {
    final source = File(
      'lib/features/workspace/presentation/site_editor_screen.dart',
    ).readAsStringSync();

    expect(source.contains('حفظ المسودة'), isTrue);
    expect(source.contains('معاينة'), isTrue);
    expect(source.contains('إرسال للمراجعة'), isTrue);
  });

  test('public home exposes four product gateways', () {
    final source = File(
      'lib/features/home/presentation/home_screen.dart',
    ).readAsStringSync();

    expect(source.contains('_ProductGatewaysSection'), isTrue);
    for (final label in <String>[
      'الأماكن',
      'الخريطة',
      'الخط الزمني',
      'القصص والذاكرة',
    ]) {
      expect(source.contains(label), isTrue);
    }
  });
}
