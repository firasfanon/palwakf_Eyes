import 'package:flutter_test/flutter_test.dart';
import 'package:pal_eyes/features/operations/data/local_operational_data_backend.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';

void main() {
  const actor = OperationalActor(
    id: 'tester',
    displayName: 'مختبر',
    roles: <String>{'editor', 'review_manager', 'release_manager'},
  );

  OperationalSnapshot seed() {
    final now = DateTime.utc(2026, 7, 19);
    return OperationalSnapshot(
      backendMode: OperationalBackendMode.localFallback,
      sites: <OperationalSiteRecord>[
        OperationalSiteRecord(
          id: 'site-1',
          slug: 'site-1',
          nameAr: 'موقع اختبار',
          governorateAr: 'القدس',
          localityAr: 'القدس',
          siteTypeAr: 'موقع أثري',
          pageCategory: 'GOVERNED_DRAFT_PAGE',
          workflowStatus: 'GOVERNED_DRAFT',
          publicationStatus: 'BLOCKED',
          coordinateStatus: 'MISSING',
          originalDraftProfile: 'expandedNarrative',
          editorialDraft: 'النص الأول',
          sourceCount: 1,
          heldClaimCount: 1,
          versionNumber: 1,
          updatedAt: now,
        ),
      ],
      sources: const <OperationalSourceRecord>[],
      claims: <OperationalClaimRecord>[
        OperationalClaimRecord(
          id: 'claim-1',
          siteId: 'site-1',
          siteNameAr: 'موقع اختبار',
          claimText: 'ادعاء اختبار',
          priorityTier: 'P0_IMMEDIATE',
          priorityScore: 100,
          workflowStatus: 'RESEARCHING',
          evidenceStatus: 'MISSING',
          publicationUse: 'BLOCKED',
          categories: const <String>['HISTORY'],
          updatedAt: now,
        ),
      ],
      reviewTasks: const <OperationalReviewTask>[],
      coordinateCandidates: const <OperationalCoordinateCandidate>[],
      mediaAssets: const <OperationalMediaAsset>[],
      releaseCandidates: const <OperationalReleaseCandidate>[],
      auditEvents: const <OperationalAuditEvent>[],
      loadedAt: now,
    );
  }

  test('saving a site draft increments version and records audit', () async {
    final backend = LocalOperationalDataBackend(seed());
    final result = await backend.saveSiteDraft(
      actor: actor,
      siteId: 'site-1',
      editorialDraft: 'النص الثاني',
    );

    expect(result.sites.single.versionNumber, 2);
    expect(result.sites.single.editorialDraft, 'النص الثاني');
    expect(result.sites.single.publicationStatus, 'BLOCKED');
    expect(result.auditEvents.single.action, 'SITE_DRAFT_SAVED');
  });

  test('submitting a site creates a review task', () async {
    final backend = LocalOperationalDataBackend(seed());
    final result = await backend.submitSiteForReview(
      actor: actor,
      siteId: 'site-1',
    );

    expect(result.reviewTasks, hasLength(1));
    expect(result.reviewTasks.single.status, 'OPEN');
    expect(result.sites.single.workflowStatus, 'SUBMITTED_FOR_REVIEW');
  });

  test('release candidate requires every human gate', () async {
    final backend = LocalOperationalDataBackend(seed());

    await expectLater(
      backend.createReleaseCandidate(
        actor: actor,
        title: 'مرشح غير مكتمل',
        siteIds: const <String>['site-1'],
        gates: const <String, bool>{
          'editorial': true,
          'sources': false,
        },
      ),
      throwsStateError,
    );

    final result = await backend.createReleaseCandidate(
      actor: actor,
      title: 'مرشح مكتمل',
      siteIds: const <String>['site-1'],
      gates: const <String, bool>{
        'preview': true,
        'editorial': true,
        'sources': true,
        'rights': true,
        'map': true,
      },
    );

    expect(result.releaseCandidates, hasLength(1));
    expect(
      result.releaseCandidates.single.status,
      'CANDIDATE_FROZEN_PUBLICATION_BLOCKED',
    );
  });
}
