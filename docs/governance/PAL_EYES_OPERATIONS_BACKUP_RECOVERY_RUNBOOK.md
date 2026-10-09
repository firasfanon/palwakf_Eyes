# بعيون فلسطينية — Staging / Backup / Recovery Security Runbook

## Status (2026-10-09)

Hosted Staging exists but migration preflight remains in PREFLIGHT_HOLD.

- Sovereign main SHA: bb3c58c24103dda1b058b8016ef1ccfe42239a76.
- Accepted candidate SHA: 1dfb308f243ac53e0524e3ac2c7a9a9b144e5c01.
- Repair branch: task/pal-eyes-staging-p0-hardening-v1, isolated from accepted candidate and main.
- Supabase org: Futuer_IT / iffwrnhqiwyallmkceca / Free.
- Supabase staging: esojldjeisjgzievhgyj / ACTIVE_HEALTHY / Sydney / PostgreSQL 17.
- Applied migrations: 0. No user-created application tables.
- GitHub environment: pal-eyes-staging, exact repair-branch deployment policy, admin bypass disabled.
- Required reviewers: NOT configured; nominate a distinct approved reviewer if GitHub plan/features permit.
- Environment secrets: NONE; fail-closed until configured.
- Hosted Staging SQL apply: NOT AUTHORIZED, NOT EXECUTED.

## 1. Exact target and protection

Only esojldjeisjgzievhgyj may be connected, queried, backed up, dry-run or eventually migrated under separately authorized operations. Never use or mutate the waqf and manasakna databases.

Verified GitHub environment variables:
- PAL_EYES_STAGING_PROJECT_REF = esojldjeisjgzievhgyj
- PAL_EYES_FORBIDDEN_PROJECT_REFS = nghxemiygpjywkodrdwx,lyeryfsrhrxuepuqepgi,kzcpnyvrgxphgbwhyntr
- PAL_EYES_STAGING_SQL_APPLY_ALLOWED = false
- PAL_EYES_STAGING_BACKUP_AGE_RECIPIENT = NOT YET CONFIGURED

Unconfigured environment secrets required only for later separately authorized execution:
- SUPABASE_ACCESS_TOKEN: credential for independent Futuer_IT staging account only.
- SUPABASE_STAGING_DB_PASSWORD: only the isolated staging database password.
- SUPABASE_STAGING_PROJECT_REF: exact staging project reference; rechecked against fixed hardcoded allowlist and GitHub variable.

Configure secrets only through the GitHub protected environment UI or a controlled credential manager. Never paste values into chats, code, git files, terminal logs, Drive or artifacts. Read back secret names only.

## 2. Encryption and recoverability

Before uploading any backup, workflow installs age on a pinned Ubuntu runner, writes plaintext backups inside runner temporary storage, encrypts the archive with an offline-owned age PUBLIC recipient, and uploads ONLY encrypted restore.tar.age plus encrypted-file SHA256SUMS (7-day retention). Plaintext backup files are removed in a shell EXIT trap.

Owner must generate and securely retain the age PRIVATE identity outside GitHub, on a protected workstation or approved vault. Never supply the private identity to CI. Configure only public age1... recipient as PAL_EYES_STAGING_BACKUP_AGE_RECIPIENT GitHub environment variable.

A real decryption and restoration test in an isolated environment remains REQUIRED before claiming recovery readiness. Merely uploading encrypted artifacts does not satisfy this gate.

## 3. Workflow security and execution boundaries

The hardened workflow is .github/workflows/supabase_staging_migrations.yml on the isolated repair branch. It:
1. Allows workflow_dispatch only, defaults apply to false, requires STAGING_ONLY confirmation.
2. Rejects any ref, organization, branch or status mismatch before database access.
3. Requires nonempty exact positive allowlist and forbidden-project registry; blocks all previously known other-project refs.
4. Validates source ancestry, migration ordering, checksums and rollback-file presence.
5. Avoids interpolating untrusted workflow inputs into bash commands.
6. Encrypts backup before artifact upload. Never uploads raw schema.sql or data.sql.
7. Uses set -euo pipefail on critical steps.
8. Requires separate apply=true operator phrase and PAL_EYES_STAGING_SQL_APPLY_ALLOWED=true (CURRENTLY FALSE).

IMPORTANT: The workflow exists only on a non-default branch. Manual workflow registration and execution from the GitHub default branch have NOT been proven. Any default-branch admission needs an independent merge authorization, not given here.

## 4. Test and evidence ledger

- Static YAML and fail-closed security probes: 15/15 PASS.
- Synthetic no-network bash behavior probes: 8/8 PASS (no hosted database contact).
- Hosted Staging migration, hosted auth/RLS/CRUD E2E, actual encrypted backup/restore: NOT EXECUTED.
- GitHub environment: branch allowlist exact, admin bypass=false, variables set, secrets absent and reviewer pending.
- Production data mutation: NO.
- Sovereign baseline promotion: NO.
- main merge: NO.
- Production deployment and publication: NO.

## 5. Next governed actions

1. Review security repair branch, tests and evidence; keep source candidate immutable.
2. Owner nominates separate trusted GitHub reviewer if possible, then configure environment protected reviewers and read back.
3. Owner securely establishes age keypair and retains private identity offline; publish public recipient into GitHub environment variables only.
4. Configure account-scoped Supabase secrets inside GitHub environment without exposing values.
5. Obtain explicit separate approval for preflight/dry-run on hosted staging.
6. Obtain another separate approval before ANY migration SQL apply.
7. After approved apply, run real Staging auth/MFA/RLS/CRUD tests and recoverability proof; keep public content and production release blocked.
END RUNBOOK
