---
slug: github-ucrm-docker-starter-note-technical-overview
id: github-ucrm-docker-starter-note-technical-overview
title: UCRM Docker Starter
repo: justin-napolitano/ucrm_docker_starter
githubUrl: https://github.com/justin-napolitano/ucrm_docker_starter
generatedAt: '2025-11-24T18:49:01.276Z'
source: github-auto
summary: >-
  This repo is a Docker-based starter kit for the Unified Cardiology Registry
  Model (UCRM). It offers essential containerized components like PostgreSQL,
  pgAdmin, dbt, and Prefect for orchestration.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: note
entryLayout: note
showInProjects: false
showInNotes: true
showInWriting: false
showInLogs: false
---

This repo is a Docker-based starter kit for the Unified Cardiology Registry Model (UCRM). It offers essential containerized components like PostgreSQL, pgAdmin, dbt, and Prefect for orchestration.

## Key Features

- **PostgreSQL Database**: Preloaded with UCRM schemas.
- **pgAdmin**: For managing and visualizing the database.
- **dbt**: Handles data modeling, seeding, and testing.
- **Prefect**: Automates dbt tasks.

## Quick Start

### Prerequisites

- Ensure Docker and Docker Compose are installed.

### Run It

```bash
# Copy env variables
cp .env.example .env

# Build and start containers
docker compose up -d --build

# Initialize DB schema and seed data
docker exec -i ucrm-postgres psql -U ucrm -d ucrm -f /migrations/V0001__init_ucrm.sql

# Run dbt tasks
docker exec -it ucrm-dbt bash -lc "dbt seed && dbt run && dbt test"
```

### Access pgAdmin

Visit [http://localhost:8080](http://localhost:8080) using credentials from your `.env`.

### Gotcha

Make sure to check your environment variables and permissions for seamless access.
