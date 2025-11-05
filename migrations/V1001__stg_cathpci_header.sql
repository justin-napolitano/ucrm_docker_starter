-- Create a dedicated staging schema for NCDR CathPCI POC
create schema if not exists stg_ncdr;

-- Header-level staging table (1 row per case)
drop table if exists stg_ncdr.cathpci_header;
create table stg_ncdr.cathpci_header (
  site_id              varchar(64) not null,
  case_id              varchar(64) not null,
  mrn                  varchar(128),
  mrn_hash             varchar(128),
  encounter_num        varchar(64),
  facility_code        varchar(64),
  operator_npi         varchar(20),
  procedure_dt         timestamp,
  primary_indication   varchar(128),
  fluoro_time_min      numeric(8,2),
  contrast_vol_ml      numeric(8,2),
  ed_arrival_time      timestamp,
  first_balloon_time   timestamp,
  source_file          varchar(512),
  load_id              varchar(64) default gen_random_uuid()::text,
  loaded_at            timestamp default current_timestamp
);
create index if not exists idx_stg_cath_site_case on stg_ncdr.cathpci_header(site_id, case_id);

