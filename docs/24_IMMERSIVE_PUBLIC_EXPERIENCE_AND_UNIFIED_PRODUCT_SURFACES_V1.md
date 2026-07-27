# MEGA_BATCH_PAL_EYES_IMMERSIVE_PUBLIC_EXPERIENCE_AND_UNIFIED_PRODUCT_SURFACES_V1

## الهدف

تحويل «بعيون فلسطينية» من واجهات فهرسة عملية إلى تجربة رقمية فلسطينية
متكاملة تجمع الأطلس، السرد البصري، المصدر، الزمن، الذاكرة الشفوية،
والمساهمة المجتمعية ضمن هوية واحدة.

## شاشة البداية

تتضمن الشاشة الرئيسية الجديدة:

1. Hero افتتاحي بعنوان **فلسطين تُروى من المكان**.
2. تنبيه حاكم ثابت للمسودة.
3. بحث مباشر في الموقع والمدينة والقرية والحقبة والمصدر.
4. عمل فني لخريطة فلسطين مع المؤشرات الكمية.
5. بوابة جغرافية للخريطة والمحافظات.
6. قصص تحريرية كبرى وصغرى.
7. استكشاف حسب الفئات.
8. شريط زمني بصري.
9. موقع اليوم.
10. رحلة «المكان ← الرواية ← المصدر ← المراجعة».
11. قسم للذاكرة الشفوية.
12. دعوة للمساهمة المجتمعية.
13. بطاقات مختارة من الكتالوج.

## النظام البصري الموحد

أضيف ملف:

`lib/core/widgets/pal_eyes_visual_system.dart`

ويحتوي:

- `PalEyesBrandMark`
- `PalEyesPattern`
- `PalestineMapArtwork`
- `PalEyesPageHero`
- `PalEyesSectionHeader`
- `PalEyesMetricTile`
- `PalEyesVisualCard`
- `PalEyesGlassPanel`
- `PalEyesTimelineBand`

## الصفحات المتأثرة

### الواجهة العامة

- الرئيسية.
- الاستكشاف.
- المواقع.
- تفاصيل الموقع.
- الخريطة.
- الخط الزمني.
- المحافظات.
- القصص.
- المصادر.
- المساهمة.
- المنهجية.

### مساحة العمل والحوكمة

- Public Shell.
- Workspace Shell.
- لوحة العمل.
- صفحات الأقسام التشغيلية العامة.
- جميع الصفحات المبنية على `PalEyesPage`.
- صفحات الإدارة والحوكمة التي تستخدم البنية العامة نفسها.

## الهوية

```text
SOVEREIGN_BLUE=0B2742
MIDNIGHT=071A2B
HERITAGE_GOLD=C89A4B
OLIVE=596A45
WARM_CANVAS=F6F2E9
ROYAL_RED=A73535
```

الأسلوب المقصود هو مزيج بين:

```text
PALESTINIAN_DIGITAL_ATLAS
+ INTERACTIVE_MUSEUM
+ EVIDENCE_ARCHIVE
+ VISUAL_EDITORIAL_MAGAZINE
```

## ما لم يتغير

- 79 موقعاً.
- 47 رواية موسعة.
- 79 مدخل مصدر.
- 16 محافظة.
- لا تعديل لبيانات المحتوى.
- لا كتابة لقاعدة البيانات.
- لا اعتماد أو نشر تلقائي.

## التحقق

```text
STATIC_CONTRACT=PASS
IMMERSIVE_UI_DESIGN_SYSTEM=PASS
DART_LEXICAL_SCAN=PASS
FLUTTER_PUB_GET=PENDING_USER_ENVIRONMENT
DART_FORMAT=PENDING_USER_ENVIRONMENT
FLUTTER_ANALYZE=PENDING_USER_ENVIRONMENT
FLUTTER_TEST=PENDING_USER_ENVIRONMENT
FLUTTER_RUN=PENDING_USER_ENVIRONMENT
```
