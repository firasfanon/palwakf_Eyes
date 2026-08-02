import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/router/route_paths.dart';

void main() {
  test('public shell exposes five primary destinations only', () {
    final shell = File(
      'lib/core/widgets/public_shell.dart',
    ).readAsStringSync();

    expect(shell.contains('_primaryItems'), isTrue);
    expect(shell.contains("label: 'الأطلس'"), isTrue);
    expect(shell.contains("label: 'القصص'"), isTrue);
    expect(shell.contains("Text('مساحة الفريق')"), isTrue);
    expect(shell.contains("label: const Text('مساحة العمل')"), isFalse);
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
    expect(stories.contains('مجلة المكان الفلسطيني'), isTrue);
    expect(detail.contains('PalEyesMediaStage'), isTrue);
    expect(detail.contains('فتح مساحة الباحث'), isFalse);
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
