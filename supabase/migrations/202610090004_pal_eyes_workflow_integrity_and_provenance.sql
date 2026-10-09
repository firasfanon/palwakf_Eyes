-- PalEyes workflow integrity, identity stamping and research provenance.
-- SOURCE CANDIDATE. Isolated CI / Staging only until separately authorized.
-- Depends on 202607190001, 202609220002, 202610090003.
-- Rollback: supabase/rollback/202610090004_down.sql
--
-- 1. Server-stamped identity: created_by / updated_by / actor_id / decided_by
--    come from auth.uid(), never from the client payload.
-- 2. Optimistic concurrency on site drafts (VERSION_CONFLICT).
-- 3. No role self-administration, even for system_admin.
-- 4. Separation of duties: review decisions need a reviewer role and cannot
--    be taken by the task creator; approval-like workflow states need
--    review_manager authority.
-- 5. Admin user directory RPC (system_admin only).
-- 6. Research provenance: Drive stays sovereign; operational copies carry
--    the sovereign reference, revision and SHA-256, and approved documents
--    are immutable.
-- 7. Public research view exposes approved manifests only.
-- 8. MFA (aal2) required for release authority and role administration.

begin;

-- 0. Authenticator assurance level ------------------------------------------
create or replace function pal_eyes.current_aal()
returns text
language sql
stable
set search_path = pal_eyes, public
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'aal',
    'aal1'
  );
$$;

revoke all on function pal_eyes.current_aal() from public;
grant execute on function pal_eyes.current_aal() to authenticated, anon;

-- Release authority now also demands a second factor (aal2).
create or replace function pal_eyes.has_release_authority()
returns boolean
language sql
stable
security definer
set search_path = pal_eyes, public
as $$
  select pal_eyes.has_any_role(array['release_manager', 'system_admin'])
     and pal_eyes.current_aal() = 'aal2';
$$;

drop policy if exists release_candidate_write on pal_eyes.release_candidates;
create policy release_candidate_write on pal_eyes.release_candidates
  for all to authenticated
  using (pal_eyes.has_release_authority())
  with check (pal_eyes.has_release_authority() and publication_status = 'BLOCKED');

-- 1. Identity stamping -------------------------------------------------------
create or replace function pal_eyes.stamp_actor()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
declare
  v_uid uuid := auth.uid();
  v_row jsonb := to_jsonb(new);
  v_patch jsonb := '{}'::jsonb;
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;
  if tg_op = 'INSERT' then
    if v_row ? 'created_by' then v_patch := v_patch || jsonb_build_object('created_by', v_uid); end if;
    if v_row ? 'actor_id' then v_patch := v_patch || jsonb_build_object('actor_id', v_uid); end if;
  end if;
  if v_row ? 'updated_by' then v_patch := v_patch || jsonb_build_object('updated_by', v_uid); end if;
  if v_row ? 'decided_by' and (v_row ->> 'decided_by') is not null then
    v_patch := v_patch || jsonb_build_object('decided_by', v_uid);
  end if;
  if v_patch = '{}'::jsonb then
    return new;
  end if;
  return jsonb_populate_record(new, v_patch);
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array[
    'sites', 'site_names', 'site_relationships', 'sources', 'source_representations',
    'editorial_records', 'site_source_links', 'claims', 'claim_evidence_links',
    'timeline_events', 'coordinate_candidates', 'media_assets', 'review_tasks',
    'review_decisions', 'content_versions', 'release_candidates', 'audit_events',
    'research_packages', 'review_adjudications', 'publication_manifests'
  ]
  loop
    execute format('drop trigger if exists a_stamp_actor on pal_eyes.%I', t);
    execute format(
      'create trigger a_stamp_actor before insert or update on pal_eyes.%I '
      'for each row execute function pal_eyes.stamp_actor()', t);
  end loop;
end;
$$;

-- 2. Optimistic concurrency on site drafts -------------------------------------
create or replace function pal_eyes.enforce_site_version()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;
  if new.editorial_draft is distinct from old.editorial_draft
     and new.version_number <> old.version_number + 1 then
    raise exception using
      errcode = '40001',
      message = format('VERSION_CONFLICT: site %s is at version %s', old.id, old.version_number);
  end if;
  if new.editorial_draft is not distinct from old.editorial_draft
     and new.version_number <> old.version_number then
    raise exception using errcode = '42501', message = 'VERSION_NUMBER_IS_SERVER_GOVERNED';
  end if;
  return new;
end;
$$;

drop trigger if exists b_enforce_site_version on pal_eyes.sites;
create trigger b_enforce_site_version
  before update on pal_eyes.sites
  for each row execute function pal_eyes.enforce_site_version();

-- 3. No role self-administration -----------------------------------------------
drop policy if exists user_roles_admin_write on pal_eyes.user_roles;
create policy user_roles_admin_write on pal_eyes.user_roles
  for all to authenticated
  using (pal_eyes.has_any_role(array['system_admin']) and user_id <> auth.uid()
         and pal_eyes.current_aal() = 'aal2')
  with check (pal_eyes.has_any_role(array['system_admin']) and user_id <> auth.uid()
              and pal_eyes.current_aal() = 'aal2');

-- 4. Separation of duties --------------------------------------------------------
create or replace function pal_eyes.enforce_review_authority()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
declare
  v_task pal_eyes.review_tasks%rowtype;
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;
  if not pal_eyes.has_any_role(array[
    'source_reviewer', 'gis_reviewer', 'rights_reviewer', 'review_manager', 'system_admin'
  ]) then
    raise exception using errcode = '42501', message = 'REVIEW_AUTHORITY_REQUIRED';
  end if;
  if tg_table_name = 'review_decisions' then
    select * into v_task from pal_eyes.review_tasks where id = new.review_task_id;
  else
    v_task := new;
  end if;
  if v_task.created_by is not null and v_task.created_by = auth.uid() then
    raise exception using errcode = '42501', message = 'SELF_REVIEW_FORBIDDEN';
  end if;
  return new;
end;
$$;

drop trigger if exists c_review_decision_authority on pal_eyes.review_decisions;
create trigger c_review_decision_authority
  before insert on pal_eyes.review_decisions
  for each row execute function pal_eyes.enforce_review_authority();

drop trigger if exists c_review_task_decision_authority on pal_eyes.review_tasks;
create trigger c_review_task_decision_authority
  before update of status on pal_eyes.review_tasks
  for each row
  when (new.status is distinct from old.status and new.status <> 'OPEN')
  execute function pal_eyes.enforce_review_authority();

create or replace function pal_eyes.enforce_workflow_authority()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;
  if new.workflow_status is distinct from old.workflow_status
     and (new.workflow_status like '%APPROVED%' or new.workflow_status like '%PUBLISH%')
     and not pal_eyes.has_any_role(array['review_manager', 'release_manager', 'system_admin']) then
    raise exception using
      errcode = '42501',
      message = format('WORKFLOW_AUTHORITY_REQUIRED: %s', new.workflow_status);
  end if;
  return new;
end;
$$;

drop trigger if exists c_site_workflow_authority on pal_eyes.sites;
create trigger c_site_workflow_authority
  before update of workflow_status on pal_eyes.sites
  for each row execute function pal_eyes.enforce_workflow_authority();

-- 5. Admin user directory ---------------------------------------------------------
create or replace function pal_eyes.admin_list_users()
returns table (user_id uuid, email text, roles text[])
language plpgsql
stable
security definer
set search_path = pal_eyes, public
as $$
begin
  if not pal_eyes.has_any_role(array['system_admin']) then
    raise exception using errcode = '42501', message = 'SYSTEM_ADMIN_REQUIRED';
  end if;
  return query
    select u.id, u.email::text,
           coalesce(array_agg(ur.role_key order by ur.role_key)
                      filter (where ur.is_active), '{}'::text[])
    from auth.users u
    left join pal_eyes.user_roles ur on ur.user_id = u.id
    group by u.id, u.email
    order by u.email;
end;
$$;

revoke all on function pal_eyes.admin_list_users() from public;
grant execute on function pal_eyes.admin_list_users() to authenticated;

-- 6. Research provenance (Drive sovereign) ---------------------------------------
alter table pal_eyes.narrative_documents
  add column if not exists sovereign_store text not null default 'WORKSPACE_DRIVE'
    check (sovereign_store in ('WORKSPACE_DRIVE')),
  add column if not exists sovereign_file_id text not null default '',
  add column if not exists sovereign_revision_id text not null default '',
  add column if not exists sovereign_url text not null default '',
  add column if not exists content_sha256 text not null default '',
  add column if not exists copy_kind text not null default 'REFERENCE_ONLY'
    check (copy_kind in ('REFERENCE_ONLY', 'FULL_OPERATIONAL_COPY')),
  add column if not exists derived_from_document_id text references pal_eyes.narrative_documents(id),
  add column if not exists approval_state text not null default 'DRAFT'
    check (approval_state in ('DRAFT', 'UNDER_REVIEW', 'APPROVED_FOR_PUBLICATION', 'SUPERSEDED'));

alter table pal_eyes.narrative_documents
  drop constraint if exists narrative_documents_copy_provenance;
alter table pal_eyes.narrative_documents
  add constraint narrative_documents_copy_provenance check (
    copy_kind = 'REFERENCE_ONLY'
    or (sovereign_file_id <> '' and sovereign_revision_id <> ''
        and content_sha256 ~ '^[0-9a-f]{64}$')
  );

create or replace function pal_eyes.protect_approved_narrative()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
declare
  v_doc_id text;
  v_state text;
begin
  if current_user not in ('authenticated', 'anon') then
    return coalesce(new, old);
  end if;
  if tg_table_name = 'narrative_documents' then
    if old.approval_state = 'APPROVED_FOR_PUBLICATION'
       and new.approval_state is distinct from 'SUPERSEDED' then
      raise exception using errcode = '42501', message = 'APPROVED_NARRATIVE_IMMUTABLE';
    end if;
    if new.approval_state = 'APPROVED_FOR_PUBLICATION'
       and old.approval_state is distinct from 'APPROVED_FOR_PUBLICATION'
       and not pal_eyes.has_any_role(array['review_manager', 'system_admin']) then
      raise exception using errcode = '42501', message = 'NARRATIVE_APPROVAL_AUTHORITY_REQUIRED';
    end if;
    return new;
  end if;
  if tg_table_name = 'narrative_sections' then
    v_doc_id := coalesce(new.narrative_document_id, old.narrative_document_id);
  else
    select s.narrative_document_id into v_doc_id
      from pal_eyes.narrative_sections s
     where s.id = coalesce(new.narrative_section_id, old.narrative_section_id);
  end if;
  select approval_state into v_state from pal_eyes.narrative_documents where id = v_doc_id;
  if v_state = 'APPROVED_FOR_PUBLICATION' then
    raise exception using errcode = '42501', message = 'APPROVED_NARRATIVE_IMMUTABLE';
  end if;
  return coalesce(new, old);
end;
$$;

drop trigger if exists d_protect_approved_doc on pal_eyes.narrative_documents;
create trigger d_protect_approved_doc
  before insert or update on pal_eyes.narrative_documents
  for each row execute function pal_eyes.protect_approved_narrative();
drop trigger if exists d_protect_approved_section on pal_eyes.narrative_sections;
create trigger d_protect_approved_section
  before insert or update or delete on pal_eyes.narrative_sections
  for each row execute function pal_eyes.protect_approved_narrative();
drop trigger if exists d_protect_approved_paragraph on pal_eyes.narrative_paragraphs;
create trigger d_protect_approved_paragraph
  before insert or update or delete on pal_eyes.narrative_paragraphs
  for each row execute function pal_eyes.protect_approved_narrative();

-- 7. Public research view: approved manifests only ----------------------------------
create or replace view pal_eyes.public_research_v1 as
select
  m.id as manifest_id,
  s.slug as site_slug,
  s.name_ar as site_name_ar,
  m.research_package_id,
  m.approved_version_id,
  m.created_at as approved_at
from pal_eyes.publication_manifests m
join pal_eyes.sites s on s.id = m.site_id
where m.publication_status = 'APPROVED_CURRENT'
  and s.publication_status = 'PUBLISHED';

revoke all on pal_eyes.public_research_v1 from public;
grant select on pal_eyes.public_research_v1 to anon, authenticated;

-- Public read surfaces (public_sites_v1, public_sources_v1, this view) were
-- unreachable for anon because 0001 never granted schema USAGE. Table-level
-- privileges and RLS still gate every relation individually.
grant usage on schema pal_eyes to anon;

-- security_invoker views also need the filter column readable by anon
-- (RLS still restricts anon to PUBLISHED rows only).
grant select (publication_status) on pal_eyes.sites to anon;
grant select (public_release_status) on pal_eyes.sources to anon;

comment on view pal_eyes.public_research_v1 is
  'Owner-executed view: only APPROVED_CURRENT manifests of PUBLISHED sites; no draft text.';

commit;
