-- UCRM v1 — PROVENANCE & MAPPINGS

-- Per-row lineage for all loads
create table if not exists ucrm_registry_event (
    registry_event_sk       bigint generated always as identity primary key,
    registry_program_c      varchar(32) not null,
    registry_schema_version varchar(32) not null,
    site_id                 varchar(64),
    source_file             varchar(512),
    load_id                 varchar(64),        -- ETL batch id/UUID
    source_primary_key      varchar(128),       -- registry-native case id
    ucrm_entity             varchar(64),        -- e.g., 'UCRM_PROCEDURE'
    ucrm_entity_sk          bigint,             -- FK inserted in target table
    loaded_at               timestamp default current_timestamp
);

create index if not exists idx_registry_event_prog   on ucrm_registry_event(registry_program_c, registry_schema_version);
create index if not exists idx_registry_event_entity on ucrm_registry_event(ucrm_entity, ucrm_entity_sk);

-- Field-level mapping metadata (registry → UCRM)
create table if not exists map_registry_to_ucrm (
    mapping_id              bigint generated always as identity primary key,
    registry_program_c      varchar(32) not null,
    registry_schema_version varchar(32) not null,
    registry_variable_id    varchar(128) not null,
    registry_variable_name  varchar(256),
    ucrm_table              varchar(64) not null,
    ucrm_column             varchar(64) not null,
    value_set_name          varchar(128),    -- for enumerations
    transform_sql           varchar(4000),   -- expression used staging→core
    is_required_flag        boolean default false,
    effective_start_dt      date default current_date,
    effective_end_dt        date
);

create index if not exists idx_map_to_ucrm_prog on map_registry_to_ucrm(registry_program_c, registry_schema_version);

-- Value-set normalization (registry code → normalized code/label)
create table if not exists map_value_sets (
    value_set_name   varchar(128) not null,
    registry_code    varchar(64)  not null,
    normalized_code  varchar(64)  not null,
    normalized_label varchar(128),
    primary key (value_set_name, registry_code)
);

