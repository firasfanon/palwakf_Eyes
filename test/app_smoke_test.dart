import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/app.dart';

void main() {
  testWidgets('public home renders productive Arabic surface', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PalEyesApp()));
    await tester.pumpAndSettle();

    expect(find.text('بعيون فلسطينية'), findsWidgets);
    expect(find.textContaining('اكتشف المكان'), findsOneWidget);
    expect(find.byKey(const Key('home-governed-draft-banner')), findsOneWidget);
    expect(find.text('مسودة خاضعة للتدقيق'), findsWidgets);
    expect(find.text('Runtime Foundation V1'), findsNothing);
    expect(find.textContaining('لا كتابة لقاعدة البيانات'), findsNothing);
  });
}
