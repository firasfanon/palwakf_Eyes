# Session Handoff — Pal_Eyes

## التاريخ

2026-07-13

## الهدف المنجز

بدء المرحلة صفر وإنشاء Baseline تأسيسي مرجعي للمشروع.

## الحالة

```text
PROJECT_ID=pal_eyes
PHASE=PHASE_0_GOVERNANCE_AND_REFERENCE_MODEL
BASELINE_VERSION=0.1.0
SOURCE_MUTATION=NONE
DATABASE_MUTATION=NONE
PRODUCTION_MUTATION=NONE
```

## المرجع الأعلى

`PAL_EYES_PROJECT_COMPREHENSIVE_GUIDE.md`

## ما تم تثبيته

- الرؤية والرسالة.
- الرواية التاريخية كمنتج مركزي.
- فصل الادعاءات والمصادر عن النص.
- Flutter/Dart/Supabase/PostGIS.
- GoRouter/Riverpod/flutter_map.
- schema سيادي `pal_eyes`.
- RBAC وحالات العمل.
- بوابات النشر.
- تحديث المرجع بعد كل Batch/Patch.

## ما لم يتم

- لم يُكتشف المستودع الفعلي.
- لم يتم جرد كود Flutter.
- لم يتم جرد Supabase.
- لم تطبق SQL.
- لم تعتمد مسارات نهائية.
- لم يتم اختيار مواقع Pilot.
- لم يتم نشر محتوى.

## نقطة الاستئناف

الخطوة التالية هي **Repository & Runtime Discovery Read-only**:

1. استلام مسار المشروع أو المستودع الفعلي.
2. فحص هيكل Flutter.
3. تحديد entrypoint وGoRouter.
4. جرد Riverpod والحزم.
5. جرد Supabase schemas/tables/RLS/RPC/Storage.
6. تحديد أحدث baseline قابل للبناء.
7. تحديث المرجع الأعلى بنتائج الجرد.
8. إعداد Batch التأسيس التقني دون تطبيق إنتاجي.

## قيود الاستئناف

- Read-only discovery أولاً.
- لا تعديل قاعدة بيانات دون تفويض صريح.
- لا اختراع مسارات تتعارض مع المشروع.
- لا استخدام نصوص تاريخية غير متحقق منها كمحتوى منشور.
