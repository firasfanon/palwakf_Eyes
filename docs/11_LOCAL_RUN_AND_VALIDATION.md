# التشغيل والتحقق المحلي

## المتطلبات

- Flutter 3.38 أو أحدث.
- Dart 3.10 أو أحدث.
- Chrome لتشغيل Flutter Web.
- Python 3 لأداة التحقق الساكن.

## تحقق كامل

```powershell
cd C:\Path\To\PAL_EYES_FLUTTER_RUNTIME_FOUNDATION_R1_0_0_20260713

.	ools\Invoke-PalEyesRuntimeChecks.ps1 `
  -ProjectRoot "." `
  -BuildWeb
```

## تشغيل محلي دون Supabase

```powershell
.	ools\Run-PalEyesChrome.ps1 -ProjectRoot "."
```

## تشغيل مع إعداد قراءة Supabase لاحقاً

```powershell
.	ools\Run-PalEyesChrome.ps1 `
  -ProjectRoot "." `
  -SupabaseUrl "https://PROJECT.supabase.co" `
  -SupabasePublishableKey "PUBLIC_PUBLISHABLE_KEY"
```

لا تستخدم `service_role` أو أي مفتاح سري في Flutter.

## أوامر يدوية

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web
flutter run -d chrome --target lib/main.dart
```
