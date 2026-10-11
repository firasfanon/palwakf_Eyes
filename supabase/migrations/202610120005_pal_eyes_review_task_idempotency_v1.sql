-- PAL_EYES review-task idempotency V1.
-- Staging-first. Retain every historical review and audit record.
-- One open editorial review per site, despite repeated UI actions.
do $migration$
declare
  v_group record;
  v_ids text[];
  v_updated integer;
begin
  for v_group in
    select entity_type, entity_id, review_type,
           array_agg(id order by created_at, id) as ids
    from pal_eyes.review_tasks
    where entity_type = 'site'
      and review_type = 'EDITORIAL'
      and status = 'OPEN'
    group by entity_type, entity_id, review_type
    having count(*) > 1
  loop
    v_ids := v_group.ids;
    if array_length(v_ids, 1) is null or array_length(v_ids, 1) < 2 then
      raise exception 'INVALID_REVIEW_RECONCILIATION_GROUP';
    end if;
    update pal_eyes.review_tasks as t
    set status = 'SUPERSEDED_DUPLICATE',
        decision_note = 'Duplicate open review superseded by ' || v_ids[1]
                        || '; preserved for historical audit, no review decision made',
        updated_at = timezone('utc', now())
    where t.id = any(v_ids[2:array_length(v_ids, 1)])
      and t.status = 'OPEN'
      and t.entity_type = v_group.entity_type
      and t.entity_id = v_group.entity_id
      and t.review_type = v_group.review_type;
    get diagnostics v_updated = row_count;
    if v_updated <> array_length(v_ids, 1) - 1 then
      raise exception 'REVIEW_RECONCILIATION_CONCURRENCY_CONFLICT';
    end if;
    insert into pal_eyes.audit_events (
      id, actor_label, action, entity_type, entity_id, summary, metadata
    ) values (
      'audit-review-reconcile-' || gen_random_uuid()::text,
      'PAL_EYES_STAGING_MIGRATION',
      'REVIEW_TASK_DUPLICATES_RECONCILED',
      v_group.entity_type,
      v_group.entity_id,
      'Historical duplicate review tasks retained and marked superseded; one remains active.',
      jsonb_build_object('active_review_id',v_ids[1],
                         'superseded_review_ids', to_jsonb(v_ids[2:array_length(v_ids,1)]),
                         'original_open_count',array_length(v_ids,1),
                         'original_audit_events_preserved',true)
    );
  end loop;
end
$migration$;

create unique index if not exists review_tasks_one_open_editorial_site_v1
  on pal_eyes.review_tasks (entity_type, entity_id, review_type)
  where entity_type='site' and review_type='EDITORIAL' and status='OPEN';

create or replace function pal_eyes.submit_site_for_review_v1(p_site_id text)
returns table (review_task_id text, created_new boolean)
language plpgsql
security invoker
set search_path = pal_eyes, pg_temp
as $function$
declare
  v_site pal_eyes.sites%rowtype;
  v_existing text;
  v_new text;
  v_actor uuid;
begin
  v_actor := auth.uid();
  if v_actor is null
    or not pal_eyes.has_any_role(array['editor','review_manager','system_admin']) then
    raise exception using errcode='42501', message='SITE_REVIEW_EDITOR_AUTHORITY_REQUIRED';
  end if;
  if p_site_id is null or trim(p_site_id) = '' then
    raise exception using errcode='22023', message='SITE_REVIEW_ID_REQUIRED';
  end if;
  select * into v_site
  from pal_eyes.sites where id = p_site_id
  for update;
  if not found then
    raise exception using errcode='P0002', message='SITE_NOT_FOUND_OR_NOT_AUTHORIZED';
  end if;
  if v_site.publication_status <> 'BLOCKED'
     or v_site.workflow_status like '%PUBLISH%'
     or v_site.workflow_status like '%APPROVED%' then
    raise exception using errcode='42501', message='SITE_REVIEW_ONLY_BLOCKED_DRAFTS';
  end if;
  select id into v_existing from pal_eyes.review_tasks
  where entity_type='site' and entity_id=p_site_id
    and review_type='EDITORIAL' and status='OPEN'
  order by created_at, id limit 1;
  if v_existing is not null then
    -- The site may have been edited since first submission. Reuse the same
    -- active review and refresh workflow, never duplicate the task or audit.
    if v_site.workflow_status <> 'SUBMITTED_FOR_REVIEW' then
      update pal_eyes.sites
        set workflow_status='SUBMITTED_FOR_REVIEW', updated_by=v_actor
      where id=p_site_id;
    end if;
    return query select v_existing, false;
    return;
  end if;

  update pal_eyes.sites
    set workflow_status='SUBMITTED_FOR_REVIEW', updated_by=v_actor
  where id=p_site_id;
  v_new := 'review-site-' || gen_random_uuid()::text;
  insert into pal_eyes.review_tasks (
    id, entity_type, entity_id, title, review_type,
    priority, status, assignee_label, created_by
  ) values (
    v_new, 'site', p_site_id, 'مراجعة تحريرية: ' || v_site.name_ar,
    'EDITORIAL', 'P1_HIGH', 'OPEN', 'غير مسند', v_actor
  );
  insert into pal_eyes.audit_events (
    id, actor_id, actor_label, action, entity_type, entity_id, summary, metadata
  ) values (
    'audit-site-review-' || gen_random_uuid()::text,
    v_actor, coalesce(auth.jwt()->>'email','authenticated-editor'),
    'SITE_SUBMITTED_FOR_REVIEW',
    'site',p_site_id,
    'Editorial review submitted once via transactional governed workflow.',
    jsonb_build_object('review_task_id',v_new,'public_release',false)
  );
  return query select v_new, true;
end
$function$;

revoke all on function pal_eyes.submit_site_for_review_v1(text) from public, anon;
grant execute on function pal_eyes.submit_site_for_review_v1(text) to authenticated;
