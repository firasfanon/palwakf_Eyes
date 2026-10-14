# PAL_EYES | Staging backup, security and authenticated UAT readiness V1

**Scope:** preparation and offline/synthetic acceptance. Read-only live catalog verification only.
**No migration, SQL apply, backup export, privilege change or real UAT session executed.**
Project `esojldjeisjgzievhgyj`; region `ap-southeast-2`; server PostgreSQL 17.
Current main `fb45893e15815b614c6e68c0bd28daff60186646`;
task base `a23dfc450c50d6125427fd21195f9e2ac397e08b`.

## Verified current gates (2026-10-15)

- Staging ACTIVE_HEALTHY; normalization migrations 0006 and 0007 already applied. Never replay.
- Legacy `pal_eyes.public_research_v1` is an anonymously selectable SECURITY DEFINER
  view. Underlying `pal_eyes.publication_manifests` and `pal_eyes.sites` have no
  anonymous direct SELECT. Old view has zero rows because no approved manifests
  or published sites currently exist.
- The safe separate `public_research_previews_v1` is security-invoker/barrier and empty.
- Source drafts: 47 narratives, 189 sections, 248 paragraphs, 79 source-site mentions;
  all rights/identity attestations unverified; 11 sources remain without site links.
- Two confirmed Auth users with two distinct active role holders:
  one `editor`, one `system_admin`. `review_manager` assignments: 0.
- MFA factors: 1 **unverified** TOTP, 0 verified. Therefore an actual `aal2`
  workflow is NOT available/proven. Do not simulate AAL2 by self-attested token.
- Organization is on Supabase `free`; no available encrypted complete export
  with a successful isolated restore was proven. Backup/rollback readiness = HOLD.
- Security Advisor additionally flags intended public boolean SECURITY DEFINER
  RPC `research_preview_is_public_v1` and authenticated privileged RPCs:
  independently test scope, denied calls and no hidden-content oracle.
  Leaked-password protection disabled is a separate security-hardening observation.

## Minimal security repair candidate (not authorized to run)

`legacy_public_research_repair_CANDIDATE.sql` contains live-definition-MD5
preflight, no-published-records preflight, negative anonymous underlying-table grant
checks, safe-view prerequisite, then a bounded **security invoker + security barrier**
change and anonymous SELECT revocation on **only the legacy manifest view**.
Authenticated access remains protected by existing owner/site policies.

**Known compatibility change:** the old anonymous legacy view endpoint changes
from HTTP 200/empty to permission denied; the actual Flutter runtime does not
reference that old view in its Dart code, but an older API E2E contract asserts
HTTP 200/empty and must be revised only upon explicit release-contract approval.
The secure public preview view remains unchanged. Future manifest publication
requires a separate sanitized public projection/read API: never grant anonymous
direct SELECT on originals just to re-enable the legacy view.
Never automatically roll back to SECURITY DEFINER. This source candidate is NOT
a migration; use approved migration tooling only after a separate decision.

## Safe backup procedure (requires separate export authorization)

1. Obtain **current live** Supabase Dashboard Connect credentials and connection
   parameters. Previous direct IPv6 backup failed; on IPv4-only Futuer-IT prefer
   an explicitly verified **Session Pooler** if supported for PostgreSQL dump.
   Do not assume a cached hostname, role password or endpoint is still valid.
2. Inventory available `pg_dump` / `pg_restore` / Supabase CLI version via
   `--version` and `--help`; match server PostgreSQL 17 tooling.
   Those native executables were **not found on PATH** at this preflight.
   Install only through a separately approved installation workflow.
3. Obtain least-privilege backup credentials from the existing protected
   Windows credential provider/DPAPI or a locked service file. Never place a
   password/token in a command line, script, chat message, Git repo or log.
   Require TLS certificate verification, connection scope, correct project ref.
4. Authorize a single consistent **read-only logical export** of exactly the
   required schemas, identities, ownership metadata and migration versions.
   Confirm if permissions exclude Auth, Storage, database roles, extensions or
   secrets; do not label any incomplete dump as a recoverable full backup.
   Example syntax **illustrative only**, not ready to execute:
   `pg_dump --dbname="service=pal_eyes_backup" --format=custom --no-owner --no-acl --file="<protected-local-path>.dump"`.
5. Encrypt using the approved protected workflow; record plaintext and encrypted
   SHA256 separately in non-public evidence; securely retire plaintext after
   cryptographic and restoration checks. Restrict ACLs and store offsite.
6. Restore only into a freshly created **isolated non-Staging** PostgreSQL 17
   target with compatible extensions and owned roles:
   `pg_restore --dbname="service=pal_eyes_isolated_restore" --no-owner --no-acl --exit-on-error "<protected-local-path>.dump"`.
   This is a *template*, not permission to provision a database.
7. Verify restore counts and row integrity (80 sites, 79 sources, 47 narratives,
   189 sections, 248 paragraphs, 79 source mentions, 47 preview controls,
   zero public previews), plus schema, indexes, constraints and roles.
   A successful `pg_restore --list` is **not** a restored-data test.
8. Record exact encrypted-archive SHA256, export timestamp, backup scope,
   tool versions, restore target isolation, restore checks, credentials-retired
   proof and accountable independent reviewer. Without these: `BACKUP=HOLD`.

Supabase documents that scheduled daily backups are available on paid plans and
recommends independent exports for Free:
https://supabase.com/docs/guides/platform/backups
Connection guidance:
https://supabase.com/docs/guides/database/connecting-to-postgres

## Bounded authenticated editorial UAT (prepared, not executed)

Prerequisites: verified recovery evidence; isolated non-production role assignment,
two distinct authenticated test identities, verified MFA/AAL2 for review and show;
signed exact-scope session task, state snapshot and explicit SQL security patch decision.

1. Authenticate an **editor** identity through the real app; prove visible internal
   draft list of 47 and inaccessible governance/admin surfaces.
2. Open a draft, read source Git blob/path and review narrative section order;
   verify original source rows remain BLOCKED and not marked scholarly verified.
3. Perform an explicitly authorized **synthetic** edit in a non-production isolated
   record only; prove version/change audit and readback; no source bibliographic
   identity or rights self-attestation.
4. As a distinct reviewer identity, prove approved/denied actions with real MFA AAL2;
   prevent same-account preparer/reviewer and reject unverified factor.
5. Exercise review/visibility operations only on synthetic isolated data:
   `SHOW_ONE`, `HIDE_ONE`, `SHOW_ALL_ELIGIBLE`, `HIDE_ALL`, selected-set toggle,
   expected-count mismatch, illegal role, lost rights auto-withdraw and idempotence.
   Public production data remains hidden.
6. Prove anonymous HTTP requests cannot retrieve internal drafts, control rows,
   original source metadata or unreviewed narrative text. Test security-invoker
   public preview returns only explicitly approved synthetic excerpts, or zero.
7. Reconcile accounts, audit events, source rights and post-UAT residue to initial
   snapshot. Remove synthetic test data only with scoped explicit authority.
8. Keep final 390px browser UAT **DEFERRED_BY_OWNER**; do not silently promote.

## Independent gate disposition

- `SECURITY_PATCH_DESIGN=OFFLINE_READY_ONLY` (14/14 proposal tests passed)
- `SQL_APPLY=DENIED_PENDING_SEPARATE_OWNER_AUTHORIZATION`
- `BACKUP_AND_ISOLATED_RESTORE=NOT_PROVEN`
- `AUTH_REAL_SESSION_UAT=NOT_EXECUTED`
- `MFA_AAL2=NOT_VERIFIED`
- `ANON_HTTP_UAT=NOT_EXECUTED`
- `HUMAN_SOURCE_REVIEW=HOLD_11_SOURCE_GAPS`
- `STAGING_LIVE_ACCEPTANCE=HOLD_SECURITY_BACKUP_AND_REAL_AUTH_UAT`
- `MAIN_MERGE=NO` `BASELINE_PROMOTION=NO` `PRODUCTION_RELEASE=NO`.
