---
title: "Gap Fill over data from v0.8.x and v0.9.x"
description: "Manual steps for gapfilling data from both Lily v0.8 and v0.9"
lead: "Task names have changed from v0.8 to v0.9. This workaround will help manage running gap find/fill tasks on databases which contain data from both versions of Lily."
menu:
  data:
    parent: "data"
    identifier: "models"
weight: 15
toc: true
---

---

### IMPORTANT

- This example uses a hardcoded schema name of `visor` which must be updated if you use another schema name for your Lily data.

- It is recommended that you truncate your `visor_gap_reports` table before using this function as it doesn't do anything special to resolve conflicts. If you are using this over heights/tasks which aren't already in your gap reports table, then you should have no issues.

### DETAIL

```sql
-- populate_gap_find_reports_supporting_legacy_tasknames will consider the current state of
-- visor_processing_reports for where gaps exist in the model tables. this function will properly
-- map legacy tasks which already exist in your processing reports and treat them as gaps with
-- the current task names. this function is indifferent to when your database started receiving
-- data coming from v0.8.X to v0.9.X
-- It should be sufficient to execute `lily job run gap fill` as usual.

create or replace function visor.populate_gap_find_reports_supporting_legacy_tasknames (min_height bigint, max_height bigint, reporter_name text)
  returns table (
    height bigint, task text, status text, reporter text, reported_at timestamp with time zone
)
  language plpgsql
  volatile parallel unsafe strict
  as $function$
begin
  return query with interesting_tasks (
    task
) as (
    values('block_parent'),
      ('drand_block_entrie'),
      ('miner_sector_deal'),
      ('miner_sector_infos_v7'),
      ('miner_sector_infos'),
      ('miner_sector_post'),
      ('miner_pre_commit_info'),
      ('miner_sector_event'),
      ('miner_current_deadline_info'),
      ('miner_fee_debt'),
      ('miner_locked_fund'),
      ('miner_info'),
      ('market_deal_proposal'),
      ('market_deal_state'),
      ('message'),
      ('block_message'),
      ('receipt'),
      ('message_gas_economy'),
      ('parsed_message'),
      ('internal_messages'),
      ('internal_parsed_messages'),
      ('multisig_transaction'),
      ('chain_power'),
      ('power_actor_claim'),
      ('chain_reward'),
      ('actor'),
      ('actor_state'),
      ('id_address'),
      ('derived_gas_outputs'),
      ('chain_economics'),
      ('chain_consensus'),
      ('multisig_approvals'),
      ('verified_registry_verifier'),
      ('verified_registry_verified_client')
),
all_heights_and_tasks_in_range as (
  select
    a.height,
    a.task
  from (
    -- 				(SELECT * FROM generate_series(900000, 1000000) AS x(height)) h
    (
      select
        *
      from
        generate_series(min_height,
          max_height) as x (height)) h
    cross join (
      select
        *
      from
        interesting_tasks) t) as a
),
heights_in_processing_report as (
  select
    unnest(
      case when v.task = 'actorstatesinit' then
        array ['id_address']
      when v.task = 'actorstatesmarket' then
        array [ 'market_deal_proposal', 'market_deal_state' ]
      when v.task = 'actorstatesminer' then
        array [
             'miner_current_deadline_info',
             'miner_fee_debt',
             'miner_info',
             'miner_locked_fund',
             'miner_pre_commit_info',
             'miner_sector_deal',
             'miner_sector_event',
             'miner_sector_infos',
             'miner_sector_infos_v7',
             'miner_sector_post'
           ]
      when v.task = 'actorstatesmultisig' then
        array ['multisig_transaction']
      when v.task = 'actorstatespower' then
        array ['chain_power', 'power_actor_claim']
      when v.task = 'actorstatesraw' then
        array ['actor', 'actor_state']
      when v.task = 'actorstatesreward' then
        array ['chain_reward']
      when v.task = 'actorstatesverifreg' then
        array ['verified_registry_verified_client', 'verified_registry_verifier']
      when v.task = 'blocks' then
        array ['block_header', 'block_parent', 'drand_block_entrie']
      when v.task = 'builtin' then
        array ['builtin']
      when v.task = 'chaineconomics' then
        array ['chain_economics']
      when v.task = 'consensus' then
        array ['chain_consensus']
      when v.task = 'gap_find' then
        array ['gap_find']
      when v.task = 'implicitmessage' then
        array ['internal_messages', 'internal_parsed_messages']
      when v.task = 'message' then
        array ['block_message', 'derived_gas_outputs', 'message_gas_economy', 'messages', 'parsed_message', 'receipt']
      when v.task = 'msapprovals' then
        array ['multisig_approvals']
        -- these v.tasks are known and should not be mapped to anything but themselves
      when v.task in('market_deal_proposal',
        'market_deal_state',
        'actor',
        'actor_state',
        'block_header',
        'block_parent',
        'drand_block_entrie',
        'block_message',
        'derived_gas_outputs',
        'message_gas_economy',
        'messages',
        'parsed_message',
        'receipt',
        'builtin',
        'chain_consensus',
        'chain_economics',
        'chain_power',
        'power_actor_claim',
        'chain_reward',
        'gap_find',
        'id_address',
        'internal_messages',
        'internal_parsed_messages',
        'multisig_approvals',
        'multisig_transaction',
        'verified_registry_verified_client',
        'verified_registry_verifier',
        'miner_current_deadline_info',
        'miner_fee_debt',
        'miner_info',
        'miner_locked_fund',
        'miner_pre_commit_info',
        'miner_sector_deal',
        'miner_sector_event',
        'miner_sector_infos',
        'miner_sector_infos_v7',
        'miner_sector_post') then
        array [v.task]
        -- this should never occur and is ownly here for validating
        -- that no legacy task names are found. If you uncomment this
        -- and find some task prepended w `idk`, then they need to be
        -- included in the above case.
        -- else array[concat('idk: ', task)]
      end) as task,
    v.height,
    v.status,
    v.status_information
  from
    visor_processing_reports v
  where
    v.height between min_height
    and max_height
),
complete_epochs_tasks as (
  select
    v.height,
    v.task
  from
    heights_in_processing_report v
  left join visor_processing_reports x on v.height = x.height
    and v.task = x.task
    and v.status = x.status
where
  v.status = 'OK'
  and v.task IN(
    select
      * from interesting_tasks)
group by
  1,
  2,
  x.status
),
tasks_with_null_round as (
  select
    pr.height,
    t.task
  from
    heights_in_processing_report pr
  cross join interesting_tasks t
where (pr.status_information = 'NULL_ROUND'
  and pr.status = 'INFO')
group by
  1,
  2
),
gaps_found as (
  select
    gaps.height,
    gaps.task
  from ((
      select
        *
      from
        all_heights_and_tasks_in_range)
    except (
      select
        *
      from
        complete_epochs_tasks)
    except (
      select
        *
      from
        tasks_with_null_round)) as gaps
  order by
    gaps.height desc,
    gaps.task
) insert into visor.visor_gap_reports (height, task, status, reporter, reported_at) (
    select
      g.height,
      g.task,
      'GAP',
      reporter_name,
      now()
    from
      gaps_found g)
  returning
    *;
end;
$function$;

-- example of how one might use the above function
select
  min(height),
  max(height)
from
  visor.visor_processing_reports;

--> 806639, 1805178
select
  visor.populate_gap_find_reports_supporting_legacy_tasknames (806639,
    1805178,
    '20220513_manual_gapfill_alltasks');
```
