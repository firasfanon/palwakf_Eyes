-- PalEyes server-boundary role tests with SYNTHETIC, NON-PRODUCTION identities.
-- Run only on an isolated throwaway Postgres after supabase_auth_stub.sql and
-- the repository migrations. Every probe runs inside a rolled-back
-- subtransaction, so probes are independent and leave no data behind.

create schema if not exists rls_test;

create table if not exists rls_test.results (
  seq serial primary key,
  probe text not null,
  actor text not null,
  expectation text not null,
  outcome text not null,
  passed boolean not null,
  detail text not null default ''
);

truncate rls_test.results;

-- Synthetic identities (fixed UUIDs, example.invalid mailboxes).
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000001', 'no-role@synthetic.example.invalid'),
  ('00000000-0000-4000-8000-000000000002', 'researcher@synthetic.example.invalid'),
  ('00000000-0000-4000-8000-000000000003', 'editor@synthetic.example.invalid'),
  ('00000000-0000-4000-8000-000000000004', 'release-manager@synthetic.example.invalid'),
  ('00000000-0000-4000-8000-000000000005', 'system-admin@synthetic.example.invalid'),
  ('00000000-0000-4000-8000-000000000006', 'rights-reviewer@synthetic.example.invalid')
on conflict do nothing;

insert into pal_eyes.user_roles (user_id, role_key) values
  ('00000000-0000-4000-8000-000000000002', 'researcher'),
  ('00000000-0000-4000-8000-000000000003', 'editor'),
  ('00000000-0000-4000-8000-000000000004', 'release_manager'),
  ('00000000-0000-4000-8000-000000000005', 'system_admin'),
  ('00000000-0000-4000-8000-000000000006', 'rights_reviewer')
on conflict do nothing;

-- Bounded synthetic fixtures (never real content).
insert into pal_eyes.sites (id, slug, name_ar, page_category)
values
  ('synthetic-site-1', 'synthetic-site-1', 'موقع اصطناعي للاختبار', 'GOVERNED_DRAFT_PAGE')
on conflict do nothing;

insert into pal_eyes.sources (id, title)
values ('synthetic-source-1', 'مصدر اصطناعي للاختبار')
on conflict do nothing;

insert into pal_eyes.audit_events (id, action, entity_type, entity_id, summary)
values ('synthetic-audit-1', 'CREATE', 'site', 'synthetic-site-1', 'synthetic')
on conflict do nothing;

insert into pal_eyes.review_tasks (id, entity_type, entity_id, title, review_type, created_by) values
  ('synthetic-review-1', 'site', 'synthetic-site-1', 'مراجعة اصطناعية ١', 'EDITORIAL', '00000000-0000-4000-8000-000000000003'),
  ('synthetic-review-2', 'site', 'synthetic-site-1', 'مراجعة اصطناعية ٢', 'RIGHTS', '00000000-0000-4000-8000-000000000006')
on conflict do nothing;

do $fixture$
begin
  if to_regclass('pal_eyes.research_packages') is not null then
    insert into pal_eyes.research_packages (record_id, package_id, version, site_entity_id, research_topic_id)
    values ('synthetic-pkg-1', 'SYN-PKG-1', 'v1', 'synthetic-site-1', 'synthetic-topic')
    on conflict do nothing;
  end if;
  if exists (select 1 from information_schema.columns
              where table_schema = 'pal_eyes' and table_name = 'narrative_documents'
                and column_name = 'approval_state') then
    insert into pal_eyes.narrative_documents (id, research_package_id, title, approval_state)
    values ('synthetic-doc-approved', 'synthetic-pkg-1', 'وثيقة معتمدة اصطناعية', 'APPROVED_FOR_PUBLICATION')
    on conflict do nothing;
    insert into pal_eyes.narrative_sections (id, narrative_document_id, section_order, title)
    values ('synthetic-sec-approved', 'synthetic-doc-approved', 1, 'قسم')
    on conflict do nothing;
    insert into pal_eyes.narrative_paragraphs (id, narrative_section_id, paragraph_order, paragraph_text)
    values ('synthetic-par-approved', 'synthetic-sec-approved', 1, 'فقرة معتمدة')
    on conflict do nothing;
  end if;
end;
$fixture$;

create or replace function rls_test.probe(
  p_probe text,
  p_actor text,
  p_role text,
  p_sub uuid,
  p_sql text,
  p_expect text,  -- 'error' | 'ok' | 'rows=N' | 'rows>0' | 'affected=N'
  p_aal text default 'aal2'
)
returns void
language plpgsql
as $$
declare
  v_outcome text;
  v_detail text := '';
  v_rows bigint;
  v_passed boolean;
begin
  begin
    perform set_config('request.jwt.claim.sub', coalesce(p_sub::text, ''), true);
    perform set_config('request.jwt.claims',
      case when p_sub is null then '' else json_build_object('sub', p_sub, 'aal', p_aal)::text end, true);
    execute format('set local role %I', p_role);
    if p_expect like 'rows%' then
      execute 'select count(*) from (' || p_sql || ') q' into v_rows;
      v_outcome := 'rows=' || v_rows;
    else
      execute p_sql;
      get diagnostics v_rows = row_count;
      v_outcome := 'ok affected=' || v_rows;
    end if;
    raise exception using errcode = 'P0001', message = '__probe_rollback__';
  exception
    when others then
      if sqlerrm <> '__probe_rollback__' then
        v_outcome := 'error';
        v_detail := sqlstate || ' ' || sqlerrm;
      end if;
  end;

  v_passed := case
    when p_expect = 'error' then v_outcome = 'error'
    when p_expect = 'ok' then v_outcome like 'ok%'
    when p_expect = 'rows>0' then v_outcome like 'rows=%' and v_outcome <> 'rows=0'
    when p_expect like 'rows=%' then v_outcome = p_expect
    when p_expect like 'affected=%' then v_outcome = 'ok ' || p_expect
    else false
  end;

  insert into rls_test.results (probe, actor, expectation, outcome, passed, detail)
  values (p_probe, p_actor, p_expect, v_outcome, v_passed, left(v_detail, 220));
end;
$$;

-- Identity shortcuts
\set NOROLE '''00000000-0000-4000-8000-000000000001'''
\set RESEARCHER '''00000000-0000-4000-8000-000000000002'''
\set EDITOR '''00000000-0000-4000-8000-000000000003'''
\set RELEASE '''00000000-0000-4000-8000-000000000004'''
\set ADMIN '''00000000-0000-4000-8000-000000000005'''
\set RIGHTS '''00000000-0000-4000-8000-000000000006'''

\o /dev/null

-- A. Anonymous visitor
select rls_test.probe('A1 anon reads internal sites table', 'anon', 'anon', null,
  'select * from pal_eyes.sites', 'error');
select rls_test.probe('A2 anon reads original draft layers', 'anon', 'anon', null,
  'select * from pal_eyes.original_draft_layers', 'error');
select rls_test.probe('A3 anon inserts a site', 'anon', 'anon', null,
  $q$insert into pal_eyes.sites (id, slug, name_ar, page_category) values ('x','x','x','GOVERNED_DRAFT_PAGE')$q$, 'error');
select rls_test.probe('A4 anon reads audit events', 'anon', 'anon', null,
  'select * from pal_eyes.audit_events', 'error');

-- B. Authenticated account without any PalEyes role
select rls_test.probe('B1 no-role reads sites (RLS hides rows)', 'no-role', 'authenticated', :NOROLE,
  'select * from pal_eyes.sites', 'rows=0');
select rls_test.probe('B2 no-role inserts a site', 'no-role', 'authenticated', :NOROLE,
  $q$insert into pal_eyes.sites (id, slug, name_ar, page_category) values ('x','x','x','GOVERNED_DRAFT_PAGE')$q$, 'error');
select rls_test.probe('B3 no-role self-grants system_admin', 'no-role', 'authenticated', :NOROLE,
  $q$insert into pal_eyes.user_roles (user_id, role_key) values ('00000000-0000-4000-8000-000000000001','system_admin')$q$, 'error');
select rls_test.probe('B4 no-role updates a site (zero rows visible)', 'no-role', 'authenticated', :NOROLE,
  $q$update pal_eyes.sites set editorial_draft = 'tamper' where id = 'synthetic-site-1'$q$, 'affected=0');

-- C. Researcher
select rls_test.probe('C1 researcher reads sites', 'researcher', 'authenticated', :RESEARCHER,
  'select * from pal_eyes.sites', 'rows>0');
select rls_test.probe('C2 researcher inserts a site (editor-only)', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.sites (id, slug, name_ar, page_category) values ('x','x','x','GOVERNED_DRAFT_PAGE')$q$, 'error');
select rls_test.probe('C3 researcher creates release candidate', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.release_candidates (id, title) values ('rc-x','x')$q$, 'error');
select rls_test.probe('C4 researcher self-grants system_admin', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.user_roles (user_id, role_key) values ('00000000-0000-4000-8000-000000000002','system_admin')$q$, 'error');
select rls_test.probe('C5 researcher creates source (positive CRUD)', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.sources (id, title) values ('synthetic-source-2','مصدر اصطناعي')$q$, 'ok');
select rls_test.probe('C6 researcher marks source PUBLISHED', 'researcher', 'authenticated', :RESEARCHER,
  $q$update pal_eyes.sources set public_release_status = 'PUBLISHED' where id = 'synthetic-source-1'$q$, 'error');
select rls_test.probe('C7 researcher rewrites an audit event', 'researcher', 'authenticated', :RESEARCHER,
  $q$update pal_eyes.audit_events set summary = 'rewritten' where id = 'synthetic-audit-1'$q$, 'error');
select rls_test.probe('C8 researcher deletes an audit event', 'researcher', 'authenticated', :RESEARCHER,
  $q$delete from pal_eyes.audit_events where id = 'synthetic-audit-1'$q$, 'error');
select rls_test.probe('C9 researcher appends an audit event (positive)', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.audit_events (id, action, entity_type, entity_id) values ('synthetic-audit-2','NOTE','site','synthetic-site-1')$q$, 'ok');

-- D. Editor
select rls_test.probe('D1 editor updates draft text (positive CRUD)', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set editorial_draft = 'نص اصطناعي', version_number = version_number + 1 where id = 'synthetic-site-1'$q$, 'affected=1');
select rls_test.probe('D2 editor publishes a site directly', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set publication_status = 'PUBLISHED' where id = 'synthetic-site-1'$q$, 'error');
select rls_test.probe('D2b editor promotes a site to CANDIDATE', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set publication_status = 'CANDIDATE' where id = 'synthetic-site-1'$q$, 'error');
select rls_test.probe('D3 editor inserts an already-PUBLISHED site', 'editor', 'authenticated', :EDITOR,
  $q$insert into pal_eyes.sites (id, slug, name_ar, page_category, publication_status) values ('x','x','x','GOVERNED_DRAFT_PAGE','PUBLISHED')$q$, 'error');
select rls_test.probe('D4 editor approves coordinates for public', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set coordinate_status = 'PUBLIC_APPROVED' where id = 'synthetic-site-1'$q$, 'error');
select rls_test.probe('D5 editor creates release candidate', 'editor', 'authenticated', :EDITOR,
  $q$insert into pal_eyes.release_candidates (id, title) values ('rc-x','x')$q$, 'error');
select rls_test.probe('D6 editor creates a new BLOCKED site (positive CRUD)', 'editor', 'authenticated', :EDITOR,
  $q$insert into pal_eyes.sites (id, slug, name_ar, page_category) values ('synthetic-site-2','synthetic-site-2','موقع اصطناعي ٢','GOVERNED_DRAFT_PAGE')$q$, 'ok');

-- E. Rights reviewer
select rls_test.probe('E1 rights reviewer edits a site', 'rights-reviewer', 'authenticated', :RIGHTS,
  $q$update pal_eyes.sites set editorial_draft = 'x' where id = 'synthetic-site-1'$q$, 'affected=0');

-- F. Release manager
select rls_test.probe('F1 release manager creates BLOCKED candidate', 'release-manager', 'authenticated', :RELEASE,
  $q$insert into pal_eyes.release_candidates (id, title) values ('rc-1','مرشح اصطناعي')$q$, 'ok');
select rls_test.probe('F2 release manager creates PUBLISHED candidate', 'release-manager', 'authenticated', :RELEASE,
  $q$insert into pal_eyes.release_candidates (id, title, publication_status) values ('rc-2','x','PUBLISHED')$q$, 'error');
select rls_test.probe('F3 release manager has no direct site write', 'release-manager', 'authenticated', :RELEASE,
  $q$update pal_eyes.sites set publication_status = 'PUBLISHED' where id = 'synthetic-site-1'$q$, 'affected=0');
select rls_test.probe('F4 release manager rewrites an audit event', 'release-manager', 'authenticated', :RELEASE,
  $q$update pal_eyes.audit_events set summary = 'rewritten' where id = 'synthetic-audit-1'$q$, 'error');

-- G. System administrator
select rls_test.probe('G1 system admin grants a role', 'system-admin', 'authenticated', :ADMIN,
  $q$insert into pal_eyes.user_roles (user_id, role_key) values ('00000000-0000-4000-8000-000000000001','researcher')$q$, 'ok');
select rls_test.probe('G1b system admin publishes a site (explicit authority)', 'system-admin', 'authenticated', :ADMIN,
  $q$update pal_eyes.sites set publication_status = 'PUBLISHED' where id = 'synthetic-site-1'$q$, 'affected=1');
select rls_test.probe('G2 system admin rewrites an audit event', 'system-admin', 'authenticated', :ADMIN,
  $q$update pal_eyes.audit_events set summary = 'rewritten' where id = 'synthetic-audit-1'$q$, 'error');


-- H. Workflow integrity and provenance (migration 0004)
select rls_test.probe('H1 editor saves draft without version bump (lost update)', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set editorial_draft = 'stale' where id = 'synthetic-site-1'$q$, 'error');
select rls_test.probe('H2 stale concurrent save is rejected', 'editor', 'authenticated', :EDITOR,
  $q$do $d$ begin
     update pal_eyes.sites set editorial_draft = 'first', version_number = 2 where id = 'synthetic-site-1';
     update pal_eyes.sites set editorial_draft = 'second', version_number = 2 where id = 'synthetic-site-1';
   end $d$$q$, 'error');
select rls_test.probe('H3 editor cannot spoof created_by', 'editor', 'authenticated', :EDITOR,
  $q$do $d$ begin
     insert into pal_eyes.sources (id, title, created_by) values ('syn-src-spoof', 'x', '00000000-0000-4000-8000-000000000005');
     if (select created_by from pal_eyes.sources where id = 'syn-src-spoof') is distinct from auth.uid() then
       raise exception 'CREATED_BY_SPOOF_ACCEPTED';
     end if;
   end $d$$q$, 'ok');
select rls_test.probe('H4 researcher cannot spoof audit actor', 'researcher', 'authenticated', :RESEARCHER,
  $q$do $d$ begin
     insert into pal_eyes.audit_events (id, action, entity_type, entity_id, actor_id)
       values ('syn-audit-spoof', 'NOTE', 'site', 'synthetic-site-1', '00000000-0000-4000-8000-000000000005');
     if (select actor_id from pal_eyes.audit_events where id = 'syn-audit-spoof') is distinct from auth.uid() then
       raise exception 'ACTOR_SPOOF_ACCEPTED';
     end if;
   end $d$$q$, 'ok');
select rls_test.probe('H5 system admin cannot grant a role to self', 'system-admin', 'authenticated', :ADMIN,
  $q$insert into pal_eyes.user_roles (user_id, role_key) values ('00000000-0000-4000-8000-000000000005','release_manager')$q$, 'error');
select rls_test.probe('H6 system admin cannot deactivate own role', 'system-admin', 'authenticated', :ADMIN,
  $q$update pal_eyes.user_roles set is_active = false where user_id = '00000000-0000-4000-8000-000000000005'$q$, 'affected=0');
select rls_test.probe('H6b system admin deactivates another user''s role (positive)', 'system-admin', 'authenticated', :ADMIN,
  $q$update pal_eyes.user_roles set is_active = false where user_id = '00000000-0000-4000-8000-000000000003'$q$, 'affected=1');
select rls_test.probe('H6c roles are never hard-deleted by API roles', 'system-admin', 'authenticated', :ADMIN,
  $q$delete from pal_eyes.user_roles where user_id = '00000000-0000-4000-8000-000000000003'$q$, 'error');
select rls_test.probe('H7 researcher cannot decide a review', 'researcher', 'authenticated', :RESEARCHER,
  $q$update pal_eyes.review_tasks set status = 'ACCEPT' where id = 'synthetic-review-1'$q$, 'error');
select rls_test.probe('H8 rights reviewer decides another author''s review (positive)', 'rights-reviewer', 'authenticated', :RIGHTS,
  $q$update pal_eyes.review_tasks set status = 'ACCEPT' where id = 'synthetic-review-1'$q$, 'affected=1');
select rls_test.probe('H9 rights reviewer cannot review own task', 'rights-reviewer', 'authenticated', :RIGHTS,
  $q$update pal_eyes.review_tasks set status = 'ACCEPT' where id = 'synthetic-review-2'$q$, 'error');
select rls_test.probe('H10 researcher cannot record a review decision', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.review_decisions (id, review_task_id, decision) values ('syn-dec-1','synthetic-review-1','ACCEPT')$q$, 'error');
select rls_test.probe('H11 editor cannot mark a site APPROVED', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set workflow_status = 'EDITORIALLY_APPROVED' where id = 'synthetic-site-1'$q$, 'error');
select rls_test.probe('H12 editor submits for review (positive)', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set workflow_status = 'SUBMITTED_FOR_REVIEW' where id = 'synthetic-site-1'$q$, 'affected=1');
select rls_test.probe('H13 editor cannot list users', 'editor', 'authenticated', :EDITOR,
  $q$select * from pal_eyes.admin_list_users()$q$, 'error');
select rls_test.probe('H14 system admin lists users (positive)', 'system-admin', 'authenticated', :ADMIN,
  $q$select * from pal_eyes.admin_list_users()$q$, 'rows>0');
select rls_test.probe('H15 anon cannot list users', 'anon', 'anon', null,
  $q$select * from pal_eyes.admin_list_users()$q$, 'error');
select rls_test.probe('H16 anon reads public sites view (nothing published)', 'anon', 'anon', null,
  $q$select * from pal_eyes.public_sites_v1$q$, 'rows=0');
select rls_test.probe('H17 anon reads public research view (nothing approved)', 'anon', 'anon', null,
  $q$select * from pal_eyes.public_research_v1$q$, 'rows=0');
select rls_test.probe('H18 anon still cannot read draft columns', 'anon', 'anon', null,
  $q$select workflow_status from pal_eyes.sites$q$, 'error');
select rls_test.probe('H19 full operational copy without provenance', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.narrative_documents (id, research_package_id, title, copy_kind) values ('syn-doc-x','synthetic-pkg-1','x','FULL_OPERATIONAL_COPY')$q$, 'error');
select rls_test.probe('H20 full operational copy with Drive provenance (positive)', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.narrative_documents (id, research_package_id, title, copy_kind, sovereign_file_id, sovereign_revision_id, content_sha256)
     values ('syn-doc-y','synthetic-pkg-1','y','FULL_OPERATIONAL_COPY','drive-file-synthetic','rev-1', repeat('a', 64))$q$, 'ok');
select rls_test.probe('H21 researcher cannot approve a narrative', 'researcher', 'authenticated', :RESEARCHER,
  $q$insert into pal_eyes.narrative_documents (id, research_package_id, title, approval_state) values ('syn-doc-z','synthetic-pkg-1','z','APPROVED_FOR_PUBLICATION')$q$, 'error');
select rls_test.probe('H22 approved narrative paragraph is immutable', 'researcher', 'authenticated', :RESEARCHER,
  $q$update pal_eyes.narrative_paragraphs set paragraph_text = 'تحريف' where id = 'synthetic-par-approved'$q$, 'error');
select rls_test.probe('H23 researcher cannot delete a site', 'researcher', 'authenticated', :RESEARCHER,
  $q$delete from pal_eyes.sites where id = 'synthetic-site-1'$q$, 'error');
select rls_test.probe('H24 editor full save-draft flow as the app runs it (positive)', 'editor', 'authenticated', :EDITOR,
  $q$do $d$ declare v int; begin
     select version_number into v from pal_eyes.sites where id = 'synthetic-site-1';
     update pal_eyes.sites set editorial_draft = 'مسودة', workflow_status = 'DRAFT_UPDATED', version_number = v + 1 where id = 'synthetic-site-1';
     insert into pal_eyes.content_versions (id, entity_type, entity_id, version_number, snapshot)
       values ('syn-ver-1', 'site', 'synthetic-site-1', v + 1, '{"publication_status":"BLOCKED"}');
     insert into pal_eyes.audit_events (id, action, entity_type, entity_id) values ('syn-audit-save', 'SITE_DRAFT_SAVED', 'site', 'synthetic-site-1');
   end $d$$q$, 'ok');

-- I. Second factor (aal2) for sensitive authority
select rls_test.probe('I1 release manager without MFA cannot create candidate', 'release-manager', 'authenticated', :RELEASE,
  $q$insert into pal_eyes.release_candidates (id, title) values ('rc-aal1','x')$q$, 'error', 'aal1');
select rls_test.probe('I2 system admin without MFA cannot publish', 'system-admin', 'authenticated', :ADMIN,
  $q$update pal_eyes.sites set publication_status = 'PUBLISHED' where id = 'synthetic-site-1'$q$, 'error', 'aal1');
select rls_test.probe('I3 system admin without MFA cannot grant roles', 'system-admin', 'authenticated', :ADMIN,
  $q$insert into pal_eyes.user_roles (user_id, role_key) values ('00000000-0000-4000-8000-000000000001','editor')$q$, 'error', 'aal1');
select rls_test.probe('I4 editor drafting needs no second factor (positive)', 'editor', 'authenticated', :EDITOR,
  $q$update pal_eyes.sites set editorial_draft = 'x', version_number = version_number + 1 where id = 'synthetic-site-1'$q$, 'affected=1', 'aal1');

\o
\pset footer off
select seq, case when passed then 'PASS' else 'FAIL' end as result, probe, expectation, outcome, detail
from rls_test.results order by seq;

select
  count(*) filter (where passed) as passed,
  count(*) filter (where not passed) as failed,
  count(*) as total
from rls_test.results;
