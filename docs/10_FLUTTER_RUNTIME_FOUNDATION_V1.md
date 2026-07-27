# Flutter Runtime Foundation V1

## الدفعة

`MEGA_BATCH_PAL_EYES_FLUTTER_RUNTIME_FOUNDATION_V1`

## التاريخ

2026-07-13

## الهدف

إنشاء أول Runtime Flutter Web فعلي فوق Baseline R0.2.0 دون اتصال إلزامي بقاعدة البيانات ودون نشر محتوى تاريخي.

## ما أُنشئ

- `pubspec.yaml` و`analysis_options.yaml`.
- نقطة التشغيل `lib/main.dart`.
- ProviderScope وRiverpod 3.
- GoRouter وShell متجاوب.
- RTL/i18n عربي/إنجليزي محلي.
- Theme أزرق/ذهبي وأحمر ملكي `#B22222`.
- صفحات: الرئيسية، الاستكشاف، المواقع، التفاصيل، الخريطة، الخط الزمني، المحافظات، القصص، المصادر، المساهمة، المنهجية، الباحث، الإدارة.
- `flutter_map` مع OpenStreetMap attribution.
- Supabase bootstrap اختياري عبر `--dart-define`.
- بيانات مكانية تجريبية موسومة `قيد البحث / غير منشور`.
- اختبارات Smoke وعقد المسارات.
- أدوات PowerShell وStatic verifier.

## الحدود

```text
SUPABASE_REQUIRED=FALSE
DATABASE_WRITE=NONE
SQL_MIGRATIONS=NONE
PRODUCTION_DEPLOYMENT=NONE
HISTORICAL_PUBLICATION=NONE
ADMIN_WRITES=DISABLED
CONTRIBUTION_SUBMIT=DISABLED
```

## ملاحظة بيئة البناء

بيئة إنشاء الحزمة لا تحتوي Flutter/Dart، لذلك لم يُنفذ فيها `pub get/analyze/test/build`. تم تنفيذ Static Source Contract، وتوجد أوامر Windows لتشغيل البوابات محلياً.
