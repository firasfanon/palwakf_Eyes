# Session Handoff — Test Contract Hotfix R3.0.2

## Parent

`PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_1_20260714`

## Candidate

`PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_2_20260715`

## Verified precondition

```text
FLUTTER_ANALYZE=PASS
STATIC_CONTRACT=PASS
TEST_FAILURES=2
```

## Repaired contracts

- `سبسطية (شمرون)` is validated through a qualifier-aware prefix.
- `تل السلطان (أريحا القديمة)` is validated through a qualifier-aware prefix.
- Home displays `مسودة خاضعة للتدقيق`.
- Smoke test scrolls the canonical banner into view.

## Required local gates

```text
flutter analyze
flutter test
flutter build web
flutter run -d chrome
```
