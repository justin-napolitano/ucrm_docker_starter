
-- ============================================================================
-- Unified Cardiology Registry Model (UCRM) - v1
-- Author: AdventHealth – Business & Clinical Analytics
-- Notes:
--   * This DDL targets Postgres-compatible warehouses; it is also Snowflake-friendly.
--   * All objects are created IF NOT EXISTS for idempotency.
--   * Adjust schema names as needed (default: public). For Snowflake, remove "if not exists" where unsupported.
-- ============================================================================

-- =====================
-- SECTION 0: PRAGMAS
-- =====================
-- Postgres recommended settings for this session (optional):
-- set search_path = public;
-- set lock_timeout = '10s';

-- =====================
-- SECTION 1: CORE DIMENSIONS
-- =====================

create table if not exists ucrm_patient (
    patient_sk              bigint generated always as identity primary key,
    mrn_hash                varchar(128) not null unique,
    birth_date              date,
    sex_at_birth_c          varchar(20),
    race_c                  varchar(40),
    ethnicity_c             varchar(40),
    death_date              date,
    created_at              timestamp default current_timestamp,
    updated_at              timestamp
);

create table if not exists ucrm_facility (
    facility_sk             bigint generated always as identity primary key,
    facility_code           varchar(64) not null unique,
    facility_name           varchar(256),
    npi                     varchar(20),
    created_at              timestamp default current_timestamp
);

create table if not exists ucrm_provider (
    provider_sk             bigint generated always as identity primary key,
    npi                     varchar(20) unique,
    provider_id_external    varchar(64),
    provider_name           varchar(256),
    specialty_c             varchar(64),
    created_at              timestamp default current_timestamp
);

create table if not exists ucrm_encounter (
    encounter_sk            bigint generated always as identity primary key,
    patient_sk              bigint not null references ucrm_patient(patient_sk),
    facility_sk             bigint references ucrm_facility(facility_sk),
    encounter_num           varchar(64), -- local visit/encounter identifier
    admit_dt                timestamp,
    discharge_dt            timestamp,
    discharge_disposition_c varchar(64),
    admission_source_c      varchar(64),
    payer_primary_c         varchar(64),
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_encounter_patient on ucrm_encounter(patient_sk);
create index if not exists idx_ucrm_encounter_facility on ucrm_encounter(facility_sk);
create index if not exists idx_ucrm_encounter_admit on ucrm_encounter(admit_dt);

-- =====================
-- SECTION 2: PROCEDURE SPINE
-- =====================

create table if not exists ucrm_procedure (
    procedure_sk            bigint generated always as identity primary key,
    encounter_sk            bigint not null references ucrm_encounter(encounter_sk),
    provider_sk             bigint references ucrm_provider(provider_sk),
    registry_program_c      varchar(32) not null, -- e.g., 'NCDR_CATHPCI','NCDR_EP_DEVICE_IMPLANT','STS_TVT'
    procedure_dt            timestamp,
    procedure_type_c        varchar(64),          -- PCI, ICD_IMPLANT, GENERATOR_CHANGE, TAVR, LAAO, etc.
    primary_indication_c    varchar(128),
    anesthesia_type_c       varchar(64),
    fluoroscopy_time_min    numeric(8,2),
    contrast_volume_ml      numeric(8,2),
    success_flag            boolean,
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_procedure_enc on ucrm_procedure(encounter_sk);
create index if not exists idx_ucrm_procedure_prog on ucrm_procedure(registry_program_c, procedure_dt);

-- =====================
-- SECTION 3: CLINICAL FACTS
-- =====================

-- Devices used/implanted (stents, valves, leads/generators, etc.)
create table if not exists ucrm_device (
    device_sk               bigint generated always as identity primary key,
    procedure_sk            bigint not null references ucrm_procedure(procedure_sk),
    device_role_c           varchar(64),      -- STENT, LEAD_RA, LEAD_RV, LEAD_LV, GENERATOR, VALVE, GRAFT
    udi                     varchar(200),
    manufacturer_c          varchar(128),
    model                   varchar(128),
    lot                     varchar(64),
    size_primary            varchar(64),      -- e.g., stent diameter/length; valve size
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_device_proc on ucrm_device(procedure_sk);
create index if not exists idx_ucrm_device_role on ucrm_device(device_role_c);

-- Diagnoses/conditions (pre/intra/post context)
create table if not exists ucrm_condition (
    condition_sk            bigint generated always as identity primary key,
    encounter_sk            bigint not null references ucrm_encounter(encounter_sk),
    coding_system_c         varchar(32),      -- ICD10, SNOMED, etc.
    code                    varchar(32),
    description             varchar(256),
    onset_dt                timestamp,
    condition_context_c     varchar(32),      -- PRE, INTRA, POST
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_condition_enc on ucrm_condition(encounter_sk);
create index if not exists idx_ucrm_condition_code on ucrm_condition(code);

-- Quantitative/qualitative measures (labs, vitals, timestamps, scores)
create table if not exists ucrm_measure (
    measure_sk              bigint generated always as identity primary key,
    encounter_sk            bigint references ucrm_encounter(encounter_sk),
    procedure_sk            bigint references ucrm_procedure(procedure_sk),
    measure_c               varchar(64),      -- e.g., 'LVEF_PCT','LDL','DBT_DOOR_TIME','DBT_BALLOON_TIME','ACCESS_SITE_CODE'
    measure_value_num       numeric(12,4),
    measure_value_txt       varchar(256),
    measure_dt              timestamp,
    source_c                varchar(16) default 'EPIC', -- EPIC or REGISTRY
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_measure_proc on ucrm_measure(procedure_sk);
create index if not exists idx_ucrm_measure_enc on ucrm_measure(encounter_sk);
create index if not exists idx_ucrm_measure_type on ucrm_measure(measure_c);

-- Outcomes/complications (in-hospital or post-procedure)
create table if not exists ucrm_outcome (
    outcome_sk              bigint generated always as identity primary key,
    encounter_sk            bigint references ucrm_encounter(encounter_sk),
    procedure_sk            bigint references ucrm_procedure(procedure_sk),
    outcome_c               varchar(128),     -- 'DEATH_INHOSP','STROKE','BLEED_BARC','VASCULAR_COMPL','AKI', etc.
    severity_c              varchar(64),
    occurred_flag           boolean,
    onset_dt                timestamp,
    source_c                varchar(16) default 'EPIC',
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_outcome_proc on ucrm_outcome(procedure_sk);
create index if not exists idx_ucrm_outcome_type on ucrm_outcome(outcome_c);

-- Medications (peri-procedural and discharge)
create table if not exists ucrm_medication (
    medication_sk           bigint generated always as identity primary key,
    encounter_sk            bigint references ucrm_encounter(encounter_sk),
    procedure_sk            bigint references ucrm_procedure(procedure_sk),
    context_c               varchar(32),      -- HOME, INTRAOP, INPATIENT, DISCHARGE
    medication_c            varchar(128),     -- normalized class/name (ASPIRIN, P2Y12_INHIBITOR, OAC, etc.)
    route_c                 varchar(32),
    strength_txt            varchar(64),
    dose_num                numeric(10,2),
    dose_unit               varchar(32),
    start_dt                timestamp,
    end_dt                  timestamp,
    source_c                varchar(16) default 'EPIC',
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_med_proc on ucrm_medication(procedure_sk);
create index if not exists idx_ucrm_med_ctx on ucrm_medication(context_c);

-- Timing events (cath/OR milestones, device test events, etc.)
create table if not exists ucrm_timing_event (
    timing_event_sk         bigint generated always as identity primary key,
    encounter_sk            bigint references ucrm_encounter(encounter_sk),
    procedure_sk            bigint references ucrm_procedure(procedure_sk),
    event_c                 varchar(64),     -- 'ED_ARRIVAL','CATH_IN','SHEATH_IN','BALLOON_INFLATION','ICD_SHOCK_TEST'
    event_dt                timestamp,
    source_c                varchar(16) default 'EPIC',
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ucrm_timing_proc on ucrm_timing_event(procedure_sk);
create index if not exists idx_ucrm_timing_event on ucrm_timing_event(event_c);

-- =====================
-- SECTION 4: PROVENANCE & MAPPINGS
-- =====================

-- Registry load lineage
create table if not exists ucrm_registry_event (
    registry_event_sk       bigint generated always as identity primary key,
    registry_program_c      varchar(32) not null,
    registry_schema_version varchar(32) not null,
    site_id                 varchar(64),
    source_file             varchar(512),
    load_id                 varchar(64),              -- ETL batch id/UUID
    source_primary_key      varchar(128),             -- registry-native case id
    ucrm_entity             varchar(64),              -- table populated (e.g., 'UCRM_PROCEDURE')
    ucrm_entity_sk          bigint,                   -- FK of populated record
    loaded_at               timestamp default current_timestamp
);

create index if not exists idx_registry_event_prog on ucrm_registry_event(registry_program_c, registry_schema_version);
create index if not exists idx_registry_event_entity on ucrm_registry_event(ucrm_entity, ucrm_entity_sk);

-- Mapping registry fields to UCRM columns (data-driven transforms)
create table if not exists map_registry_to_ucrm (
    mapping_id              bigint generated always as identity primary key,
    registry_program_c      varchar(32) not null,
    registry_schema_version varchar(32) not null,
    registry_variable_id    varchar(128) not null,
    registry_variable_name  varchar(256),
    ucrm_table              varchar(64) not null,
    ucrm_column             varchar(64) not null,
    value_set_name          varchar(128),        -- if enumerated
    transform_sql           varchar(4000),       -- SQL expression used in staging→core
    is_required_flag        boolean default false,
    effective_start_dt      date default current_date,
    effective_end_dt        date
);

create index if not exists idx_map_to_ucrm_prog on map_registry_to_ucrm(registry_program_c, registry_schema_version);

-- Value set normalization (registry codes → normalized codes/labels)
create table if not exists map_value_sets (
    value_set_name          varchar(128) not null,
    registry_code           varchar(64) not null,
    normalized_code         varchar(64) not null,
    normalized_label        varchar(128),
    primary key (value_set_name, registry_code)
);

-- =====================
-- SECTION 5: PROGRAM EXTENSIONS (OPTIONAL)
-- =====================

-- CathPCI lesions (if you capture segment-level data)
create table if not exists ext_cathpci_lesion (
    lesion_sk               bigint generated always as identity primary key,
    procedure_sk            bigint not null references ucrm_procedure(procedure_sk),
    vessel_c                varchar(32),      -- LAD, LCx, RCA, LM, GRAFT
    segment_c               varchar(32),
    stenosis_pct_pre        numeric(5,2),
    stenosis_pct_post       numeric(5,2),
    culprit_flag            boolean,
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ext_lesion_proc on ext_cathpci_lesion(procedure_sk);

-- ICD/EP system details
create table if not exists ext_icd_system (
    icd_system_sk           bigint generated always as identity primary key,
    procedure_sk            bigint not null references ucrm_procedure(procedure_sk),
    system_type_c           varchar(32),     -- ICD, CRT-D, CRT-P
    generator_model         varchar(128),
    shock_test_performed_flag boolean,
    created_at              timestamp default current_timestamp
);

create index if not exists idx_ext_icd_proc on ext_icd_system(procedure_sk);

-- =====================
-- SECTION 6: ANALYST VIEWS (STABLE CONTRACTS)
-- =====================

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
  max(case when outcome_c = 'DEATH_INHOSP' then occurred_flag end) as death_inhosp,
  max(case when outcome_c = 'STROKE' then occurred_flag end)       as stroke_any,
  max(case when outcome_c = 'BLEED_BARC' then occurred_flag end)   as bleed_barc_any
from ucrm_outcome o
join ucrm_procedure pr on pr.procedure_sk = o.procedure_sk
group by pr.procedure_sk, pr.registry_program_c;

-- Door-to-balloon computation for CathPCI
create or replace view v_cathpci_dbt as
select
  pr.procedure_sk,
  datediff(
    minute,
    min(case when m.measure_c = 'DBT_DOOR_TIME'    then m.measure_dt end),
    min(case when m.measure_c = 'DBT_BALLOON_TIME' then m.measure_dt end)
  ) as dbt_minutes
from ucrm_measure m
join ucrm_procedure pr on pr.procedure_sk = m.procedure_sk
where pr.registry_program_c = 'NCDR_CATHPCI'
group by pr.procedure_sk;

-- =====================
-- SECTION 7: STARTER VALUE SETS (EXAMPLES)
-- =====================

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('CATHPCI_INDICATION','1','STEMI','ST-Elevation MI')
on conflict do nothing;

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('CATHPCI_INDICATION','2','NSTEMI','Non-ST-Elevation MI')
on conflict do nothing;

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('CATHPCI_INDICATION','3','UA','Unstable Angina')
on conflict do nothing;

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('ACCESS_SITE','1','RADIAL','Radial'),
('ACCESS_SITE','2','FEMORAL','Femoral')
on conflict do nothing;

-- =====================
-- SECTION 8: OPTIONAL SUPPORT OBJECTS
-- =====================

-- Suggested unique keys (enforce only if your upstream guarantees uniqueness)
-- alter table ucrm_procedure add constraint uq_ucrm_proc_enc_dt unique (encounter_sk, procedure_dt) deferrable initially deferred;

-- Example helper function (Postgres) for MRN hashing with a server-side salt
-- create extension if not exists pgcrypto;
-- create or replace function hash_mrn(mrn text) returns text language sql immutable as $$
--   select encode(digest(mrn || current_setting('app.mrn_salt', true), 'sha256'), 'hex');
-- $$;

-- End of file
