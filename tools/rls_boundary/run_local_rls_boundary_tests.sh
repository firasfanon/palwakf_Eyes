#!/usr/bin/env bash
# Runs the PalEyes server-boundary role tests against a THROWAWAY local
# PostgreSQL database. Refuses to run against anything that is not a local
# socket / loopback target. No shared, staging or production database is used.
#
# Usage:
#   PGHOST=/tmp/pg PGPORT=55432 tools/rls_boundary/run_local_rls_boundary_tests.sh [--baseline-only]
#
# --baseline-only applies only the migrations present on accepted main
# (to document pre-existing findings); default applies every migration in
# supabase/migrations in lexical order.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOST="${PGHOST:-/tmp}"
PORT="${PGPORT:-5432}"
USER_NAME="${PGUSER:-postgres}"
DB="pal_eyes_rls_boundary_$$"

case "$HOST" in
  /*|localhost|127.0.0.1|::1) ;;
  *) echo "REFUSED_NON_LOCAL_DATABASE_HOST=$HOST" >&2; exit 2 ;;
esac

MODE="${1:-}"
MIGRATIONS=()
if [ "$MODE" = "--baseline-only" ]; then
  MIGRATIONS=(
    "$ROOT/supabase/migrations/202607190001_pal_eyes_operational_backend.sql"
    "$ROOT/supabase/migrations/202609220002_pal_eyes_research_knowledge_model_v1.sql"
  )
else
  while IFS= read -r file; do MIGRATIONS+=("$file"); done < <(ls "$ROOT"/supabase/migrations/*.sql | sort)
fi

PSQL=(psql -X -v ON_ERROR_STOP=1 -h "$HOST" -p "$PORT" -U "$USER_NAME")

"${PSQL[@]}" -d postgres -qc "create database $DB" >/dev/null
trap '"${PSQL[@]}" -d postgres -qc "drop database if exists $DB" >/dev/null 2>&1 || true' EXIT

"${PSQL[@]}" -d "$DB" -q -f "$ROOT/tools/rls_boundary/supabase_auth_stub.sql" >/dev/null
for migration in "${MIGRATIONS[@]}"; do
  echo "APPLY $(basename "$migration")"
  "${PSQL[@]}" -d "$DB" -q -f "$migration" >/dev/null
done

if [ "$MODE" = "--rollback-cycle" ]; then
  # Seed real governed baseline, fingerprint it, roll back 0004 and 0003,
  # re-apply them, and prove the data is byte-identical.
  for seed in "$ROOT"/supabase/seed/*.sql; do
    echo "SEED $(basename "$seed")"
    "${PSQL[@]}" -d "$DB" -q -f "$seed" >/dev/null
  done
  FP_SQL="select md5(string_agg(t, '|' order by t)) from (
            select 'sites:' || count(*) || ':' || md5(string_agg(id || slug || name_ar || editorial_draft || publication_status || version_number, ',' order by id)) as t from pal_eyes.sites
            union all select 'sources:' || count(*) || ':' || md5(string_agg(id || title || public_release_status, ',' order by id)) from pal_eyes.sources
            union all select 'claims:' || count(*) from pal_eyes.claims
            union all select 'drafts:' || count(*) from pal_eyes.original_draft_layers
            union all select 'editorial:' || count(*) from pal_eyes.editorial_records) f"
  BEFORE=$("${PSQL[@]}" -d "$DB" -tAc "$FP_SQL")
  for down in "$ROOT/supabase/rollback/202610090004_down.sql" "$ROOT/supabase/rollback/202610090003_down.sql"; do
    echo "ROLLBACK $(basename "$down")"
    "${PSQL[@]}" -d "$DB" -q -f "$down" >/dev/null
  done
  MID=$("${PSQL[@]}" -d "$DB" -tAc "$FP_SQL")
  for up in "$ROOT/supabase/migrations/202610090003_pal_eyes_publication_fail_closed_guard.sql" \
            "$ROOT/supabase/migrations/202610090004_pal_eyes_workflow_integrity_and_provenance.sql"; do
    echo "REAPPLY $(basename "$up")"
    "${PSQL[@]}" -d "$DB" -q -f "$up" >/dev/null
  done
  AFTER=$("${PSQL[@]}" -d "$DB" -tAc "$FP_SQL")
  for seed in "$ROOT"/supabase/seed/*.sql; do
    echo "SEED_AGAIN $(basename "$seed")"
    "${PSQL[@]}" -d "$DB" -q -f "$seed" >/dev/null
  done
  RESEED=$("${PSQL[@]}" -d "$DB" -tAc "$FP_SQL")
  echo "FINGERPRINT_AFTER_RESEED=$RESEED"
  SITES=$("${PSQL[@]}" -d "$DB" -tAc "select count(*) from pal_eyes.sites")
  PUBLISHED=$("${PSQL[@]}" -d "$DB" -tAc "select count(*) from pal_eyes.sites where publication_status <> 'BLOCKED'")
  echo "SEED_SITES=$SITES"
  echo "SEED_NON_BLOCKED_SITES=$PUBLISHED"
  echo "FINGERPRINT_BEFORE=$BEFORE"
  echo "FINGERPRINT_AFTER_ROLLBACK=$MID"
  echo "FINGERPRINT_AFTER_REAPPLY=$AFTER"
  if [ "$BEFORE" != "$MID" ] || [ "$BEFORE" != "$AFTER" ] || [ "$BEFORE" != "$RESEED" ] || [ "$PUBLISHED" != "0" ]; then
    echo "ROLLBACK_DATA_INTEGRITY=FAIL"; exit 1
  fi
  echo "ROLLBACK_DATA_INTEGRITY=PASS"
fi

"${PSQL[@]}" -d "$DB" -q -f "$ROOT/tools/rls_boundary/rls_boundary_tests.sql" | tee "${RLS_REPORT:-/dev/null}"

FAILED=$("${PSQL[@]}" -d "$DB" -tAc "select count(*) from rls_test.results where not passed")
TOTAL=$("${PSQL[@]}" -d "$DB" -tAc "select count(*) from rls_test.results")
echo "RLS_BOUNDARY_TOTAL=$TOTAL"
echo "RLS_BOUNDARY_FAILED=$FAILED"
[ "$FAILED" = "0" ]
