# Session Handoff — R4.0.1

Parent local state: formatted R3.0.3 with verify/analyze/test PASS.

Failed package: R4.0.0, no source files copied.

Required package: `PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_1_20260715`.

After APPLY, run:

```text
verify
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Browser UAT must confirm no `ListTile background color or ink splashes
may be invisible` assertion.
