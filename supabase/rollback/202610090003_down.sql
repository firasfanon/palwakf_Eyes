-- Rollback for 202610090003_pal_eyes_publication_fail_closed_guard.sql
-- WARNING: re-opens the publication and audit gaps that 0003 closed.
begin;

do $$
declare r record;
begin
  for r in select event_object_table as t, trigger_name as n
             from information_schema.triggers
            where trigger_schema = 'pal_eyes' and trigger_name like 'guard_public_%'
            group by event_object_table, trigger_name
  loop
    execute format('drop trigger if exists %I on pal_eyes.%I', r.n, r.t);
  end loop;
end;
$$;
drop function if exists pal_eyes.guard_public_state_transition();
drop function if exists pal_eyes.has_release_authority();

drop trigger if exists audit_events_append_only on pal_eyes.audit_events;
drop function if exists pal_eyes.reject_audit_mutation();
grant update on pal_eyes.audit_events to authenticated;

commit;
