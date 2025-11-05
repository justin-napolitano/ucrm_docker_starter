#!/bin/bash

# enable hashing functions just in case
docker exec -it ucrm-postgres psql -U ucrm -d ucrm -c "create extension if not exists pgcrypto;"

# run core DDL
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V0001__init_core_dims.sql
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V0002__procedure_and_facts.sql
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V0003__provenance_and_mappings.sql
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V0004__program_extensions.sql
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V0005__analyst_views.sql
# SKIP V0006__starter_value_sets.sql for now (since you don’t want to seed anything)

