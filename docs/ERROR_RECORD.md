# سجل الأخطاء المتكررة

لا توجد أخطاء تنفيذية حتى الآن؛ الحزمة تأسيسية فقط.

## القالب المعتمد

### ERR-XXXX — العنوان

- التاريخ:
- السبب:
- الملفات المتأثرة:
- ما فشل:
- ما جُرّب ولم ينجح:
- الحل:
- التحقق:
- آخر Baseline مستقر:
- حالة الإغلاق:


## ENV-0001 — Flutter CLI unavailable in package generation environment

- التاريخ: 2026-07-13
- السبب: بيئة إنشاء الحزمة لا تحتوي Flutter أو Dart CLI.
- الملفات المتأثرة: لا يوجد تلف ملفات.
- ما فشل: لم تُنفذ بوابات `flutter pub get/analyze/test/build`.
- ما فشل سابقاً: لا يوجد.
- الحل: تضمين أدوات PowerShell وتشغيل البوابات في بيئة المستخدم Flutter 3.44.1/Dart 3.12.1.
- التحقق المنفذ: Static Source Contract = PASS.
- آخر Baseline مستقر: R0.2.0.
- الحالة: OPEN_ENVIRONMENTAL — ليست مشكلة في المصدر حتى يثبت العكس.


## PKG-0001 — Apply script not found after ZIP extraction

- التاريخ: 2026-07-14
- السبب: فك الحزمة أو فتح مجلد غير مطابق لبنية الأرشيف أدى إلى عدم العثور على السكربت بالمسار المتوقع.
- الملفات المتأثرة: لا يوجد تعديل على المشروع.
- ما فشل: استدعاء `Apply-PalEyesFlutterRuntimeFoundationV1.ps1`.
- ما جُرّب ولم ينجح: التشغيل من مسار ظُن أنه جذر الحزمة.
- الحل: Baseline جديد يحتوي المثبت في الجذر، مع README واضح.
- التحقق: Baseline package structure verified.
- آخر Baseline مستقر: R1.0.0 source package.
- الحالة: CLOSED_BY_R1_0_1.

## ENV-0002 — PowerShell Execution Policy blocked scripts

- التاريخ: 2026-07-14
- السبب: سياسة الجهاز تمنع تشغيل ملفات `.ps1`.
- الملفات المتأثرة: لا يوجد.
- ما فشل: تشغيل سكربت التثبيت.
- ما جُرّب ولم ينجح: الاستدعاء المباشر قبل تجاوز Process scope.
- الحل: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force`.
- التحقق: التجاوز مؤقت وينتهي بإغلاق نافذة PowerShell.
- آخر Baseline مستقر: R1.0.0.
- الحالة: DOCUMENTED.

## PKG-0002 — Parent baseline gate rejected fresh project

- التاريخ: 2026-07-14
- السبب: حزمة Upgrade اشترطت علامة R0.2.0 داخل مشروع جديد.
- الملفات المتأثرة: لا يوجد؛ التوقف حدث قبل النسخ.
- ما فشل: WhatIf لحزمة Built Apply على `C:\Users\DELL\StudioProjects\Pal_Eyes`.
- ما جُرّب ولم ينجح: التشغيل المباشر وبـ`powershell.exe -ExecutionPolicy Bypass`.
- الحل: إنشاء Baseline Fresh Install لا يعتمد على Parent، مع فصل واضح بين Baseline وPatch.
- التحقق: المثبت الجديد لا يفحص Parent ويستخدم Manifest الحالي.
- آخر Baseline مستقر: R1.0.0.
- الحالة: CLOSED_BY_R1_0_1.


## DEP-0003 — Flutter localization intl solver conflict

- التاريخ: 2026-07-14
- السبب: Flutter 3.44.1 يثبت `intl 0.20.2` بينما Baseline طلب `^0.20.3`.
- الحل: تثبيت `intl: 0.20.2`.
- التحقق: `flutter pub get=PASS`.
- الحالة: CLOSED.

## VER-0004 — Static verifier retained obsolete intl expectation

- التاريخ: 2026-07-14
- السبب: verifier توقع `^0.20.3` بعد إصلاح pubspec.
- الحل: مواءمة العقد إلى `0.20.2`.
- التحقق: `STATIC_SOURCE_CONTRACT=PASS`.
- الحالة: CLOSED.

## CMP-0005 — Unterminated string in places screen

- التاريخ: 2026-07-14
- السبب: سطر فعلي داخل سلسلة Dart أحادية الاقتباس.
- الحل: استبداله بـ`\n`.
- التحقق: الملف التشغيلي المصحح SHA-256 `9f0beee9836215410d84ed8d64330250b9ac0deed7651aa4bb367132fcfcd4b5`.
- الحالة: CLOSED.

## ANA-0006 — Analyzer scanned stale backup Dart source

- التاريخ: 2026-07-14
- السبب: نسخة قديمة من الملف المكسور كانت داخل `backups/`.
- الحل: إضافة `backups/**` إلى analyzer exclude.
- التحقق: `flutter analyze=PASS`.
- الحالة: CLOSED.


## WEB-WARN-0007 — Existing viewport meta replaced

- التاريخ: 2026-07-14
- التصنيف: Warning غير مانع.
- الأثر: لا أثر تشغيلي ظاهر.
- القرار: يراجع عند تحسين Web shell.

## MAP-WARN-0008 — OpenStreetMap public tile usage warning

- التاريخ: 2026-07-14
- التصنيف: Production readiness warning.
- الأثر: خوادم OSM العامة ليست خياراً مضموناً للاستخدام الإنتاجي واسع النطاق.
- القرار: اختيار Tile provider أو استضافة Tiles قبل Production.
- الحالة: OPEN_FOR_PRODUCTION_PHASE.


## ERR-0010 — 2026-07-14 — Three-site document coverage truncation

### Symptom

The productive surfaces exposed only Solomon's Pools, Sebastia, and Tell
es-Sultan while the reference draft contained a substantially wider matrix,
narratives, governorate coverage, and source mentions.

### Classification

```text
TYPE=PRODUCT_SCOPE_TRUNCATION
THREE_SITES=INITIAL_RENDERED_EXAMPLES
FULL_DOCUMENT_COVERAGE=REQUIRED
```

### Repair

`MEGA_BATCH_PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_V1` extracts and displays:

```text
SITES=79
EXPANDED_NARRATIVES=47
SOURCES=79
GOVERNORATES=16
```

### Prevention

Static contracts and tests now assert exact counts, key sites, zero published
records, coordinate gaps, and the two governorate extraction gaps.


## ERR-0011 — 2026-07-14 — Extension import scope compile failure

### Symptom

`site_card.dart` could not resolve `DraftContentProfileX.icon` and
`DraftContentProfileX.labelAr`. Two additional unused imports caused analyzer
warnings.

### Repair

`PAL_EYES_FULL_DRAFT_SITE_CATALOG_EXTENSION_IMPORT_ALIGNMENT_COMPILE_HOTFIX_V1` adds the direct extension import and removes both unused
imports.

### Prevention

The static verifier now enforces exact import placement.


## ERR-0012 — 2026-07-15 — Runtime test-contract mismatch

### Symptom

`flutter analyze` passed, but two tests failed:

- exact-name matching rejected `سبسطية (شمرون)`;
- Home smoke test did not find the canonical draft-banner title.

### Root cause

The catalog correctly preserved qualified canonical names, while the test used
strict equality. The Home banner used a descriptive title instead of the
governed canonical title.

### Repair

`PAL_EYES_FULL_DRAFT_SITE_CATALOG_TEST_CONTRACT_AND_DRAFT_BANNER_ALIGNMENT_HOTFIX_V1` applies qualifier-aware name assertions and canonical banner
alignment.

## ERR-0013 — 2026-07-15 — Fragile Home banner smoke identity

تم الإصلاح بواسطة `PAL_EYES_HOME_DRAFT_BANNER_SMOKE_TEST_IDENTITY_HOTFIX_V1` بنقل التنبيه إلى Hero الأول واختباره بالهوية.


## ERR-0014 — 2026-07-15 — Product surfaces visually functional but not immersive

### Symptom

The project had productive routes and complete draft catalog coverage, but the
Home and related pages still read as operational cards rather than a distinctive
Palestinian digital-atlas experience.

### Repair

`MEGA_BATCH_PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_V1` introduces a shared visual system and specialized immersive surfaces
across the public product and workspace.

### Prevention

The static verifier now asserts brand, map, page-hero, story, methodology, and
contribution design contracts.

## ERR-0015 — 2026-07-15 — Formatted-source hash drift and ListTile Material assertion

R4.0.0 stopped before mutation because the local R3.0.3 sources were formatted.
The running R3.0.3 surface also exposed a ListTile/ColoredBox assertion.
`MEGA_BATCH_PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_V1_0_1` repairs both contracts.

## ERR-0016 — 2026-07-15 — Lazy immersive Home section test

The immersive Home test queried `قصص من المكان` before its Sliver section was
built. `PAL_EYES_IMMERSIVE_HOME_LAZY_SECTION_TEST_AND_ANALYZER_CLEANUP_HOTFIX_V1` adds stable section keys and controlled scrolling.

## ERR-0017 — 2026-07-15 — Compact PalEyesVisualCard overflow

Three cards overflowed by 4px. `PAL_EYES_VISUAL_CARD_COMPACT_HEIGHT_OVERFLOW_HOTFIX_V1` closes the shared layout defect.

## ERR-0018 — 2026-07-15 — Local Flutter execution unavailable in build environment

### Symptom

The governed-content adoption package could be statically generated and verified, but Flutter/Dart executables are not available in the package build environment.

### Containment

Static source contracts, exact content counts, forbidden database-write scans, source linking, publication blocks, and generated-data structure were verified.

### Remaining gate

`flutter analyze`, `flutter test`, and browser UAT remain mandatory in the user's local Flutter environment before baseline acceptance.

## ERR-0019 — 2026-07-15 — Governed content adoption preimage drift and ListTile runtime assertion

### Evidence

- `PAYLOAD_INTEGRITY=PASS`
- Application stopped at `home_screen.dart` before any files were copied.
- `verify_governed_content_adoption.py` remained absent.
- Existing baseline passed `flutter analyze` and 20 tests.
- Chrome raised repeated `ListTile background color or ink splashes may be invisible`.

### Root cause

1. The package source contract was built against a non-identical R4.0.3 source
   snapshot and did not accept the locally formatted/current file hashes.
2. A transparent Material wrapper did not provide the independent painted
   Material canvas required by the current Flutter debug assertion.

### Repair

- Exact current local source hashes are accepted alongside the known ancestor.
- Public drawer, workspace navigation and map-gap ListTiles use
  `Material(color: Colors.transparent)`.
- Static and Flutter regression contracts prevent reintroduction.

## ERR-0020 — 2026-07-15 — Governed page compile blocker and legacy getter regression

### Evidence

- `dart format` stopped at an unterminated Arabic interpolation in `place_detail_screen.dart`.
- `flutter analyze` reported 35 issues, dominated by the same parser failure.
- Legacy evidence tests observed 0 expanded narratives and 0 mapped coordinates because public-display getters replaced raw evidence getters.

### Root cause

1. A generated two-line single-quoted Dart string was not escaped or concatenated.
2. Public governance semantics were overloaded onto the legacy `hasCoordinates` and `hasExpandedNarrative` getters.
3. Four analyzer cleanup items remained.

### Repair

- Use adjacent double-quoted strings with an explicit newline.
- Add `hasPublicCoordinates` while restoring raw evidence getters.
- Route public providers and pages through `hasPublicCoordinates`.
- Update governed/legacy tests and analyzer cleanup.

## ERR-0021 — 2026-07-19 — Legacy narrative count 79 and residual ListTile assertion

### Evidence

- R5.1.2 Apply PASS.
- All three static verifiers PASS.
- `flutter analyze`: No issues found.
- Two tests failed because `hasExpandedNarrative` returned 79 instead of 47.
- Chrome continued to raise the `ListTile`/`ColoredBox` assertion.

### Root causes

1. Every governed site received at least one review/status narrative section,
   so `narrativeSections.isNotEmpty` no longer represented the original
   47-row expanded-narrative extraction class.
2. The workspace sidebar still used a `ColoredBox` above `ExpansionTile`;
   the tile headers are internal ListTiles and therefore remained below the
   colored intermediate surface.

### Repair

- `hasExpandedNarrative` now reads the immutable content profile.
- Workspace and map roots use `Material` canvases.
- Regression tests scan all interactive ListTile/ExpansionTile source files.

## ERR-0022 — 2026-07-19 — Original historical draft hidden from pages

### Symptom

The original uploaded historical material remained in the extraction catalog,
but the runtime repository returned the governed catalog only. The detail page
therefore rendered short reviewed editorial records and hid the original
47 expanded narratives.

### Root cause

The governed adoption layer replaced the repository surface instead of
augmenting it with a separately governed original-draft layer.

### Repair

A dual narrative catalog now attaches the original extraction record to every
governed site. The detail page renders reviewed and original layers separately.
Original content is debug-only and public release remains blocked.

## ERR-0023 — 2026-07-19 — R5.2.0 create drift and stale catalog test

### Evidence

- R5.2.0 WhatIf stopped before copy at
  `test/legacy_narrative_metric_and_expansion_tile_material_canvas_contract_test.dart`.
- The file already existed from R5.1.3.
- `flutter analyze` passed.
- One test failed because it requested governed page categories from the raw
  extraction catalog and returned zero instead of 57.
- Two compile-verifier checks failed only because of formatter-sensitive
  literal matching.

### Repair

- R5.2.1 uses R5.1.3 as its actual parent.
- Existing R5.1.3 test files are replace targets, not create targets.
- The metric test reads the dual catalog.
- Static checks match semantic markers rather than quote layout.

## ERR-0024 — 2026-07-19 — R6.0.0 analyzer and SiteCard overflow

### Evidence

- Product UX, original draft, governed adoption and foundation static gates passed.
- Compile verifier had one formatter-sensitive false positive.
- Analyzer returned four information-level findings.
- Immersive home test reported three SiteCard overflows, each 24 pixels.
- Browser screenshots showed the public home and grouped workspace rendering.

### Root cause

The third card chip introduced for the original-draft profile caused the
badge wrap to consume an additional row inside a fixed card boundary.

### Repair

- Remove the redundant page-category chip from the card.
- Keep status plus one compact original-profile tag.
- Add a widget regression test at the exact immersive-home card boundary.
- Sort imports and remove the unnecessary underscore parameter.
- Make the compile verifier semantic rather than formatter-sensitive.

## ERR-0025 — 2026-07-19 — Residual SiteCard overflow by 4px

### Evidence

After R6.0.1:

- `dart format lib test` passed with zero changed files.
- `flutter analyze` returned `No issues found`.
- One widget test failed with a RenderFlex overflow of exactly 4 pixels.
- Chrome compiled and started successfully.

### Repair

The non-compact card body retains its 19-pixel horizontal padding while
vertical padding changes from 19 to 17 pixels. This recovers exactly four
vertical pixels without increasing card height or removing content.

## ERR-0026 — 2026-07-19 — R7 operational compile and SQL closure

### Runtime evidence

- All six static verification suites passed.
- Dart format completed and changed 19 operational files.
- Analyzer reported four compile errors and eleven information findings.
- Tests were compile-blocked by the same missing getters and extension import.
- The SQL contract additionally exposed an invalid unquoted conflict update:
  `public_map_use=BLOCKED`.

### Root causes

1. Coordinate candidates were mapped from `OperationalSiteRecord`, which does
   not carry raw latitude and longitude.
2. `OperationalBackendModeX` was not imported by the source registry screen.
3. Constructors and async context flow did not satisfy the active lint profile.
4. Seed SQL used an invalid unquoted value in four `ON CONFLICT` updates.

### Repair

- Map coordinates directly from governed `HeritageSite` records.
- Import the domain extension explicitly.
- Reorder factories, use an initializing formal and guard BuildContext.
- Use `excluded.public_map_use` and strengthen SQL regression coverage.

## ERR-0027 — 2026-07-19 — Local fallback coordinate seed count mismatch

### Evidence

R7.0.1 passed both static verification suites and `flutter analyze`, but
one runtime test returned three coordinate candidates while the governed
operational manifest and SQL seed contain four.

### Root cause

The local mapper read the three legacy coordinates embedded in the site
catalog. The operational backend seed defines a separate governed candidate
registry containing four records. These are distinct data layers and must not
be treated as interchangeable.

### Repair

A dedicated local operational coordinate seed now mirrors the four SQL seed
records by ID, site, coordinate and source. The mapper, site statuses and GIS
review tasks consume that seed. The legacy catalog coordinates remain
unchanged and are not promoted into the operational registry automatically.

## ERR-0028 — 2026-07-20 — Public experience resembled an administration surface

### الملاحظة

كانت الواجهة العامة تعرض عدداً كبيراً من المسارات والمصطلحات الحاكمية،
كما كانت بعض صفحات المواقع تقود مباشرة إلى مساحة الباحث. أدى ذلك إلى
تشويش مسار الزائر وإضعاف الإحساس بالمتحف والأطلس والمجلة.

### المعالجة

- تقليص التنقل الأولي إلى خمسة مسارات.
- فصل مساحة الفريق بصرياً ووظيفياً.
- إضافة بحث متعدد الأبعاد وترتيب وفلاتر نشطة.
- إنشاء مجلة سردية بثلاث قصص طويلة و12 فصلاً.
- إعادة تصميم الخريطة بوصفها أطلساً عاماً fail-closed.
- إضافة حالات تحميل وفراغ وخطأ مشتركة وقابلة للوصول.

## ERR-0029 — 2026-07-20 — Legacy site-card label test after public terminology change

R8.0.0 passed all static verifiers. `flutter analyze` reported two
`directives_ordering` informational findings, and one widget test expected
the previous internal label «رواية أصلية موسعة» while the public card now
renders «حكاية موسعة».

The repair sorts the two imports, updates the unchanged 364×402 regression
test, preserves the no-overflow assertion, and reconciles R6.0.1/R6.0.2.

## ERR-0030 — 2026-08-02 — PalEyesMediaStage unbounded Stack height

### Evidence

Browser runtime failed at `public_experience_maturity.dart` because the media stage supplied only `minHeight` to a `Stack` whose children were positioned. The effective constraints were `370.0<=h<=Infinity`, so the Stack could not derive a finite size. The later box, null, and mouse-tracker messages were cascading failures.

### Repair

The media stage now owns the finite height already provided by its callers. Desktop-scrollable and 390-pixel mobile widget tests preserve the contract. The OpenStreetMap tile warning is tracked separately and was not the cause.

## ERR-0031 — 2026-08-02 — Mandatory Figma workflow reduced visual quality

### Observation

The generated Figma screens were structurally useful but visually weaker than the accepted Flutter screens. Treating them as a mandatory upstream authority would introduce an unnecessary design-to-code round trip and risk visual regression.

### Resolution

Figma remains preserved as an optional experiment and documentation surface. Direct Flutter visual development is restored as the primary workflow, with human browser review as the visual acceptance authority.

## ERR-R9-001 — 2026-08-02 — Baseline format drift and nested repository contamination

**Marker:** `PAL_EYES_R9_0_1_FORMAT_AND_NESTED_REPOSITORY_ERROR_RECORD`

### Symptoms

- 83 of 106 Dart files failed a global format census; the R8/R9 target scope contained 12 files requiring canonical formatting.
- A complete nested Git/Flutter repository existed at `Pal_Eyes\Pal_Eyes`.

### Root cause

- Historical packages were applied without a canonical target-scoped format gate.
- A duplicate working copy was placed inside the authoritative repository root.

### Failed or unsafe approaches

- Global `dart format lib test` was rejected because it would have expanded the patch to unrelated legacy files.
- Deleting the nested repository before evidence preservation risked losing uncommitted changes; the operator ultimately deleted it manually and authorized continuation using the outer repository as authoritative.

### Repair

- Formatted only the 12 verified R8/R9 files.
- Proved no format scope escape.
- Re-ran static verification, analyze, 65 tests, whitespace checks, Chrome/Edge runtime, and visual UAT.
- Promoted `PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802`.

### Prevention

- Future baselines must run a target-scoped Dart format check before packaging.
- Future scripts must fail closed when a nested `Pal_Eyes` repository exists.
- Last stable baseline: `PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802`.
