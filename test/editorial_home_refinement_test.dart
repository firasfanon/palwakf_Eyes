import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/app.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const ProviderScope(child: PalEyesApp()));
  await tester.pumpAndSettle();
}

void main() {
  test('home no longer ships text-baked panel screenshots as content', () {
    final home = File(
      'lib/features/home/presentation/home_screen.dart',
    ).readAsStringSync();
    expect(home.contains('ApprovedReferenceDesign.timeline'), isFalse);
    expect(home.contains('ApprovedReferenceDesign.map,'), isFalse);
    expect(home.contains('ApprovedReferenceDesign.featured'), isFalse);
    expect(home.contains('showMarkers: false'), isTrue);
    expect(home.contains('widthFactor: 0.5'), isTrue);
  });

  testWidgets('desktop home exposes the four live entry points in order', (
    tester,
  ) async {
    await _pump(tester, const Size(1440, 1000));
    for (final label in <String>[
      'الأماكن',
      'البحوث',
      'الحكايات',
      'الخريطة التفاعلية',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('فلسطين..\nأكثر من مكان'), findsOneWidget);
    expect(find.text('القدس'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home reading order: story, source record, map, research', (
    tester,
  ) async {
    await _pump(tester, const Size(1440, 1000));
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-research-section')),
      400,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('قصة من فلسطين'), findsOneWidget);
    expect(find.text('من السجل المصدري'), findsOneWidget);
    expect(find.text('استكشف على الخريطة'), findsOneWidget);
    expect(find.text('أحدث البحوث'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home reaches timeline band without overflow at 390x844', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-timeline-band')),
      500,
      scrollable: scrollable,
      maxScrolls: 40,
    );
    await tester.pumpAndSettle();
    expect(find.text('رحلة عبر الزمن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
