-- Load CathPCI measures (door & balloon) based on already-inserted procedures

with src as (
  select h.*,
         coalesce(h.encounter_num, h.site_id || '-' || h.case_id) as encounter_num_eff
  from stg_ncdr.cathpci_header h
),
measures as (
  -- Door time
  select
    e.encounter_sk,
    p.procedure_sk,
    'DBT_DOOR_TIME'::varchar(64) as measure_c,
    null::numeric as measure_value_num,
    null::varchar as measure_value_txt,
    s.ed_arrival_time::timestamp as measure_dt,
    'REGISTRY'::varchar(64) as source_c
  from src s
  join ucrm_encounter e on e.encounter_num = s.encounter_num_eff
  join ucrm_procedure p on p.encounter_sk = e.encounter_sk
                        and p.registry_program_c = 'NCDR_CATHPCI'
  where s.ed_arrival_time is not null

  union all

  -- Balloon time
  select
    e.encounter_sk,
    p.procedure_sk,
    'DBT_BALLOON_TIME'::varchar(64) as measure_c,
    null::numeric as measure_value_num,
    null::varchar as measure_value_txt,
    s.first_balloon_time::timestamp as measure_dt,
    'REGISTRY'::varchar(64) as source_c
  from src s
  join ucrm_encounter e on e.encounter_num = s.encounter_num_eff
  join ucrm_procedure p on p.encounter_sk = e.encounter_sk
                        and p.registry_program_c = 'NCDR_CATHPCI'
  where s.first_balloon_time is not null
)
insert into ucrm_measure
  (encounter_sk, procedure_sk, measure_c, measure_value_num, measure_value_txt, measure_dt, source_c)
select * from measures
on conflict (procedure_sk, measure_c, measure_dt) do nothing;
