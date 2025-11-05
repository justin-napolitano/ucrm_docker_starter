-- UCRM v1 — CORE DIMENSIONS
-- Compatible with Postgres. For Snowflake, remove "if not exists" and identity syntax.

-- Patients (PHI-minimal)
create table if not exists ucrm_patient (
    patient_sk       bigint generated always as identity primary key,
    mrn_hash         varchar(128) not null unique,
    birth_date       date,
    sex_at_birth_c   varchar(20),
    race_c           varchar(40),
    ethnicity_c      varchar(40),
    death_date       date,
    created_at       timestamp default current_timestamp,
    updated_at       timestamp
);

-- Facilities
create table if not exists ucrm_facility (
    facility_sk   bigint generated always as identity primary key,
    facility_code varchar(64) not null unique,
    facility_name varchar(256),
    npi           varchar(20),
    created_at    timestamp default current_timestamp
);

-- Providers
create table if not exists ucrm_provider (
    provider_sk          bigint generated always as identity primary key,
    npi                  varchar(20) unique,
    provider_id_external varchar(64),
    provider_name        varchar(256),
    specialty_c          varchar(64),
    created_at           timestamp default current_timestamp
);

-- Encounters
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

create index if not exists idx_ucrm_encounter_patient  on ucrm_encounter(patient_sk);
create index if not exists idx_ucrm_encounter_facility on ucrm_encounter(facility_sk);
create index if not exists idx_ucrm_encounter_admit    on ucrm_encounter(admit_dt);

