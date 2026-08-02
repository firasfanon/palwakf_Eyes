import 'dart:async';

import 'package:pal_eyes/features/operations/data/operational_data_backend.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

class OperationalWorkspaceStore {
  OperationalWorkspaceStore({
    required OperationalDataBackend backend,
    required this.actor,
  }) : _backend = backend;

  final OperationalDataBackend _backend;
  final OperationalActor actor;
  final StreamController<OperationalSnapshot> _controller =
      StreamController<OperationalSnapshot>.broadcast(sync: true);

  OperationalSnapshot? _snapshot;
  Future<OperationalSnapshot>? _initialization;

  OperationalBackendMode get backendMode => _backend.mode;

  Stream<OperationalSnapshot> watch() async* {
    yield await initialize();
    yield* _controller.stream;
  }

  Future<OperationalSnapshot> initialize() {
    return _initialization ??= _backend.loadSnapshot().then((snapshot) {
      _snapshot = snapshot;
      return snapshot;
    });
  }

  OperationalSnapshot get current {
    final snapshot = _snapshot;
    if (snapshot == null) {
      throw StateError('OPERATIONAL_STORE_NOT_INITIALIZED');
    }
    return snapshot;
  }

  Future<void> _run(
    Future<OperationalSnapshot> Function() operation,
  ) async {
    final snapshot = await operation();
    _snapshot = snapshot;
    _controller.add(snapshot);
  }

  Future<void> refresh() => _run(_backend.loadSnapshot);

  Future<void> saveSiteDraft({
    required String siteId,
    required String editorialDraft,
  }) {
    return _run(
      () => _backend.saveSiteDraft(
        actor: actor,
        siteId: siteId,
        editorialDraft: editorialDraft,
      ),
    );
  }

  Future<void> submitSiteForReview(String siteId) {
    return _run(
      () => _backend.submitSiteForReview(
        actor: actor,
        siteId: siteId,
      ),
    );
  }

  Future<void> addSource({
    required String title,
    required String attribution,
    required String sourceType,
    required String url,
  }) {
    return _run(
      () => _backend.addSource(
        actor: actor,
        title: title,
        attribution: attribution,
        sourceType: sourceType,
        url: url,
      ),
    );
  }

  Future<void> updateClaimStatus({
    required String claimId,
    required String workflowStatus,
    required String evidenceStatus,
  }) {
    return _run(
      () => _backend.updateClaimStatus(
        actor: actor,
        claimId: claimId,
        workflowStatus: workflowStatus,
        evidenceStatus: evidenceStatus,
      ),
    );
  }

  Future<void> decideReviewTask({
    required String taskId,
    required String decision,
    required String note,
  }) {
    return _run(
      () => _backend.decideReviewTask(
        actor: actor,
        taskId: taskId,
        decision: decision,
        note: note,
      ),
    );
  }

  Future<void> addCoordinateCandidate({
    required String siteId,
    required String siteNameAr,
    required double latitude,
    required double longitude,
    required String sourceId,
  }) {
    return _run(
      () => _backend.addCoordinateCandidate(
        actor: actor,
        siteId: siteId,
        siteNameAr: siteNameAr,
        latitude: latitude,
        longitude: longitude,
        sourceId: sourceId,
      ),
    );
  }

  Future<void> registerMediaAsset({
    required String siteId,
    required String title,
    required String assetType,
    required String ownerLabel,
  }) {
    return _run(
      () => _backend.registerMediaAsset(
        actor: actor,
        siteId: siteId,
        title: title,
        assetType: assetType,
        ownerLabel: ownerLabel,
      ),
    );
  }

  Future<void> createReleaseCandidate({
    required String title,
    required List<String> siteIds,
    required Map<String, bool> gates,
  }) {
    return _run(
      () => _backend.createReleaseCandidate(
        actor: actor,
        title: title,
        siteIds: siteIds,
        gates: gates,
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
