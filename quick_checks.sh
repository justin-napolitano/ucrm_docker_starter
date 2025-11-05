docker exec -it ucrm-postgres psql -U ucrm -d ucrm -c "select count(*) patients from ucrm_patient;"
docker exec -it ucrm-postgres psql -U ucrm -d ucrm -c "select count(*) cathpci_procs from ucrm_procedure where registry_program_c='NCDR_CATHPCI';"
docker exec -it ucrm-postgres psql -U ucrm -d ucrm -c "select * from ucrm_registry_event order by loaded_at desc limit 10;"
docker exec -it ucrm-postgres psql -U ucrm -d ucrm -c "
  select p.procedure_sk,
         extract(epoch from (max(case when m.measure_c='DBT_BALLOON_TIME' then m.measure_dt end)
                          -  max(case when m.measure_c='DBT_DOOR_TIME'    then m.measure_dt end)))/60.0 as dbt_min
  from ucrm_procedure p join ucrm_measure m using (procedure_sk)
  where p.registry_program_c='NCDR_CATHPCI'
  group by p.procedure_sk
  order by dbt_min nulls last limit 20;"

