# PAL_EYES_FULL_DRAFT_SITE_CATALOG_TEST_CONTRACT_AND_DRAFT_BANNER_ALIGNMENT_HOTFIX_V1

## الحالة السابقة

نجح `flutter analyze` دون Issues، ثم فشل اختباران:

1. اختبار الكتالوج استخدم المطابقة الحرفية `سبسطية`، بينما الاسم
   الفعلي المحفوظ هو `سبسطية (شمرون)`.
2. اختبار Home طلب العنوان الحاكم `مسودة خاضعة للتدقيق`، بينما
   الواجهة استخدمت عنواناً وصفياً مختلفاً.

وكان عقد `تل السلطان` سيواجه العيب نفسه لأن الاسم الفعلي هو
`تل السلطان (أريحا القديمة)`.

## الإصلاح

```text
SEBASTIA_ASSERTION=STARTS_WITH
TELL_ES_SULTAN_ASSERTION=STARTS_WITH
HOME_DRAFT_BANNER=CANONICAL_TITLE
SMOKE_TEST=SCROLL_UNTIL_VISIBLE
REGRESSION_GATE=ADDED
```

## ما لم يتغير

```text
SITES=79
EXPANDED_NARRATIVES=47
SOURCES=79
GOVERNORATES=16
DATABASE_MUTATION=NONE
AUTOMATIC_PUBLICATION=BLOCKED
```
