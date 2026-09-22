-- PAL_EYES_RESEARCH_KNOWLEDGE_MODEL_AND_WORKSPACE_OPERATIONALIZATION_V1
-- Additive/source-only migration. DO NOT apply to live/shared Supabase under this batch.
-- PDR-001..019. No destructive migration, publication, or production authority.

begin;

alter table pal_eyes.sources
  add column if not exists canonical_url text not null default '',
  add column if not exists identifiers jsonb not null default '{}'::jsonb,
  add column if not exists edition text not null default '',
  add column if not exists publisher text not null default '',
  add column if not exists institution text not null default '',
  add column if not exists identity_status text not null default 'UNVERIFIED',
  add column if not exists authority_assessment text not null default 'UNASSESSED',
  add column if not exists identity_verified_at timestamptz,
  add column if not exists identity_verified_by uuid references auth.users(id);

alter table pal_eyes.claims
  add column if not exists claim_type text not null default 'FACT'
    check (claim_type in ('FACT','INFERENCE','ORAL_TRADITION','CONTESTED')),
  add column if not exists information_confidence text not null default 'UNASSESSED',
  add column if not exists confidence_rationale text not null default '';

alter table pal_eyes.claim_evidence_links
  add column if not exists relation_type text not null default 'CONTEXT'
    check (relation_type in ('SUPPORTS','CONTRADICTS','QUALIFIES','CONTEXT')),
  add column if not exists source_role text not null default 'SECONDARY'
    check (source_role in ('PRIMARY','SECONDARY','OFFICIAL','ORAL','ARCHIVAL_BRIDGE')),
  add column if not exists locator_id text,
  add column if not exists evidence_strength text not null default 'UNASSESSED',
  add column if not exists inspected_by text not null default '',
  add column if not exists inspected_at timestamptz,
  add column if not exists transcription_reference text not null default '',
  add column if not exists representation_checksum text not null default '';

alter table pal_eyes.media_rights
  add column if not exists creator text not null default '',
  add column if not exists rights_holder text not null default '',
  add column if not exists source_page_url text not null default '',
  add column if not exists original_asset_url text not null default '',
  add column if not exists license_code text not null default '',
  add column if not exists license_url text not null default '',
  add column if not exists allowed_use text not null default '',
  add column if not exists noncommercial boolean,
  add column if not exists no_derivatives boolean,
  add column if not exists share_alike boolean,
  add column if not exists attribution_text text not null default '',
  add column if not exists verified_at timestamptz,
  add column if not exists verified_by uuid references auth.users(id),
  add column if not exists derivative_provenance text not null default '';

create table if not exists pal_eyes.research_packages (
  record_id text primary key,
  package_id text not null,
  schema_key text not null default 'PAL_EYES_RESEARCH_PACKAGE_V1',
  version text not null,
  site_entity_id text not null references pal_eyes.sites(id) on delete cascade,
  research_topic_id text not null,
  lifecycle_stage text not null default 'researchCompleteReviewDeferred',
  publication_decision text not null default 'pending'
    check (publication_decision in ('pending','approved','rejected')),
  evidence_freeze_id text not null default '',
  source_snapshot jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (package_id, version)
);

create table if not exists pal_eyes.narrative_documents (
  id text primary key,
  research_package_id text not null references pal_eyes.research_packages(record_id) on delete cascade,
  title text not null,
  language_code text not null default 'ar',
  workflow_status text not null default 'DRAFT',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.narrative_sections (
  id text primary key,
  narrative_document_id text not null references pal_eyes.narrative_documents(id) on delete cascade,
  section_order integer not null check (section_order > 0),
  title text not null,
  research_note text not null default '',
  workflow_status text not null default 'DRAFT',
  unique (narrative_document_id, section_order)
);

create table if not exists pal_eyes.narrative_paragraphs (
  id text primary key,
  narrative_section_id text not null references pal_eyes.narrative_sections(id) on delete cascade,
  paragraph_order integer not null check (paragraph_order > 0),
  paragraph_text text not null,
  workflow_status text not null default 'DRAFT',
  unique (narrative_section_id, paragraph_order)
);

create table if not exists pal_eyes.paragraph_claim_links (
  id text primary key,
  paragraph_id text not null references pal_eyes.narrative_paragraphs(id) on delete cascade,
  claim_id text not null references pal_eyes.claims(id) on delete cascade,
  link_role text not null default 'SUPPORTING',
  unique (paragraph_id, claim_id, link_role)
);

create table if not exists pal_eyes.legacy_source_mentions (
  id text primary key,
  research_package_id text references pal_eyes.research_packages(record_id) on delete cascade,
  mention_text text not null,
  canonical_source_id text references pal_eyes.sources(id) on delete set null,
  crosswalk_status text not null default 'UNRESOLVED'
    check (crosswalk_status in ('SAME_SOURCE','ALTERNATE_TOPIC','UNRESOLVED','REJECTED')),
  rationale text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.source_locators (
  id text primary key,
  source_id text not null references pal_eyes.sources(id) on delete cascade,
  locator_type text not null,
  volume text not null default '',
  issue text not null default '',
  chapter text not null default '',
  pages text not null default '',
  folio text not null default '',
  archive_repository text not null default '',
  fonds text not null default '',
  series text not null default '',
  register_ref text not null default '',
  item_ref text not null default '',
  case_hujja text not null default '',
  inscription text not null default '',
  original_date text not null default '',
  copy_date text not null default '',
  access_copy text not null default '',
  custodian text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.claim_conflicts (
  id text primary key,
  research_package_id text not null references pal_eyes.research_packages(record_id) on delete cascade,
  issue text not null,
  claim_ids text[] not null,
  relation_type text not null
    check (relation_type in ('CONTRADICTS','ALTERNATE_INTERPRETATION','SUPERSEDES','QUALIFIES')),
  conflict_status text not null default 'OPEN'
    check (conflict_status in ('OPEN','RESOLVED','UNRESOLVED')),
  resolution text not null default '',
  narrative_effect text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.temporal_assertions (
  id text primary key,
  research_package_id text not null references pal_eyes.research_packages(record_id) on delete cascade,
  subject text not null,
  predicate text not null,
  object_value text not null,
  assertion_dimension text not null,
  valid_from text not null default '',
  valid_to text not null default '',
  event_date text not null default '',
  source_ids text[] not null default '{}'::text[],
  verification_status text not null default 'UNRESOLVED',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.archive_provenance (
  id text primary key,
  source_id text not null references pal_eyes.sources(id) on delete cascade,
  archive_repository text not null,
  fonds text not null default '',
  series text not null default '',
  register_ref text not null default '',
  item_ref text not null default '',
  manifestation text not null default '',
  original_date text not null default '',
  copy_date text not null default '',
  custody_note text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.research_entity_relations (
  id text primary key,
  source_entity_id text not null references pal_eyes.sites(id) on delete cascade,
  target_entity_id text not null references pal_eyes.sites(id) on delete cascade,
  research_topic_id text,
  research_package_id text references pal_eyes.research_packages(record_id) on delete cascade,
  relation_type text not null,
  provenance text not null,
  confidence text not null default 'UNRESOLVED',
  created_at timestamptz not null default timezone('utc', now()),
  check (source_entity_id <> target_entity_id)
);

create table if not exists pal_eyes.research_aliases (
  id text primary key,
  entity_id text not null references pal_eyes.sites(id) on delete cascade,
  label text not null,
  language_code text not null default 'ar',
  alias_type text not null,
  valid_period text not null default '',
  disambiguation_note text not null default '',
  provenance text not null,
  verification_status text not null default 'UNRESOLVED',
  merge_directive boolean not null default false check (merge_directive = false)
);

create table if not exists pal_eyes.spatial_boundary_observations (
  id text primary key,
  entity_id text not null references pal_eyes.sites(id) on delete cascade,
  boundary_type text not null,
  source_id text not null,
  scope text not null,
  temporal_scope text not null,
  certainty text not null,
  observed_at timestamptz,
  geometry_reference text,
  legal_inference_allowed boolean not null default false check (legal_inference_allowed = false)
);

create table if not exists pal_eyes.current_condition_observations (
  id text primary key,
  entity_id text not null references pal_eyes.sites(id) on delete cascade,
  component_entity_id text,
  condition_type text not null,
  condition_status text not null,
  observed_at timestamptz not null,
  source_id text not null,
  observation_scope text not null check (observation_scope in ('wholeEntity','component')),
  note text not null default ''
);

create table if not exists pal_eyes.review_adjudications (
  id text primary key,
  entity_type text not null,
  entity_id text not null,
  version_id text not null,
  review_stage text not null
    check (review_stage in ('experimentalHuman','specialistExpert','competentAuthority','sovereignCurrent','publication')),
  reviewer_body text not null,
  authority_ref text not null,
  authority_scope text not null,
  decision text not null
    check (decision in ('pending','accept','defer','reject','needsMoreEvidence')),
  rationale text not null default '',
  evidence_refs text[] not null default '{}'::text[],
  evidence_freeze_id text not null,
  supersedes_version text not null default '',
  created_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.publication_manifests (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  research_package_id text not null references pal_eyes.research_packages(record_id) on delete restrict,
  approved_version_id text not null,
  specialist_adjudication_id text not null references pal_eyes.review_adjudications(id) on delete restrict,
  authority_adjudication_id text not null references pal_eyes.review_adjudications(id) on delete restrict,
  sovereign_adjudication_id text not null references pal_eyes.review_adjudications(id) on delete restrict,
  publication_status text not null default 'BLOCKED'
    check (publication_status in ('BLOCKED','APPROVED_CURRENT','SUPERSEDED')),
  immutable_snapshot jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists research_packages_site_stage_idx
  on pal_eyes.research_packages(site_entity_id, lifecycle_stage);
create index if not exists source_locators_source_idx
  on pal_eyes.source_locators(source_id, locator_type);
create index if not exists review_adjudications_entity_stage_idx
  on pal_eyes.review_adjudications(entity_type, entity_id, review_stage, created_at desc);
create index if not exists publication_manifests_site_status_idx
  on pal_eyes.publication_manifests(site_id, publication_status);

do $$
declare table_name text;
begin
  foreach table_name in array array[
    'research_packages','narrative_documents','narrative_sections',
    'narrative_paragraphs','paragraph_claim_links','legacy_source_mentions',
    'source_locators','claim_conflicts','temporal_assertions',
    'archive_provenance','research_entity_relations','research_aliases',
    'spatial_boundary_observations','current_condition_observations'
  ]
  loop
    execute format('alter table pal_eyes.%I enable row level security', table_name);
    execute format('alter table pal_eyes.%I force row level security', table_name);
    execute format('drop policy if exists research_internal_read on pal_eyes.%I', table_name);
    execute format(
      'create policy research_internal_read on pal_eyes.%I for select to authenticated using (pal_eyes.has_any_role(array[''researcher'',''editor'',''source_reviewer'',''gis_reviewer'',''rights_reviewer'',''review_manager'',''release_manager'',''system_admin'']))',
      table_name
    );
    execute format('drop policy if exists research_governed_write on pal_eyes.%I', table_name);
    execute format(
      'create policy research_governed_write on pal_eyes.%I for all to authenticated using (pal_eyes.has_any_role(array[''researcher'',''editor'',''review_manager'',''system_admin''])) with check (pal_eyes.has_any_role(array[''researcher'',''editor'',''review_manager'',''system_admin'']))',
      table_name
    );
  end loop;
end;
$$;

-- Adjudication and publication authority tables are intentionally excluded from
-- the general research write policy because permissive PostgreSQL policies OR
-- together. Their write authority must remain narrower than workspace editing.
alter table pal_eyes.review_adjudications enable row level security;
alter table pal_eyes.review_adjudications force row level security;
drop policy if exists review_adjudications_internal_read on pal_eyes.review_adjudications;
create policy review_adjudications_internal_read
  on pal_eyes.review_adjudications
  for select to authenticated
  using (pal_eyes.has_any_role(array[
    'researcher','editor','source_reviewer','gis_reviewer','rights_reviewer',
    'review_manager','release_manager','system_admin'
  ]));
drop policy if exists review_adjudications_governed_write on pal_eyes.review_adjudications;
create policy review_adjudications_governed_write
  on pal_eyes.review_adjudications
  for all to authenticated
  using (pal_eyes.has_any_role(array[
    'source_reviewer','gis_reviewer','rights_reviewer','review_manager','system_admin'
  ]))
  with check (pal_eyes.has_any_role(array[
    'source_reviewer','gis_reviewer','rights_reviewer','review_manager','system_admin'
  ]));

alter table pal_eyes.publication_manifests enable row level security;
alter table pal_eyes.publication_manifests force row level security;
drop policy if exists publication_manifest_internal_read on pal_eyes.publication_manifests;
create policy publication_manifest_internal_read
  on pal_eyes.publication_manifests
  for select to authenticated
  using (pal_eyes.has_any_role(array[
    'researcher','editor','source_reviewer','gis_reviewer','rights_reviewer',
    'review_manager','release_manager','system_admin'
  ]));

-- Publication manifests are deliberately stricter than research workspace tables.
drop policy if exists publication_manifest_release_manager_write on pal_eyes.publication_manifests;
create policy publication_manifest_release_manager_write
  on pal_eyes.publication_manifests
  for all to authenticated
  using (pal_eyes.has_any_role(array['release_manager','system_admin']))
  with check (pal_eyes.has_any_role(array['release_manager','system_admin']));

-- This migration defines storage contracts only. It does not create a public resolver,
-- apply data, grant publication authority, or mutate production.
commit;
