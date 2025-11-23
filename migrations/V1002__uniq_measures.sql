-- Ensure re-runs won't duplicate measures
create unique index if not exists uidx_ucrm_measure_proc_code_dt
  on ucrm_measure(procedure_sk, measure_c, measure_dt);
