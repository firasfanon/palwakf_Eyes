import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/router/route_paths.dart';

void main() {
  test('public route contract is unique and absolute', () {
    expect(
      RoutePaths.publicRoutes.toSet().length,
      RoutePaths.publicRoutes.length,
    );
    for (final route in RoutePaths.publicRoutes) {
      expect(route.startsWith('/'), isTrue, reason: route);
      expect(route.startsWith('/workspace'), isFalse, reason: route);
      expect(route.startsWith('/admin'), isFalse, reason: route);
    }
  });

  test('workspace routes are grouped under workspace', () {
    for (final route in RoutePaths.workspaceRoutes) {
      expect(route.startsWith('/workspace'), isTrue, reason: route);
    }
  });

  test('governance routes are isolated under admin governance', () {
    for (final route in RoutePaths.governanceRoutes) {
      expect(route.startsWith('/admin/governance'), isTrue, reason: route);
    }
  });

  test('place helper creates a stable detail path', () {
    expect(RoutePaths.place('solomons-pools'), '/places/solomons-pools');
  });
}
