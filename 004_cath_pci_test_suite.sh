docker exec -i ucrm-postgres psql -U ucrm -d ucrm <<'SQL'
\echo '--- 1️⃣ STAGING CHECK ---'
select count(*) as stg_rows from stg_ncdr.cathpci_header;
select * from stg_ncdr.cathpci_header limit 5;

\echo '--- 2️⃣ CORE TABLE COUNTS ---'
select count(*) as patients   from ucrm_patient;
select count(*) as facilities from ucrm_facility;
select count(*) as providers  from ucrm_provider;
select count(*) as encounters from ucrm_encounter;
select count(*) as procedures from ucrm_procedure where registry_program_c = 'NCDR_CATHPCI';
select count(*) as measures   from ucrm_measure;

\echo '--- 3️⃣ PROVENANCE CHECK ---'
select * from ucrm_registry_event order by loaded_at desc limit 5;

\echo '--- 4️⃣ ENCOUNTER NUM DEBUG ---'
select site_id, case_id, encounter_num,
       site_id || '-' || case_id as generated_encounter_num,
       encounter_num is null as was_null
from stg_ncdr.cathpci_header limit 5;

\echo '--- 5️⃣ MRN HASH DEBUG ---'
select mrn, mrn_hash,
       encode(digest(coalesce(mrn,''),'sha256'),'hex') as computed_hash
from stg_ncdr.cathpci_header limit 5;
SQL
