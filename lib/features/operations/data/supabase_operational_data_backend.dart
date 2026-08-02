import 'package:pal_eyes/features/operations/data/operational_data_backend.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOperationalDataBackend implements OperationalDataBackend {
  SupabaseOperationalDataBackend(this._client);

  final SupabaseClient _client;

  @override
  OperationalBackendMode get mode => OperationalBackendMode.supabase;

  String _nextId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  List<Map<String, Object?>> _rows(Object? value) {
    return (value as List<dynamic>? ?? const <dynamic>[])
        .map((row) => Map<String, Object?>.from(row as Map))
        .toList(growable: false);
  }

  Future<void> _insertAudit({
    required OperationalActor actor,
    required String action,
    required String entityType,
    required String entityId,
    required String summary,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    await _client.schema('pal_eyes').from('audit_events').insert(
      <String, Object?>{
        'id': _nextId('audit'),
        'actor_id': _client.auth.currentUser?.id,
        'actor_label': actor.displayName,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'summary': summary,
        'metadata': metadata,
      },
    );
  }

  @override
  Future<OperationalSnapshot> loadSnapshot() async {
    final siteRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('sites')
          .select()
          .order('name_ar'),
    );
    final sourceRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('sources')
          .select()
          .order('title'),
    );
    final claimRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('claims')
          .select()
          .order('priority_score', ascending: false),
    );
    final taskRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('review_tasks')
          .select()
          .order('created_at', ascending: false),
    );
    final coordinateRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('coordinate_candidates')
          .select()
          .order('updated_at', ascending: false),
    );
    final mediaRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('media_assets')
          .select()
          .order('updated_at', ascending: false),
    );
    final releaseRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('release_candidates')
          .select()
          .order('created_at', ascending: false),
    );
    final auditRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('audit_events')
          .select()
          .order('created_at', ascending: false)
          .limit(200),
    );

    return OperationalSnapshot(
      backendMode: OperationalBackendMode.supabase,
      sites: siteRows.map(OperationalSiteRecord.fromJson).toList(),
      sources: sourceRows.map(OperationalSourceRecord.fromJson).toList(),
      claims: claimRows.map(OperationalClaimRecord.fromJson).toList(),
      reviewTasks: taskRows.map(OperationalReviewTask.fromJson).toList(),
      coordinateCandidates: coordinateRows
          .map(OperationalCoordinateCandidate.fromJson)
          .toList(),
      mediaAssets: mediaRows.map(OperationalMediaAsset.fromJson).toList(),
      releaseCandidates:
          releaseRows.map(OperationalReleaseCandidate.fromJson).toList(),
      auditEvents: auditRows.map(OperationalAuditEvent.fromJson).toList(),
      loadedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<OperationalSnapshot> saveSiteDraft({
    required OperationalActor actor,
    required String siteId,
    required String editorialDraft,
  }) async {
    final current = _rows(
      await _client
          .schema('pal_eyes')
          .from('sites')
          .select('version_number')
          .eq('id', siteId)
          .limit(1),
    );
    final version = current.isEmpty
        ? 1
        : ((current.first['version_number'] as num?)?.toInt() ?? 1) + 1;

    await _client.schema('pal_eyes').from('sites').update(
      <String, Object?>{
        'editorial_draft': editorialDraft,
        'workflow_status': 'DRAFT_UPDATED',
        'version_number': version,
        'updated_by': _client.auth.currentUser?.id,
      },
    ).eq('id', siteId);

    await _client.schema('pal_eyes').from('content_versions').insert(
      <String, Object?>{
        'id': _nextId('version'),
        'entity_type': 'site',
        'entity_id': siteId,
        'version_number': version,
        'snapshot': <String, Object?>{
          'editorial_draft': editorialDraft,
          'publication_status': 'BLOCKED',
        },
        'created_by': _client.auth.currentUser?.id,
      },
    );

    await _insertAudit(
      actor: actor,
      action: 'SITE_DRAFT_SAVED',
      entityType: 'site',
      entityId: siteId,
      summary: 'حفظ مسودة الموقع وإنشاء إصدار محكوم.',
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> submitSiteForReview({
    required OperationalActor actor,
    required String siteId,
  }) async {
    final siteRows = _rows(
      await _client
          .schema('pal_eyes')
          .from('sites')
          .select('name_ar')
          .eq('id', siteId)
          .limit(1),
    );
    final name = siteRows.isEmpty
        ? siteId
        : (siteRows.first['name_ar'] ?? siteId).toString();

    await _client.schema('pal_eyes').from('sites').update(
      <String, Object?>{
        'workflow_status': 'SUBMITTED_FOR_REVIEW',
        'updated_by': _client.auth.currentUser?.id,
      },
    ).eq('id', siteId);

    await _client.schema('pal_eyes').from('review_tasks').insert(
      <String, Object?>{
        'id': _nextId('review-site'),
        'entity_type': 'site',
        'entity_id': siteId,
        'title': 'مراجعة تحريرية: $name',
        'review_type': 'EDITORIAL',
        'priority': 'P1_HIGH',
        'status': 'OPEN',
        'assignee_label': 'غير مسند',
        'created_by': _client.auth.currentUser?.id,
      },
    );

    await _insertAudit(
      actor: actor,
      action: 'SITE_SUBMITTED_FOR_REVIEW',
      entityType: 'site',
      entityId: siteId,
      summary: 'إرسال الموقع إلى قائمة المراجعة البشرية.',
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> addSource({
    required OperationalActor actor,
    required String title,
    required String attribution,
    required String sourceType,
    required String url,
  }) async {
    final id = _nextId('source');
    await _client.schema('pal_eyes').from('sources').insert(
      <String, Object?>{
        'id': id,
        'title': title,
        'attribution': attribution,
        'source_type': sourceType,
        'url': url,
        'workflow_status': 'METADATA_REVIEW',
        'rights_status': 'PENDING',
        'public_release_status': 'BLOCKED',
        'created_by': _client.auth.currentUser?.id,
        'updated_by': _client.auth.currentUser?.id,
      },
    );
    await _insertAudit(
      actor: actor,
      action: 'SOURCE_REGISTERED',
      entityType: 'source',
      entityId: id,
      summary: 'تسجيل مصدر جديد بانتظار مراجعة البيانات والحقوق.',
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> updateClaimStatus({
    required OperationalActor actor,
    required String claimId,
    required String workflowStatus,
    required String evidenceStatus,
  }) async {
    await _client.schema('pal_eyes').from('claims').update(
      <String, Object?>{
        'workflow_status': workflowStatus,
        'evidence_status': evidenceStatus,
        'updated_by': _client.auth.currentUser?.id,
      },
    ).eq('id', claimId);
    await _insertAudit(
      actor: actor,
      action: 'CLAIM_STATUS_CHANGED',
      entityType: 'claim',
      entityId: claimId,
      summary: 'تحديث حالة البحث والدليل للادعاء.',
      metadata: <String, Object?>{
        'workflow_status': workflowStatus,
        'evidence_status': evidenceStatus,
      },
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> decideReviewTask({
    required OperationalActor actor,
    required String taskId,
    required String decision,
    required String note,
  }) async {
    await _client.schema('pal_eyes').from('review_tasks').update(
      <String, Object?>{
        'status': decision,
        'decision_note': note,
        'decided_by': _client.auth.currentUser?.id,
        'decided_at': DateTime.now().toUtc().toIso8601String(),
      },
    ).eq('id', taskId);
    await _client.schema('pal_eyes').from('review_decisions').insert(
      <String, Object?>{
        'id': _nextId('decision'),
        'review_task_id': taskId,
        'decision': decision,
        'note': note,
        'decided_by': _client.auth.currentUser?.id,
      },
    );
    await _insertAudit(
      actor: actor,
      action: 'REVIEW_DECISION_RECORDED',
      entityType: 'review_task',
      entityId: taskId,
      summary: 'تسجيل قرار مراجعة بشري.',
      metadata: <String, Object?>{'decision': decision},
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> addCoordinateCandidate({
    required OperationalActor actor,
    required String siteId,
    required String siteNameAr,
    required double latitude,
    required double longitude,
    required String sourceId,
  }) async {
    final id = _nextId('coordinate');
    await _client.schema('pal_eyes').from('coordinate_candidates').insert(
      <String, Object?>{
        'id': id,
        'site_id': siteId,
        'site_name_ar': siteNameAr,
        'latitude': latitude,
        'longitude': longitude,
        'source_id': sourceId,
        'verification_status': 'PENDING_GIS_REVIEW',
        'promotion_status': 'NOT_PROMOTED',
        'public_map_use': 'BLOCKED',
        'created_by': _client.auth.currentUser?.id,
        'updated_by': _client.auth.currentUser?.id,
      },
    );
    await _insertAudit(
      actor: actor,
      action: 'COORDINATE_CANDIDATE_ADDED',
      entityType: 'coordinate_candidate',
      entityId: id,
      summary: 'إضافة إحداثيات مرشحة محجوبة عن الخريطة العامة.',
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> registerMediaAsset({
    required OperationalActor actor,
    required String siteId,
    required String title,
    required String assetType,
    required String ownerLabel,
  }) async {
    final id = _nextId('media');
    await _client.schema('pal_eyes').from('media_assets').insert(
      <String, Object?>{
        'id': id,
        'site_id': siteId,
        'title': title,
        'asset_type': assetType,
        'owner_label': ownerLabel,
        'rights_status': 'PENDING_RIGHTS_REVIEW',
        'internal_use_status': 'BLOCKED',
        'public_use_status': 'BLOCKED',
        'created_by': _client.auth.currentUser?.id,
        'updated_by': _client.auth.currentUser?.id,
      },
    );
    await _insertAudit(
      actor: actor,
      action: 'MEDIA_ASSET_REGISTERED',
      entityType: 'media_asset',
      entityId: id,
      summary: 'تسجيل مادة وسائط بانتظار فحص الحقوق.',
    );
    return loadSnapshot();
  }

  @override
  Future<OperationalSnapshot> createReleaseCandidate({
    required OperationalActor actor,
    required String title,
    required List<String> siteIds,
    required Map<String, bool> gates,
  }) async {
    if (gates.values.any((passed) => !passed)) {
      throw StateError('RELEASE_CANDIDATE_GATES_INCOMPLETE');
    }
    final id = _nextId('release');
    await _client.schema('pal_eyes').from('release_candidates').insert(
      <String, Object?>{
        'id': id,
        'title': title,
        'status': 'CANDIDATE_FROZEN_PUBLICATION_BLOCKED',
        'site_ids': siteIds,
        'gates': gates,
        'created_by': _client.auth.currentUser?.id,
        'created_by_label': actor.displayName,
      },
    );
    await _insertAudit(
      actor: actor,
      action: 'RELEASE_CANDIDATE_CREATED',
      entityType: 'release_candidate',
      entityId: id,
      summary: 'إنشاء مرشح إصدار مجمد دون نشر عام.',
      metadata: const <String, Object?>{'publication': 'BLOCKED'},
    );
    return loadSnapshot();
  }
}
