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

  test('place and research helpers create stable public detail paths', () {
    expect(RoutePaths.place('solomons-pools'), '/places/solomons-pools');
    expect(RoutePaths.researchItem('solomons-pools'), '/research/solomons-pools');
    expect(RoutePaths.publicRoutes, contains(RoutePaths.research));
    expect(RoutePaths.workspaceRoutes, contains(RoutePaths.workspaceResearch));
    expect(RoutePaths.admin, '/admin');
  });
}
