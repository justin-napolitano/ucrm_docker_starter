-- OPTIONAL: enable pgcrypto for hashing if you don't have mrn_hash in file
create extension if not exists pgcrypto;

-- 1) Normalize a working set
with src as (
  select
    h.*,
    -- prefer provided mrn_hash else compute from mrn
    coalesce(h.mrn_hash, encode(digest(coalesce(h.mrn,''), 'sha256'),'hex')) as mrn_hash_eff,
    -- prefer given encounter_num else synthesize from site+case
    coalesce(h.encounter_num, h.site_id || '-' || h.case_id) as encounter_num_eff
  from stg_ncdr.cathpci_header h
),

-- 2) Upsert dimensions (insert-ignore style)
ins_patient as (
  insert into ucrm_patient (mrn_hash, birth_date, sex_at_birth_c, race_c, ethnicity_c)
  select distinct s.mrn_hash_eff, null, null, null, null
  from src s
  on conflict (mrn_hash) do nothing
  returning patient_sk, mrn_hash
),
ins_facility as (
  insert into ucrm_facility (facility_code, facility_name, npi)
  select distinct s.facility_code, null, null
  from src s
  where s.facility_code is not null
  on conflict (facility_code) do nothing
  returning facility_sk, facility_code
),
ins_provider as (
  insert into ucrm_provider (npi, provider_id_external, provider_name, specialty_c)
  select distinct s.operator_npi, null, null, null
  from src s
  where s.operator_npi is not null
  on conflict (npi) do nothing
  returning provider_sk, npi
),

-- 3) Encounters (one per encounter_num_eff)
ins_encounter as (
  insert into ucrm_encounter (patient_sk, facility_sk, encounter_num, admit_dt, discharge_dt)
  select
    p.patient_sk,
    f.facility_sk,
    s.encounter_num_eff,
    s.ed_arrival_time,  -- use ED arrival as admit proxy for POC
    null
  from src s
  join ucrm_patient  p on p.mrn_hash     = s.mrn_hash_eff
  left join ucrm_facility f on f.facility_code = s.facility_code
  on conflict (encounter_num) do nothing
  returning encounter_sk, encounter_num
),

-- 4) Procedures (PCI) spine
ins_procedure as (
  insert into ucrm_procedure (
    encounter_sk, provider_sk, registry_program_c,
    procedure_dt, procedure_type_c, primary_indication_c,
    fluoroscopy_time_min, contrast_volume_ml, success_flag
  )
  select
    e.encounter_sk,
    pr.provider_sk,
    'NCDR_CATHPCI',
    s.procedure_dt,
    'PCI',
    s.primary_indication,              -- leave raw text/code as-is for POC
    s.fluoro_time_min,
    s.contrast_vol_ml,
    null
  from src s
  join ucrm_encounter e on e.encounter_num = s.encounter_num_eff
  left join ucrm_provider  pr on pr.npi = s.operator_npi
  -- idempotency: avoid re-inserting the same case (site+case). Use a left-join anti-pattern if needed.
  returning procedure_sk, encounter_sk, s.site_id, s.case_id, s.source_file, s.load_id
),

-- 5) Measures: DBT door & balloon times
ins_measures as (
  insert into ucrm_measure (encounter_sk, procedure_sk, measure_c, measure_value_num, measure_value_txt, measure_dt, source_c)
  select
    ip.encounter_sk,
    ip.procedure_sk,
    m.measure_c,
    null,
    null,
    m.measure_dt,
    'REGISTRY'
  from ins_procedure ip
  join (
    select e.encounter_sk, p.procedure_sk, 'DBT_DOOR_TIME' as measure_c, s.ed_arrival_time as measure_dt
    from src s
    join ucrm_encounter e on e.encounter_num = s.encounter_num_eff
    join ucrm_procedure p  on p.encounter_sk = e.encounter_sk and p.registry_program_c = 'NCDR_CATHPCI'
    union all
    select e.encounter_sk, p.procedure_sk, 'DBT_BALLOON_TIME' as measure_c, s.first_balloon_time as measure_dt
    from src s
    join ucrm_encounter e on e.encounter_num = s.encounter_num_eff
    join ucrm_procedure p  on p.encounter_sk = e.encounter_sk and p.registry_program_c = 'NCDR_CATHPCI'
  ) m on m.procedure_sk = ip.procedure_sk
  where m.measure_dt is not null
  returning encounter_sk, procedure_sk
)

-- 6) Provenance: one row per inserted procedure
insert into ucrm_registry_event (
  registry_program_c, registry_schema_version, site_id,
  source_file, load_id, source_primary_key, ucrm_entity, ucrm_entity_sk
)
select
  'NCDR_CATHPCI', 'POC', ip.site_id,
  ip.source_file, ip.load_id, ip.case_id, 'UCRM_PROCEDURE', ip.procedure_sk
from ins_procedure ip;

