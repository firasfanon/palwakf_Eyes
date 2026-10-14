-- PAL_EYES: STAGING_SECURITY_BACKUP_AND_AUTH_UAT_INTEGRATED_RECOVERY_V1
-- SOURCE-ONLY CANDIDATE: NOT APPROVED / NOT APPLIED. Requires SEPARATE owner authorization.
-- Chosen boundary: retire anonymous access to the UNSAFE legacy manifest view
-- while preserving the protected authenticated view and current preview API.
-- Intentional contract change: /rest/v1/public_research_v1 anon returns 403
-- instead of the current HTTP 200 + [] until a separately approved, sanitized
-- manifest projection restores backward-compatible public output.
-- DO NOT RUN before confirmed restorable encrypted backup and client review.
BEGIN;
DO $pal_eyes_preflight$
BEGIN
  IF current_setting('server_version_num')::int < 150000 THEN
    RAISE EXCEPTION 'MINIMUM_POSTGRES_15_REQUIRED';
  END IF;
  IF md5(pg_get_viewdef('pal_eyes.public_research_v1'::regclass,true))
       <> '9d934935cd0891caf9e171ce1e994afe' THEN
    RAISE EXCEPTION 'LEGACY_VIEW_DEFINITION_DRIFT';
  END IF;
  IF EXISTS (SELECT 1 FROM pal_eyes.public_research_v1)
     OR EXISTS (SELECT 1 FROM pal_eyes.publication_manifests WHERE publication_status='APPROVED_CURRENT')
     OR EXISTS (SELECT 1 FROM pal_eyes.sites WHERE publication_status='PUBLISHED')
  THEN
    RAISE EXCEPTION 'EXISTING_PUBLIC_CONTENT_REQUIRES_MIGRATION_PLAN';
  END IF;
  IF has_table_privilege('anon','pal_eyes.publication_manifests','SELECT')
     OR has_table_privilege('anon','pal_eyes.sites','SELECT') THEN
    RAISE EXCEPTION 'UNEXPECTED_ANON_BASE_TABLE_GRANT';
  END IF;
  IF NOT has_table_privilege('authenticated','pal_eyes.public_research_v1','SELECT')
     OR NOT has_table_privilege('authenticated','pal_eyes.sites','SELECT')
     OR NOT has_table_privilege('authenticated','pal_eyes.publication_manifests','SELECT')
  THEN
    RAISE EXCEPTION 'AUTHENTICATED_VIEW_DEPENDENCIES_DRIFT';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_class c WHERE c.oid='pal_eyes.public_research_previews_v1'::regclass
                 AND 'security_invoker=true'=ANY(c.reloptions)) THEN
    RAISE EXCEPTION 'SAFE_PUBLIC_PREVIEW_VIEW_NOT_PRESENT';
  END IF;
END;
$pal_eyes_preflight$;
-- The legacy manifest-view HTTP endpoint is intentionally closed to anonymous
-- callers, without granting anonymous access to tables containing original drafts.
REVOKE SELECT ON pal_eyes.public_research_v1 FROM PUBLIC, anon;
ALTER VIEW pal_eyes.public_research_v1
  SET (security_invoker=true, security_barrier=true);
DO $pal_eyes_postflight$
DECLARE v_options text[];
BEGIN
  SELECT reloptions INTO v_options FROM pg_class
  WHERE oid='pal_eyes.public_research_v1'::regclass;
  IF NOT 'security_invoker=true'=ANY(v_options)
     OR NOT 'security_barrier=true'=ANY(v_options)
     OR has_table_privilege('anon','pal_eyes.public_research_v1','SELECT')
     OR NOT has_table_privilege('authenticated','pal_eyes.public_research_v1','SELECT')
  THEN RAISE EXCEPTION 'LEGACY_VIEW_REPAIR_POSTCHECK_FAILED'; END IF;
END;
$pal_eyes_postflight$;
COMMIT;
-- NO AUTOMATIC ROLLBACK TO SECURITY DEFINER. If a release test fails:
-- stop, preserve fail-closed grants, and seek a separate sanitized-view decision.
