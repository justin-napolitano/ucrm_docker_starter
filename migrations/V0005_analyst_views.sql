-- UCRM v1 — ANALYST-FACING VIEWS (Postgres-compatible)

create or replace view v_cardio_cases as
select
  pr.procedure_sk,
  pr.registry_program_c,
  pr.procedure_dt,
  e.encounter_sk,
  e.admit_dt,
  e.discharge_dt,
  p.patient_sk,
  f.facility_sk,
  pr.procedure_type_c,
  pr.primary_indication_c,
  pr.fluoroscopy_time_min,
  pr.contrast_volume_ml
from ucrm_procedure pr
join ucrm_encounter e on e.encounter_sk = pr.encounter_sk
join ucrm_patient  p on p.patient_sk = e.patient_sk
join ucrm_facility f on f.facility_sk = e.facility_sk;

create or replace view v_outcomes_core as
select
  pr.procedure_sk,
  pr.registry_program_c,
  -- Postgres-native boolean aggregation
  bool_or(o.occurred_flag) filter (where o.outcome_c = 'DEATH_INHOSP') as death_inhosp,
  bool_or(o.occurred_flag) filter (where o.outcome_c = 'STROKE')       as stroke_any,
  bool_or(o.occurred_flag) filter (where o.outcome_c = 'BLEED_BARC')   as bleed_barc_any
from ucrm_outcome o
join ucrm_procedure pr on pr.procedure_sk = o.procedure_sk
group by pr.procedure_sk, pr.registry_program_c;

-- Door-to-balloon (CathPCI) — Postgres: use epoch math (no datediff)
create or replace view v_cathpci_dbt as
select
  pr.procedure_sk,
  extract(
    epoch from (
      max(case when m.measure_c = 'DBT_BALLOON_TIME' then m.measure_dt end)
    - max(case when m.measure_c = 'DBT_DOOR_TIME'    then m.measure_dt end)
    )
  ) / 60.0 as dbt_minutes
from ucrm_measure m
join ucrm_procedure pr on pr.procedure_sk = m.procedure_sk
where pr.registry_program_c = 'NCDR_CATHPCI'
group by pr.procedure_sk;

