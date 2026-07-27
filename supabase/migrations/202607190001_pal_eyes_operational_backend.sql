-- PalEyes governed operational backend R7.0.0
-- Source-only migration. Production deployment remains unapproved.

begin;

create extension if not exists pgcrypto;
create schema if not exists pal_eyes;

revoke all on schema pal_eyes from public;
grant usage on schema pal_eyes to authenticated;
grant usage on schema pal_eyes to service_role;

create or replace function pal_eyes.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists pal_eyes.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role_key text not null check (role_key in (
    'researcher',
    'editor',
    'source_reviewer',
    'gis_reviewer',
    'rights_reviewer',
    'review_manager',
    'release_manager',
    'system_admin'
  )),
  is_active boolean not null default true,
  granted_at timestamptz not null default timezone('utc', now()),
  granted_by uuid references auth.users(id),
  primary key (user_id, role_key)
);

create or replace function pal_eyes.has_any_role(required_roles text[])
returns boolean
language sql
stable
security definer
set search_path = pal_eyes, public
as $$
  select exists (
    select 1
    from pal_eyes.user_roles ur
    where ur.user_id = auth.uid()
      and ur.is_active
      and ur.role_key = any(required_roles)
  );
$$;

revoke all on function pal_eyes.has_any_role(text[]) from public;
grant execute on function pal_eyes.has_any_role(text[]) to authenticated;

create table if not exists pal_eyes.sites (
  id text primary key,
  slug text not null unique,
  name_ar text not null,
  name_en text not null default '',
  governorate_ar text not null default '',
  locality_ar text not null default '',
  site_type_ar text not null default '',
  page_category text not null check (page_category in (
    'GOVERNED_DRAFT_PAGE',
    'LIMITED_RESEARCH_PAGE'
  )),
  workflow_status text not null default 'DRAFT',
  publication_status text not null default 'BLOCKED' check (
    publication_status in ('BLOCKED', 'CANDIDATE', 'PUBLISHED', 'ARCHIVED')
  ),
  coordinate_status text not null default 'MISSING' check (
    coordinate_status in ('MISSING', 'REVIEW_CANDIDATE', 'INTERNAL_APPROVED', 'PUBLIC_APPROVED')
  ),
  original_draft_profile text not null default 'catalogSummary',
  editorial_draft text not null default '',
  source_count integer not null default 0 check (source_count >= 0),
  held_claim_count integer not null default 0 check (held_claim_count >= 0),
  version_number integer not null default 1 check (version_number > 0),
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.site_names (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  name_value text not null,
  language_code text not null default 'ar',
  name_type text not null default 'alternate',
  source_id text,
  verification_status text not null default 'PENDING',
  public_use_status text not null default 'BLOCKED',
  created_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.site_relationships (
  id text primary key,
  source_site_id text not null references pal_eyes.sites(id) on delete cascade,
  target_site_id text not null references pal_eyes.sites(id) on delete cascade,
  relation_type text not null,
  workflow_status text not null default 'CANDIDATE',
  public_use_status text not null default 'BLOCKED',
  evidence jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (source_site_id <> target_site_id)
);

create table if not exists pal_eyes.original_draft_layers (
  site_id text primary key references pal_eyes.sites(id) on delete cascade,
  source_filename text not null,
  source_sha256 text not null,
  source_line_count integer not null,
  content_profile text not null,
  summary_draft text not null default '',
  narrative_sections jsonb not null default '[]'::jsonb,
  source_mentions jsonb not null default '[]'::jsonb,
  timeline_periods jsonb not null default '[]'::jsonb,
  verification_status text not null default 'ORIGINAL_DRAFT_UNDER_REVIEW',
  development_visibility text not null default 'DEBUG_ONLY',
  public_release_status text not null default 'BLOCKED',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.sources (
  id text primary key,
  title text not null,
  attribution text not null default '',
  source_type text not null default 'reference',
  url text not null default '',
  workflow_status text not null default 'METADATA_REVIEW',
  rights_status text not null default 'PENDING',
  public_release_status text not null default 'BLOCKED',
  linked_site_count integer not null default 0,
  linked_claim_count integer not null default 0,
  bibliographic_data jsonb not null default '{}'::jsonb,
  rights_data jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.source_representations (
  id text primary key,
  source_id text not null references pal_eyes.sources(id) on delete cascade,
  representation_type text not null,
  storage_path text not null default '',
  checksum_sha256 text not null default '',
  mime_type text not null default '',
  rights_status text not null default 'PENDING',
  public_access_status text not null default 'BLOCKED',
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.editorial_records (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  claim_id text,
  editorial_text_ar text not null,
  workflow_status text not null default 'DRAFT',
  historical_review_status text not null default 'PENDING',
  rights_status text not null default 'PENDING',
  publication_status text not null default 'BLOCKED',
  source_ids text[] not null default '{}'::text[],
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.site_source_links (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  source_id text not null references pal_eyes.sources(id) on delete cascade,
  claim_id text,
  editorial_record_id text references pal_eyes.editorial_records(id) on delete set null,
  link_role text not null,
  verification_status text not null default 'PENDING',
  publication_status text not null default 'BLOCKED',
  created_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  unique (site_id, source_id, claim_id, editorial_record_id, link_role)
);

create table if not exists pal_eyes.claims (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  site_name_ar text not null default '',
  claim_text text not null,
  priority_tier text not null default 'P2_NORMAL',
  priority_score integer not null default 0,
  workflow_status text not null default 'NEW',
  evidence_status text not null default 'MISSING',
  publication_use text not null default 'BLOCKED',
  categories text[] not null default '{}'::text[],
  required_methods text[] not null default '{}'::text[],
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.claim_evidence_links (
  id text primary key,
  claim_id text not null references pal_eyes.claims(id) on delete cascade,
  source_id text not null references pal_eyes.sources(id) on delete cascade,
  evidence_scope text not null default '',
  locator text not null default '',
  support_status text not null default 'PENDING',
  reviewer_note text not null default '',
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (claim_id, source_id, locator)
);

create table if not exists pal_eyes.timeline_events (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  title_ar text not null,
  period_label text not null default '',
  start_year integer,
  end_year integer,
  event_text_ar text not null default '',
  verification_status text not null default 'PENDING',
  publication_status text not null default 'BLOCKED',
  source_ids text[] not null default '{}'::text[],
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.coordinate_candidates (
  id text primary key,
  site_id text not null references pal_eyes.sites(id) on delete cascade,
  site_name_ar text not null default '',
  latitude numeric(11,8) not null check (latitude between -90 and 90),
  longitude numeric(11,8) not null check (longitude between -180 and 180),
  source_id text references pal_eyes.sources(id) on delete set null,
  source_notation text not null default '',
  candidate_type text not null default 'reference_point',
  verification_status text not null default 'PENDING_GIS_REVIEW',
  promotion_status text not null default 'NOT_PROMOTED',
  public_map_use text not null default 'BLOCKED',
  reviewer_note text not null default '',
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.media_assets (
  id text primary key,
  site_id text references pal_eyes.sites(id) on delete set null,
  title text not null,
  asset_type text not null,
  storage_path text not null default '',
  checksum_sha256 text not null default '',
  owner_label text not null default 'غير محدد',
  rights_status text not null default 'PENDING_RIGHTS_REVIEW',
  internal_use_status text not null default 'BLOCKED',
  public_use_status text not null default 'BLOCKED',
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.media_rights (
  id text primary key,
  media_asset_id text not null references pal_eyes.media_assets(id) on delete cascade,
  owner_label text not null default '',
  license_label text not null default '',
  permission_reference text not null default '',
  review_status text not null default 'PENDING',
  internal_use_approved boolean not null default false,
  public_use_approved boolean not null default false,
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  note text not null default '',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.review_tasks (
  id text primary key,
  entity_type text not null,
  entity_id text not null,
  title text not null,
  review_type text not null,
  priority text not null default 'P2_NORMAL',
  status text not null default 'OPEN',
  assignee_id uuid references auth.users(id),
  assignee_label text not null default 'غير مسند',
  decision_note text not null default '',
  created_by uuid references auth.users(id),
  decided_by uuid references auth.users(id),
  decided_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.review_decisions (
  id text primary key,
  review_task_id text not null references pal_eyes.review_tasks(id) on delete cascade,
  decision text not null check (decision in (
    'ACCEPT',
    'RETURN_FOR_REVISION',
    'REJECT',
    'HOLD'
  )),
  note text not null default '',
  decided_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.content_versions (
  id text primary key,
  entity_type text not null,
  entity_id text not null,
  version_number integer not null check (version_number > 0),
  snapshot jsonb not null,
  change_summary text not null default '',
  created_by uuid references auth.users(id),
  created_at timestamptz not null default timezone('utc', now()),
  unique (entity_type, entity_id, version_number)
);

create table if not exists pal_eyes.release_candidates (
  id text primary key,
  title text not null,
  status text not null default 'CANDIDATE_FROZEN_PUBLICATION_BLOCKED',
  site_ids text[] not null default '{}'::text[],
  gates jsonb not null default '{}'::jsonb,
  frozen_snapshot jsonb not null default '{}'::jsonb,
  publication_status text not null default 'BLOCKED',
  created_by uuid references auth.users(id),
  created_by_label text not null default '',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists pal_eyes.audit_events (
  id text primary key,
  actor_id uuid references auth.users(id),
  actor_label text not null default '',
  action text not null,
  entity_type text not null,
  entity_id text not null,
  summary text not null default '',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists sites_name_ar_trgm_idx
  on pal_eyes.sites using gin (to_tsvector('simple', coalesce(name_ar, '') || ' ' || coalesce(name_en, '') || ' ' || coalesce(locality_ar, '')));
create index if not exists sites_governorate_idx on pal_eyes.sites(governorate_ar);
create index if not exists sources_title_search_idx
  on pal_eyes.sources using gin (to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(attribution, '')));
create index if not exists claims_text_search_idx
  on pal_eyes.claims using gin (to_tsvector('simple', coalesce(claim_text, '') || ' ' || coalesce(site_name_ar, '')));
create index if not exists review_tasks_status_priority_idx
  on pal_eyes.review_tasks(status, priority, created_at desc);
create index if not exists audit_events_entity_idx
  on pal_eyes.audit_events(entity_type, entity_id, created_at desc);

-- Updated-at triggers.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'sites',
    'site_relationships',
    'original_draft_layers',
    'sources',
    'editorial_records',
    'claims',
    'claim_evidence_links',
    'timeline_events',
    'coordinate_candidates',
    'media_assets',
    'media_rights',
    'review_tasks'
  ]
  loop
    execute format('drop trigger if exists set_updated_at on pal_eyes.%I', table_name);
    execute format(
      'create trigger set_updated_at before update on pal_eyes.%I for each row execute function pal_eyes.set_updated_at()',
      table_name
    );
  end loop;
end;
$$;

-- RLS activation.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'user_roles',
    'sites',
    'site_names',
    'site_relationships',
    'original_draft_layers',
    'sources',
    'source_representations',
    'editorial_records',
    'site_source_links',
    'claims',
    'claim_evidence_links',
    'timeline_events',
    'coordinate_candidates',
    'media_assets',
    'media_rights',
    'review_tasks',
    'review_decisions',
    'content_versions',
    'release_candidates',
    'audit_events'
  ]
  loop
    execute format('alter table pal_eyes.%I enable row level security', table_name);
    execute format('alter table pal_eyes.%I force row level security', table_name);
  end loop;
end;
$$;

-- Role self-read and administrator management.
drop policy if exists user_roles_self_read on pal_eyes.user_roles;
create policy user_roles_self_read on pal_eyes.user_roles
  for select to authenticated
  using (user_id = auth.uid() or pal_eyes.has_any_role(array['system_admin']));

drop policy if exists user_roles_admin_write on pal_eyes.user_roles;
create policy user_roles_admin_write on pal_eyes.user_roles
  for all to authenticated
  using (pal_eyes.has_any_role(array['system_admin']))
  with check (pal_eyes.has_any_role(array['system_admin']));

-- Internal read policies.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'sites', 'site_names', 'site_relationships', 'original_draft_layers',
    'sources', 'source_representations', 'editorial_records', 'site_source_links',
    'claims', 'claim_evidence_links', 'timeline_events', 'coordinate_candidates',
    'media_assets', 'media_rights', 'review_tasks', 'review_decisions',
    'content_versions', 'release_candidates', 'audit_events'
  ]
  loop
    execute format('drop policy if exists internal_read on pal_eyes.%I', table_name);
    execute format(
      'create policy internal_read on pal_eyes.%I for select to authenticated using (pal_eyes.has_any_role(array[''researcher'',''editor'',''source_reviewer'',''gis_reviewer'',''rights_reviewer'',''review_manager'',''release_manager'',''system_admin'']))',
      table_name
    );
  end loop;
end;
$$;

-- Sites and editorial workflow writes.
drop policy if exists sites_editor_write on pal_eyes.sites;
create policy sites_editor_write on pal_eyes.sites
  for all to authenticated
  using (pal_eyes.has_any_role(array['editor','review_manager','system_admin']))
  with check (pal_eyes.has_any_role(array['editor','review_manager','system_admin']));

drop policy if exists editorial_editor_write on pal_eyes.editorial_records;
create policy editorial_editor_write on pal_eyes.editorial_records
  for all to authenticated
  using (pal_eyes.has_any_role(array['editor','review_manager','system_admin']))
  with check (pal_eyes.has_any_role(array['editor','review_manager','system_admin']));

drop policy if exists original_draft_research_write on pal_eyes.original_draft_layers;
create policy original_draft_research_write on pal_eyes.original_draft_layers
  for all to authenticated
  using (pal_eyes.has_any_role(array['researcher','editor','review_manager','system_admin']))
  with check (pal_eyes.has_any_role(array['researcher','editor','review_manager','system_admin']));

-- Sources and claims writes.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'sources', 'source_representations', 'site_source_links',
    'claims', 'claim_evidence_links', 'timeline_events'
  ]
  loop
    execute format('drop policy if exists research_write on pal_eyes.%I', table_name);
    execute format(
      'create policy research_write on pal_eyes.%I for all to authenticated using (pal_eyes.has_any_role(array[''researcher'',''source_reviewer'',''editor'',''review_manager'',''system_admin''])) with check (pal_eyes.has_any_role(array[''researcher'',''source_reviewer'',''editor'',''review_manager'',''system_admin'']))',
      table_name
    );
  end loop;
end;
$$;

-- GIS writes.
do $$
declare
  table_name text;
begin
  foreach table_name in array array['coordinate_candidates', 'site_relationships', 'site_names']
  loop
    execute format('drop policy if exists gis_write on pal_eyes.%I', table_name);
    execute format(
      'create policy gis_write on pal_eyes.%I for all to authenticated using (pal_eyes.has_any_role(array[''gis_reviewer'',''review_manager'',''system_admin''])) with check (pal_eyes.has_any_role(array[''gis_reviewer'',''review_manager'',''system_admin'']))',
      table_name
    );
  end loop;
end;
$$;

-- Media rights writes.
do $$
declare
  table_name text;
begin
  foreach table_name in array array['media_assets', 'media_rights']
  loop
    execute format('drop policy if exists rights_write on pal_eyes.%I', table_name);
    execute format(
      'create policy rights_write on pal_eyes.%I for all to authenticated using (pal_eyes.has_any_role(array[''rights_reviewer'',''review_manager'',''system_admin''])) with check (pal_eyes.has_any_role(array[''rights_reviewer'',''review_manager'',''system_admin'']))',
      table_name
    );
  end loop;
end;
$$;

-- Review, version and audit writes.
do $$
declare
  table_name text;
begin
  foreach table_name in array array['review_tasks', 'review_decisions', 'content_versions', 'audit_events']
  loop
    execute format('drop policy if exists workflow_write on pal_eyes.%I', table_name);
    execute format(
      'create policy workflow_write on pal_eyes.%I for all to authenticated using (pal_eyes.has_any_role(array[''researcher'',''editor'',''source_reviewer'',''gis_reviewer'',''rights_reviewer'',''review_manager'',''release_manager'',''system_admin''])) with check (pal_eyes.has_any_role(array[''researcher'',''editor'',''source_reviewer'',''gis_reviewer'',''rights_reviewer'',''review_manager'',''release_manager'',''system_admin'']))',
      table_name
    );
  end loop;
end;
$$;

-- Release candidate writes are limited to release managers and administrators.
drop policy if exists release_candidate_write on pal_eyes.release_candidates;
create policy release_candidate_write on pal_eyes.release_candidates
  for all to authenticated
  using (pal_eyes.has_any_role(array['release_manager','system_admin']))
  with check (
    pal_eyes.has_any_role(array['release_manager','system_admin'])
    and publication_status = 'BLOCKED'
  );

-- Public read views expose only explicitly published records.
create or replace view pal_eyes.public_sites_v1
with (security_invoker = true)
as
select
  id,
  slug,
  name_ar,
  name_en,
  governorate_ar,
  locality_ar,
  site_type_ar,
  editorial_draft,
  coordinate_status,
  metadata,
  updated_at
from pal_eyes.sites
where publication_status = 'PUBLISHED';

create or replace view pal_eyes.public_sources_v1
with (security_invoker = true)
as
select
  id,
  title,
  attribution,
  source_type,
  url,
  rights_status,
  updated_at
from pal_eyes.sources
where public_release_status = 'PUBLISHED';

revoke all on all tables in schema pal_eyes from anon;

drop policy if exists public_sites_published_read on pal_eyes.sites;
create policy public_sites_published_read on pal_eyes.sites
  for select to anon
  using (publication_status = 'PUBLISHED');

drop policy if exists public_sources_published_read on pal_eyes.sources;
create policy public_sources_published_read on pal_eyes.sources
  for select to anon
  using (public_release_status = 'PUBLISHED');

grant select (
  id,
  slug,
  name_ar,
  name_en,
  governorate_ar,
  locality_ar,
  site_type_ar,
  editorial_draft,
  coordinate_status,
  metadata,
  updated_at
) on pal_eyes.sites to anon;

grant select (
  id,
  title,
  attribution,
  source_type,
  url,
  rights_status,
  updated_at
) on pal_eyes.sources to anon;

grant select on pal_eyes.public_sites_v1 to anon, authenticated;
grant select on pal_eyes.public_sources_v1 to anon, authenticated;

grant select, insert, update on all tables in schema pal_eyes to authenticated;
grant usage, select on all sequences in schema pal_eyes to authenticated;
grant all on all tables in schema pal_eyes to service_role;
grant all on all sequences in schema pal_eyes to service_role;

alter default privileges in schema pal_eyes
  revoke all on tables from public;
alter default privileges in schema pal_eyes
  grant select, insert, update on tables to authenticated;
alter default privileges in schema pal_eyes
  grant all on tables to service_role;

comment on schema pal_eyes is
  'Governed operational data plane for Palestinian Eyes. Public release remains fail-closed.';
comment on table pal_eyes.original_draft_layers is
  'Original uploaded historical drafts. Never exposed through public views.';
comment on table pal_eyes.release_candidates is
  'Frozen release candidates. Candidate creation is not publication.';

commit;
