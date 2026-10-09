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

create or replace function rls_test.probe(
  p_probe text,
  p_actor text,
  p_role text,
  p_sub uuid,
  p_sql text,
  p_expect text  -- 'error' | 'ok' | 'rows=N' | 'rows>0' | 'affected=N'
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
  $q$update pal_eyes.sites set editorial_draft = 'نص اصطناعي' where id = 'synthetic-site-1'$q$, 'affected=1');
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

\o
\pset footer off
select seq, case when passed then 'PASS' else 'FAIL' end as result, probe, expectation, outcome, detail
from rls_test.results order by seq;

select
  count(*) filter (where passed) as passed,
  count(*) filter (where not passed) as failed,
  count(*) as total
from rls_test.results;
