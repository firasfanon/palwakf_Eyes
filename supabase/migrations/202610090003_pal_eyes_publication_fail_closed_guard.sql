-- PalEyes publication fail-closed guard and append-only audit log.
-- SOURCE-ONLY CANDIDATE MIGRATION. Not applied to any shared, staging or
-- production database. Applying it requires separate owner authorization.
--
-- Findings closed (proven with tools/rls_boundary on an isolated Postgres):
--   * editor could set sites.publication_status = 'PUBLISHED' directly
--     (sites_editor_write is FOR ALL), bypassing review and release control;
--   * editor could insert a site that is already PUBLISHED;
--   * editor could set sites.coordinate_status = 'PUBLIC_APPROVED';
--   * researcher could set sources.public_release_status = 'PUBLISHED'
--     (research_write is FOR ALL);
--   * any internal role, including system_admin, could rewrite audit_events
--     (UPDATE granted + workflow_write FOR ALL).
--
-- Policy: only release_manager or system_admin may move a record into a
-- publicly visible state. Audit events are append-only for every
-- authenticated role. Table owners / service maintenance are unaffected.

begin;

create or replace function pal_eyes.has_release_authority()
returns boolean
language sql
stable
security definer
set search_path = pal_eyes, public
as $$
  select pal_eyes.has_any_role(array['release_manager', 'system_admin']);
$$;

revoke all on function pal_eyes.has_release_authority() from public;
grant execute on function pal_eyes.has_release_authority() to authenticated;

create or replace function pal_eyes.guard_public_state_transition()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
declare
  v_column text := tg_argv[0];
  v_new text;
  v_old text;
  v_public_values text[] := string_to_array(tg_argv[1], ',');
begin
  -- Only end-user API roles are constrained; migrations and service
  -- maintenance run as owner/service roles.
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;

  v_new := to_jsonb(new) ->> v_column;
  if tg_op = 'UPDATE' then
    v_old := to_jsonb(old) ->> v_column;
  end if;

  if v_new = any(v_public_values)
     and (tg_op = 'INSERT' or v_old is distinct from v_new)
     and not pal_eyes.has_release_authority() then
    raise exception using
      errcode = '42501',
      message = format(
        'PUBLICATION_FAIL_CLOSED: %s.%s -> %s requires release authority',
        tg_table_name, v_column, v_new
      );
  end if;

  return new;
end;
$$;

do $$
declare
  spec record;
begin
  for spec in
    select * from (values
      ('sites', 'publication_status', 'CANDIDATE,PUBLISHED'),
      ('sites', 'coordinate_status', 'PUBLIC_APPROVED'),
      ('sources', 'public_release_status', 'PUBLISHED'),
      ('original_draft_layers', 'public_release_status', 'PUBLISHED'),
      ('editorial_records', 'publication_status', 'PUBLISHED'),
      ('site_source_links', 'publication_status', 'PUBLISHED'),
      ('timeline_events', 'publication_status', 'PUBLISHED')
    ) as s(table_name, column_name, public_values)
  loop
    execute format(
      'drop trigger if exists guard_public_%2$s on pal_eyes.%1$I',
      spec.table_name, spec.column_name
    );
    execute format(
      'create trigger guard_public_%2$s before insert or update of %2$I on pal_eyes.%1$I '
      'for each row execute function pal_eyes.guard_public_state_transition(%2$L, %3$L)',
      spec.table_name, spec.column_name, spec.public_values
    );
  end loop;
end;
$$;

-- Append-only audit log.
create or replace function pal_eyes.reject_audit_mutation()
returns trigger
language plpgsql
security invoker
set search_path = pal_eyes, public
as $$
begin
  if current_user in ('authenticated', 'anon') then
    raise exception using
      errcode = '42501',
      message = 'AUDIT_LOG_APPEND_ONLY: audit events cannot be modified or deleted';
  end if;
  return coalesce(new, old);
end;
$$;

drop trigger if exists audit_events_append_only on pal_eyes.audit_events;
create trigger audit_events_append_only
  before update or delete on pal_eyes.audit_events
  for each row execute function pal_eyes.reject_audit_mutation();

revoke update, delete on pal_eyes.audit_events from authenticated;

comment on function pal_eyes.guard_public_state_transition() is
  'Fail-closed publication guard: public-facing states require release_manager or system_admin.';
comment on function pal_eyes.reject_audit_mutation() is
  'Audit events are append-only for API roles.';

commit;
