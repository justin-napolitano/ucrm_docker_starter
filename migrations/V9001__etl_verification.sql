--- ETL VERIFICATION ---
select count(*) as stg_rows from stg_ncdr.cathpci_header;
select count(*) as patients   from ucrm_patient;
select count(*) as facilities from ucrm_facility;
select count(*) as providers  from ucrm_provider;
select count(*) as encounters from ucrm_encounter;
select count(*) as procedures from ucrm_procedure where registry_program_c = 'NCDR_CATHPCI';
select count(*) as measures   from ucrm_measure;
select * from ucrm_registry_event order by loaded_at desc limit 5;
