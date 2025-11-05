# UCRM Docker Starter

## Quick Start
```bash
cp .env.example .env
docker compose up -d --build
docker exec -i ucrm-postgres psql -U ${POSTGRES_USER:-ucrm} -d ${POSTGRES_DB:-ucrm} -f /migrations/V0001__init_ucrm.sql
docker exec -it ucrm-dbt bash -lc "dbt seed && dbt run && dbt test"
```
Open pgAdmin at http://localhost:8080 (credentials in .env)
