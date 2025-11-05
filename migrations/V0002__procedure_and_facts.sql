-- UCRM v1 — PROCEDURE SPINE + CLINICAL FACTS

-- Procedure spine (program-agnostic)
create table if not exists ucrm_procedure (
    procedure_sk         bigint generated always as identity primary key,
    encounter_sk         bigint not null references ucrm_encounter(encounter_sk),
    provider_sk          bigint references ucrm_provider(provider_sk),
    registry_program_c   varchar(32) not null, -- 'NCDR_CATHPCI','NCDR_EP_DEVICE_IMPLANT','STS_TVT',...
    procedure_dt         timestamp,
    procedure_type_c     varchar(64),          -- PCI, ICD_IMPLANT, TAVR, LAAO, etc.
    primary_indication_c varchar(128),
    anesthesia_type_c    varchar(64),
    fluoroscopy_time_min numeric(8,2),
    contrast_volume_ml   numeric(8,2),
    success_flag         boolean,
    created_at           timestamp default current_timestamp
);

create index if not exists idx_ucrm_procedure_enc  on ucrm_procedure(encounter_sk);
create index if not exists idx_ucrm_procedure_prog on ucrm_procedure(registry_program_c, procedure_dt);

-- Devices (stents, valves, generators, leads, etc.)
create table if not exists ucrm_device (
    device_sk      bigint generated always as identity primary key,
    procedure_sk   bigint not null references ucrm_procedure(procedure_sk),
    device_role_c  varchar(64),   -- STENT, LEAD_RA, LEAD_RV, GENERATOR, VALVE, GRAFT
    udi            varchar(200),
    manufacturer_c varchar(128),
    model          varchar(128),
    lot            varchar(64),
    size_primary   varchar(64),   -- stent diameter/length; valve size
    created_at     timestamp default current_timestamp
);

create index if not exists idx_ucrm_device_proc on ucrm_device(procedure_sk);
create index if not exists idx_ucrm_device_role on ucrm_device(device_role_c);

-- Conditions (diagnoses/problems with context)
create table if not exists ucrm_condition (
    condition_sk         bigint generated always as identity primary key,
    encounter_sk         bigint not null references ucrm_encounter(encounter_sk),
    coding_system_c      varchar(32),  -- ICD10, SNOMED
    code                 varchar(32),
    description          varchar(256),
    onset_dt             timestamp,
    condition_context_c  varchar(32),  -- PRE, INTRA, POST
    created_at           timestamp default current_timestamp
);

create index if not exists idx_ucrm_condition_enc  on ucrm_condition(encounter_sk);
create index if not exists idx_ucrm_condition_code on ucrm_condition(code);

-- Measures (labs, vitals, timestamps, derived values)
create table if not exists ucrm_measure (
    measure_sk        bigint generated always as identity primary key,
    encounter_sk      bigint references ucrm_encounter(encounter_sk),
    procedure_sk      bigint references ucrm_procedure(procedure_sk),
    measure_c         varchar(64),    -- 'LVEF_PCT','LDL','DBT_DOOR_TIME','DBT_BALLOON_TIME','ACCESS_SITE_CODE'
    measure_value_num numeric(12,4),
    measure_value_txt varchar(256),
    measure_dt        timestamp,
    source_c          varchar(16) default 'EPIC', -- EPIC or REGISTRY
    created_at        timestamp default current_timestamp
);

create index if not exists idx_ucrm_measure_proc on ucrm_measure(procedure_sk);
create index if not exists idx_ucrm_measure_enc  on ucrm_measure(encounter_sk);
create index if not exists idx_ucrm_measure_type on ucrm_measure(measure_c);

-- Outcomes (complications/adjudications)
create table if not exists ucrm_outcome (
    outcome_sk    bigint generated always as identity primary key,
    encounter_sk  bigint references ucrm_encounter(encounter_sk),
    procedure_sk  bigint references ucrm_procedure(procedure_sk),
    outcome_c     varchar(128),   -- 'DEATH_INHOSP','STROKE','BLEED_BARC','VASCULAR_COMPL','AKI', ...
    severity_c    varchar(64),
    occurred_flag boolean,
    onset_dt      timestamp,
    source_c      varchar(16) default 'EPIC',
    created_at    timestamp default current_timestamp
);

create index if not exists idx_ucrm_outcome_proc on ucrm_outcome(procedure_sk);
create index if not exists idx_ucrm_outcome_type on ucrm_outcome(outcome_c);

-- Medications (peri-procedural + discharge)
create table if not exists ucrm_medication (
    medication_sk bigint generated always as identity primary key,
    encounter_sk  bigint references ucrm_encounter(encounter_sk),
    procedure_sk  bigint references ucrm_procedure(procedure_sk),
    context_c     varchar(32),      -- HOME, INTRAOP, INPATIENT, DISCHARGE
    medication_c  varchar(128),     -- normalized class/name (ASPIRIN, P2Y12_INHIBITOR, OAC, etc.)
    route_c       varchar(32),
    strength_txt  varchar(64),
    dose_num      numeric(10,2),
    dose_unit     varchar(32),
    start_dt      timestamp,
    end_dt        timestamp,
    source_c      varchar(16) default 'EPIC',
    created_at    timestamp default current_timestamp
);

create index if not exists idx_ucrm_med_proc on ucrm_medication(procedure_sk);
create index if not exists idx_ucrm_med_ctx  on ucrm_medication(context_c);

-- Timing events (milestones)
create table if not exists ucrm_timing_event (
    timing_event_sk bigint generated always as identity primary key,
    encounter_sk    bigint references ucrm_encounter(encounter_sk),
    procedure_sk    bigint references ucrm_procedure(procedure_sk),
    event_c         varchar(64),   -- 'ED_ARRIVAL','CATH_IN','SHEATH_IN','BALLOON_INFLATION','ICD_SHOCK_TEST'
    event_dt        timestamp,
    source_c        varchar(16) default 'EPIC',
    created_at      timestamp default current_timestamp
);

create index if not exists idx_ucrm_timing_proc  on ucrm_timing_event(procedure_sk);
create index if not exists idx_ucrm_timing_event on ucrm_timing_event(event_c);

