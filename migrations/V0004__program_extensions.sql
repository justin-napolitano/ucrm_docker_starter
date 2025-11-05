-- UCRM v1 — PROGRAM-SPECIFIC EXTENSIONS (optional but common)

-- CathPCI lesions (segment-level)
create table if not exists ext_cathpci_lesion (
    lesion_sk        bigint generated always as identity primary key,
    procedure_sk     bigint not null references ucrm_procedure(procedure_sk),
    vessel_c         varchar(32),      -- LAD, LCx, RCA, LM, GRAFT
    segment_c        varchar(32),
    stenosis_pct_pre numeric(5,2),
    stenosis_pct_post numeric(5,2),
    culprit_flag     boolean,
    created_at       timestamp default current_timestamp
);

create index if not exists idx_ext_lesion_proc on ext_cathpci_lesion(procedure_sk);

-- ICD/EP system details
create table if not exists ext_icd_system (
    icd_system_sk             bigint generated always as identity primary key,
    procedure_sk              bigint not null references ucrm_procedure(procedure_sk),
    system_type_c             varchar(32),   -- ICD, CRT-D, CRT-P
    generator_model           varchar(128),
    shock_test_performed_flag boolean,
    created_at                timestamp default current_timestamp
);

create index if not exists idx_ext_icd_proc on ext_icd_system(procedure_sk);

