-- PAL_EYES_RESEARCH_PREVIEW_VISIBILITY_V1 / independently reviewed security repair (R2).
-- PROGRAM: PAL_EYES_PREVIEW_SECURITY_AND_FLUTTER_CLOSURE_V1
-- SOURCE CANDIDATE. Isolated synthetic tests only. Staging apply requires a
-- separate owner decision. Production: DENIED.
--
-- Public reads use a sanitized projection + SECURITY INVOKER view. Original
-- research, editorial notes and source assets remain under internal RLS.
--
-- R2 closes findings proven on the R1 candidate (see evidence report):
--   F-01 HIGH   researcher/editor could self-attest sources CLEARED/VERIFIED and
--               links VERIFIED, satisfying the preview rights gate alone.
--   F-02 MEDIUM anon could probe eligibility of hidden items (boolean oracle).
--   F-03 MEDIUM showing / approving public copy needed no second factor (aal2).
--   F-04 MEDIUM requested_visible survived loss of eligibility and silently
--               re-exposed an item when rights were re-cleared.
--   F-05 LOW    identical re-review withdrew a visible item and wrote audit.
--   F-06 LOW    identical copy re-submission reset the independent review.
--   F-07 LOW    audit of a withdrawal did not record the previous visibility.

-- 0. Preflight: definer functions below rely on the owner bypassing FORCE RLS.
DO $preflight$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname=current_user AND (rolbypassrls OR rolsuper))
 THEN RAISE EXCEPTION 'PREVIEW_OWNER_MUST_BYPASS_RLS'; END IF;
 IF (SELECT count(*) FROM pal_eyes.draft_research_narratives_v1 WHERE publication_status='BLOCKED')<>47
 THEN RAISE EXCEPTION 'PREVIEW_PREFLIGHT_EXPECTED_47_BLOCKED_NARRATIVES'; END IF;
END $preflight$;

-- 1. Attestation guard (F-01). Rights clearance, source identity and link
--    verification are separate reviewer authorities; content roles cannot
--    self-attest them through the FOR ALL research_write policy.
CREATE FUNCTION pal_eyes.guard_source_attestation_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER
SET search_path=pal_eyes,pg_temp AS $$
DECLARE v_new jsonb:=to_jsonb(NEW); v_old jsonb;
BEGIN
 IF current_user NOT IN ('authenticated','anon') THEN RETURN NEW; END IF;
 IF TG_OP='UPDATE' THEN v_old:=to_jsonb(OLD); END IF;
 IF TG_TABLE_NAME='sources' THEN
  IF v_new->>'rights_status'='CLEARED'
     AND (v_old IS NULL OR v_old->>'rights_status' IS DISTINCT FROM 'CLEARED')
     AND NOT pal_eyes.has_any_role(ARRAY['rights_reviewer','review_manager','system_admin'])
  THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='SOURCE_RIGHTS_CLEARANCE_AUTHORITY_REQUIRED'; END IF;
  IF v_new->>'identity_status'='VERIFIED'
     AND (v_old IS NULL OR v_old->>'identity_status' IS DISTINCT FROM 'VERIFIED')
     AND NOT pal_eyes.has_any_role(ARRAY['source_reviewer','review_manager','system_admin'])
  THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='SOURCE_IDENTITY_VERIFICATION_AUTHORITY_REQUIRED'; END IF;
 ELSIF TG_TABLE_NAME='site_source_links' THEN
  IF v_new->>'verification_status'='VERIFIED'
     AND (v_old IS NULL OR v_old->>'verification_status' IS DISTINCT FROM 'VERIFIED'
          OR v_old->>'site_id' IS DISTINCT FROM v_new->>'site_id'
          OR v_old->>'source_id' IS DISTINCT FROM v_new->>'source_id')
     AND NOT pal_eyes.has_any_role(ARRAY['source_reviewer','review_manager','system_admin'])
  THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='SOURCE_LINK_VERIFICATION_AUTHORITY_REQUIRED'; END IF;
 END IF;
 RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION pal_eyes.guard_source_attestation_v1() FROM PUBLIC,anon,authenticated;

CREATE TRIGGER e_guard_source_attestation_v1
 BEFORE INSERT OR UPDATE OF rights_status,identity_status ON pal_eyes.sources
 FOR EACH ROW EXECUTE FUNCTION pal_eyes.guard_source_attestation_v1();
CREATE TRIGGER e_guard_link_attestation_v1
 BEFORE INSERT OR UPDATE OF verification_status,site_id,source_id ON pal_eyes.site_source_links
 FOR EACH ROW EXECUTE FUNCTION pal_eyes.guard_source_attestation_v1();

-- 2. Control and projection tables.
CREATE TABLE pal_eyes.research_preview_controls_v1 (
 narrative_id text PRIMARY KEY REFERENCES pal_eyes.draft_research_narratives_v1(id) ON DELETE RESTRICT,
 site_id text NOT NULL REFERENCES pal_eyes.sites(id),
 preview_title text NOT NULL,
 preview_excerpt text NOT NULL DEFAULT '',
 requested_visible boolean NOT NULL DEFAULT false,
 preview_text_reviewed boolean NOT NULL DEFAULT false,
 privacy_reviewed boolean NOT NULL DEFAULT false,
 copy_prepared_by uuid REFERENCES auth.users(id),
 copy_reviewed_by uuid REFERENCES auth.users(id),
 updated_by uuid REFERENCES auth.users(id),
 updated_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT preview_copy_length CHECK (length(preview_excerpt)<=200000),
 CONSTRAINT preview_checked_before_show CHECK (
   NOT requested_visible OR
   (preview_text_reviewed AND privacy_reviewed AND length(trim(preview_excerpt))>=80)
 )
);
INSERT INTO pal_eyes.research_preview_controls_v1(narrative_id,site_id,preview_title)
SELECT id,site_id,title FROM pal_eyes.draft_research_narratives_v1
WHERE publication_status='BLOCKED';
ALTER TABLE pal_eyes.research_preview_controls_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.research_preview_controls_v1 FORCE ROW LEVEL SECURITY;
CREATE POLICY preview_internal_read ON pal_eyes.research_preview_controls_v1
 FOR SELECT TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','source_reviewer','rights_reviewer','review_manager','system_admin']));
-- No INSERT/UPDATE/DELETE policy and no write grant: mutations only via RPC.
REVOKE ALL ON pal_eyes.research_preview_controls_v1 FROM PUBLIC,anon,authenticated;
GRANT SELECT ON pal_eyes.research_preview_controls_v1 TO authenticated;

-- Holds only copy that has passed an independent editorial/privacy review.
CREATE TABLE pal_eyes.research_public_projection_v1 (
 narrative_id text PRIMARY KEY REFERENCES pal_eyes.research_preview_controls_v1(narrative_id) ON DELETE CASCADE,
 site_id text NOT NULL,
 title text NOT NULL,
 preview_text text NOT NULL,
 requested_visible boolean NOT NULL DEFAULT false,
 disclaimer text NOT NULL DEFAULT
  'مادة بحثية أولية قيد التحقيق والتدقيق. المعلومات الواردة قابلة للتحديث والتصحيح، ولا تمثل الصيغة العلمية النهائية المعتمدة.',
 CONSTRAINT projection_minimum_copy CHECK (length(trim(preview_text))>=80)
);
ALTER TABLE pal_eyes.research_public_projection_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.research_public_projection_v1 FORCE ROW LEVEL SECURITY;
REVOKE ALL ON pal_eyes.research_public_projection_v1 FROM PUBLIC,anon,authenticated;
GRANT SELECT ON pal_eyes.research_public_projection_v1 TO anon,authenticated;

-- 3. Eligibility (single source of truth). Returns NULL when eligible,
--    otherwise the first blocking reason. INTERNAL ONLY (F-02).
CREATE FUNCTION pal_eyes.research_preview_ineligibility_v1(p_narrative_id text)
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
 SELECT CASE
  WHEN c.narrative_id IS NULL THEN 'سجل التحكم غير موجود'
  WHEN n.id IS NULL OR n.site_id IS DISTINCT FROM c.site_id
    OR n.publication_status IS DISTINCT FROM 'BLOCKED'
    OR n.scholarly_verified IS DISTINCT FROM false
    THEN 'حالة البحث لا تسمح بالمعاينة'
  WHEN c.preview_text_reviewed IS NOT TRUE THEN 'نص المعاينة يحتاج مراجعة مستقلة'
  WHEN c.privacy_reviewed IS NOT TRUE THEN 'فحص الخصوصية غير مكتمل'
  WHEN length(trim(coalesce(c.preview_excerpt,'')))<80 THEN 'نص المعاينة غير جاهز'
  WHEN NOT EXISTS (SELECT 1 FROM pal_eyes.site_source_links l WHERE l.site_id=c.site_id)
    THEN 'لا توجد مصادر مرتبطة بالموقع'
  WHEN EXISTS (SELECT 1 FROM pal_eyes.site_source_links l LEFT JOIN pal_eyes.sources s ON s.id=l.source_id
               WHERE l.site_id=c.site_id AND s.id IS NULL)
    THEN 'رابط مصدر يشير إلى مصدر غير موجود'
  WHEN EXISTS (SELECT 1 FROM pal_eyes.site_source_links l
               WHERE l.site_id=c.site_id AND l.verification_status IS DISTINCT FROM 'VERIFIED')
    THEN 'روابط المصادر لم يُتحقق منها'
  WHEN EXISTS (SELECT 1 FROM pal_eyes.site_source_links l JOIN pal_eyes.sources s ON s.id=l.source_id
               WHERE l.site_id=c.site_id AND s.identity_status IS DISTINCT FROM 'VERIFIED')
    THEN 'هوية المصادر لم يُتحقق منها'
  WHEN EXISTS (SELECT 1 FROM pal_eyes.site_source_links l JOIN pal_eyes.sources s ON s.id=l.source_id
               WHERE l.site_id=c.site_id AND s.rights_status IS DISTINCT FROM 'CLEARED')
    THEN 'حقوق المصادر غير مُجازة'
  ELSE NULL END
 FROM (SELECT p_narrative_id AS id) q
 LEFT JOIN pal_eyes.research_preview_controls_v1 c ON c.narrative_id=q.id
 LEFT JOIN pal_eyes.draft_research_narratives_v1 n ON n.id=c.narrative_id
$$;
REVOKE ALL ON FUNCTION pal_eyes.research_preview_ineligibility_v1(text) FROM PUBLIC,anon,authenticated;

CREATE FUNCTION pal_eyes.research_preview_eligibility_v1(p_narrative_id text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
 SELECT p_narrative_id IS NOT NULL AND pal_eyes.research_preview_ineligibility_v1(p_narrative_id) IS NULL
$$;
REVOKE ALL ON FUNCTION pal_eyes.research_preview_eligibility_v1(text) FROM PUBLIC,anon,authenticated;

-- The only elevated helper reachable by visitors. It reveals nothing beyond
-- what the public view already shows: true only for currently public rows.
CREATE FUNCTION pal_eyes.research_preview_is_public_v1(p_narrative_id text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
 SELECT EXISTS (SELECT 1 FROM pal_eyes.research_preview_controls_v1 c
                WHERE c.narrative_id=p_narrative_id AND c.requested_visible)
    AND pal_eyes.research_preview_eligibility_v1(p_narrative_id)
$$;
REVOKE ALL ON FUNCTION pal_eyes.research_preview_is_public_v1(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pal_eyes.research_preview_is_public_v1(text) TO anon,authenticated;

CREATE POLICY public_preview_only_eligible ON pal_eyes.research_public_projection_v1
 FOR SELECT TO anon,authenticated USING (
 requested_visible AND pal_eyes.research_preview_is_public_v1(narrative_id));

CREATE VIEW pal_eyes.public_research_previews_v1
 WITH (security_invoker=true,security_barrier=true) AS
SELECT narrative_id,site_id,title,preview_text,disclaimer
FROM pal_eyes.research_public_projection_v1;
REVOKE ALL ON pal_eyes.public_research_previews_v1 FROM PUBLIC,anon,authenticated;
GRANT SELECT ON pal_eyes.public_research_previews_v1 TO anon,authenticated;

-- 4. Shared helpers for audited state changes (internal only).
CREATE FUNCTION pal_eyes.research_preview_set_visible_internal_v1(
 p_narrative_id text,p_visible boolean,p_actor uuid,p_action text,p_batch text,p_reason text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
DECLARE v_old boolean;
BEGIN
 SELECT requested_visible INTO v_old FROM pal_eyes.research_preview_controls_v1
 WHERE narrative_id=p_narrative_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION USING ERRCODE='P0002',MESSAGE='PREVIEW_NARRATIVE_NOT_FOUND'; END IF;
 IF v_old IS NOT DISTINCT FROM p_visible THEN RETURN; END IF;
 UPDATE pal_eyes.research_preview_controls_v1
  SET requested_visible=p_visible,updated_by=coalesce(p_actor,updated_by),updated_at=now()
  WHERE narrative_id=p_narrative_id;
 UPDATE pal_eyes.research_public_projection_v1 SET requested_visible=p_visible
  WHERE narrative_id=p_narrative_id;
 IF p_visible AND NOT FOUND
 THEN RAISE EXCEPTION USING ERRCODE='P0002',MESSAGE='PREVIEW_APPROVED_PROJECTION_MISSING'; END IF;
 INSERT INTO pal_eyes.audit_events(id,actor_id,actor_label,action,entity_type,entity_id,summary,metadata)
 VALUES ('audit-preview-item-'||gen_random_uuid()::text,p_actor,
  CASE WHEN p_actor IS NULL THEN 'PAL_EYES_PREVIEW_GUARD' ELSE 'authorized-preview-editor' END,
  p_action,'draft_research_narrative',p_narrative_id,
  'Public preview visibility updated; scientific approval unchanged',
  jsonb_build_object('batch_id',p_batch,'old_visible',v_old,'new_visible',p_visible,
   'reason',p_reason,'scholarly_verified',false,'publication_status','BLOCKED'));
END $$;
REVOKE ALL ON FUNCTION pal_eyes.research_preview_set_visible_internal_v1(text,boolean,uuid,text,text,text) FROM PUBLIC,anon,authenticated;

-- 5. Automatic withdrawal when an attestation is lost (F-04). A later
--    re-clearance never re-exposes an item without a fresh decision.
CREATE FUNCTION pal_eyes.reconcile_preview_on_attestation_change_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
DECLARE v_sites text[]; v_id text; v_reason text;
BEGIN
 IF TG_TABLE_NAME='sources' THEN
  SELECT array_agg(DISTINCT l.site_id) INTO v_sites FROM pal_eyes.site_source_links l
  WHERE l.source_id IN (NEW.id, OLD.id);
 ELSE
  v_sites:=ARRAY[CASE WHEN TG_OP<>'INSERT' THEN OLD.site_id END,
                 CASE WHEN TG_OP<>'DELETE' THEN NEW.site_id END];
 END IF;
 IF v_sites IS NULL THEN RETURN NULL; END IF;
 IF NOT EXISTS (SELECT 1 FROM pal_eyes.research_preview_controls_v1
                WHERE site_id=ANY(v_sites) AND requested_visible) THEN RETURN NULL; END IF;
 PERFORM pg_advisory_xact_lock(hashtext('pal_eyes_preview_visibility_v1'));
 FOR v_id IN SELECT narrative_id FROM pal_eyes.research_preview_controls_v1
             WHERE site_id=ANY(v_sites) AND requested_visible ORDER BY narrative_id LOOP
  v_reason:=pal_eyes.research_preview_ineligibility_v1(v_id);
  IF v_reason IS NOT NULL THEN
   PERFORM pal_eyes.research_preview_set_visible_internal_v1(v_id,false,auth.uid(),
    'PUBLIC_RESEARCH_PREVIEW_WITHDRAWN_INELIGIBLE',NULL,v_reason);
  END IF;
 END LOOP;
 RETURN NULL;
END $$;
REVOKE ALL ON FUNCTION pal_eyes.reconcile_preview_on_attestation_change_v1() FROM PUBLIC,anon,authenticated;

CREATE TRIGGER z_reconcile_preview_sources_v1
 AFTER UPDATE OF rights_status,identity_status ON pal_eyes.sources
 FOR EACH ROW EXECUTE FUNCTION pal_eyes.reconcile_preview_on_attestation_change_v1();
CREATE TRIGGER z_reconcile_preview_links_v1
 AFTER INSERT OR DELETE OR UPDATE OF verification_status,site_id,source_id ON pal_eyes.site_source_links
 FOR EACH ROW EXECUTE FUNCTION pal_eyes.reconcile_preview_on_attestation_change_v1();

-- 6. Private management listing.
CREATE FUNCTION pal_eyes.get_research_preview_controls_v1()
RETURNS TABLE(narrative_id text,title text,requested_visible boolean,
 eligible boolean,reason text,preview_text text,
 copy_reviewed boolean,privacy_checked boolean,publicly_visible boolean)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pal_eyes,pg_temp AS $$
BEGIN
 IF auth.uid() IS NULL OR NOT pal_eyes.has_any_role(
 ARRAY['researcher','editor','source_reviewer','rights_reviewer','review_manager','system_admin'])
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_INTERNAL_READ_AUTHORITY_REQUIRED'; END IF;
 RETURN QUERY
 SELECT c.narrative_id,c.preview_title,c.requested_visible,
  (x.why IS NULL),
  coalesce(x.why,'مؤهل للمعاينة العامة'),
  c.preview_excerpt,c.preview_text_reviewed,c.privacy_reviewed,
  (c.requested_visible AND x.why IS NULL)
 FROM pal_eyes.research_preview_controls_v1 c
 CROSS JOIN LATERAL (SELECT pal_eyes.research_preview_ineligibility_v1(c.narrative_id) AS why) x
 ORDER BY c.preview_title,c.narrative_id;
END $$;
REVOKE ALL ON FUNCTION pal_eyes.get_research_preview_controls_v1() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION pal_eyes.get_research_preview_controls_v1() TO authenticated;

-- 7. Prepare public copy. Identical copy is a no-op (F-06).
CREATE FUNCTION pal_eyes.prepare_research_preview_excerpt_v1(
 p_narrative_id text,p_excerpt text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
DECLARE v_actor uuid:=auth.uid(); v_rec pal_eyes.research_preview_controls_v1%ROWTYPE;
 v_copy text:=trim(p_excerpt);
BEGIN
 IF v_actor IS NULL OR NOT pal_eyes.has_any_role(ARRAY['editor','review_manager','system_admin'])
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_COPY_EDITOR_AUTHORITY_REQUIRED'; END IF;
 IF p_narrative_id IS NULL OR p_excerpt IS NULL
 OR length(v_copy)<80 OR length(p_excerpt)>200000
 THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_COPY_INVALID'; END IF;
 PERFORM pg_advisory_xact_lock(hashtext('pal_eyes_preview_visibility_v1'));
 SELECT * INTO v_rec FROM pal_eyes.research_preview_controls_v1
 WHERE narrative_id=p_narrative_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION USING ERRCODE='P0002',MESSAGE='PREVIEW_NARRATIVE_NOT_FOUND'; END IF;
 IF v_rec.preview_excerpt=v_copy THEN
  RETURN jsonb_build_object('changed',false,'narrative_id',p_narrative_id);
 END IF;
 UPDATE pal_eyes.research_preview_controls_v1
 SET preview_excerpt=v_copy,preview_text_reviewed=false,
     privacy_reviewed=false,requested_visible=false,
     copy_prepared_by=v_actor,copy_reviewed_by=NULL,
     updated_by=v_actor,updated_at=now()
 WHERE narrative_id=p_narrative_id;
 DELETE FROM pal_eyes.research_public_projection_v1 WHERE narrative_id=p_narrative_id;
 INSERT INTO pal_eyes.audit_events(id,actor_id,actor_label,action,entity_type,entity_id,summary,metadata)
 VALUES ('audit-preview-copy-'||gen_random_uuid()::text,v_actor,'authorized-editor',
 'PUBLIC_RESEARCH_PREVIEW_COPY_PREPARED','draft_research_narrative',p_narrative_id,
 'New public-preview copy prepared; approval and visibility reset',
 jsonb_build_object('copy_length',length(v_copy),'previous_visible',v_rec.requested_visible,
  'previously_reviewed',(v_rec.preview_text_reviewed AND v_rec.privacy_reviewed),
  'requested_visible',false));
 RETURN jsonb_build_object('changed',true,'narrative_id',p_narrative_id);
END $$;
REVOKE ALL ON FUNCTION pal_eyes.prepare_research_preview_excerpt_v1(text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION pal_eyes.prepare_research_preview_excerpt_v1(text,text) TO authenticated;

-- 8. Independent copy/privacy review. Reviewer must differ from preparer,
--    even for admin. Approval requires aal2 (F-03). Identical decision is a
--    no-op (F-05).
CREATE FUNCTION pal_eyes.review_research_preview_excerpt_v1(
 p_narrative_id text,p_copy_reviewed boolean,p_privacy_reviewed boolean)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
DECLARE v_actor uuid:=auth.uid(); v_rec pal_eyes.research_preview_controls_v1%ROWTYPE;
 v_approve boolean;
BEGIN
 IF v_actor IS NULL OR NOT pal_eyes.has_any_role(ARRAY['review_manager','system_admin'])
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_INDEPENDENT_REVIEW_AUTHORITY_REQUIRED'; END IF;
 IF p_narrative_id IS NULL OR p_copy_reviewed IS NULL OR p_privacy_reviewed IS NULL
 THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_REVIEW_VALUES_REQUIRED'; END IF;
 v_approve:=p_copy_reviewed AND p_privacy_reviewed;
 IF v_approve AND pal_eyes.current_aal() IS DISTINCT FROM 'aal2'
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_MFA_REQUIRED'; END IF;
 PERFORM pg_advisory_xact_lock(hashtext('pal_eyes_preview_visibility_v1'));
 SELECT * INTO v_rec FROM pal_eyes.research_preview_controls_v1
 WHERE narrative_id=p_narrative_id FOR UPDATE;
 IF NOT FOUND OR length(trim(v_rec.preview_excerpt))<80
 THEN RAISE EXCEPTION USING ERRCODE='P0002',MESSAGE='PREVIEW_COPY_NOT_READY'; END IF;
 IF v_rec.copy_prepared_by IS NULL OR v_rec.copy_prepared_by=v_actor
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_INDEPENDENT_REVIEWER_REQUIRED'; END IF;
 IF v_rec.copy_reviewed_by IS NOT NULL
    AND v_rec.preview_text_reviewed=p_copy_reviewed
    AND v_rec.privacy_reviewed=p_privacy_reviewed
    AND (NOT v_approve OR EXISTS (SELECT 1 FROM pal_eyes.research_public_projection_v1 j
         WHERE j.narrative_id=p_narrative_id AND j.preview_text=v_rec.preview_excerpt))
 THEN RETURN jsonb_build_object('changed',false,'narrative_id',p_narrative_id); END IF;
 UPDATE pal_eyes.research_preview_controls_v1
 SET preview_text_reviewed=p_copy_reviewed,privacy_reviewed=p_privacy_reviewed,
     requested_visible=false,copy_reviewed_by=v_actor,
     updated_by=v_actor,updated_at=now()
 WHERE narrative_id=p_narrative_id;
 DELETE FROM pal_eyes.research_public_projection_v1 WHERE narrative_id=p_narrative_id;
 IF v_approve THEN
  INSERT INTO pal_eyes.research_public_projection_v1(
    narrative_id,site_id,title,preview_text,requested_visible)
  VALUES (v_rec.narrative_id,v_rec.site_id,v_rec.preview_title,v_rec.preview_excerpt,false);
 END IF;
 INSERT INTO pal_eyes.audit_events(id,actor_id,actor_label,action,entity_type,entity_id,summary,metadata)
 VALUES ('audit-preview-review-'||gen_random_uuid()::text,v_actor,'authorized-reviewer',
 'PUBLIC_RESEARCH_PREVIEW_COPY_REVIEWED','draft_research_narrative',p_narrative_id,
 'Independent copy/privacy review; public visibility remains off',
 jsonb_build_object('copy_reviewed',p_copy_reviewed,'privacy_reviewed',p_privacy_reviewed,
  'previous_visible',v_rec.requested_visible,'requested_visible',false));
 RETURN jsonb_build_object('changed',true,'narrative_id',p_narrative_id);
END $$;
REVOKE ALL ON FUNCTION pal_eyes.review_research_preview_excerpt_v1(text,boolean,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION pal_eyes.review_research_preview_excerpt_v1(text,boolean,boolean) TO authenticated;

-- 9. Visibility control: single = SELECTED with one id; ALL; SELECTED set.
--    Showing requires aal2 (F-03); hiding never does (reduces exposure).
--    Ineligible items found visible are withdrawn in the same command (F-04).
CREATE FUNCTION pal_eyes.set_research_preview_visibility_v1(
 p_visible boolean,p_scope text,p_ids text[] DEFAULT NULL,
 p_expected_count integer DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pal_eyes,pg_temp AS $$
DECLARE
 v_actor uuid:=auth.uid(); v_ids text[]; v_id text; v_count integer;
 v_changed integer:=0;v_excluded integer:=0;v_eligible integer:=0;v_withdrawn integer:=0;
 v_old boolean;v_reason text;v_batch text:='preview-batch-'||gen_random_uuid()::text;
 v_excluded_ids text[]:='{}';
BEGIN
 IF v_actor IS NULL OR NOT pal_eyes.has_any_role(ARRAY['editor','review_manager','system_admin'])
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_WRITE_AUTHORITY_REQUIRED'; END IF;
 IF p_visible IS NULL OR p_scope IS NULL OR p_scope NOT IN ('ALL','SELECTED')
 OR p_expected_count IS NULL OR p_expected_count<1
 THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_SCOPE_AND_EXPECTED_COUNT_REQUIRED'; END IF;
 IF p_visible AND pal_eyes.current_aal() IS DISTINCT FROM 'aal2'
 THEN RAISE EXCEPTION USING ERRCODE='42501',MESSAGE='PREVIEW_MFA_REQUIRED'; END IF;
 PERFORM pg_advisory_xact_lock(hashtext('pal_eyes_preview_visibility_v1'));
 IF p_scope='ALL' THEN
  IF p_ids IS NOT NULL THEN
   RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_ALL_SCOPE_TAKES_NO_IDS'; END IF;
  SELECT array_agg(narrative_id ORDER BY narrative_id) INTO v_ids
  FROM pal_eyes.research_preview_controls_v1;
 ELSE
  IF p_ids IS NULL OR cardinality(p_ids)=0 OR array_position(p_ids,NULL) IS NOT NULL
  THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_IDS_REQUIRED'; END IF;
  SELECT array_agg(DISTINCT x ORDER BY x) INTO v_ids FROM unnest(p_ids) AS t(x);
 END IF;
 v_count:=coalesce(cardinality(v_ids),0);
 IF v_count=0 OR v_count<>p_expected_count
 THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_EXPECTED_COUNT_MISMATCH'; END IF;
 IF p_scope='SELECTED' AND
  (SELECT count(*) FROM pal_eyes.research_preview_controls_v1
   WHERE narrative_id=ANY(v_ids))<>v_count
 THEN RAISE EXCEPTION USING ERRCODE='22023',MESSAGE='PREVIEW_UNKNOWN_IDS'; END IF;
 FOREACH v_id IN ARRAY v_ids LOOP
  SELECT requested_visible INTO v_old
  FROM pal_eyes.research_preview_controls_v1 WHERE narrative_id=v_id FOR UPDATE;
  v_reason:=pal_eyes.research_preview_ineligibility_v1(v_id);
  IF v_reason IS NULL THEN v_eligible:=v_eligible+1; END IF;
  IF v_reason IS NOT NULL AND v_old THEN
   PERFORM pal_eyes.research_preview_set_visible_internal_v1(v_id,false,v_actor,
    'PUBLIC_RESEARCH_PREVIEW_WITHDRAWN_INELIGIBLE',v_batch,v_reason);
   v_withdrawn:=v_withdrawn+1; v_old:=false;
  END IF;
  IF p_visible AND v_reason IS NOT NULL THEN
   v_excluded:=v_excluded+1; v_excluded_ids:=v_excluded_ids||v_id; CONTINUE;
  END IF;
  IF v_old IS DISTINCT FROM p_visible THEN
   PERFORM pal_eyes.research_preview_set_visible_internal_v1(v_id,p_visible,v_actor,
    'PUBLIC_RESEARCH_PREVIEW_VISIBILITY_CHANGED',v_batch,NULL);
   v_changed:=v_changed+1;
  END IF;
 END LOOP;
 -- A no-op writes no audit event (idempotent repeated commands).
 IF v_changed>0 OR v_withdrawn>0 THEN
  INSERT INTO pal_eyes.audit_events(id,actor_id,actor_label,action,entity_type,entity_id,summary,metadata)
  VALUES ('audit-preview-batch-'||gen_random_uuid()::text,v_actor,'authorized-preview-editor',
  'PUBLIC_RESEARCH_PREVIEW_BULK_ACTION','research_preview_batch',v_batch,
  'Public preview visibility batch changed; scientific approval unchanged',
  jsonb_build_object('scope',p_scope,'visible',p_visible,'targets',v_count,
    'changed',v_changed,'excluded',v_excluded,'withdrawn',v_withdrawn,
    'eligible',v_eligible,'ids',to_jsonb(v_ids),'excluded_ids',to_jsonb(v_excluded_ids)));
 END IF;
 RETURN jsonb_build_object('batch_id',CASE WHEN v_changed>0 OR v_withdrawn>0 THEN v_batch END,
  'targets',v_count,'changed',v_changed,'excluded',v_excluded,'withdrawn',v_withdrawn,
  'eligible',v_eligible,'requested_visible',p_visible,'excluded_ids',to_jsonb(v_excluded_ids));
END $$;
REVOKE ALL ON FUNCTION pal_eyes.set_research_preview_visibility_v1(boolean,text,text[],integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION pal_eyes.set_research_preview_visibility_v1(boolean,text,text[],integer) TO authenticated;

-- 10. Bootstrapping must never publish a single record.
DO $check$
BEGIN
 IF (SELECT count(*) FROM pal_eyes.research_preview_controls_v1)<>47
 OR (SELECT count(*) FROM pal_eyes.research_preview_controls_v1 WHERE requested_visible)<>0
 OR (SELECT count(*) FROM pal_eyes.research_public_projection_v1)<>0
 OR (SELECT count(*) FROM pal_eyes.public_research_previews_v1)<>0
 OR EXISTS (SELECT 1 FROM pal_eyes.draft_research_narratives_v1
            WHERE publication_status<>'BLOCKED' OR scholarly_verified)
 THEN RAISE EXCEPTION 'PREVIEW_BOOTSTRAP_VALIDATION_FAIL'; END IF;
END $check$;
