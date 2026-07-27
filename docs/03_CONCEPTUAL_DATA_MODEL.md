# نموذج البيانات المفاهيمي

## حدود المخططات

- `pal_eyes`: الجداول السيادية.
- `public`: views وRPC wrappers فقط.
- لا جداول تشغيلية سيادية داخل `public`.

## العلاقات الأساسية

```text
governorate 1─* locality
locality 1─* heritage_site
heritage_site 1─* site_name
heritage_site 1─* site_geometry
heritage_site 1─* site_period
heritage_site 1─* narrative_document
narrative_document 1─* narrative_section
narrative_section 1─* narrative_paragraph
narrative_paragraph 1─* historical_claim
historical_claim *─* citation
citation *─1 source
heritage_site *─* source
heritage_site *─* media_asset
heritage_site *─* oral_history_interview
heritage_site 1─* site_condition
heritage_site 1─* site_threat
```

## معرفات أساسية

- UUID داخلي لكل كيان.
- `slug` ثابت للموقع العام.
- `site_code` بشري ثابت.
- `source_code` للمراجع.
- لا تعتمد الأسماء كمفاتيح.

## الحقول الحرجة للموقع

- `id`
- `site_code`
- `slug`
- `primary_name_ar`
- `primary_name_en`
- `locality_id`
- `site_type_id`
- `public_summary_ar`
- `documentation_status`
- `publication_status`
- `sensitivity_level`
- `created_at`
- `updated_at`

## البيانات المكانية

- نقطة أو خط أو مضلع.
- SRID 4326.
- دقة الإحداثيات.
- مصدر الهندسة.
- مستوى الإظهار العام.
- تاريخ التحقق.

## النسخ

كل تغيير منشور يولد:

- نسخة محتوى.
- حدث نشر.
- قرار مراجعة.
- سجل تدقيق.
