import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/operations/domain/staging_site_draft.dart';

void main() {
  test('Staging site draft stays blocked with human review and provenance', () {
    final input = StagingSiteDraft(
      nameAr: 'بيت لحم',
      governorateAr: 'بيت لحم',
      localityAr: 'بيت لحم',
      editorialDraft:
          'مسودة بحثية غير نهائية تتطلب تحقيقًا علميًا ومراجعة بشرية قبل النشر.',
      sourceLocator: 'وثيقة أرشيفية أولية — قيد التحقق',
    );
    final row = input.toInsertRow(
      id: 'research-draft-123',
      authorId: 'user-123',
    );
    expect(row['publication_status'], 'BLOCKED');
    expect(row['workflow_status'], 'GOVERNED_DRAFT');
    expect(row['page_category'], 'GOVERNED_DRAFT_PAGE');
    expect(row['slug'], 'research-draft-123');
    expect((row['metadata'] as Map)['publication_approved'], false);
    expect((row['metadata'] as Map)['requires_review'], true);
    expect(
      (row['metadata'] as Map)['source_verification_status'],
      'PENDING_HUMAN_REVIEW',
    );
    expect(row.containsKey('approved_at'), false);
  });

  test('Incomplete research text is rejected', () {
    expect(
      () => const StagingSiteDraft(
        nameAr: 'موضوع',
        governorateAr: '',
        localityAr: 'موضع',
        editorialDraft: 'نص قصير',
        sourceLocator: '',
      ).toInsertRow(id: 'draft-id', authorId: 'author-id'),
      throwsArgumentError,
    );
  });

  test('Missing author is rejected', () {
    expect(
      () => const StagingSiteDraft(
        nameAr: 'موضوع',
        governorateAr: '',
        localityAr: 'موضع',
        editorialDraft:
            'هذا نص بحثي أولي مكتوب للتجربة داخل مساحة العمل دون أن ينشر.',
        sourceLocator: '',
      ).toInsertRow(id: 'draft-id', authorId: ''),
      throwsArgumentError,
    );
  });
}
