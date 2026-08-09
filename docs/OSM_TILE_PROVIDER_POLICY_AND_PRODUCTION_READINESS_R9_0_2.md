# Pal Eyes OSM Tile Provider Policy and Production Readiness — R9.0.2

## Authority

- Batch: `PAL_EYES_OSM_TILE_PROVIDER_POLICY_AND_PRODUCTION_READINESS_CLOSURE_V1`
- Parent baseline: `PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802`
- Parent commit: `21d70b068870be72e573140ceb7a9ba17e644da3`
- Candidate baseline: `PAL_EYES_OSM_TILE_PROVIDER_POLICY_AND_PRODUCTION_READINESS_R9_0_2_20260803`
- Candidate version: `9.0.2+31`

## Policy decision

The OSM standard raster endpoint is permitted only for controlled local,
development, staging, and low-volume pilot use. Production does not fall
back to the OSM public tile service. Production requires the explicit
`approved_external` mode and `MAP_TILE_PROVIDER_APPROVED=true`, together
with a complete HTTPS URL template, attribution, licence URL, and issue
report URL.

An incomplete, unknown, or unapproved production configuration resolves to
a disabled tile runtime. No tile requests are sent in that state.

## OSM compliance controls

- Exact standard endpoint:
  `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- Visible attribution:
  `© OpenStreetMap contributors`
- Licence:
  `https://www.openstreetmap.org/copyright`
- Map issue reporting:
  `https://www.openstreetmap.org/fixthemap`
- Native identifier:
  `ps.paleyes.app`
- Web referrer policy:
  `strict-origin-when-cross-origin`
- Cache bypass headers are not introduced.
- Prefetch, bulk download, offline archives, and background seeding remain
  forbidden.

## Runtime configuration

The application accepts these compile-time values through `--dart-define`:

- `PAL_EYES_ENV`
- `MAP_TILE_PROVIDER_MODE`
- `MAP_TILE_URL_TEMPLATE`
- `MAP_TILE_ATTRIBUTION_TEXT`
- `MAP_TILE_ATTRIBUTION_URL`
- `MAP_TILE_ISSUE_REPORT_URL`
- `MAP_TILE_USER_AGENT_PACKAGE_NAME`
- `MAP_TILE_MAX_NATIVE_ZOOM`
- `MAP_TILE_PROVIDER_APPROVED`

## Governance boundaries

This batch does not authorize production deployment, provider purchase,
provider account creation, database writes, Supabase apply, publication,
public coordinates, public markers, or approved media.

## Primary policy references

- OpenStreetMap Foundation Operations Working Group:
  `https://operations.osmfoundation.org/policies/tiles/`
- flutter_map tile layer and attribution documentation:
  `https://docs.fleaflet.dev/layers/tile-layer`
- flutter_map caching documentation:
  `https://docs.fleaflet.dev/layers/tile-layer/caching`
- url_launcher package:
  `https://pub.dev/packages/url_launcher`
