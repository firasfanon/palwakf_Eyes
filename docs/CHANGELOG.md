# سجل التغييرات

## [4.0.3] — 2026-07-15

- Made PalEyesVisualCard height-aware through LayoutBuilder.
- Bounded compact descriptions with Expanded space and ellipsis.
- Preserved footer visibility.
- Added a dedicated compact-card overflow test.

## [4.0.2] — 2026-07-15

- Replaced two unnecessary double-underscore closure parameters.
- Added stable identities for the Home stories and evidence sections.
- Updated the immersive Home test to scroll lazy sections into view.
- Visual design and content counts remain unchanged.

## [4.0.1] — 2026-07-15

- Accepts the verified, Dart-formatted R3.0.3 local preimage.
- Adds direct Material boundaries around interactive ListTile surfaces.
- Adds a dedicated immersive Home contract test.
- Supersedes the non-applied R4.0.0 package.

## [4.0.0] — 2026-07-15

### Added

- Immersive Palestinian digital-atlas Home experience.
- Unified visual design system and custom Palestine map artwork.
- Premium public and workspace shells.
- Global branded page hero across product, workspace, admin, and governance pages.
- Editorial stories, category discovery, visual timeline, site-of-the-day,
  evidence journey, oral-memory, and community-contribution surfaces.
- Responsive mobile navigation and dark-mode alignment.

### Changed

- Site cards redesigned as visual heritage scenes.
- Map redesigned as a full-screen spatial storytelling surface.
- Stories, methodology, contribution, workspace dashboard, and generic
  workspace sections redesigned.
- Public content pages now carry route-specific icon and eyebrow identity.

### Boundaries

- Content records unchanged.
- Database mutation: NONE.
- Production mutation: NONE.
- Automatic publication: BLOCKED.

## [3.0.3] — 2026-07-15

- Moved the governed Home draft banner into the first Hero surface.
- Added stable key `home-governed-draft-banner`.
- Replaced fragile scroll/text-count smoke logic with key identity.
- Content counts unchanged; no database mutation.

## [3.0.2] — 2026-07-15

### Fixed

- Made the Sebastia key-site assertion aware of the canonical qualified label
  `سبسطية (شمرون)`.
- Made the Tell es-Sultan assertion aware of the canonical qualified label
  `تل السلطان (أريحا القديمة)`.
- Restored the canonical Home banner title `مسودة خاضعة للتدقيق`.
- Made the Home smoke test scroll the governed banner into view.
- Added a static regression gate for all four contracts.

### Boundaries

- Content records unchanged.
- Database mutation: NONE.
- Automatic publication: BLOCKED.

## [3.0.1] — 2026-07-14

### Fixed

- Added the direct `draft_content_profile.dart` import to `site_card.dart`.
- Removed the unused profile import from `places_screen.dart`.
- Removed the unused metrics import from `workspace_dashboard_screen.dart`.
- Added a static extension-import-scope regression gate.

### Boundaries

- Catalog/content counts unchanged.
- Database mutation: NONE.
- Automatic publication: BLOCKED.

## [3.0.0] — 2026-07-14

### Added

- 79-site draft catalog extracted from the user-provided reference draft.
- 47 expanded narrative drafts.
- 79-entry draft source registry.
- 16-governorate coverage registry.
- Explicit coordinate-gap and governorate-gap surfaces.
- Progressive rendering and filtering across public and workspace screens.
- JSON content seeds and extraction evidence.
- Full catalog/source/governorate contract tests.

### Changed

- Home, discovery, places, detail, map, timeline, governorates, sources,
  workspace dashboard, and workspace place management now represent the
  full extracted scope instead of three examples.
- Map markers are limited to evidenced coordinates.
- Internal operational summaries now show full-catalog workloads.

### Boundaries

- Approved content: 0.
- Published content: 0.
- Database mutation: NONE.
- Production mutation: NONE.
- Automatic publication: BLOCKED.

## [2.0.2-null-aware-syntax-hotfix] — 2026-07-14

### Fixed

- Replaced invalid postfix `trailing?,` with the valid null-aware
  collection element `?trailing,`.
- Corrected the static regression gate to enforce prefix syntax.

### Boundaries

- Database mutation: NONE.
- Production mutation: NONE.
- Automatic publication: BLOCKED.

## [2.0.1-compile-hotfix] — 2026-07-14

### Fixed

- Removed invalid `const` from `ConstrainedBox` in the home contribution callout.
- Removed invalid `const` from `ConstrainedBox` in the place-detail workspace callout.
- Escaped the narrative evidence line break as `\n`.
- Replaced the explicit nullable trailing check with a null-aware collection element.

### Verification

- Static contract: PASS.
- Compile-hotfix regression gate: PASS.
- Local Flutter analyze/test/build: pending user environment.

### Boundaries

- Database mutation: NONE.
- Production mutation: NONE.
- Automatic publication: BLOCKED.

## [2.0.0] — 2026-07-14

### Added

- Public Shell منفصل.
- Workspace Shell مع Sidebar مبوب.
- Governance subsurface تحت `/admin/governance`.
- صفحات عامة إنتاجية محسنة.
- مسودات تاريخية ظاهرة مع حالات التدقيق.
- Workspace dashboard وإدارة المواقع ونموذج إضافة موقع محلي.
- اختبارات Draft visibility وRoute grouping.
- Static verifier لعقود UI/UX والحوكمة المعزولة.

### Removed from public UI

- Runtime Foundation labels.
- Local database-write warnings.
- Research/Admin entries from public navigation.

### Boundaries

- Database mutation: NONE.
- Production: NONE.
- Automatic publication: BLOCKED.

## [1.0.2-initial-browser-accepted] — 2026-07-14

### Accepted

- Chrome local runtime launch.
- Home page desktop RTL rendering.
- App shell, Hero, work-surface cards, and research sample cards.
- No visible red screen or overflow in supplied evidence.

### Added

- Browser UAT evidence and acceptance report.
- Parallel operational/UI/governance development policy.
- Next operational Mega Batch scope.

### Warnings

- Flutter viewport replacement: non-blocking.
- OpenStreetMap public tile usage warning: production decision required.

### Pending

- Full route UAT.
- Mobile UAT.
- Dark mode UAT.
- Map interaction UAT.

### Mutations

- Database: NONE.
- Production: NONE.
- Historical publication: NONE.

## [1.0.2] — 2026-07-14

### Fixed

- Flutter 3.44.1 / `intl` dependency conflict.
- Static verifier stale dependency contract.
- Unterminated string literal in places screen.
- Analyzer scanning stale Dart files under `backups/`.

### Verified

- Static Source Contract: PASS.
- Flutter pub get: PASS.
- Flutter analyze: PASS, no issues.
- Flutter test: PASS, 3 tests.
- Flutter build web: PASS.
- Runtime checks: PASS.

### Pending

- Browser UAT.

### Mutations

- Database: NONE.
- Production: NONE.
- Historical publication: NONE.

## [1.0.1] — 2026-07-14

### Added

- Baseline كامل ذاتي الاكتفاء للتثبيت على مشروع جديد.
- Fresh install script مع `-WhatIf`.
- Manifest وSHA-256 verification قبل النسخ.
- منع الاستبدال الصامت للمجلدات غير الفارغة.
- Backup تلقائي عند `-AllowReplaceExisting`.
- Baseline marker ثابت.
- Baseline verification script.
- دليل تثبيت وتوريث محدث.

### Fixed

- إزالة الاعتماد الإجباري على Parent Baseline R0.2.0 عند تأسيس مشروع جديد.
- إصلاح مسارات PowerShell المكتوبة في README.
- توضيح التعامل مع Execution Policy.
- تحسين فشل التحقق عند غياب Flutter بدلاً من إرجاع نجاح ملتبس.

### Verified

- Parent Full Baseline ZIP: PASS.
- Static Source Contract: PASS.
- No `legacy.dart`: PASS.
- No hardcoded Supabase URL or secret: PASS.
- No database write calls: PASS.
- No Supabase migrations: PASS.

### Pending Local Environment

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build web`
- Browser UAT

### Mutations

- Flutter source: packaging and tooling patch only.
- Database: NONE.
- Production: NONE.
- Historical publication: NONE.

## [1.0.0] — 2026-07-13

### Added

- Flutter Web Runtime Foundation.
- Riverpod 3 ProviderScope and Notifier settings.
- GoRouter responsive shell and route contract.
- Arabic-first RTL and local English switch.
- Sovereign blue/gold/royal-red theme.
- Home, discovery, places, detail, map, timeline, governorates, stories, sources, contribution, methodology, research, and admin screens.
- Optional Supabase bootstrap via compile-time dart-defines.
- Demo repository with unpublished research-pending samples.
- Flutter widget and route tests.
- Static source verifier and Windows run/check scripts.
- Runtime foundation documentation and handoff.

### Verified

- Static source contract: PASS.
- No `legacy.dart`: PASS.
- No hardcoded Supabase URL/key: PASS.
- No database write calls: PASS.
- No Supabase migrations: PASS.
- ZIP validation: pending package build step.

### Environment limitation

- Flutter/Dart CLI was not available in the package generation environment.
- `flutter pub get/analyze/test/build web` must run in the user's Flutter environment.

### Mutations

- Parent baseline: NONE.
- Flutter source: CREATED in promoted baseline.
- Database: NONE.
- Production: NONE.
- Historical publication: NONE.

## [0.2.0] — 2026-07-13

### Added

- تقرير Repository & Runtime Discovery بوضع القراءة فقط.
- دليل سلامة Baseline المصدر.
- أداة جرد Python قابلة لإعادة الاستخدام.
- PowerShell wrapper للتشغيل على Windows.
- وثيقة جاهزية Flutter Runtime Foundation.
- Session Handoff محدث.

### Verified

- Parent ZIP validation: PASS.
- Parent manifest validation: PASS.
- Parent ZIP SHA-256: `88b87fc2e9ec5934e30f92976862808287210fb043b3d75263b3ea6417ff4b83`.

### Classified

- Repository: Documentation and Governance Baseline.
- Flutter Runtime: Not present.
- Supabase local project: Not present.
- Runtime failure: False.

### Mutations

- Parent baseline: NONE.
- Runtime source: NONE.
- Database: NONE.
- Production: NONE.
- Documentation/evidence baseline: UPDATED.

## [0.1.0] — 2026-07-13

### Added

- المرجع الأعلى للمشروع.
- ميثاق المشروع.
- خطة المرحلة صفر.
- حوكمة الرواية والمصادر.
- نموذج البيانات المفاهيمي.
- RBAC وسير العمل وبوابات النشر.
- المعمارية التقنية.
- نطاق المنتج والمسارات.
- معايير القبول.
- سجل القرارات.
- سجل الأخطاء.
- ملف توريث الجلسة.
- مسودة SQL تصميمية غير مطبقة.
- Baseline manifest.

### Changed

- لا يوجد؛ هذا أول Baseline.

### Database

- `NO_MUTATION`

### Source

- `NO_MUTATION`

## [5.1.0] — 2026-07-15 — Governed content adoption

### Added

- 79 governed site records derived from the corrected R1.0.1 candidate.
- 92 historically reviewed Arabic editorial records.
- 95 governed source records with rights and reuse states.
- 211 held research claims in the research workspace.
- Governed page-category, identity, relation, coordinate, media and publication fields.
- Dedicated static verifier and content-adoption contract test.
- Governed content seeds and current project-memory updates.

### Changed

- 57 site pages now use reviewed narratives and linked sources.
- 22 site pages use a limited research-only presentation.
- The public map exposes zero coordinates; three coordinates remain review-only.
- Sources and research workspaces now expose the governed registries.
- Home and places surfaces display the adoption metrics.

### Governance

- Database mutation: NONE.
- Public publication: BLOCKED.
- Approved media assets: 0.
- Local Flutter analyze/test/browser UAT: PENDING.

## [5.1.1] — 2026-07-15 — Source-contract and ListTile boundary repair

### Fixed

- Accepts the exact local R4.0.3 source snapshot captured by the failed
  content-adoption run.
- Replaces transparent Material wrappers around ListTiles with owned
  transparent Material canvases.
- Adds static and Flutter regression contracts for the runtime assertion.

### Preserved

- 79 governed site records.
- 57 governed draft pages and 22 limited research pages.
- 92 editorial records, 95 sources and 211 held claims.
- Database import and publication remain blocked.

## [5.1.2] — 2026-07-15 — Compile and dual-contract repair

### Fixed

- Closed the broken narrative evidence string in the place detail page.
- Removed the invalid const invocation and analyzer cleanup issues.
- Restored raw evidence semantics for 47 expanded narratives and 3 coordinates.
- Added a separate public-coordinate gate that remains at zero.
- Updated governed visibility tests for 57 governed and 22 limited pages.

### Governance preserved

- 92 reviewed editorial records.
- 95 governed sources.
- 211 held claims.
- Database import and publication remain blocked.

## [5.1.3] — 2026-07-19 — Legacy metric and Material canvas repair

### Fixed

- Restores the original 47 expanded-narrative evidence count.
- Keeps 57 governed editorial pages as a separate product metric.
- Places workspace ExpansionTile headers below a painted Material canvas.
- Removes the remaining root ColoredBox from the map interaction surface.
- Adds broad ListTile/ExpansionTile boundary regression coverage.

### Preserved

- 79 sites, 92 editorial records, 95 sources and 211 held claims.
- Public coordinates remain 0; review coordinates remain 3.
- Database import and publication remain blocked.

## [5.2.0] — 2026-07-19 — Original historical draft restoration

### Added

- Exact project copy of the 5334-line uploaded historical source file.
- Original historical draft domain layer and 79-site provenance registry.
- Dual narrative catalog combining governed and original layers by canonical ID.
- Separate detail-page surface for the original draft.
- Debug-only visibility policy and public-release block.
- Original-draft filters, badges and metrics.
- Contract tests for 47 expanded narratives and 32 catalog summaries.

### Preserved

- 92 reviewed editorial records.
- 57 governed draft pages and 22 limited research pages.
- 211 held claims remain in the research workspace.
- No database write or publication.

## [5.2.1] — 2026-07-19 — Source contract and dual metric repair

### Fixed

- Removes the R5.2.0 create-target drift against an already-applied R5.1.3.
- Measures 47 original narratives, 57 governed pages and 22 limited pages
  from the dual narrative catalog.
- Makes compile-contract verification resilient to Dart formatter output.

### Preserved

- Exact uploaded historical source.
- 79 original draft layers.
- Debug-only original-draft visibility.
- Database import and publication remain blocked.

## [6.0.0] — 2026-07-19 — Product UX phases 1–4 foundation

- Added four public discovery gateways.
- Added Today, Site Editor, Source Registry, Claim Workspace and Review Queue.
- Added GIS Review, Media/Rights and Relationship surfaces.
- Added Preview, Approval, Release Candidate and Audit surfaces.
- Added task-focused shared UX components and local interaction states.
- Publication, database writes and production deployment remain blocked.

## [6.0.1] — 2026-07-19 — Analyzer and SiteCard overflow closure

- Reduced SiteCard badge density from three badges to two.
- Added exact boundary regression coverage for original-draft cards.
- Sorted Dart imports and removed analyzer information findings.
- Repaired the formatter-sensitive compile static verifier.
- Preserved all four R6.0.0 product UX phases and governance boundaries.

## [6.0.2] — 2026-07-19 — Residual 4px SiteCard closure

- Recovered exactly four vertical pixels in non-compact SiteCard layout.
- Preserved the 364×402 regression boundary.
- Preserved both content-status and original-draft badges.
- No card-height increase and no content removal.

## [7.0.0] — 2026-07-19 — Operational backend activation

- Added governed Supabase schema, RLS and idempotent baseline seed.
- Added hybrid local/Supabase operational repositories.
- Activated site, source, claim, GIS, media, review, release and audit workflows.
- Bound workspace screens to operational data providers.
- Kept public release and production deployment blocked.

## [7.0.1] — 2026-07-19 — Operational compile, mapper and SQL closure

- Repaired coordinate candidate mapping from governed HeritageSite records.
- Imported the backend-mode Arabic label extension explicitly.
- Closed all reported operational analyzer information findings.
- Guarded BuildContext use across async gaps.
- Repaired four invalid public_map_use conflict updates in seed SQL.
- Added mapper and SQL regression coverage.

## [7.0.2] — 2026-07-19 — Coordinate seed parity closure

- Added a local governed coordinate seed matching the four SQL seed records.
- Reconciled local site coordinate status with operational seed identities.
- Reconciled initial GIS tasks to four and total review tasks to sixteen.
- Strengthened runtime and static parity checks for exact candidate IDs.
- Preserved zero public coordinates and blocked publication.

## [8.0.0] — 2026-07-20 — Public experience maturity round 2

- Simplified public navigation to five primary destinations.
- Separated the team workspace from the visitor journey.
- Added multi-dimensional search modes, sorting and active-filter feedback.
- Reframed the places catalog as a visual Palestinian atlas.
- Added a rights-safe museum-style media stage to place pages.
- Rebuilt the public map around approved coordinates only.
- Added a long-form editorial magazine with three stories and twelve chapters.
- Added shared loading, empty and error states with accessibility semantics.
- Reduced mobile discovery pagination to twelve cards and added repaint boundaries.

## [8.0.1] — 2026-07-20 — Analyzer and public story badge contract closure

- Sorted imports in place detail and places catalog screens.
- Reconciled the 364×402 SiteCard test with «حكاية موسعة».
- Preserved the no-overflow assertion and card dimensions.
- Reconciled R6.0.1 and R6.0.2 historical verifiers.
- Kept database and publication boundaries unchanged.
