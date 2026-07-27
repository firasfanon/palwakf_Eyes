# ملف توريث — الخلفية التشغيلية R7.0.0

```text
TARGET_BASELINE=PAL_EYES_GOVERNED_OPERATIONAL_BACKEND_AND_WORKFLOW_ACTIVATION_R7_0_0_20260719
PARENT_BASELINE=PAL_EYES_PRODUCT_UX_PHASES_1_TO_4_FOUNDATION_R6_0_2_20260719
STATUS=BUILT_PENDING_LOCAL_AND_STAGING_UAT

SITES=79
ORIGINAL_DRAFT_LAYERS=79
SOURCES=95
EDITORIAL_RECORDS=92
CLAIMS=211
SITE_SOURCE_LINKS=144
RELATIONSHIPS=9
COORDINATE_CANDIDATES=4
INITIAL_REVIEW_TASKS=16

LOCAL_FALLBACK_WORKFLOW=ACTIVE_IN_SESSION
SUPABASE_SCHEMA=PREPARED_NOT_APPLIED
RLS=PREPARED
PUBLICATION=BLOCKED
PRODUCTION=NOT_APPROVED
```

## البوابات التالية

1. Apply source package.
2. Static verifiers.
3. dart format, flutter analyze, flutter test.
4. Local workflow UAT: save draft, add source, update claim, review decision,
   coordinate candidate, media registration, release candidate, audit event.
5. Separate staging DB authorization before running the SQL apply script.
