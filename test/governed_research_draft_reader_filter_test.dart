import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/research/presentation/governed_research_draft_reader.dart';

void main() {
  const records = <ReviewableNarrative>[
    ReviewableNarrative(
      id: 'research-001',
      title: 'بيت لحم',
      status: 'UNDER_HUMAN_REVIEW',
      sections: [],
    ),
    ReviewableNarrative(
      id: 'research-002',
      title: 'بيت جالا',
      status: 'DRAFT',
      sections: [],
    ),
    ReviewableNarrative(
      id: 'research-003',
      title: 'الخليل',
      status: 'NEEDS_CORRECTION',
      sections: [],
    ),
  ];

  test('empty and whitespace search preserves the original corpus', () {
    expect(filterReviewableNarratives(records, ''), same(records));
    expect(filterReviewableNarratives(records, '  '), same(records));
  });

  test('Arabic title search narrows drafts without changing statuses', () {
    final result = filterReviewableNarratives(records, 'بيت');
    expect(result.map((item) => item.id), ['research-001', 'research-002']);
    expect(result.every((item) => item.status.isNotEmpty), isTrue);
  });

  test('ID and case-insensitive research status are searchable', () {
    expect(
      filterReviewableNarratives(records, 'RESEARCH-003').single.title,
      'الخليل',
    );
    expect(
      filterReviewableNarratives(records, 'draft').single.title,
      'بيت جالا',
    );
    expect(filterReviewableNarratives(records, 'missing'), isEmpty);
  });
}
