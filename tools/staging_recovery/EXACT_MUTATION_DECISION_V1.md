# PAL_EYES — exact separate mutation decision V1 (NO AUTHORIZATION IMPLIED)

Current reference before proposal commit: task branch
`task/pal-eyes-research-product-completion-v1` at
`a23dfc450c50d6125427fd21195f9e2ac397e08b`.
Production/main head `fb45893e15815b614c6e68c0bd28daff60186646` unchanged.

**Decision requested, NOT granted:** after (a) recoverable encrypted backup +
isolated restore PASS and (b) independent review, authorize once on exact live
state the bounded change in `legacy_public_research_repair_CANDIDATE.sql` ONLY.

Preconditions:
- Free-plan Staging remains `ACTIVE_HEALTHY`, no published manifest/site,
  zero legacy view rows; exact definition MD5
  `9d934935cd0891caf9e171ce1e994afe`, current task SHA unchanged.
- Anon has no direct underlying-table SELECT; authenticated has required grants.
- Separate decision accepts old anonymous endpoint change from HTTP 200/empty to
  403/permission-denied. Verify no outside consumers or provide replacement.
- Encrypted backup SHA, isolated restore readback, extension and role support
  independently accepted. Postgres 17 migration executor scoped, recorded.
- Only one controlled apply. No automatic retry.

Exact proposed database mutation (NOT RUN):
1. `REVOKE SELECT ON pal_eyes.public_research_v1 FROM PUBLIC, anon;`
2. `ALTER VIEW pal_eyes.public_research_v1 SET (security_invoker=true, security_barrier=true);`
Preflight and postflight guards in SQL proposal are part of the required one
transaction. No unrelated table, role, source, MFA, storage, production change.

After authorized apply, mandatory readback:
- legacy view: invoker=true, barrier=true; anon SELECT=false;
- existing authenticated view rights preserved; no direct anon base-table grants;
- newer `public_research_previews_v1` unchanged, 0 current public rows;
- source counts and rights states unchanged;
- advisory Security Definer View ERROR gone;
- anonymous HTTP old endpoint 403 is *expected and separately acknowledged*;
- independent negative tests for SECURITY DEFINER helper and role/rights flows.

If precondition fails, do NOT apply. If postflight fails, transaction rollback
occurs; never 'repair' by giving anon SELECT on underlying drafts. A
return to the original SECURITY DEFINER view is not an allowed automatic rollback.

Other separate decisions, NOT combined with SQL authorization:
- authorize bounded **read-only data export** using approved backup credentials,
  encryption and isolated restore; prevent changing source database;
- approve real synthetic/test-user MFA enrollment and authenticated/editor
  testing only after explicit account authority; never insert fake JWT/AAL2;
- decide password-protection security setting separately;
- preserve 11 research-source linkage gaps and scholar signoff as HOLD.

`STAGING_LIVE_ACCEPTANCE=HOLD`
`MAIN_MERGE=NO`
`BASELINE_PROMOTION=NO`
`PRODUCTION_RELEASE=NO`
`FINAL_MOBILE_BROWSER_UAT=DEFERRED_BY_OWNER`
