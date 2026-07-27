# الدليل الشامل الحاكم لمشروع بعيون فلسطينية

## بيانات الوثيقة

| الحقل | القيمة |
|---|---|
| الاسم العربي | بعيون فلسطينية |
| الاسم الإنجليزي | Palestinian Eyes |
| المعرّف التقني | `pal_eyes` |
| الإصدار | `4.0.0` |
| التاريخ | `2026-07-14` |
| الحالة | مرجع حاكم تأسيسي |
| المرحلة الحالية | المرحلة صفر: الحوكمة والنموذج المرجعي |
| نوع الحزمة | Design-only / No runtime or database mutation |

> هذا الملف هو المرجع الأعلى للمشروع، ويجب تحديثه بعد كل Batch أو Patch ناجح.

---

## 1. الرؤية

منصة رقمية فلسطينية سيادية لحصر المواقع التاريخية والأثرية والثقافية في فلسطين، وبناء **وثيقة تاريخية فلسطينية موثقة لكل موقع**، مرتبطة بالادعاءات والمصادر والأدلة والخرائط والوسائط والذاكرة الشفوية.

المنصة ليست دليلاً سياحياً أو قائمة أماكن، بل تجمع بين:

- موسوعة تاريخية مكانية.
- خريطة تفاعلية لفلسطين.
- محرك روايات ووثائق تاريخية.
- سجل مصادر وأدلة قابل للتدقيق.
- أرشيف صور ووثائق وخرائط وشهادات.
- نظام بحث واستكشاف ومقارنة.
- منصة مساهمة مجتمعية محكومة.
- لوحة بحث وتحرير ومراجعة ونشر.

---

## 2. المبادئ الحاكمة

1. **الرواية الفلسطينية الموثقة هي المنتج المركزي.**
2. لا تُنشر معلومة محورية بلا مصدر أو دليل قابل للتتبع.
3. يتم الفصل بين الحقيقة، والاستنتاج، والرواية الشفوية، والتقليد الشعبي، والمعلومة المتنازع عليها.
4. الذكاء الاصطناعي مساعد بحثي وتحريري فقط، ولا يملك الاعتماد أو النشر.
5. لا تُستخدم مصادر أو اقتباسات أو أرقام صفحات غير متحقق منها.
6. تحفظ النسخ السابقة، وسجل القرارات، ومسار المراجعة.
7. تحمى المواقع الحساسة من كشف الإحداثيات أو التفاصيل التي قد تسهل النهب أو الإضرار.
8. تحفظ حقوق الصور والوثائق والمقابلات قبل النشر.
9. واجهة عامة بسيطة، والحوكمة الثقيلة داخل مساحة الإدارة والبحث.
10. لا تُقاس جودة المشروع بعدد المواقع فقط، بل بعمق الرواية وقابلية تدقيقها.

---

## 3. التقنيات المعتمدة

### الواجهة

- Flutter Web.
- Android وiOS وPWA من قاعدة الكود نفسها.
- Dart.
- `GoRouter`.
- `flutter_riverpod.dart` للملفات الجديدة.
- `flutter_map` للخرائط.
- RTL/i18n.
- بنية Feature-based.
- Repositories وServices.
- Widgets مشتركة قابلة لإعادة الاستخدام.
- OOP وDRY.
- عدم استخدام `legacy.dart` في التطوير الجديد.

### الخلفية

- Supabase Auth.
- PostgreSQL.
- PostGIS.
- Supabase Storage.
- Edge Functions.
- RPCs محكومة للعمليات المركبة.
- Realtime عند الحاجة التشغيلية فقط.

### السيادة

- مخطط سيادي: `pal_eyes`.
- `public` للـ views وRPC wrappers المحكومة فقط.
- لا يوضع `service_role` داخل Flutter.
- RLS إلزامي على الجداول التشغيلية.

---

## 4. الكيان المركزي

الكيان التشغيلي المركزي هو:

```text
heritage_site
```

لكن لا تُختزل الصفحة في سجل واحد. النموذج الصحيح:

```text
Heritage Site
├── Names and aliases
├── Geometry and administrative context
├── Historical narrative document
│   ├── Sections
│   ├── Paragraphs
│   └── Claims
├── Sources and citations
├── Timeline and periods
├── Media and representations
├── Oral history
├── Condition and threats
├── Relationships to other sites
└── Versions, reviews, and publication events
```

---

## 5. محتوى الوثيقة التاريخية لكل موقع

1. الموقع والجغرافيا.
2. أصل الاسم والتسميات.
3. الخلفية السابقة للنشأة.
4. التأسيس والبناء.
5. التطور حسب العصور.
6. العمارة والهندسة.
7. المياه والزراعة والبيئة.
8. الاقتصاد والحرف والتجارة.
9. الحياة الاجتماعية.
10. الإدارة والأوقاف والملكية.
11. الأهمية الدينية والروحية.
12. السكان والعائلات المرتبطة.
13. الذاكرة الشفوية.
14. الروايات المختلفة والمتعارضة.
15. التحولات الحديثة.
16. التهجير أو الاستيطان أو التدمير.
17. حالة الحفظ الحالية.
18. المخاطر والتهديدات.
19. أعمال الترميم.
20. الخلاصة الفلسطينية للموقع.

---

## 6. المنهجية البحثية

### درجات المحتوى

| النوع | شرط العرض |
|---|---|
| حقيقة موثقة | مصدر قابل للتحقق |
| استنتاج بحثي | يوسم كاستنتاج وتذكر أدلته |
| رواية شفوية | تنسب للراوي والمقابلة |
| تقليد ديني أو شعبي | يوصف بوصفه تقليداً |
| معلومة متنازع عليها | تعرض الآراء والمصادر |
| معلومة غير مثبتة | لا تنشر كحقيقة |

### دورة البحث

```text
Source Discovery
→ Source Registration
→ Rights Review
→ Evidence Extraction
→ Claim Drafting
→ Narrative Drafting
→ Historical Fact Check
→ Editorial Review
→ Geospatial Review
→ Rights Review
→ Approval
→ Publication
→ Periodic Revalidation
```

---

## 7. النطاق الوظيفي

### المنصة العامة

- الصفحة الرئيسية.
- استكشاف المواقع.
- صفحة الموقع.
- الخريطة.
- الخط الزمني.
- المحافظات والمدن.
- القصص والمجموعات.
- المصادر.
- الوسائط.
- الذاكرة الشفوية.
- حالة الحفظ.
- المساهمة.
- الحساب والمفضلة.

### مساحة الباحث

- المواقع قيد البحث.
- الوثائق التاريخية.
- الادعاءات.
- المصادر والأدلة.
- مراجعة الحقوق.
- الذاكرة الشفوية.
- قوائم المراجعة.

### لوحة الإدارة

- لوحة مؤشرات.
- إدارة المواقع.
- محرر الرواية.
- سجل الادعاءات.
- إدارة المصادر.
- إدارة الخرائط.
- مكتبة الوسائط.
- المساهمات.
- المراجعات.
- المستخدمون والأدوار.
- التصنيفات.
- النشر.
- التحليلات.
- سجل التدقيق.
- الإعدادات والنسخ الاحتياطي.

---

## 8. المسارات المرجعية

```text
/
 /discover
 /places
 /places/:slug
 /map
 /timeline
 /governorates
 /governorates/:slug
 /cities/:slug
 /stories
 /collections
 /sources
 /media
 /oral-history
 /conservation
 /contribute
 /methodology
 /about
 /contact
 /account
 /favorites

/research/*
/admin/*
```

المسارات نهائية فقط بعد مطابقتها مع المستودع الفعلي وRoute Registry، ولا يجوز اختراع مسارات تتعارض مع بنية المنصة المضيفة.

---

## 9. الأدوار المرجعية

- `super_admin`
- `admin`
- `chief_editor`
- `historical_editor`
- `researcher`
- `fact_checker`
- `geospatial_editor`
- `media_editor`
- `rights_reviewer`
- `translator`
- `trusted_contributor`
- `contributor`
- `viewer`

الصلاحيات منفصلة عن الأدوار، مثل:

```text
site.create
site.edit
site.publish
narrative.review
source.verify
media.approve
map.edit
user.manage
audit.read
```

---

## 10. حالات سير العمل

### الرواية

```text
research_pending
research_in_progress
draft
fact_check
editorial_review
rights_review
approved
published
needs_revision
archived
```

### المساهمة

```text
submitted
initial_screening
needs_information
research_review
rights_review
accepted
partially_accepted
rejected
published
```

### المصدر

```text
discovered
registered
rights_pending
verification_pending
verified
restricted
rejected
archived
```

---

## 11. نموذج البيانات المرجعي

### الجغرافيا

- `governorates`
- `localities`
- `locality_aliases`
- `administrative_boundaries`

### المواقع

- `heritage_sites`
- `site_names`
- `site_geometries`
- `site_periods`
- `site_relations`
- `site_designations`
- `site_conditions`
- `site_threats`

### الروايات

- `narrative_documents`
- `narrative_sections`
- `narrative_paragraphs`
- `historical_claims`
- `claim_relations`
- `narrative_versions`

### المصادر

- `sources`
- `source_authors`
- `source_files`
- `source_versions`
- `source_rights`
- `citations`
- `claim_citations`
- `site_sources`

### الوسائط

- `media_assets`
- `media_representations`
- `media_rights`
- `site_media_links`

### الذاكرة الشفوية

- `oral_history_interviews`
- `oral_history_participants`
- `oral_history_segments`
- `oral_history_consents`
- `oral_history_site_links`

### سير العمل والإدارة

- `review_tasks`
- `review_comments`
- `review_decisions`
- `publication_events`
- `content_versions`
- `contributions`
- `notifications`
- `profiles`
- `roles`
- `permissions`
- `role_permissions`
- `user_role_assignments`
- `audit_events`
- `system_settings`

---

## 12. بوابات النشر

لا تنشر وثيقة موقع قبل تحقق ما يلي:

- اكتمال هوية الموقع.
- مراجعة الموقع الجغرافي.
- وجود مصدر لكل ادعاء أساسي.
- مطابقة الاقتباسات للأصل.
- توثيق الصفحات أو موضع الدليل.
- مراجعة الحقوق.
- مراجعة اللغة.
- مراجعة الرواية الشفوية والموافقات.
- قرار اعتماد مسجل.
- وجود نسخة سابقة قابلة للاستعادة.
- عدم كشف معلومات حساسة.

---

## 13. الأمن والخصوصية

- RLS على جميع الجداول التشغيلية.
- MFA للإدارة.
- روابط موقعة للملفات المقيدة.
- فصل ملفات المساهمات عن الملفات المنشورة.
- فحص الأنواع والأحجام.
- حفظ Hash للملفات الأصلية.
- منع الحذف المادي المباشر للمصادر المستخدمة.
- حماية بيانات الرواة.
- إخفاء المواقع الحساسة من API العام.
- سجل تدقيق غير قابل للتعديل من المستخدمين العاديين.

---

## 14. الأداء والوصول

- تحميل تدريجي للصور.
- صور مصغرة متعددة.
- Marker clustering.
- تحميل ضمن نطاق الخريطة.
- Pagination.
- بحث عربي مطبع.
- دعم قارئات الشاشة.
- تنقل بلوحة المفاتيح.
- تباين مناسب.
- دعم تكبير النص.
- تجاوب كامل ومنع overflow.
- حفظ مسودات النماذج الطويلة.

---

## 15. مراحل التنفيذ

### المرحلة صفر — الحالية

- ميثاق المشروع.
- منهجية الرواية.
- سياسة المصادر والحقوق.
- نموذج البيانات المفاهيمي.
- التصنيفات.
- حالات سير العمل.
- RBAC.
- الأمن وRLS.
- بوابات النشر.
- معايير القبول.
- baseline وسجلات الحوكمة.

### المرحلة الأولى

- النواة العامة.
- صفحة الموقع.
- الخريطة.
- البحث.
- الخط الزمني.
- المحافظات والمدن.
- 10–20 موقعاً تجريبياً موثقاً.

### المرحلة الثانية

- مساحة البحث والتحرير.
- محرر الرواية.
- سجل الادعاءات.
- المراجعات والإصدارات.
- مكتبة المصادر والوسائط.

### المرحلة الثالثة

- المساهمة المجتمعية.
- الذاكرة الشفوية.
- الإبلاغ عن الأضرار.
- المفضلة والمجموعات.

### المرحلة الرابعة

- التوسع متعدد اللغات.
- تطبيقات الجوال.
- الجولات.
- الخرائط التاريخية.
- API عام.
- أدوات ذكاء اصطناعي مساعدة ومحكومة.

---

## 16. قواعد صيانة المرجع

بعد كل Batch/Patch ناجح:

1. تحديث هذا الملف.
2. تحديث `CHANGELOG`.
3. تسجيل القرار المعماري أو البحثي في `DECISION_LOG`.
4. تسجيل الأخطاء المتكررة في `ERROR_RECORD`.
5. تحديث لقطة الحالة.
6. إنشاء Baseline مضغوط عند وجود تغيرات متعددة.
7. إنشاء Session Handoff شامل قبل إنهاء جلسة تطويرية مهمة.

---

## 17. الحالة الحالية

```text
PROJECT_ID=pal_eyes
CURRENT_PHASE=PHASE_0_GOVERNANCE_AND_REFERENCE_MODEL
FOUNDATION_BASELINE=R1.0.2
SOURCE_MUTATION=NONE
DATABASE_MUTATION=NONE
PRODUCTION_APPROVAL=NOT_REQUESTED
PUBLICATION_APPROVAL=NOT_REQUESTED
NEXT_GATE=LOCAL_FLUTTER_VALIDATION_AND_FULL_UI_UAT
```


---

## 18. نتيجة Repository & Runtime Discovery — 2026-07-13

تم اعتماد V0.1.0 كـ Parent Baseline والتحقق منه بوضع القراءة فقط.

### نتائج السلامة

```text
PARENT_ZIP_VALIDATION=PASS
PARENT_MANIFEST_VALIDATION=PASS
PARENT_ZIP_SHA256=88b87fc2e9ec5934e30f92976862808287210fb043b3d75263b3ea6417ff4b83
```

### نتائج Runtime

```text
REPOSITORY_CLASS=DOCUMENTATION_AND_GOVERNANCE_BASELINE
FLUTTER_RUNTIME=NOT_PRESENT
SUPABASE_LOCAL_PROJECT=NOT_PRESENT
FLUTTER_ANALYZE=NOT_APPLICABLE
FLUTTER_TEST=NOT_APPLICABLE
FLUTTER_BUILD=NOT_APPLICABLE
RUNTIME_FAILURE=FALSE
```

لا يعد غياب Runtime خطأ؛ V0.1.0 أنشئ أصلاً كحزمة حوكمة وتصميم.

### القرار

- الحفاظ على V0.1.0 Baseline أصل غير معدل.
- ترقية الوثائق والأدلة إلى R0.2.0.
- إنشاء Flutter Runtime في دفعة مستقلة لاحقة.
- لا اتصال بقاعدة البيانات ولا تطبيق SQL في مرحلة الجرد.


---

## 19. Flutter Runtime Foundation V1 — 2026-07-13

تم إنشاء أول Runtime Flutter فعلي فوق Baseline R0.2.0.

```text
FLUTTER_RUNTIME_SOURCE=PRESENT
RIVERPOD_ROOT=PRESENT
GOROUTER_ROOT=PRESENT
RTL_I18N_FOUNDATION=PRESENT
FLUTTER_MAP_FOUNDATION=PRESENT
SUPABASE_BOOTSTRAP=OPTIONAL_DISABLED_BY_DEFAULT
DATABASE_WRITE=NONE
SQL_MIGRATIONS=NONE
HISTORICAL_PUBLICATION=NONE
STATIC_SOURCE_CONTRACT=PASS
LOCAL_FLUTTER_ANALYZE=PENDING_USER_ENVIRONMENT
LOCAL_FLUTTER_TEST=PENDING_USER_ENVIRONMENT
LOCAL_FLUTTER_BUILD_WEB=PENDING_USER_ENVIRONMENT
```

### القرار الحاكم

- البيانات الظاهرة حالياً عينات واجهة غير منشورة.
- لا تُعد صفحة موقع وثيقة تاريخية معتمدة حتى اجتياز دورة البحث والمراجعة.
- تهيئة Supabase لا تحدث إلا عند توفير `SUPABASE_URL` و`SUPABASE_PUBLISHABLE_KEY` عبر `--dart-define`.
- لا يوجد أي استدعاء كتابة لقاعدة البيانات في Runtime Foundation.


---

## 20. Development Baseline R1.0.1 — 2026-07-14

تمت ترقية الحزمة إلى Baseline تأسيسي ذاتي الاكتفاء لا يحتاج Parent Baseline سابقاً.

```text
BASELINE_NAME=PAL_EYES_DEVELOPMENT_BASELINE_R1_0_1_20260714
INSTALL_MODE=FRESH_OR_EXPLICIT_REPLACE
DEFAULT_PROJECT_ROOT=C:\Users\DELL\StudioProjects\Pal_Eyes
PACKAGE_INTEGRITY_VALIDATION=REQUIRED
TARGET_NONEMPTY_DEFAULT=BLOCKED
TARGET_BACKUP_ON_REPLACE=REQUIRED
DATABASE_MUTATION=NONE
PRODUCTION_MUTATION=NONE
```

### الإصلاحات

- إضافة `Install-PalEyesDevelopmentBaseline.ps1`.
- إضافة تحقق Manifest وSHA-256 قبل التثبيت.
- إضافة `PAL_EYES_BASELINE_ID.txt`.
- إضافة `Verify-PalEyesDevelopmentBaseline.ps1`.
- إصلاح أوامر PowerShell في README.
- جعل غياب Flutter فشلاً واضحاً في التحقق الكامل، مع خيار Static-only صريح.
- توثيق أخطاء فك الحزمة وسياسة Execution Policy وParent Baseline.

### القرار

هذه النسخة هي الأساس الرسمي للتطوير اللاحق بعد نجاح التثبيت والتحقق المحلي. يبقى قبول Runtime النهائي معلقاً حتى اجتياز:

```text
flutter pub get
flutter analyze
flutter test
flutter build web
Browser UAT
```


---

## 21. Flutter Runtime Validation — 2026-07-14

تم اجتياز بوابات Runtime محلياً على:

```text
Flutter 3.44.1
Dart 3.12.1
```

### النتائج

```text
STATIC_SOURCE_CONTRACT=PASS
FLUTTER_PUB_GET=PASS
FLUTTER_ANALYZE=PASS
FLUTTER_TEST=PASS
FLUTTER_BUILD_WEB=PASS
PAL_EYES_RUNTIME_CHECKS=PASS
```

### الإصلاحات المدمجة

- `intl: 0.20.2`.
- مواءمة أداة التحقق مع `intl 0.20.2`.
- إصلاح `places_screen.dart`.
- استبعاد `backups/**` من التحليل.

### الحالة

Runtime تقنياً صالح للبناء والاختبار. بوابة القبول المتبقية:

```text
BROWSER_UAT=PENDING
```

ولا توجد قاعدة بيانات حية أو نشر إنتاجي أو محتوى تاريخي معتمد.


---

## 22. Initial Browser UAT Acceptance — 2026-07-14

تم تشغيل الموقع بنجاح على Chrome وإثبات الصفحة الرئيسية العربية RTL بصرياً.

```text
INITIAL_BROWSER_UAT=PASS
FULL_ROUTE_UAT=PENDING
MOBILE_UAT=PENDING
DARK_MODE_UAT=PENDING
SUPABASE_ENABLED=FALSE
```

تمت ترقية Baseline إلى:

`PAL_EYES_INITIAL_BROWSER_UAT_ACCEPTED_R1_0_2_20260714`

## 23. التوجيه الحاكم للتطوير القادم

كل Mega Batch قادم يجب أن يدمج:

```text
Operational Product Value
+ UI/UX Development
+ Required Governance
+ Tests and Evidence
```

لا تُنفذ حوكمة فقط إلا عند وجود ضرورة أمنية أو سيادية أو Blocker واضح.

الدفعة التالية:

`MEGA_BATCH_PAL_EYES_OPERATIONAL_PLACE_DISCOVERY_DOCUMENTATION_AND_REVIEW_V1`


---

## 24. UI/UX Productive Surfaces and Grouped Navigation — 2026-07-14

تم بناء `MEGA_BATCH_PAL_EYES_UI_UX_PRODUCTIVE_SURFACES_AND_GROUPED_NAVIGATION_V1`.

### العقود الجديدة

```text
PUBLIC_SHELL=SEPARATE
WORKSPACE_SHELL=GROUPED_SIDEBAR
GOVERNANCE=ISOLATED_UNDER_ADMIN_GOVERNANCE
DRAFT_CONTENT_VISIBLE_DURING_DEVELOPMENT=TRUE
AUTOMATIC_PUBLICATION=BLOCKED
```

### المحتوى الظاهر

تظهر مواد برك سليمان وسبسطية وتل السلطان داخل صفحات الموقع والخريطة
والخط الزمني والمصادر، مع وسم «مسودة خاضعة للتدقيق».

### المرحلة التالية

```text
LOCAL_FLUTTER_ANALYZE_TEST_BUILD=PENDING
DESKTOP_ROUTE_UAT=PENDING
MOBILE_UAT=PENDING
DARK_MODE_UAT=PENDING
```


---

## 25. Compile Hotfix R2.0.1 — 2026-07-14

تم إصلاح Compile blockers في `PAL_EYES_UI_UX_PRODUCTIVE_SURFACES_COMPILE_HOTFIX_V1`:

```text
HOME_CONST_CONSTRAINED_BOX=FIXED
PLACE_CONST_CONSTRAINED_BOX=FIXED
EVIDENCE_NOTE_UNTERMINATED_STRING=FIXED
NULL_AWARE_TRAILING=FIXED
STATIC_REGRESSION_GATE=PASS
```

بوابات Flutter المحلية ما زالت مطلوبة قبل اعتماد Baseline.


---

## 26. Null-aware Collection Element Syntax Hotfix — 2026-07-14

تم تصحيح عنصر `trailing` داخل قائمة Widgets إلى الصيغة الصحيحة:

```dart
?trailing,
```

المرشح الناتج:

```text
PAL_EYES_UI_UX_PRODUCTIVE_SURFACES_COMPILE_HOTFIX_R2_0_2_20260714
```

يبقى القبول النهائي معلقاً على بوابات Flutter المحلية.


---

## 27. Full Draft Site Catalog, Source Registry and Governorate Coverage — 2026-07-14

تم تنفيذ `MEGA_BATCH_PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_V1` لمعالجة اختزال الوثيقة في ثلاثة مواقع.

### التغطية الناتجة

```text
SITE_CATALOG=79
EXPANDED_NARRATIVE_DRAFTS=47
DRAFT_SOURCE_REGISTRY=79
GOVERNORATE_COVERAGE=16
MAPPED_COORDINATES=3
COORDINATE_GAPS=76
GOVERNORATE_EXTRACTION_GAPS=2
```

### العقود

```text
ALL_EXTRACTED_CONTENT_VISIBLE_DURING_DEVELOPMENT=TRUE
ALL_CONTENT_MARKED_AS_DRAFT=TRUE
SOURCE_VERIFICATION_REQUIRED=TRUE
UNVERIFIED_COORDINATES_NOT_INVENTED=TRUE
APPROVED_CONTENT=0
PUBLISHED_CONTENT=0
AUTOMATIC_PUBLICATION=BLOCKED
```

### المنتجات

تم تحديث الصفحة الرئيسية والاستكشاف والمواقع والتفاصيل والخريطة والخط
الزمني والمحافظات والمصادر ومساحة العمل. أضيفت ملفات JSON محلية للمحتوى
ودليل استخراج واختبارات للعقود الكمية.

### القبول

التحقق الساكن ناجح. تبقى بوابات Flutter وUAT المحلية معلقة.


---

## 28. Extension Import Alignment Compile Hotfix — 2026-07-14

تم إصلاح نطاق استيراد `DraftContentProfileX` وإزالة استيرادين غير
مستخدمين. لم تتغير أعداد المحتوى:

```text
SITES=79
EXPANDED_NARRATIVES=47
SOURCES=79
GOVERNORATES=16
```

المرشح الناتج: `PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_1_20260714`.


---

## 29. Test Contract and Draft Banner Alignment — 2026-07-15

تم إصلاح عقدي الاختبار بعد نجاح Analyzer:

```text
SEBASTIA_CANONICAL_LABEL=سبسطية (شمرون)
TELL_ES_SULTAN_CANONICAL_LABEL=تل السلطان (أريحا القديمة)
NAME_ASSERTION_MODE=QUALIFIER_AWARE_PREFIX
HOME_DRAFT_BANNER=مسودة خاضعة للتدقيق
```

لم تتغير بيانات الكتالوج. المرشح الناتج: `PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_2_20260715`.


---

## 30. Home Draft Banner Smoke Identity — 2026-07-15

```text
HOME_BANNER_LOCATION=FIRST_HERO_SURFACE
HOME_BANNER_KEY=home-governed-draft-banner
SMOKE_TEST_ASSERTION=BY_KEY
REPEATED_LABEL_ALLOWED=TRUE
```

Candidate: `PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_R3_0_3_20260715`.


---

## 31. Immersive Public Experience and Unified Product Surfaces — 2026-07-15

تم تنفيذ `MEGA_BATCH_PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_V1` لتثبيت هوية بصرية وسردية موحدة على المشروع كله.

### المبدأ

> الخريطة ليست خلفية للموقع، بل هي بوابة السرد.

### شاشة البداية

```text
OPENING_HERO=PALESTINE_TOLD_FROM_PLACE
SEARCH=SITE_CITY_VILLAGE_PERIOD_SOURCE
MAP_GATEWAY=ENABLED
EDITORIAL_STORIES=ENABLED
CATEGORY_DISCOVERY=ENABLED
VISUAL_TIMELINE=ENABLED
SITE_OF_THE_DAY=ENABLED
EVIDENCE_JOURNEY=ENABLED
ORAL_MEMORY=ENABLED
COMMUNITY_CONTRIBUTION=ENABLED
```

### الصفحات

تم توحيد التصميم على الواجهة العامة ومساحة العمل والإدارة والحوكمة من
خلال `PalEyesPageHero` وPublic/Workspace shells ونظام البطاقات الجديد،
مع إعادة تصميم متخصصة للرئيسية والخريطة والقصص والمنهجية والمساهمة
ولوحة العمل وبطاقات المواقع.

### الحدود

```text
CONTENT_DATA_MUTATION=NONE
DATABASE_MUTATION=NONE
SUPABASE_SCHEMA_APPLY=NONE
AUTOMATIC_PUBLICATION=BLOCKED
```

Candidate: `PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_0_20260715`.


---

## 32. Format-aware R4 apply and Material boundary repair

```text
TARGET=PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_1_20260715
FORMATTED_LOCAL_PREIMAGE=ACCEPTED
LIST_TILE_MATERIAL_BOUNDARIES=REPAIRED
R4_0_0_APPLIED=FALSE
R4_0_1_REQUIRED=TRUE
```


---

## 33. Analyzer cleanup and lazy Home test — 2026-07-15

```text
TARGET=PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_2_20260715
ANALYZER_INFO_FIXES=2
HOME_LAZY_SECTION_KEYS=2
IMMERSIVE_TEST_SCROLL_CONTRACT=ENABLED
VISUAL_DESIGN_CHANGE=NONE
```


---

## 34. Compact visual-card overflow closure — 2026-07-15

```text
TARGET=PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_R4_0_3_20260715
OVERFLOW_PIXELS=4
AFFECTED_CARDS=3
SHARED_COMPONENT_REPAIR=TRUE
DEDICATED_WIDGET_TEST=TRUE
VISUAL_DIRECTION_CHANGE=NONE
```


## R5.1.0 — Governed Content Adoption

57 governed draft pages and 22 limited research pages now use the historically reviewed Arabic editorial baseline and governed source registry. Held claims remain in the research workspace. Public map coordinates, database import, unapproved media and publication remain blocked.
