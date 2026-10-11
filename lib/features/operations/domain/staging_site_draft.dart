/// An internal research draft. No publication transition is present here.
class StagingSiteDraft {
  const StagingSiteDraft({
    required this.nameAr,
    required this.governorateAr,
    required this.localityAr,
    required this.editorialDraft,
    required this.sourceLocator,
  });

  final String nameAr;
  final String governorateAr;
  final String localityAr;
  final String editorialDraft;
  final String sourceLocator;

  Map<String, Object?> toInsertRow({
    required String id,
    required String authorId,
  }) {
    final name = nameAr.trim();
    final locality = localityAr.trim();
    final text = editorialDraft.trim();
    if (id.trim().isEmpty || authorId.trim().isEmpty) {
      throw ArgumentError('DRAFT_ACTOR_AND_ID_REQUIRED');
    }
    if (name.length < 2 || locality.length < 2 || text.length < 30) {
      throw ArgumentError('DRAFT_REQUIRED_FIELDS_INVALID');
    }
    if (text.length > 100000) {
      throw ArgumentError('DRAFT_TEXT_TOO_LONG');
    }
    final locator = sourceLocator.trim();
    return <String, Object?>{
      'id': id,
      'slug': id,
      'name_ar': name,
      'governorate_ar': governorateAr.trim(),
      'locality_ar': locality,
      'page_category': 'GOVERNED_DRAFT_PAGE',
      'workflow_status': 'GOVERNED_DRAFT',
      'publication_status': 'BLOCKED',
      'coordinate_status': 'MISSING',
      'original_draft_profile': 'expandedNarrative',
      'editorial_draft': text,
      'created_by': authorId,
      'updated_by': authorId,
      'metadata': <String, Object?>{
        'source_locator': locator,
        'source_verification_status': 'PENDING_HUMAN_REVIEW',
        'requires_review': true,
        'publication_approved': false,
        'record_origin': 'staging_editorial_draft',
      },
    };
  }
}
