# ملف توريث جلسة بعيون فلسطينية — R5.1.0

```text
TARGET_BASELINE=PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_0_20260715
BATCH=MEGA_BATCH_PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_V1
PACKAGE_STATUS=BUILT_PENDING_LOCAL_UAT
GOVERNED_DRAFT_PAGES=57
LIMITED_RESEARCH_PAGES=22
EDITORIAL_RECORDS=92
SOURCE_REGISTRY=95
HELD_CLAIMS=211
PUBLIC_MAP_COORDINATES=0
REVIEW_COORDINATES=3
APPROVED_MEDIA_ASSETS=0
DATABASE_IMPORT=BLOCKED
PUBLICATION=BLOCKED
```

## ما تم بناؤه

- اعتماد الكتالوج المرشح R1.0.1 في طبقة بيانات تطوير محكومة.
- عرض الروايات الـ92 المراجعة فقط في 57 صفحة.
- بناء 22 صفحة بحث محدودة لا تعرض الروايات الخام.
- سجل مصادر محكوم من 95 سجلاً مع حالات الحقوق.
- مساحة بحث تعرض الادعاءات المعلقة الـ211.
- حجب الإحداثيات الثلاث عن الخريطة العامة وإبقاؤها للمراجعة.
- حجب جميع الوسائط غير المعتمدة.
- تحديث ذاكرة المشروع والخطة والمتتبع والعقد المستمر.

## التحقق المطلوب محلياً

1. `python tools\verify_governed_content_adoption.py`
2. `python tools\verify_flutter_runtime_foundation_static.py`
3. `flutter pub get`
4. `dart format lib test`
5. `flutter analyze`
6. `flutter test`
7. `flutter run -d chrome --target lib/main.dart`

## UAT المطلوب

- صفحة محكومة تعرض النصوص المراجعة ومصادرها فقط.
- صفحة بحث محدودة تعرض الهوية والفجوات ولا تعرض سرداً تاريخياً خاماً.
- سجل المصادر يعرض حقوق النص والصور والنشر.
- مساحة الباحث تعرض 211 ادعاءً.
- الخريطة العامة تعرض صفر إحداثيات، مع إبقاء 3 إحداثيات في المراجعة.
- لا تظهر صورة أو خريطة غير معتمدة.

## بوابة الاعتماد

لا يصبح الخط الأساسي مقبولاً محلياً قبل نجاح Static Verify وAnalyze وTests وBrowser UAT.
