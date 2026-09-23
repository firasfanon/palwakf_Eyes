import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/router/route_paths.dart';

void main() {
  test('public shell exposes the V2 discovery architecture', () {
    final shell = File('lib/core/widgets/public_shell.dart').readAsStringSync();

    expect(shell.contains('_desktopItems'), isTrue);
    expect(shell.contains("'استكشف'"), isTrue);
    expect(shell.contains("'الأماكن'"), isTrue);
    expect(shell.contains("'البحوث'"), isTrue);
    expect(shell.contains("'الحكايات'"), isTrue);
    expect(shell.contains('presentationMode.isInternal'), isTrue);
    expect(shell.contains("label: const Text('مساحة العمل')"), isTrue);
    expect(shell.contains("tooltip: 'الحوكمة والإدارة'"), isTrue);
  });

  test('public experience has atlas museum and magazine surfaces', () {
    final discovery = File(
      'lib/features/discovery/presentation/discovery_screen.dart',
    ).readAsStringSync();
    final map = File(
      'lib/features/map/presentation/map_screen.dart',
    ).readAsStringSync();
    final stories = File(
      'lib/features/stories/presentation/stories_screen.dart',
    ).readAsStringSync();
    final detail = File(
      'lib/features/places/presentation/place_detail_screen.dart',
    ).readAsStringSync();

    expect(discovery.contains('SegmentedButton<String>'), isTrue);
    expect(discovery.contains('ترتيب النتائج'), isTrue);
    expect(map.contains('أطلس فلسطين'), isTrue);
    expect(map.contains('تعرض فقط المواقع ذات الإحداثيات العامة'), isTrue);
    expect(stories.contains('حكايات عن المكان'), isTrue);
    expect(detail.contains('PalEyesMediaPlaceholder'), isTrue);
    expect(detail.contains('فتح مساحة الباحث'), isFalse);
    expect(detail.contains("'عن هذه المادة'"), isTrue);
    expect(detail.contains('_PublicPlaceExperience'), isTrue);
  });

  test('loading empty and error states are shared and accessible', () {
    final states = File(
      'lib/core/widgets/public_experience_maturity.dart',
    ).readAsStringSync();

    expect(states.contains('PublicContentStateKind.loading'), isTrue);
    expect(states.contains('PublicContentStateKind.empty'), isTrue);
    expect(states.contains('PublicContentStateKind.error'), isTrue);
    expect(states.contains('liveRegion: true'), isTrue);
    expect(states.contains('image: true'), isTrue);
  });

  test('story detail route and helper are stable', () {
    expect(RoutePaths.story('water-memory'), '/stories/water-memory');
    expect(RoutePaths.storyDetail, '/stories/:slug');
  });
}
