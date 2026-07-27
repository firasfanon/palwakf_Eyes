# خطة مشروع بعيون فلسطينية — الحالية

```yaml
plan_version: PAL_EYES_ORIGINAL_HISTORICAL_DRAFT_LAYER_AND_DUAL_NARRATIVE_SURFACE_R5_2_1_20260719
updated_at: 2026-07-15
current_phase: GOVERNED_CONTENT_ADOPTION
verification_phase_1: CLOSED_AT_ADOPTION_THRESHOLD
```

## المرحلة الحالية — اعتماد المحتوى في صفحات التطوير

### الهدف

تحويل نتائج البحث والتحقق إلى تجربة منتج قابلة للاستخدام، دون انتظار اكتمال كل الأبحاث اللاحقة.

### المخرجات

| المهمة | النطاق | الحالة |
|---|---:|---|
| ربط سجل المصادر بالمشروع | 95 سجل مصدر/بحث | READY |
| اعتماد السجلات التحريرية | 92 | IMPLEMENTED_PENDING_LOCAL_UAT |
| صفحات مسودة محكومة | 57 | IMPLEMENTED_PENDING_LOCAL_UAT |
| صفحات بحث محدودة | 22 | IMPLEMENTED_PENDING_LOCAL_UAT |
| ربط الادعاء بالمصدر | 92 سجل تحريري | READY |
| شارة المسودة وحالة التحقق | 79 صفحة | REQUIRED |
| بدائل بصرية محايدة | 79 صفحة عند الحاجة | REQUIRED |
| اختبارات عدم عرض الادعاءات المفتوحة | 211 ادعاء | REQUIRED |

## الدفعة الرئيسية التالية

```text
MEGA_BATCH_PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_V1
```

### بوابات النجاح

```text
SITE_IDENTITY_FROM_R1_0_1_CANDIDATE=TRUE
EDITORIAL_RECORDS_ADOPTED=92
GOVERNED_DRAFT_PAGES=57
LIMITED_RESEARCH_PAGES=22
SOURCE_LINKS_RESOLVE=TRUE
HELD_CLAIMS_HIDDEN_FROM_NARRATIVE=TRUE
DRAFT_LABEL_VISIBLE=TRUE
UNAPPROVED_MEDIA_BLOCKED=TRUE
FLUTTER_ANALYZE=PASS
FLUTTER_TEST=PASS
BROWSER_UAT=PASS
DATABASE_WRITE=FALSE
PUBLICATION=BLOCKED
```

## المسارات المتوازية

### A. البحث المستمر

- 211 ادعاءً في Research Backlog.
- الأولوية حسب P0/P1/P2/P3.
- لا توقف صفحات التطوير.
- كل إغلاق جديد يضاف كتحديث تحريري محكوم.

### B. الأدلة الميدانية والقانونية وGIS

- 13 طلباً هندسياً/ميدانياً.
- طلبان قانونيان.
- 6 طلبات هوية وحدود.
- 6 طلبات اكتشاف مصادر.

### C. الوسائط والحقوق

- Submission 001 ينتظر ملفات فعلية.
- لا موافقة تلقائية.
- كل ملف يحتاج SHA-256 وبيانات حقوق.
- يستخدم المشروع placeholders محايدة حتى اعتماد الأصل.

## المراحل اللاحقة

1. مراجعة بشرية على مستوى الصفحة.
2. UAT للمحتوى والروابط وحالات اليقين.
3. مرشح حقوق وسائط على مستوى الملف.
4. مرشح استيراد قاعدة بيانات مستقل.
5. Staging.
6. قرار نشر بشري على دفعات.

## قاعدة تحديث الخطة

تحدث هذه الخطة بعد كل دفعة تغير الأولوية أو عدد الصفحات أو المصادر أو الادعاءات أو الأصول أو الاختبارات.


## تحديث R5.1.0 — تم بناء اعتماد المحتوى

الحالة: `BUILT_PENDING_LOCAL_UAT`.

- 57 صفحة مسودة محكومة.
- 22 صفحة بحث محدودة.
- 92 مادة عربية مراجعة.
- 95 سجل مصدر محكوم.
- 211 ادعاءً في مساحة الباحث.
- 0 إحداثيات عامة و0 وسائط معتمدة.

الخطوة التالية: Apply → Static Verify → Analyze → Test → Chrome UAT.


## R5.2.1 — استعادة المادة التاريخية الأصلية

| المسار | العدد | الحالة |
|---|---:|---|
| طبقات المسودة الأصلية | 79 | IMPLEMENTED_PENDING_LOCAL_UAT |
| الروايات الأصلية الموسعة | 47 | DEVELOPMENT_VISIBLE |
| بطاقات الفهرسة الأصلية | 32 | DEVELOPMENT_VISIBLE |
| الروايات المحكومة | 92 | PRESERVED |
| النشر العام للمسودة الأصلية | 0 | BLOCKED |

البوابة التالية: تطبيق الحزمة، الفحوص الساكنة، `flutter analyze`,
`flutter test`، ثم UAT لصفحة ذات رواية أصلية موسعة وصفحة ذات بطاقة أصلية.

## R7.0.0 — الخلفية التشغيلية المحكومة

| Gate | Scope | Status |
|---|---|---|
| A | schema + RLS + role matrix | BUILT |
| B | seed import + hybrid repositories | BUILT |
| C | site/source/claim/GIS/media/review workflows | BUILT |
| D | versions + audit + release candidate | BUILT |

البوابة التالية: تطبيق المصدر وفحوص Flutter ثم UAT محلي، وبعدها تفويض منفصل لقاعدة staging.

## المرحلة الحالية — Public Experience Maturity R8

### تم البناء

- خمسة مسارات عامة أساسية وأربعة على الهاتف.
- بحث متعدد الأبعاد بخمسة أوضاع وخمسة فلاتر وأربعة ترتيبات.
- أطلس بصري وبطاقات مواقع موجّهة للزائر.
- خريطة عامة تستخدم الإحداثيات المعتمدة فقط.
- مجلة بثلاث قصص و12 فصلاً.
- حالات تحميل وفراغ وخطأ مشتركة.
- دلالات وصول، live regions، وعناوين للصور التجريدية.

### بوابة القبول

1. WhatIf وApply.
2. جميع الفحوص الساكنة.
3. dart format وflutter analyze وflutter test.
4. Browser UAT على سطح المكتب والهاتف.
5. UAT لوحة المفاتيح وتكبير النص وحالات الفراغ والخطأ.
