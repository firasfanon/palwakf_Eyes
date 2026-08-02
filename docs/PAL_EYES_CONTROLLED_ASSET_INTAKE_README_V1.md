# دليل الإدخال المحكوم للوسائط — بعيون فلسطينية

```yaml
batch_id: MEGA_BATCH_PAL_EYES_P0_HELD_CLAIM_RESEARCH_EXECUTION_AND_CONTROLLED_ASSET_INTAKE_V1
candidate_catalog: PAL_EYES_CORRECTED_CANONICAL_CATALOG_CANDIDATE_R1_0_1_20260715
intake_status: OPEN_FOR_CONTROLLED_SUBMISSION
current_submitted_assets: 0
automatic_approval: false
database_import: blocked
publication: blocked
```

## طريقة الاستخدام

1. ضع ملفات الوسائط المراد فحصها في مجلد مستقل دون تعديل ملفات المشروع.
2. أنشئ صفاً منفصلاً لكل ملف في `PAL_EYES_CONTROLLED_ASSET_INTAKE_REGISTER_V1.csv`.
3. املأ `canonical_site_id` و`canonical_slug` من الكتالوج المرشح فقط.
4. احسب SHA-256 لكل ملف وأدخل اسم الملف ونوعه وحجمه.
5. أدخل المنشئ وصاحب الحقوق والترخيص ورابط المصدر ودليل الإذن.
6. لا تستخدم حالة `approved_public` إلا بعد مراجعة بشرية للملف المحدد.
7. الصور والخرائط المأخوذة من صفحة مصدر لا ترث تلقائياً ترخيص نص الصفحة.

## حالات القرار

```text
pending
approved_internal
approved_public
rejected
quarantined
```

## قيود حاكمة

- عدم معرفة صاحب الحقوق يفرض `UNKNOWN_WITH_HOLD`.
- غياب دليل الإذن يمنع الاستخدام العام.
- وجود أشخاص أو ملكيات خاصة أو مواقع حساسة يتطلب مراجعة مستقلة.
- تغيير الحجم أو القص أو المعالجة لا ينشئ حقاً جديداً في الأصل.
- قبول النص التاريخي للموقع لا يعني قبول الصورة المرتبطة بالمصدر.
