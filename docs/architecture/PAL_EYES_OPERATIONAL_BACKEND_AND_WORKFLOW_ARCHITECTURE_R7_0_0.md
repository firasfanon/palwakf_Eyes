# معمارية الخلفية التشغيلية المحكومة — R7.0.0

```yaml
project_id: pal_eyes
baseline: PAL_EYES_GOVERNED_OPERATIONAL_BACKEND_AND_WORKFLOW_ACTIVATION_R7_0_0_20260719
status: BUILT_PENDING_LOCAL_AND_STAGING_UAT
```

## القرار المعماري

تعمل المنصة بنمط هجين:

```text
SUPABASE_CONFIGURED + MIGRATION_APPLIED
→ pal_eyes schema + RLS + persistent audit

SUPABASE_DISABLED
→ governed in-memory fallback seeded from the accepted local baseline
```

لا تستخدم الواجهة مفتاح `service_role`. كل عمليات Supabase تمر عبر المستخدم
المصادق عليه وRLS. لا توجد كتابة من المستخدم المجهول.

## دورة العمل

```text
Source intake
→ metadata and rights review
→ site/claim linking
→ claim research
→ editorial draft and version
→ human review decision
→ GIS/media/rights gates
→ frozen release candidate
→ PUBLICATION BLOCKED
```

## جداول التشغيل

- sites, site_names, site_relationships
- original_draft_layers, editorial_records, content_versions
- sources, source_representations, site_source_links
- claims, claim_evidence_links, timeline_events
- coordinate_candidates
- media_assets, media_rights
- review_tasks, review_decisions
- release_candidates, audit_events, user_roles

## الحدود

- المادة الأصلية غير موجودة في أي Public View.
- الإحداثيات المرشحة محجوبة عن الخريطة العامة.
- الوسائط الجديدة تبدأ بحقوق محجوبة.
- مرشح الإصدار ليس نشراً.
- تطبيق قاعدة البيانات على Production غير معتمد.
