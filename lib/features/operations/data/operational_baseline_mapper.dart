import 'package:pal_eyes/features/operations/data/operational_coordinate_seed.dart';
import 'package:pal_eyes/features/operations/domain/operational_models.dart';
import 'package:pal_eyes/features/places/domain/heritage_site.dart';
import 'package:pal_eyes/features/research/domain/governed_research_backlog_item.dart';
import 'package:pal_eyes/features/sources/domain/draft_source_registry_entry.dart';

abstract final class OperationalBaselineMapper {
  static OperationalSnapshot fromCurrentBaseline({
    required List<HeritageSite> sites,
    required List<DraftSourceRegistryEntry> sources,
    required List<GovernedResearchBacklogItem> claims,
  }) {
    final now = DateTime.utc(2026, 7, 19, 12);

    final operationalSites = sites
        .map((site) {
          return OperationalSiteRecord(
            id: site.id,
            slug: site.slug,
            nameAr: site.nameAr,
            governorateAr: site.governorateAr,
            localityAr: site.localityAr,
            siteTypeAr: site.siteTypeAr,
            pageCategory: site.pageCategory.name,
            workflowStatus: site.isGovernedDraft
                ? 'GOVERNED_DRAFT'
                : 'LIMITED_RESEARCH',
            publicationStatus: site.publicationBlocked
                ? 'BLOCKED'
                : 'PUBLISHED',
            coordinateStatus: site.hasPublicCoordinates
                ? 'PUBLIC_APPROVED'
                : operationalCoordinateSeedSiteIds.contains(site.id)
                ? 'REVIEW_CANDIDATE'
                : 'MISSING',
            originalDraftProfile: site.hasOriginalExpandedNarrative
                ? 'expandedNarrative'
                : 'catalogSummary',
            editorialDraft: site.narrativeSections
                .map((section) => '${section.title}\n${section.draftText}')
                .join('\n\n'),
            sourceCount: site.sources.length,
            heldClaimCount: site.heldClaimCount,
            versionNumber: 1,
            updatedAt: now,
          );
        })
        .toList(growable: false);

    final operationalSources = sources
        .map((source) {
          return OperationalSourceRecord(
            id: source.id,
            title: source.title,
            attribution: source.attribution,
            sourceType: source.sourceTypeAr,
            url: source.url,
            workflowStatus: source.evidenceScopeStatus.contains('CLOSED')
                ? 'VERIFIED'
                : 'METADATA_REVIEW',
            rightsStatus: source.textReuseStatus.isEmpty
                ? 'PENDING'
                : source.textReuseStatus,
            publicReleaseStatus: source.publicReleaseStatus,
            linkedSiteCount: source.mentionedSiteCount,
            linkedClaimCount: source.isEditorialSource ? 1 : 0,
            updatedAt: now,
          );
        })
        .toList(growable: false);

    final operationalClaims =
        claims
            .map((claim) {
              return OperationalClaimRecord(
                id: claim.claimId,
                siteId: claim.siteId,
                siteNameAr: claim.siteNameAr,
                claimText: claim.claimText,
                priorityTier: claim.priorityTier,
                priorityScore: claim.priorityScore,
                workflowStatus: switch (claim.researchStatus) {
                  'OPEN' => 'RESEARCHING',
                  'HELD' => 'HOLD',
                  _ => claim.researchStatus,
                },
                evidenceStatus: claim.requiresFieldEvidence
                    ? 'FIELD_EVIDENCE_REQUIRED'
                    : 'SOURCE_EVIDENCE_REQUIRED',
                publicationUse: 'BLOCKED',
                categories: claim.categories,
                updatedAt: now,
              );
            })
            .toList(growable: false)
          ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    final reviewTasks = <OperationalReviewTask>[
      ...operationalClaims
          .take(12)
          .map(
            (claim) => OperationalReviewTask(
              id: 'review-${claim.id}',
              entityType: 'claim',
              entityId: claim.id,
              title: 'مراجعة ادعاء: ${claim.siteNameAr}',
              reviewType: 'CLAIM_EVIDENCE',
              priority: claim.priorityTier,
              status: 'OPEN',
              assigneeLabel: 'غير مسند',
              createdAt: now,
              updatedAt: now,
            ),
          ),
      ...operationalCoordinateSeed.map(
        (coordinate) => OperationalReviewTask(
          id: 'review-coordinate-${coordinate.id}',
          entityType: 'coordinate',
          entityId: coordinate.id,
          title: 'مراجعة إحداثيات: ${coordinate.siteNameAr}',
          reviewType: 'GIS',
          priority: 'P1_HIGH',
          status: 'OPEN',
          assigneeLabel: 'غير مسند',
          createdAt: now,
          updatedAt: now,
        ),
      ),
    ];

    final coordinateCandidates = operationalCoordinateSeed
        .map((coordinate) => coordinate.toCandidate(updatedAt: now))
        .toList(growable: false);

    return OperationalSnapshot(
      backendMode: OperationalBackendMode.localFallback,
      sites: operationalSites,
      sources: operationalSources,
      claims: operationalClaims,
      reviewTasks: reviewTasks,
      coordinateCandidates: coordinateCandidates,
      mediaAssets: const <OperationalMediaAsset>[],
      releaseCandidates: const <OperationalReleaseCandidate>[],
      auditEvents: <OperationalAuditEvent>[
        OperationalAuditEvent(
          id: 'audit-baseline-r7',
          actorLabel: 'النظام المحلي',
          action: 'BASELINE_LOADED',
          entityType: 'baseline',
          entityId: 'R7_0_0',
          summary: 'تحميل الحالة التشغيلية من خط الأساس المحلي المحكوم.',
          metadata: const <String, Object?>{
            'database_write': false,
            'publication': 'BLOCKED',
          },
          createdAt: now,
        ),
      ],
      loadedAt: now,
    );
  }
}
