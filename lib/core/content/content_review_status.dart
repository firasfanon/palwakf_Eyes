import 'package:flutter/material.dart';

enum ContentReviewStatus {
  draft,
  researchInProgress,
  sourceReview,
  factCheck,
  editorialReview,
  rightsReview,
  approved,
  published,
  needsRevision,
  archived,
}

extension ContentReviewStatusX on ContentReviewStatus {
  String get labelAr => switch (this) {
    ContentReviewStatus.draft => 'مسودة خاضعة للتدقيق',
    ContentReviewStatus.researchInProgress => 'قيد البحث',
    ContentReviewStatus.sourceReview => 'مراجعة المصادر',
    ContentReviewStatus.factCheck => 'تدقيق تاريخي',
    ContentReviewStatus.editorialReview => 'مراجعة تحريرية',
    ContentReviewStatus.rightsReview => 'مراجعة الحقوق',
    ContentReviewStatus.approved => 'معتمد',
    ContentReviewStatus.published => 'منشور',
    ContentReviewStatus.needsRevision => 'يحتاج تعديلاً',
    ContentReviewStatus.archived => 'مؤرشف',
  };

  IconData get icon => switch (this) {
    ContentReviewStatus.draft => Icons.edit_note_rounded,
    ContentReviewStatus.researchInProgress => Icons.science_rounded,
    ContentReviewStatus.sourceReview => Icons.library_books_rounded,
    ContentReviewStatus.factCheck => Icons.fact_check_rounded,
    ContentReviewStatus.editorialReview => Icons.rate_review_rounded,
    ContentReviewStatus.rightsReview => Icons.policy_rounded,
    ContentReviewStatus.approved => Icons.verified_rounded,
    ContentReviewStatus.published => Icons.public_rounded,
    ContentReviewStatus.needsRevision => Icons.history_edu_rounded,
    ContentReviewStatus.archived => Icons.archive_rounded,
  };

  Color color(ColorScheme scheme) => switch (this) {
    ContentReviewStatus.draft => const Color(0xFF9A6700),
    ContentReviewStatus.researchInProgress => const Color(0xFF275D8C),
    ContentReviewStatus.sourceReview => const Color(0xFF6750A4),
    ContentReviewStatus.factCheck => const Color(0xFF006C4C),
    ContentReviewStatus.editorialReview => const Color(0xFF6F4B00),
    ContentReviewStatus.rightsReview => const Color(0xFF8C1D40),
    ContentReviewStatus.approved => const Color(0xFF1F6B3A),
    ContentReviewStatus.published => scheme.primary,
    ContentReviewStatus.needsRevision => scheme.error,
    ContentReviewStatus.archived => scheme.outline,
  };

  bool get isPubliclyPublished => this == ContentReviewStatus.published;
}
