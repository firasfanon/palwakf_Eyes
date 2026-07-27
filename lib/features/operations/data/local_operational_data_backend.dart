import 'package:pal_eyes/features/operations/data/operational_data_backend.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class LocalOperationalDataBackend implements OperationalDataBackend {
  LocalOperationalDataBackend(this._snapshot);

  OperationalSnapshot _snapshot;
  int _sequence = 0;

  @override
  OperationalBackendMode get mode => OperationalBackendMode.localFallback;

  String _nextId(String prefix) {
    _sequence += 1;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_sequence';
  }

  OperationalAuditEvent _audit({
    required OperationalActor actor,
    required String action,
    required String entityType,
    required String entityId,
    required String summary,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return OperationalAuditEvent(
      id: _nextId('audit'),
      actorLabel: actor.displayName,
      action: action,
      entityType: entityType,
      entityId: entityId,
      summary: summary,
      metadata: metadata,
      createdAt: DateTime.now().toUtc(),
    );
  }

  OperationalSnapshot _commit({
    List<OperationalSiteRecord>? sites,
    List<OperationalSourceRecord>? sources,
    List<OperationalClaimRecord>? claims,
    List<OperationalReviewTask>? reviewTasks,
    List<OperationalCoordinateCandidate>? coordinateCandidates,
    List<OperationalMediaAsset>? mediaAssets,
    List<OperationalReleaseCandidate>? releaseCandidates,
    OperationalAuditEvent? audit,
  }) {
    _snapshot = _snapshot.copyWith(
      sites: sites,
      sources: sources,
      claims: claims,
      reviewTasks: reviewTasks,
      coordinateCandidates: coordinateCandidates,
      mediaAssets: mediaAssets,
      releaseCandidates: releaseCandidates,
      auditEvents: audit == null
          ? _snapshot.auditEvents
          : <OperationalAuditEvent>[audit, ..._snapshot.auditEvents],
      loadedAt: DateTime.now().toUtc(),
    );
    return _snapshot;
  }

  @override
  Future<OperationalSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<OperationalSnapshot> saveSiteDraft({
    required OperationalActor actor,
    required String siteId,
    required String editorialDraft,
  }) async {
    final now = DateTime.now().toUtc();
    final sites = _snapshot.sites
        .map((site) {
          if (site.id != siteId) {
            return site;
          }
          return site.copyWith(
            editorialDraft: editorialDraft,
            workflowStatus: 'DRAFT_UPDATED',
            versionNumber: site.versionNumber + 1,
            updatedAt: now,
          );
        })
        .toList(growable: false);

    return _commit(
      sites: sites,
      audit: _audit(
        actor: actor,
        action: 'SITE_DRAFT_SAVED',
        entityType: 'site',
        entityId: siteId,
        summary: 'حفظ مسودة الموقع وإنشاء إصدار محلي جديد.',
        metadata: <String, Object?>{'public_release': 'BLOCKED'},
      ),
    );
  }

  @override
  Future<OperationalSnapshot> submitSiteForReview({
    required OperationalActor actor,
    required String siteId,
  }) async {
    final site = _snapshot.sites.firstWhere((item) => item.id == siteId);
    final task = OperationalReviewTask(
      id: _nextId('review-site'),
      entityType: 'site',
      entityId: siteId,
      title: 'مراجعة تحريرية: ${site.nameAr}',
      reviewType: 'EDITORIAL',
      priority: 'P1_HIGH',
      status: 'OPEN',
      assigneeLabel: 'غير مسند',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final sites = _snapshot.sites
        .map((item) {
          return item.id == siteId
              ? item.copyWith(
                  workflowStatus: 'SUBMITTED_FOR_REVIEW',
                  updatedAt: DateTime.now().toUtc(),
                )
              : item;
        })
        .toList(growable: false);

    return _commit(
      sites: sites,
      reviewTasks: <OperationalReviewTask>[task, ..._snapshot.reviewTasks],
      audit: _audit(
        actor: actor,
        action: 'SITE_SUBMITTED_FOR_REVIEW',
        entityType: 'site',
        entityId: siteId,
        summary: 'إرسال الموقع إلى قائمة المراجعة البشرية.',
      ),
    );
  }

  @override
  Future<OperationalSnapshot> addSource({
    required OperationalActor actor,
    required String title,
    required String attribution,
    required String sourceType,
    required String url,
  }) async {
    final source = OperationalSourceRecord(
      id: _nextId('source'),
      title: title,
      attribution: attribution,
      sourceType: sourceType,
      url: url,
      workflowStatus: 'METADATA_REVIEW',
      rightsStatus: 'PENDING',
      publicReleaseStatus: 'BLOCKED',
      linkedSiteCount: 0,
      linkedClaimCount: 0,
      updatedAt: DateTime.now().toUtc(),
    );
    return _commit(
      sources: <OperationalSourceRecord>[source, ..._snapshot.sources],
      audit: _audit(
        actor: actor,
        action: 'SOURCE_REGISTERED',
        entityType: 'source',
        entityId: source.id,
        summary: 'تسجيل مصدر جديد بانتظار مراجعة البيانات والحقوق.',
      ),
    );
  }

  @override
  Future<OperationalSnapshot> updateClaimStatus({
    required OperationalActor actor,
    required String claimId,
    required String workflowStatus,
    required String evidenceStatus,
  }) async {
    final claims = _snapshot.claims
        .map((claim) {
          return claim.id == claimId
              ? claim.copyWith(
                  workflowStatus: workflowStatus,
                  evidenceStatus: evidenceStatus,
                  updatedAt: DateTime.now().toUtc(),
                )
              : claim;
        })
        .toList(growable: false);

    return _commit(
      claims: claims,
      audit: _audit(
        actor: actor,
        action: 'CLAIM_STATUS_CHANGED',
        entityType: 'claim',
        entityId: claimId,
        summary: 'تحديث حالة البحث والدليل للادعاء.',
        metadata: <String, Object?>{
          'workflow_status': workflowStatus,
          'evidence_status': evidenceStatus,
        },
      ),
    );
  }

  @override
  Future<OperationalSnapshot> decideReviewTask({
    required OperationalActor actor,
    required String taskId,
    required String decision,
    required String note,
  }) async {
    final tasks = _snapshot.reviewTasks
        .map((task) {
          return task.id == taskId
              ? task.copyWith(
                  status: decision,
                  updatedAt: DateTime.now().toUtc(),
                )
              : task;
        })
        .toList(growable: false);

    return _commit(
      reviewTasks: tasks,
      audit: _audit(
        actor: actor,
        action: 'REVIEW_DECISION_RECORDED',
        entityType: 'review_task',
        entityId: taskId,
        summary: 'تسجيل قرار مراجعة بشري.',
        metadata: <String, Object?>{'decision': decision, 'note': note},
      ),
    );
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
    final candidate = OperationalCoordinateCandidate(
      id: _nextId('coordinate'),
      siteId: siteId,
      siteNameAr: siteNameAr,
      latitude: latitude,
      longitude: longitude,
      sourceId: sourceId,
      verificationStatus: 'PENDING_GIS_REVIEW',
      promotionStatus: 'NOT_PROMOTED',
      publicMapUse: 'BLOCKED',
      updatedAt: DateTime.now().toUtc(),
    );
    return _commit(
      coordinateCandidates: <OperationalCoordinateCandidate>[
        candidate,
        ..._snapshot.coordinateCandidates,
      ],
      audit: _audit(
        actor: actor,
        action: 'COORDINATE_CANDIDATE_ADDED',
        entityType: 'coordinate_candidate',
        entityId: candidate.id,
        summary: 'إضافة إحداثيات مرشحة محجوبة عن الخريطة العامة.',
      ),
    );
  }

  @override
  Future<OperationalSnapshot> registerMediaAsset({
    required OperationalActor actor,
    required String siteId,
    required String title,
    required String assetType,
    required String ownerLabel,
  }) async {
    final asset = OperationalMediaAsset(
      id: _nextId('media'),
      siteId: siteId,
      title: title,
      assetType: assetType,
      ownerLabel: ownerLabel,
      rightsStatus: 'PENDING_RIGHTS_REVIEW',
      internalUseStatus: 'BLOCKED',
      publicUseStatus: 'BLOCKED',
      updatedAt: DateTime.now().toUtc(),
    );
    return _commit(
      mediaAssets: <OperationalMediaAsset>[asset, ..._snapshot.mediaAssets],
      audit: _audit(
        actor: actor,
        action: 'MEDIA_ASSET_REGISTERED',
        entityType: 'media_asset',
        entityId: asset.id,
        summary: 'تسجيل مادة وسائط بانتظار فحص الحقوق.',
      ),
    );
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
    final candidate = OperationalReleaseCandidate(
      id: _nextId('release'),
      title: title,
      status: 'CANDIDATE_FROZEN_PUBLICATION_BLOCKED',
      siteIds: List<String>.unmodifiable(siteIds),
      gates: Map<String, bool>.unmodifiable(gates),
      createdAt: DateTime.now().toUtc(),
      createdBy: actor.displayName,
    );
    return _commit(
      releaseCandidates: <OperationalReleaseCandidate>[
        candidate,
        ..._snapshot.releaseCandidates,
      ],
      audit: _audit(
        actor: actor,
        action: 'RELEASE_CANDIDATE_CREATED',
        entityType: 'release_candidate',
        entityId: candidate.id,
        summary: 'إنشاء مرشح إصدار مجمد دون تنفيذ نشر عام.',
        metadata: const <String, Object?>{'publication': 'BLOCKED'},
      ),
    );
  }
}
