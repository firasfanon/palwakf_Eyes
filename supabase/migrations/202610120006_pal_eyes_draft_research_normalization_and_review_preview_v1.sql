-- PAL_EYES_DRAFT_RESEARCH_NORMALIZATION_AND_REVIEW_PREVIEW_V1.
-- GitHub original historical draft corpus, NOT sovereign Workspace Drive publication documents.
-- Controlled internal research preview; no public access or publication transition.
DO $preflight$
BEGIN
  IF (SELECT count(*) FROM pal_eyes.sites WHERE metadata->>'canonical_source_git_blob'='ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c') <> 79
    OR (SELECT count(*) FROM pal_eyes.sources WHERE bibliographic_data->>'source_git_blob'='285a708df8423cf57fcdbaa88afcb15931dfd6e7') <> 79
    OR (SELECT count(*) FROM pal_eyes.research_packages) <> 0
    OR (SELECT count(*) FROM pal_eyes.site_source_links) <> 0
    OR (SELECT count(*) FROM pal_eyes.sites WHERE jsonb_typeof(metadata->'original_expanded_narrative')='object') <> 47
  THEN
    RAISE EXCEPTION 'SOURCE_AND_TARGET_NORMALIZATION_PREFLIGHT_FAILED';
  END IF;
END
$preflight$;

CREATE TABLE pal_eyes.draft_research_narratives_v1 (
  id text PRIMARY KEY,
  site_id text NOT NULL UNIQUE REFERENCES pal_eyes.sites(id),
  title text NOT NULL,
  original_language text NOT NULL DEFAULT 'ar',
  source_git_blob text NOT NULL,
  original_source_path text NOT NULL,
  research_status text NOT NULL DEFAULT 'UNDER_HUMAN_REVIEW'
    CHECK (research_status IN ('DRAFT','UNDER_HUMAN_REVIEW','NEEDS_CORRECTION')),
  publication_status text NOT NULL DEFAULT 'BLOCKED'
    CHECK (publication_status='BLOCKED'),
  scholarly_verified boolean NOT NULL DEFAULT false
    CHECK (scholarly_verified=false),
  created_at timestamptz NOT NULL DEFAULT timezone('utc',now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc',now())
);
CREATE TABLE pal_eyes.draft_research_sections_v1 (
  id text PRIMARY KEY,
  narrative_id text NOT NULL REFERENCES pal_eyes.draft_research_narratives_v1(id),
  section_order integer NOT NULL CHECK(section_order>0),
  title text NOT NULL,
  original_text text NOT NULL,
  verification_status text NOT NULL DEFAULT 'PENDING_HUMAN_REVIEW',
  UNIQUE(narrative_id, section_order)
);
CREATE TABLE pal_eyes.draft_research_paragraphs_v1 (
  id text PRIMARY KEY,
  section_id text NOT NULL REFERENCES pal_eyes.draft_research_sections_v1(id),
  paragraph_order integer NOT NULL CHECK(paragraph_order>0),
  paragraph_text text NOT NULL,
  verification_status text NOT NULL DEFAULT 'PENDING_HUMAN_REVIEW',
  UNIQUE(section_id, paragraph_order)
);

-- RLS is additionally enforced by PostgreSQL even for table owners.
ALTER TABLE pal_eyes.draft_research_narratives_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.draft_research_narratives_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.draft_research_sections_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.draft_research_sections_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.draft_research_paragraphs_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE pal_eyes.draft_research_paragraphs_v1 FORCE ROW LEVEL SECURITY;

CREATE POLICY internal_research_preview_read ON pal_eyes.draft_research_narratives_v1
 FOR SELECT TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','source_reviewer','gis_reviewer','rights_reviewer','review_manager','release_manager','system_admin'])
);
CREATE POLICY internal_research_preview_write ON pal_eyes.draft_research_narratives_v1
 FOR ALL TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','review_manager','system_admin'])
) WITH CHECK (
 publication_status='BLOCKED' AND scholarly_verified=false
 AND pal_eyes.has_any_role(ARRAY['researcher','editor','review_manager','system_admin'])
);
CREATE POLICY internal_research_preview_read ON pal_eyes.draft_research_sections_v1
 FOR SELECT TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','source_reviewer','gis_reviewer','rights_reviewer','review_manager','release_manager','system_admin'])
);
CREATE POLICY internal_research_preview_write ON pal_eyes.draft_research_sections_v1
 FOR ALL TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','review_manager','system_admin'])
) WITH CHECK (
 pal_eyes.has_any_role(ARRAY['researcher','editor','review_manager','system_admin'])
);
CREATE POLICY internal_research_preview_read ON pal_eyes.draft_research_paragraphs_v1
 FOR SELECT TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','source_reviewer','gis_reviewer','rights_reviewer','review_manager','release_manager','system_admin'])
);
CREATE POLICY internal_research_preview_write ON pal_eyes.draft_research_paragraphs_v1
 FOR ALL TO authenticated USING (
 pal_eyes.has_any_role(ARRAY['researcher','editor','review_manager','system_admin'])
) WITH CHECK (
 pal_eyes.has_any_role(ARRAY['researcher','editor','review_manager','system_admin'])
);

REVOKE ALL ON pal_eyes.draft_research_narratives_v1 FROM PUBLIC, anon;
REVOKE ALL ON pal_eyes.draft_research_sections_v1 FROM PUBLIC, anon;
REVOKE ALL ON pal_eyes.draft_research_paragraphs_v1 FROM PUBLIC, anon;
GRANT SELECT, INSERT, UPDATE ON pal_eyes.draft_research_narratives_v1 TO authenticated;
GRANT SELECT, INSERT, UPDATE ON pal_eyes.draft_research_sections_v1 TO authenticated;
GRANT SELECT, INSERT, UPDATE ON pal_eyes.draft_research_paragraphs_v1 TO authenticated;

INSERT INTO pal_eyes.research_packages
(record_id,package_id,schema_key,version,site_entity_id,research_topic_id,
 lifecycle_stage,publication_decision,evidence_freeze_id,source_snapshot)
SELECT 'draft-package-'||s.id,
       'DRAFT-'||s.id,
       'PAL_EYES_RESEARCH_PACKAGE_V1',
       '1.0.0-staging-draft',
       s.id,
       'RESEARCH_TOPIC_'||upper(replace(s.id,'-','_')),
       'researchDraftReviewRequired',
       'pending',
       'PAL_EYES_GOVERNED_RESEARCH_CORPUS_V1_FROZEN_2026_09_15',
       jsonb_build_object(
          'origin','ORIGINAL_GITHUB_DRAFT_SITE_CATALOG',
          'source_path','content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json',
          'source_git_blob','ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c',
          'source_ref','4775ea949f41e267cc26076125c20304d9a8df23',
          'review_status','PENDING_HUMAN_REVIEW',
          'publication_status','BLOCKED',
          'source_mentions',s.metadata->'source_mentions_raw',
          'original_review_status',s.metadata->>'review_status_from_source',
          'note','Draft index record; no source claim accepted as verified'
       )
FROM pal_eyes.sites s
WHERE s.metadata->>'canonical_source_git_blob'='ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c';

INSERT INTO pal_eyes.site_source_links
(id,site_id,source_id,link_role,verification_status,publication_status)
SELECT 'draft-mention-'||src.id||'-'||site.id,
       site.id,
       src.id,
       'UNVERIFIED_SOURCE_MENTION',
       'PENDING_HUMAN_REVIEW',
       'BLOCKED'
FROM pal_eyes.sources src
CROSS JOIN LATERAL jsonb_array_elements_text(src.bibliographic_data->'site_slugs') ss(slug)
JOIN pal_eyes.sites site ON site.slug=ss.slug
WHERE src.bibliographic_data->>'source_git_blob'='285a708df8423cf57fcdbaa88afcb15931dfd6e7';

INSERT INTO pal_eyes.draft_research_narratives_v1
(id,site_id,title,source_git_blob,original_source_path)
SELECT 'draft-narrative-'||id, id,
       metadata->'original_expanded_narrative'->>'title',
       metadata->>'canonical_source_git_blob',
       'content_seed/PAL_EYES_DRAFT_SITE_CATALOG_V1.json'
FROM pal_eyes.sites
WHERE jsonb_typeof(metadata->'original_expanded_narrative')='object'
AND metadata->>'canonical_source_git_blob'='ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c';

INSERT INTO pal_eyes.draft_research_sections_v1
(id,narrative_id,section_order,title,original_text)
SELECT 'draft-section-'||s.id||'-'||sec.ordinality,
       'draft-narrative-'||s.id,
       sec.ordinality::integer,
       sec.value->>0,
       sec.value->>1
FROM pal_eyes.sites s
CROSS JOIN LATERAL jsonb_array_elements(
 s.metadata->'original_expanded_narrative'->'sections'
) WITH ORDINALITY sec(value,ordinality)
WHERE s.metadata->>'canonical_source_git_blob'='ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c'
AND jsonb_typeof(s.metadata->'original_expanded_narrative')='object';

INSERT INTO pal_eyes.draft_research_paragraphs_v1
(id,section_id,paragraph_order,paragraph_text)
SELECT 'draft-paragraph-'||sec.id||'-'||p.ordinality,
       sec.id, p.ordinality::integer, trim(p.content)
FROM pal_eyes.draft_research_sections_v1 sec
CROSS JOIN LATERAL regexp_split_to_table(sec.original_text,E'\\n[[:space:]]*\\n')
  WITH ORDINALITY p(content,ordinality)
WHERE length(trim(p.content))>0;

DO $postflight$
BEGIN
IF (SELECT count(*) FROM pal_eyes.research_packages WHERE publication_decision='pending')<>79
 OR (SELECT count(*) FROM pal_eyes.site_source_links WHERE publication_status='BLOCKED')<>79
 OR (SELECT count(*) FROM pal_eyes.draft_research_narratives_v1 WHERE publication_status='BLOCKED')<>47
 OR (SELECT count(*) FROM pal_eyes.draft_research_sections_v1) < 47
 OR (SELECT count(*) FROM pal_eyes.draft_research_paragraphs_v1) < 47
THEN RAISE EXCEPTION 'DRAFT_NORMALIZATION_POSTCHECK_FAILED'; END IF;
INSERT INTO pal_eyes.audit_events
(id,actor_label,action,entity_type,entity_id,summary,metadata)
VALUES('audit-draft-normalization-v1','PAL_EYES_STAGING_MIGRATION',
       'UNPUBLISHED_RESEARCH_DRAFT_CORPUS_NORMALIZED','research_corpus',
       'PAL_EYES_GOVERNED_RESEARCH_CORPUS_V1_FROZEN_2026_09_15',
       'Research catalog normalized for internal human review; no public release',
       jsonb_build_object('packages',79,'source_mentions',79,'narrative_drafts',47,
        'publication_allowed',false,
        'source_git_blob','ecac3f5207706f038c6ffeb9f8c2ec78f2862c0c'));
END
$postflight$;
