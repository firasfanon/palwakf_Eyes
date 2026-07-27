import 'package:pal_eyes/features/operations/domain/operational_models.dart';

abstract interface class OperationalDataBackend {
  OperationalBackendMode get mode;

  Future<OperationalSnapshot> loadSnapshot();

  Future<OperationalSnapshot> saveSiteDraft({
    required OperationalActor actor,
    required String siteId,
    required String editorialDraft,
  });

  Future<OperationalSnapshot> submitSiteForReview({
    required OperationalActor actor,
    required String siteId,
  });

  Future<OperationalSnapshot> addSource({
    required OperationalActor actor,
    required String title,
    required String attribution,
    required String sourceType,
    required String url,
  });

  Future<OperationalSnapshot> updateClaimStatus({
    required OperationalActor actor,
    required String claimId,
    required String workflowStatus,
    required String evidenceStatus,
  });

  Future<OperationalSnapshot> decideReviewTask({
    required OperationalActor actor,
    required String taskId,
    required String decision,
    required String note,
  });

  Future<OperationalSnapshot> addCoordinateCandidate({
    required OperationalActor actor,
    required String siteId,
    required String siteNameAr,
    required double latitude,
    required double longitude,
    required String sourceId,
  });

  Future<OperationalSnapshot> registerMediaAsset({
    required OperationalActor actor,
    required String siteId,
    required String title,
    required String assetType,
    required String ownerLabel,
  });

  Future<OperationalSnapshot> createReleaseCandidate({
    required OperationalActor actor,
    required String title,
    required List<String> siteIds,
    required Map<String, bool> gates,
  });
}
