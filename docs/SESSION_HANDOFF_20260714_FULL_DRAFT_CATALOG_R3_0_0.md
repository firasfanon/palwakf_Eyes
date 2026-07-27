# Session Handoff — Full Draft Catalog R3.0.0

## Current candidate

`PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_0_20260714`

## Parent

`PAL_EYES_UI_UX_PRODUCTIVE_SURFACES_COMPILE_HOTFIX_R2_0_2_20260714`

## Batch

`MEGA_BATCH_PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_V1`

## Delivered product state

```text
SITE_CATALOG=79
EXPANDED_NARRATIVES=47
SOURCE_REGISTRY=79
GOVERNORATES=16
MAPPED_COORDINATES=3
COORDINATE_GAPS=76
GOVERNORATE_EXTRACTION_GAPS=2
APPROVED=0
PUBLISHED=0
```

## Critical decisions

- Three prior sites are examples, not full coverage.
- The reference document is an extraction draft, not historical authority.
- All extracted material appears during development with draft labels.
- Unknown coordinates are not invented.
- Source mentions remain in a verification registry.
- North Gaza and Deir al-Balah remain explicit zero-row gaps.
- Governance remains isolated from daily product screens.

## Local validation required

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build web`
5. Desktop route UAT
6. Mobile 320px UAT
7. Dark-mode UAT
8. Map and coordinate-gap UAT
9. Source-registry filtering UAT
10. Review of several expanded narratives and catalog-only pages

## Boundaries

No live database write, migration, production deployment, or historical
publication is included.
