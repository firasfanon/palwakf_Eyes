# PAL Eyes PDR-001..019 Implementation Map V1

Status: MEGA_BATCH_IMPLEMENTED_AND_VALIDATED_ON_TASK_BRANCH
Date: 2026-09-22
Base: 6d97fd625e82f37dcada0daf69f379a200a00dec
Branch: task/PAL-EYES-RESEARCH-KNOWLEDGE-WORKSPACE-V1

## Governance boundary

This implementation is non-production only. It does not authorize or perform main merge,
baseline promotion, live/shared Supabase mutation, production release, publication, media
publication clearance, or specialist/legal/waqf/sovereignty adjudication.

Experimental human approval remains distinct from specialist expert approval.

## PDR mapping

| PDR | Implementation |
|---|---|
| PDR-001 | PAL_EYES_RESEARCH_PACKAGE_V1 typed Dart contract + JSON schema + validator + staging adapter + round-trip test |
| PDR-002 | Narrative document/section/paragraph structures preserve ordered multi-section drafts and paragraph→claim links |
| PDR-003 | Canonical source identity fields plus preserved legacy mentions and crosswalk storage |
| PDR-004 | First-class structured source locator domain/storage contract |
| PDR-005 | Claim information confidence is distinct from source authority assessment |
| PDR-006 | Evidence relation/source-role/inspection/checksum fields |
| PDR-007 | First-class conflicts and alternative interpretations |
| PDR-008 | Time-bounded temporal assertions with dimensions such as ownership/revenue/water/lease/unit count |
| PDR-009 | Archive provenance hierarchy: repository/fonds/series/register/item/manifestation/original/copy dates |
| PDR-010 | Item-level media rights metadata and fail-closed publication requirements |
| PDR-011 | Review adjudication stages separate experimental human, specialist expert, competent authority, sovereign current and publication |
| PDR-012 | Approved citation resolver exposes claim/source/locator/confidence only after approved-only gate passes |
| PDR-013 | Existing Research Workspace extended with Draft Assembly / package completeness / evidence / conflict / rights / specialist-debt workbench |
| PDR-014 | Additive-only SQL migration; no destructive migration, rewrite, legacy ID/route break |
| PDR-015 | ApprovedOnlyPublicationResolverV1 fail-closed against draft/experimental/specialist-pending packages |
| PDR-016 | Existing ResearchEntityRelation contract reused; no duplicate implementation |
| PDR-017 | Existing time-scoped boundary/current-condition contracts reused and integrated into package V1 |
| PDR-018 | Existing governed alias/disambiguation contract reused and integrated into package V1 |
| PDR-019 | Existing integrity matrix reused and expanded with package, 62-compatibility, authority, SQL and narrow-layout tests |

## Pilot

RCP-V1-005 / PAL-EYES-CENSUS-005 / Souq al-Qattanin is the engineering pilot.
The fixture is explicitly technical/non-factual and validates:
12 ordered sections, claims, evidence, locators, source identity, confidence, conflict,
temporal assertion, archive provenance, media rights, experimental human approval,
specialist debt, alias, boundary and current-condition semantics.

## Compatibility

The existing frozen staging corpus remains authoritative for non-production staging.
All 62 content-manifest packages must adapt to ResearchPackageV1 without becoming
publication eligible. Existing production research-sidecar absence remains fail-closed.

## Authority/RLS

General research workspace tables use governed internal RLS. review_adjudications and
publication_manifests are excluded from the permissive workspace write policy.
Review adjudication write is limited to reviewer/review-manager/admin roles.
Publication manifest write is limited to release-manager/system-admin roles.

## Acceptance gates

- targeted research tests
- full Flutter analyze
- full test suite
- production-negative static verifier
- Flutter web release build
- desktop + 390px RTL workspace UAT
- diff/scope/secret checks
- independent engineering review
- exact commit/push/remote SHA readback

## Validation closeout

- Flutter analyze: PASS / zero issues
- Targeted research tests: PASS
- Full Flutter test suite: PASS 113/113
- Souq al-Qattanin 12-section round-trip: PASS
- Full 62-package non-production compatibility: PASS
- Desktop Research Workspace widget UAT: PASS
- 390px RTL Research Workspace/Workbench UAT: PASS
- Web release build: PASS
- Production research-sidecar static guard: PASS
- Git diff check: PASS
- Secret scan: PASS
- Migration destructive-operation scan: PASS
- Package versioning regression: PASS; stable package_id supports immutable versions via record_id + unique(package_id, version)

## Deferred by explicit boundary

- live/shared Supabase apply
- main merge
- sovereign baseline promotion
- production release
- publication
- specialist review debt closure
