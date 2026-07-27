# MEGA_BATCH_PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_V1_0_1

## Root cause 1: source contract drift

R4.0.0 was built against the unformatted R3.0.3 archive. The local
project had already passed `dart format lib test`, so several Dart
source hashes were semantically equivalent but different. The APPLY
script failed before copying any file.

## Root cause 2: ListTile material boundary

Runtime reported that ListTile ink/background could be hidden by the
scaffold ColoredBox. Direct transparent Material boundaries were added
to:

- Public drawer navigation and utility items.
- Workspace grouped navigation.
- Map coordinate-gap registry.

## Repair contract

```text
ACCEPT_UNFORMATTED_R3_0_3_HASHES=TRUE
ACCEPT_USER_FORMATTED_R3_0_3_HASHES=TRUE
MATERIAL_BOUNDARY_REGRESSION_GATE=TRUE
APPLY_BEFORE_COPY_VALIDATION=TRUE
DATABASE_MUTATION=NONE
```

R4.0.0 was not applied and is superseded by `PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_1_20260715`.
