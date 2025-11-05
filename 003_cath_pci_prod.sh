#!/bin/bash
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V2001__cathpci_poc_load.sql

