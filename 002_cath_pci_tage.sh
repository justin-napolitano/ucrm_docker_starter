#!/bin/bash
# create staging table
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V1001__stg_cathpci_header.sql

# copy & load your CSV export into staging (adjust path/filename)
docker cp ./CathPCI_sample.csv ucrm-postgres:/tmp/CathPCI_sample.csv
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -c "\copy stg_ncdr.cathpci_header from '/tmp/CathPCI_sample.csv' with csv header"

