# جاهزية تأسيس Runtime والخطوة التالية

## اسم الدفعة التالية المقترحة

`MEGA_BATCH_PAL_EYES_FLUTTER_RUNTIME_FOUNDATION_V1`

## الهدف

إنشاء أول Runtime Flutter قابل للبناء، مع إبقاء قاعدة البيانات واتصال Supabase خارج التطبيق حتى تثبيت عقود البيئة والأمان.

## نطاق الدفعة

### إنشاء Flutter Foundation

- `pubspec.yaml`
- `analysis_options.yaml`
- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/router/app_router.dart`
- Theme عربي RTL.
- Localizations foundation.
- Riverpod root.
- GoRouter root.
- Web shell.
- صفحات Placeholder حقيقية للمسارات الأساسية.

### البنية

- `core/`
- `features/home/`
- `features/places/`
- `features/map/`
- `features/research/`
- `features/admin/`

### الحزم الأولية

تعتمد الإصدارات بعد التحقق من Flutter الفعلي، وتشمل مبدئياً:

- `flutter_riverpod`
- `go_router`
- `supabase_flutter`
- `flutter_map`
- `latlong2`
- `intl`

### بوابات القبول

- `flutter pub get` ينجح.
- `flutter analyze` بلا أخطاء.
- اختبارات Smoke تنجح.
- `flutter build web` ينجح.
- RTL يعمل.
- المسارات الأساسية قابلة للوصول.
- لا يوجد اتصال كتابة بقاعدة البيانات.
- لا مفاتيح حساسة في المصدر.
- تحديث المرجع الأعلى وChangelog وHandoff.
- Baseline وUpdates-only ZIP.

## ما هو خارج هذه الدفعة

- إنشاء الجداول الحية.
- تطبيق RLS.
- استيراد محتوى تاريخي.
- إعداد مستخدمين حقيقيين.
- نشر Production.
- اعتماد تصميم نهائي كامل.
