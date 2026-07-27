# Session Handoff — Immersive UI/UX R4.0.0

## Candidate

`PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_0_20260715`

## Parent

`PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_3_20260715`

## Batch

`MEGA_BATCH_PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_V1`

## Product state

```text
HOME=IMMERSIVE_ATLAS_STORYTELLING
PUBLIC_SHELL=UNIFIED_PREMIUM
WORKSPACE_SHELL=UNIFIED_PREMIUM
GLOBAL_PAGE_HERO=ENABLED
RESPONSIVE_DESIGN=ENABLED
DARK_MODE=DESIGN_SYSTEM_ALIGNED
CONTENT_COUNTS=UNCHANGED
```

## Key implementation files

- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_theme.dart`
- `lib/core/widgets/pal_eyes_visual_system.dart`
- `lib/core/widgets/pal_eyes_page.dart`
- `lib/core/widgets/public_shell.dart`
- `lib/core/widgets/workspace_shell.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/map/presentation/map_screen.dart`
- `lib/features/stories/presentation/stories_screen.dart`
- `lib/features/methodology/presentation/methodology_screen.dart`
- `lib/features/contributions/presentation/contribute_screen.dart`
- `lib/features/workspace/presentation/workspace_dashboard_screen.dart`
- `lib/features/workspace/presentation/workspace_section_screen.dart`
- `lib/features/places/presentation/widgets/site_card.dart`

## Local validation sequence

```text
verify
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

## UAT focus

- Desktop Home at 1440px.
- Tablet around 900px.
- Mobile at 320–430px.
- Dark mode.
- Public navigation and drawer.
- Map overlays and coordinate-gap list.
- Story cards and timeline band.
- Site cards in places/discovery.
- Workspace shell/sidebar.
- Contribution form.
- Governance pages under the unified page hero.

## Boundaries

No database, Supabase schema, publication, or production mutation.
