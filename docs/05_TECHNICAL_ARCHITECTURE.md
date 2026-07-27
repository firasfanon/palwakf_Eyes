# المعمارية التقنية

## Flutter

```text
lib/
├── app/
│   ├── router/
│   ├── theme/
│   └── localization/
├── core/
│   ├── auth/
│   ├── database/
│   ├── errors/
│   ├── network/
│   └── widgets/
├── features/
│   ├── home/
│   ├── discovery/
│   ├── places/
│   ├── narratives/
│   ├── map/
│   ├── timeline/
│   ├── sources/
│   ├── media/
│   ├── oral_history/
│   ├── contributions/
│   ├── account/
│   ├── research/
│   └── admin/
└── main.dart
```

## قواعد Flutter

- `flutter_riverpod.dart` في الملفات الجديدة.
- GoRouter للمسارات.
- لا منطق قاعدة بيانات داخل Widgets.
- Repositories للقراءة والكتابة.
- Services للعمليات المركبة.
- DTO/Domain Models منفصلة.
- معالجة أخطاء موحدة.
- RTL/i18n من البداية.
- لا تعديل لملفات منصة مشتركة دون ضرورة تكاملية أو أمنية.

## Supabase

- Auth للمصادقة.
- PostgreSQL/PostGIS.
- Storage للملفات.
- Edge Functions للعمليات ذات الامتياز.
- RLS لكل جدول.
- RPCs محكومة.
- public wrappers للقراءة العامة فقط.

## التخزين

Buckets مقترحة:

- `pal-eyes-public-media`
- `pal-eyes-source-files`
- `pal-eyes-contribution-uploads`
- `pal-eyes-oral-history`
- `pal-eyes-restricted-evidence`

الأسماء النهائية لا تعتمد قبل جرد المستودع والبيئة الفعلية.
