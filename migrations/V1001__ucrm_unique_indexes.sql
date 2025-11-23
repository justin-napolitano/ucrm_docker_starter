--Ensure ON CONFLICT targets exist (safe to re-run)
create unique index if not exists uidx_ucrm_patient_mrn_hash
  on ucrm_patient(mrn_hash);

create unique index if not exists uidx_ucrm_facility_facility_code
  on ucrm_facility(facility_code);

create unique index if not exists uidx_ucrm_provider_npi
  on ucrm_provider(npi);

create unique index if not exists uidx_ucrm_encounter_encounter_num
  on ucrm_encounter(encounter_num);
