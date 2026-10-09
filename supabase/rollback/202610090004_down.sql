-- Rollback for 202610090004_pal_eyes_workflow_integrity_and_provenance.sql
-- Restores the 0003 state. Provenance columns are kept (additive, data-bearing);
-- drop them only with a separate data-retention decision.
begin;

revoke select (publication_status) on pal_eyes.sites from anon;
revoke select (public_release_status) on pal_eyes.sources from anon;
revoke usage on schema pal_eyes from anon;
drop view if exists pal_eyes.public_research_v1;

drop trigger if exists d_protect_approved_doc on pal_eyes.narrative_documents;
drop trigger if exists d_protect_approved_section on pal_eyes.narrative_sections;
drop trigger if exists d_protect_approved_paragraph on pal_eyes.narrative_paragraphs;
drop function if exists pal_eyes.protect_approved_narrative();
alter table pal_eyes.narrative_documents drop constraint if exists narrative_documents_copy_provenance;

drop function if exists pal_eyes.admin_list_users();

drop trigger if exists c_site_workflow_authority on pal_eyes.sites;
drop function if exists pal_eyes.enforce_workflow_authority();
drop trigger if exists c_review_decision_authority on pal_eyes.review_decisions;
drop trigger if exists c_review_task_decision_authority on pal_eyes.review_tasks;
drop function if exists pal_eyes.enforce_review_authority();

drop policy if exists user_roles_admin_write on pal_eyes.user_roles;
create policy user_roles_admin_write on pal_eyes.user_roles
  for all to authenticated
  using (pal_eyes.has_any_role(array['system_admin']))
  with check (pal_eyes.has_any_role(array['system_admin']));

drop policy if exists release_candidate_write on pal_eyes.release_candidates;
create policy release_candidate_write on pal_eyes.release_candidates
  for all to authenticated
  using (pal_eyes.has_any_role(array['release_manager','system_admin']))
  with check (pal_eyes.has_any_role(array['release_manager','system_admin'])
              and publication_status = 'BLOCKED');

create or replace function pal_eyes.has_release_authority()
returns boolean
language sql
stable
security definer
set search_path = pal_eyes, public
as $fn$
  select pal_eyes.has_any_role(array['release_manager', 'system_admin']);
$fn$;
drop function if exists pal_eyes.current_aal();

drop trigger if exists b_enforce_site_version on pal_eyes.sites;
drop function if exists pal_eyes.enforce_site_version();

do $$
declare t text;
begin
  for t in select event_object_table from information_schema.triggers
            where trigger_schema = 'pal_eyes' and trigger_name = 'a_stamp_actor'
            group by event_object_table
  loop
    execute format('drop trigger if exists a_stamp_actor on pal_eyes.%I', t);
  end loop;
end;
$$;
drop function if exists pal_eyes.stamp_actor();

commit;
