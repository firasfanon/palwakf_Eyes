import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/app/theme/approved_reference_design.dart';

/// Performance budget: every image the public UI actually renders stays under
/// 200 KB so the 390px first load is not dominated by artwork.
void main() {
  test('rendered artwork respects the 200 KB per-image budget', () {
    final rendered = <String>[
      ApprovedReferenceDesign.hero,
      ApprovedReferenceDesign.timeline,
      ApprovedReferenceDesign.map,
      ApprovedReferenceDesign.featured,
      ApprovedReferenceDesign.memoryCta,
      ...ApprovedReferenceDesign.gatewayAssets,
      ...ApprovedReferenceDesign.storyAssets,
    ];
    for (final path in rendered) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      expect(file.lengthSync(), lessThan(200 * 1024), reason: path);
    }
  });
}
