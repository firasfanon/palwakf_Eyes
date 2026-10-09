# ADR — مصدر الحقيقة البحثي والنسخة التشغيلية

الحالة: **منفّذ على مستوى قاعدة البيانات والاختبارات** (migration `202610090004`).

## القرار السيادي

- `RESEARCH_SOURCE_OF_TRUTH = WORKSPACE_DRIVE` — الأصل السيادي للبحث يبقى في Drive مساحة العمل.
- `OPERATIONAL_CONTENT_STORE = SUPABASE` — Supabase مخزن تشغيلي، لا يحل محل الأصل.

## التنفيذ في المخطط (`pal_eyes.narrative_documents`)

| العمود | الغرض |
|---|---|
| `sovereign_store` (افتراضي `WORKSPACE_DRIVE`) | أين يقيم الأصل |
| `sovereign_file_id`, `sovereign_revision_id`, `sovereign_url` | مرجع الأصل ومعرّف المصدر ونسخته |
| `content_sha256` | البصمة الرقمية للنص المنسوخ |
| `copy_kind` = `REFERENCE_ONLY` \| `FULL_OPERATIONAL_COPY` | مرجع فقط أم نسخة تشغيلية كاملة |
| `derived_from_document_id` | علاقة النسخ/التحرير بين الوثائق |
| `approval_state` = `DRAFT` \| `UNDER_REVIEW` \| `APPROVED_FOR_PUBLICATION` \| `SUPERSEDED` | فصل المسودة عن المعتمد |

قيود مفروضة:

1. **قيد `narrative_documents_copy_provenance`**: أي `FULL_OPERATIONAL_COPY` يجب أن يحمل `sovereign_file_id` و`sovereign_revision_id` و`content_sha256` (64 حرفًا سداسيًا). لا نسخة كاملة بلا أصل وبصمة.
2. **`protect_approved_narrative()`**: الوثيقة المعتمدة للنشر وأقسامها وفقراتها غير قابلة للتعديل (`APPROVED_NARRATIVE_IMMUTABLE`)؛ التعديل يتم بوثيقة جديدة `derived_from_document_id` ثم `SUPERSEDED` للقديمة.
3. الانتقال إلى `APPROVED_FOR_PUBLICATION` يتطلب دور `review_manager` أو `release_manager` أو `system_admin` (`NARRATIVE_APPROVAL_AUTHORITY_REQUIRED`).
4. لا يظهر للعامة إلا ما يمر عبر `public_research_v1`: manifests بحالة `APPROVED_CURRENT` لمواقع `PUBLISHED`. البحث قيد التحقيق مرئي في مساحة العمل/المراجعة حسب RLS، ولا يظهر عامًّا أبدًا.

## الأدلة

- `tools/rls_boundary/rls_boundary_tests.sql` — مجسّات H17–H22 (الواجهة العامة للبحث فارغة، أعمدة المسودة محجوبة عن anon، نسخة كاملة بلا مرجع مرفوضة، نسخة بمرجع Drive مقبولة، اعتماد من باحث مرفوض، فقرة معتمدة غير قابلة للتعديل).
- CI job `rls-boundary` على Postgres 17 + دورة rollback مع ثبات بصمة البيانات.

## ما لم يُنفّذ (ومعزول)

- مزامنة آلية Drive → Supabase تتطلب ربط حساب خدمة Google Workspace بصلاحيات قراءة — **BLOCKED** (صلاحية خارجية غير ممنوحة). الإدخال حاليًا يدوي عبر المحرر مع حقول المرجع.
