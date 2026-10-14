# PAL_EYES — Staging live acceptance: read-only preflight (2026-10-15)

Project: `esojldjeisjgzievhgyj` (Pal_Eyes), Supabase `ap-southeast-2`, PostgreSQL 17.11.
GitHub task head at check: `dce0f1fba738303ada2b9ede879594c3a80ff87a`.
GitHub main: `fb45893e15815b614c6e68c0bd28daff60186646` (unchanged).

## Migration reconciliation — IMPORTANT PREVIOUS STATE CORRECTION

Supabase live migration history **already includes**:
- `20261011212441` / `202610120005_pal_eyes_review_task_idempotency_v1`
- `20261011220826` / `202610120006_pal_eyes_draft_research_normalization_and_review_preview_v1`
- `20261012202243` / `202610120007_pal_eyes_dual_research_preview_visibility_v1`

Earlier reports describing 0006/0007 as **UNAPPLIED** are obsolete for the live Staging state.
Do not re-apply or reset these migrations. Existing history does **not** by itself establish
who applied them, when the external authorization occurred, or backup safety.

## Verified live Postgres read-only results

- Sites: 80 total, 79 bearing exact canonical site Git blob `ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c`.
- Sources: 79 bearing exact source Git blob `285a708df8423cf57fcdbaa88afcb15931dfd6e7`.
- 47 normalized narratives, 189 sections, 248 paragraphs, 79 packages and 79 source-site mentions.
- Comparison against original site metadata: section mismatches = **0**, paragraph mismatches = **0**.
- Comparison against original source registry site slugs: source-link mismatches = **0**.
- Orphan narratives, sections, paragraphs, source links = **0**.
- 11 source rows have no site link, unchanged; no fabricated links.
- Normalization audit-event ID `audit-draft-normalization-v1` occurs once.
- 47 preview control records; requested_visible = **0**; public projection rows = **0**;
  public research preview view rows = **0**.
- Non-BLOCKED or scholarly_verified narrative rows = **0**.
- Source links moved out of PENDING_HUMAN_REVIEW or BLOCKED = **0**.
- Source identity VERIFIED = **0**, rights CLEARED = **0**.
- Existing approved publication manifests = **0**; published sites = **0**.
- Narrative, section, paragraph, control and public projection tables: PostgreSQL RLS enabled and forced.
- `public_research_previews_v1` is `security_invoker=true, security_barrier=true`.

## Read-only access simulation

A `BEGIN TRANSACTION READ ONLY; SET LOCAL ROLE anon` database test returned
zero public-preview rows and zero public-projection rows. Attempts to SELECT draft
narratives and preview control tables failed with PostgreSQL SQLSTATE **42501**.
A role switch to `authenticated` without an authenticated user identity returned
zero protected draft rows. These are DB role-level tests, **not** a complete real
HTTP Data API test, session authentication test, or end-to-end browser UAT.

## Blocking safety and readiness findings

1. **SECURITY HOLD:** The Supabase Security Advisor reported one EXTERNAL ERROR:
   legacy `pal_eyes.public_research_v1` is a SECURITY DEFINER view. `anon`
   currently has SELECT on this view, while it has no direct SELECT on
   `pal_eyes.sites` or `pal_eyes.publication_manifests`; a blind change to
   SECURITY INVOKER could therefore break future public reads. Currently the
   view returns zero rows, but this does not cure the architectural defect.
   Prepare and separately authorize a guarded repair with replacement public
   projection and regression proof, or a scoped access revocation if accepted.
2. **SECURITY REVIEW REQUIRED:** Supabase Advisor reported an anonymously callable
   SECURITY DEFINER helper `research_preview_is_public_v1`; the candidate
   intentionally returns only a public boolean, but security review and negative
   RPC regression are required. Authenticated SECURITY DEFINER RPC notices and
   leaked password protection disabled require separate risk disposition.
3. **BACKUP HOLD:** Supabase organization `Futuer_IT` reports plan `free`.
   No usable recent encrypted backup and tested restore point was independently
   verified. Supabase documents daily backups as a Pro/Team/Enterprise entitlement;
   a Free project should not be considered rollback-ready without an independently
   verified export or other proven recovery mechanism.
4. **AUTHENTICATED EDITORIAL UAT HOLD:** A real bounded editor/reviewer user session
   with role enforcement, MFA and browser actions was not exercised.
5. **ANON HTTP UAT HOLD:** An attempted direct anonymous HTTP read through a local
   execution channel was rejected by the tool security gate. No bypass, retry,
   or equivalence claim; PostgreSQL role-level checks above are the evidence.
6. **HUMAN SCHOLARLY REVIEW HOLD:** The 79 links are unverified, 11 sources remain
   unlinked; no evidence of independent human source/rights acceptance.
7. **FINAL MOBILE BROWSER UAT DEFERRED BY OWNER.**

## Decision

`SCHEMA_AND_DATA_RECONCILIATION=PASS`
`NORMALIZATION_POSTFLIGHT=PASS`
`ANON_DB_ROLE_DENIAL=PASS`
`PUBLIC_VISIBILITY=ZERO`
`STAGING_LIVE_ACCEPTANCE=HOLD_SECURITY_BACKUP_AND_REAL_AUTH_UAT`
`MAIN_MERGE=NO`; `BASELINE_PROMOTION=NO`; `PRODUCTION_RELEASE=NO`.

No SQL migration, shared database mutation, role change, public preview action,
Git main merge or publication was performed by this verification run.
