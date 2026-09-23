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
}
