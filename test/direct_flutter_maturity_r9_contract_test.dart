import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round 3 is implemented directly in Flutter across public surfaces', () {
    final shared = File(
      'lib/core/widgets/direct_flutter_maturity_r9.dart',
    ).readAsStringSync();
    final home = File(
      'lib/features/home/presentation/home_screen.dart',
    ).readAsStringSync();
    final discovery = File(
      'lib/features/discovery/presentation/discovery_screen.dart',
    ).readAsStringSync();
    final places = File(
      'lib/features/places/presentation/places_screen.dart',
    ).readAsStringSync();
    final detail = File(
      'lib/features/places/presentation/place_detail_screen.dart',
    ).readAsStringSync();
    final map = File(
      'lib/features/map/presentation/map_screen.dart',
    ).readAsStringSync();
    final stories = File(
      'lib/features/stories/presentation/stories_screen.dart',
    ).readAsStringSync();
    final storyDetail = File(
      'lib/features/stories/presentation/story_detail_screen.dart',
    ).readAsStringSync();

    expect(shared.contains('class PalEyesPublicIdentityStrip'), isTrue);
    expect(shared.contains('class PalEyesEditorialPrelude'), isTrue);
    expect(shared.contains('class PalEyesMapEmptyExperience'), isTrue);
    expect(shared.contains('class PalEyesContentCompass'), isTrue);
    expect(shared.contains('class PalEyesChapterRail'), isTrue);
    expect(shared.contains('class PalEyesReadingFrame'), isTrue);

    expect(home.contains('PalEyesHeritageScene'), isTrue);
    expect(discovery.contains('PalEyesPublicIdentityStrip'), isTrue);
    expect(places.contains('PalEyesEditorialPrelude'), isTrue);
    expect(detail.contains('PalEyesTabStripV1'), isTrue);
    expect(map.contains('PalEyesParchmentPanel'), isTrue);
    expect(stories.contains('PalEyesMediaPlaceholder'), isTrue);
    expect(storyDetail.contains('PalEyesChapterRail'), isTrue);
    expect(storyDetail.contains('PalEyesReadingFrame'), isTrue);
  });

  test('round 3 preserves fail-closed publication and map boundaries', () {
    final map = File(
      'lib/features/map/presentation/map_screen.dart',
    ).readAsStringSync();
    final shared = File(
      'lib/core/widgets/direct_flutter_maturity_r9.dart',
    ).readAsStringSync();
    final project = File('PAL_EYES_BASELINE_ID.txt').readAsStringSync();

    expect(map.contains('mappedSitesProvider'), isTrue);
    expect(map.contains('reviewCoordinateSitesProvider'), isFalse);
    expect(shared.contains('لا نقاط مؤقتة على الخريطة العامة'), isTrue);
    expect(project.contains('DATABASE_WRITE=FALSE'), isTrue);
    expect(project.contains('PUBLICATION=BLOCKED'), isTrue);
    expect(project.contains('FIGMA_DEPENDENCY=FALSE'), isTrue);
  });

  test('mobile RTL and accessibility hardening is explicit', () {
    final widgetTest = File(
      'test/direct_flutter_maturity_r9_widget_test.dart',
    ).readAsStringSync();
    final theme = File('lib/app/theme/app_theme.dart').readAsStringSync();

    expect(widgetTest.contains('Size(390, 844)'), isTrue);
    expect(widgetTest.contains('TextDirection.rtl'), isTrue);
    expect(widgetTest.contains('tester.takeException()'), isTrue);
    expect(theme.contains('MaterialTapTargetSize.padded'), isTrue);
    expect(theme.contains('focusColor:'), isTrue);
    expect(theme.contains('hoverColor:'), isTrue);
  });
}
