# MEGA_BATCH_PAL_EYES_FULL_DRAFT_SITE_CATALOG_SOURCE_REGISTRY_AND_GOVERNORATE_COVERAGE_V1

## 1. السبب

كان المرشح السابق يعرض ثلاثة مواقع فقط، رغم أن المسودة المرجعية تحتوي
مصفوفة واسعة للمواقع والمحافظات والمصادر وروايات موسعة. هذه الدفعة
تحول كامل المادة القابلة للاستخراج إلى أسطح منتج مرئية، من دون
اعتبار المسودة مصدراً تاريخياً معتمداً.

## 2. الناتج الكمي

| العنصر | العدد |
|---|---:|
| صفوف المواقع الخام | 79 |
| كتالوج المواقع النهائي | 79 |
| الروايات الموسعة | 47 |
| سجل المصادر | 79 |
| المحافظات | 16 |
| المواقع ذات الإحداثيات | 3 |
| فجوات الإحداثيات | 76 |
| فجوات المحافظات | 2 |

## 3. الأسطح الإنتاجية

- الصفحة الرئيسية تعرض نطاق الكتالوج.
- الاستكشاف: بحث وفلاتر المحافظة والفترة والنوع ومستوى المادة.
- المواقع: عرض تدريجي للكتالوج الكامل.
- صفحة الموقع: الرواية والمصادر وحالة الإحداثيات.
- الخريطة: تعرض المواقع ذات الإحداثيات فقط وتكشف بقية الفجوات.
- الخط الزمني: تصفية وتحميل تدريجي.
- المحافظات: جميع المحافظات، بما فيها الفجوات الصفرية.
- المصادر: سجل مستقل قابل للبحث والتصفية.
- مساحة العمل: مؤشرات ومهام للكتالوج الكامل.

## 4. تصنيف المادة

```text
CATALOG_SUMMARY=DRAFT
EXPANDED_NARRATIVE=DRAFT
SOURCE_REGISTRY=NEEDS_BIBLIOGRAPHIC_VERIFICATION
COORDINATES=NEEDS_GEOSPATIAL_VERIFICATION_UNLESS_EVIDENCED
APPROVED=0
PUBLISHED=0
```

## 5. الفجوات المعلنة

- شمال غزة: لا صفوف مواقع قابلة للاستخراج في المصفوفة.
- دير البلح: لا صفوف مواقع قابلة للاستخراج في المصفوفة.
- 76 موقعاً دون إحداثيات مدققة.

لا تُملأ هذه الفجوات بالتخمين.

## 6. ملفات البذور

- `content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json`
- `content_seed/PAL_EYES_DRAFT_SOURCE_REGISTRY_V1.json`
- `content_seed/PAL_EYES_GOVERNORATE_COVERAGE_V1.json`

هذه ملفات محلية لإظهار المنتج واختباره، وليست Migration ولا كتابة
إلى Supabase.

## 7. بوابات القبول

```text
STATIC_SOURCE_CONTRACT=PASS
FLUTTER_PUB_GET=PENDING
FLUTTER_ANALYZE=PENDING
FLUTTER_TEST=PENDING
FLUTTER_BUILD_WEB=PENDING
DESKTOP_UAT=PENDING
MOBILE_UAT=PENDING
DARK_MODE_UAT=PENDING
MAP_GAP_UAT=PENDING
```
