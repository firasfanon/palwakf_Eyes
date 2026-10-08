import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/theme/app_theme.dart';

void main() {
  test('chip labels keep explicit readable foreground in both themes', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();

    expect(light.chipTheme.labelStyle?.color, light.colorScheme.onSurface);
    expect(dark.chipTheme.labelStyle?.color, dark.colorScheme.onSurface);
    expect(
      dark.chipTheme.backgroundColor,
      dark.colorScheme.surfaceContainerHighest,
    );
  });

  test('research metadata chips stay readable and mobile bounded', () {
    final detail = File(
      'lib/features/research/presentation/public_research_detail_screen.dart',
    ).readAsStringSync();
    final packageCard = File(
      'lib/features/research/presentation/staging_research_package_card.dart',
    ).readAsStringSync();

    for (final source in <String>[detail, packageCard]) {
      expect(source, contains('backgroundColor: const Color(0xFFF1E8D7)'));
      expect(source, contains('color: Color(0xFF302B24)'));
      expect(source, contains('maxWidth: mobile ? 250 : 320'));
      expect(source, contains('softWrap: true'));
    }
  });

  test(
    'research package notice and source keep explicit readable contrast',
    () {
      final packageCard = File(
        'lib/features/research/presentation/staging_research_package_card.dart',
      ).readAsStringSync();

      expect(packageCard, contains('color: const Color(0xFFF5EDDD)'));
      expect(packageCard, contains('color: Color(0xFF302B24)'));
      expect(packageCard, contains('color: const Color(0xFF4A4338)'));
    },
  );

  test('workspace workflow rail starts from the RTL first stage', () {
    final dashboard = File(
      'lib/features/workspace/presentation/workspace_dashboard_screen.dart',
    ).readAsStringSync();

    expect(dashboard, contains('scrollDirection: Axis.horizontal'));
    expect(dashboard, contains('reverse: false'));
    expect(dashboard, contains('textDirection: TextDirection.rtl'));
  });
}
