# Initial Browser UAT Acceptance

## البيانات

| الحقل | القيمة |
|---|---|
| المشروع | `pal_eyes` |
| التاريخ | 2026-07-14 |
| المسار المحلي | `C:\Users\DELL\StudioProjects\Pal_Eyes` |
| Flutter | `3.44.1` |
| Dart | `3.12.1` |
| المتصفح | Chrome |
| Supabase | معطل محلياً |
| الحالة | `INITIAL_BROWSER_UAT_ACCEPTED` |

## ما تم إثباته

- تشغيل `lib/main.dart` على Chrome.
- فتح الصفحة الرئيسية بنجاح.
- واجهة عربية RTL.
- ظهور الشريط العلوي والتنقل الجانبي.
- ظهور Hero والرسالة الرئيسية.
- ظهور بطاقات سطوح العمل.
- ظهور عينات المواقع البحثية.
- لا شاشة حمراء أو استثناء Runtime ظاهر.
- لا Overflow ظاهر في لقطة سطح المكتب.
- رابط Debug Service وDevTools أُنشئ بنجاح.

## التحذيرات غير المانعة

### Viewport

Flutter Web استبدل وسم `meta viewport` الموجود. لم يمنع التشغيل.

### OpenStreetMap

ظهر تحذير `flutter_map` المتعلق بسياسة استخدام خوادم OpenStreetMap العامة. يجب قبل الإنتاج اختيار مزود Tiles مناسب أو عقد استخدام متوافق.

## حدود القبول

هذا القبول لا يثبت بعد:

- جميع المسارات الثلاثة عشر.
- الهاتف الضيق.
- الجهاز اللوحي.
- الوضع الداكن.
- تبديل اللغة.
- تفاعل الخريطة الكامل.
- Console خالياً من كل Warning.
- Production hosting.
- Supabase integration.

## القرار

```text
INITIAL_BROWSER_UAT=PASS
FULL_VISUAL_ACCEPTANCE=NOT_YET_GRANTED
RUNTIME_BASELINE=PROMOTED
NEXT_MODE=PARALLEL_OPERATIONAL_UI_GOVERNANCE_DEVELOPMENT
```
