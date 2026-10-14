# PAL_EYES — Encrypted backup export and isolated restore authorization decision

**Date:** 2026-10-15. **Project:** `esojldjeisjgzievhgyj`, Staging only.
**Program:** `SEPARATE_PAL_EYES_STAGING_ENCRYPTED_BACKUP_EXPORT_AND_ISOLATED_RESTORE_AUTHORIZATION_DECISION`.
**User scope:** authorize up to one read-only export, encrypt/hash, restore only into
a properly isolated database, verify data and obtain independent acceptance.
**No staging mutation, no security SQL, no automatic retry.**

## Fresh toolchain and connection results — Futuer-IT

- Remote device `Futuer-IT`: ONLINE.
- PostgreSQL source database: Supabase project `esojldjeisjgzievhgyj`,
  region `ap-southeast-2`, server 17.11, `ACTIVE_HEALTHY`.
- A local Windows service named `postgresql-x64-18` is RUNNING.
  Service executable is under `D:\Program Files\PostgreSQL\18\bin\`.
- `pg_dump.exe --version`: **18.6**; `pg_restore.exe --version`: **18.6**;
  `psql.exe --version`: **18.6**. Tools absent from `PATH`, **not** uninstalled.
  PostgreSQL 18 dump client supports source PostgreSQL 17; this does **not**
  prove a restore or portability of privileged Supabase objects.
- `age --version` and `age-keygen --version`: **1.3.2**, available.
- DNS for owner-provided `aws-0-ap-southeast-2.pooler.supabase.com`
  resolved to IPv4 addresses. TCP 5432 CONNECTED.
  `pg_isready` on session pooler port 5432: **accepting connections**, exit 0.
  This is network/protocol readiness only, **not authenticated DB access**.
- `pg_isready` for local `127.0.0.1:5432`: accepting connections.
- One read-only `psql -w` authentication probe on local 127.0.0.1:5432
  as postgres: **FAILED**, SQL client reports `fe_sendauth: no password
  supplied`; exit 2. **No retry**.
- `%APPDATA%\postgresql\pgpass.conf`, `.pg_service.conf`, and
  `PGSERVICE/PGSERVICEFILE/PGPASSFILE` are not configured in the current
  Windows user context. Their absence does not establish that no secure
  credentials exist anywhere; none were accessed or disclosed here.
- Current repository still includes legacy GitHub Actions workflow
  `.github/workflows/supabase_staging_migrations.yml`, restricted to branch
  `task/pal-eyes-staging-p0-hardening-v1`. It does **not** authorize
  the current `task/pal-eyes-research-product-completion-v1` branch.
  Workflow uses protected GitHub environment password and offline-owned age
  recipient; earlier project handoff reports a Session Pooler password
  authentication failure. **Do not rerun it automatically** or bypass its
  branch guard.
- No safely authenticated source-session read-only dump, encrypted backup,
  archive SHA, isolated restore, or target-data readback was executed.

## Gate results

`SOURCE_PROJECT_IDENTITY=PASS`
`POSTGRES_CLIENT_TOOLCHAIN=PASS_PG18_6`
`ENCRYPTION_TOOLCHAIN=PASS_AGE1_3_2`
`IPV4_SESSION_POOLER_DNS_TCP=PASS`
`IPV4_SESSION_POOLER_PG_READY=PASS_UNAUTHENTICATED_ONLY`
`SOURCE_BACKUP_DB_AUTH=NOT_VERIFIED`
`LOCAL_RESTORE_DB_AUTH=FAILED_NO_PASSWORD_SUPPLIED`
`RESTORE_TARGET_ISOLATION=NOT_PROVEN`
`ENCRYPTION_RECIPIENT_CUSTODY=NOT_PROVEN_IN_LOCAL_CONTEXT`
`READ_ONLY_EXPORT=NOT_STARTED`
`ENCRYPTED_ARCHIVE=NOT_CREATED`
`SHA256_ARCHIVE=NOT_CREATED`
`ISOLATED_RESTORE=NOT_EXECUTED`
`INDEPENDENT_RECOVERY_ACCEPTANCE=HOLD`
`SECURITY_SQL_APPLY=DENIED`
`MAIN_MERGE=DENIED`
`BASELINE_PROMOTION=DENIED`
`PRODUCTION_RELEASE=DENIED`

## Exact blocking constraints and next admissible action

**FAIL CLOSED: BACKUP_EXPORT_HOLD_CREDENTIAL_AND_RESTORE_ISOLATION.**
To use the one-time authority without leaking secrets, first establish
an **existing approved protected-credential binding** for exact project-ref,
correct Session Pooler username, verified TLS, and read-only export scope.
Do not request or print a password in chat/command lines. Reconcile prior
`POSTGRES_AUTH_REJECTED` evidence before any new authenticated attempt;
a changed or fixed credential requires a fresh, explicit bounded decision,
not an automatic retry.

Separately prove a **freshly isolated local PostgreSQL restore target** with
its own authorized credentials and no access to the shared original project
databases. The existing local PostgreSQL 18 service is not inherently an
isolated restore destination. Prove cryptographic age **recipient ownership**
and offline recovery key custody before creating a sensitive archive.
No blanket assumption that a schema-only/data-only export covers users,
roles, storage objects, extensions and all restoration dependencies.

If and only if all required gates pass, conduct **one** approved read-only dump
with zero SQL mutations to Staging, immediately age-encrypt it, hash it,
restore to the isolated target and reconcile
`80 sites / 79 sources / 47 narratives / 189 sections / 248 paragraphs /
79 source links / 47 preview controls / 0 public previews`.
Keep evidence separate from research contents and secrets.
A restore into PostgreSQL 18 proves *logical recovery* but is not automatically
full version-17 environment/extension equivalence; document any drift.

## Independent disposition

**Authorization requested/conditionally scoped; EXECUTION NOT ADMITTED.**
The evidence does not prove a recoverable backup or independent restore.
No export was attempted and no automatic retry is authorized.

Relevant documentation:
- https://www.postgresql.org/docs/18/app-pgdump.html
- https://supabase.com/docs/guides/database/connecting-to-postgres
- https://supabase.com/docs/guides/platform/backups
