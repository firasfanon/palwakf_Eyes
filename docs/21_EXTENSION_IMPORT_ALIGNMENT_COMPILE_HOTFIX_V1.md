# PAL_EYES_FULL_DRAFT_SITE_CATALOG_EXTENSION_IMPORT_ALIGNMENT_COMPILE_HOTFIX_V1

## العيب

`site_card.dart` استخدم امتداد `DraftContentProfileX` من خلال
`site.contentProfile.icon` و`site.contentProfile.labelAr`، لكنه لم
يستورد ملف الامتداد مباشرة. استيراد `heritage_site.dart` لا يعيد
تصدير imports انتقالياً في Dart.

## الإصلاح

```text
SITE_CARD_DIRECT_EXTENSION_IMPORT=ADDED
PLACES_UNUSED_EXTENSION_IMPORT=REMOVED
WORKSPACE_UNUSED_METRICS_IMPORT=REMOVED
REGRESSION_GATE=ADDED
```

## الحدود

لا تغيير في كتالوج المواقع أو الروايات أو المصادر أو المحافظات.
لا كتابة لقاعدة البيانات ولا نشر تلقائي.
