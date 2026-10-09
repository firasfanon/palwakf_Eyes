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

MIGRATIONS=()
if [ "${1:-}" = "--baseline-only" ]; then
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

"${PSQL[@]}" -d "$DB" -q -f "$ROOT/tools/rls_boundary/rls_boundary_tests.sql" | tee "${RLS_REPORT:-/dev/null}"

FAILED=$("${PSQL[@]}" -d "$DB" -tAc "select count(*) from rls_test.results where not passed")
TOTAL=$("${PSQL[@]}" -d "$DB" -tAc "select count(*) from rls_test.results")
echo "RLS_BOUNDARY_TOTAL=$TOTAL"
echo "RLS_BOUNDARY_FAILED=$FAILED"
[ "$FAILED" = "0" ]
