import 'package:flutter/material.dart';

enum DraftContentProfile { catalogSummary, expandedNarrative }

extension DraftContentProfileX on DraftContentProfile {
  String get labelAr => switch (this) {
    DraftContentProfile.catalogSummary => 'بطاقة فهرسة مسودة',
    DraftContentProfile.expandedNarrative => 'رواية موسعة مسودة',
  };

  IconData get icon => switch (this) {
    DraftContentProfile.catalogSummary => Icons.inventory_2_outlined,
    DraftContentProfile.expandedNarrative => Icons.auto_stories_outlined,
  };
}
