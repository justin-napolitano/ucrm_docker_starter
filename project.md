---
slug: github-ucrm-docker-starter
id: github-ucrm-docker-starter
title: Docker Starter Kit for Unified Cardiology Registry Model
repo: justin-napolitano/ucrm_docker_starter
githubUrl: https://github.com/justin-napolitano/ucrm_docker_starter
generatedAt: '2025-11-24T21:36:43.785Z'
source: github-auto
summary: >-
  Deploy and manage the UCRM environment using Docker with PostgreSQL, pgAdmin,
  dbt, and Prefect for orchestration.
tags:
  - docker
  - postgresql
  - pgadmin
  - dbt
  - prefect
  - etl
  - data transformation
seoPrimaryKeyword: ucrm docker starter kit
seoSecondaryKeywords:
  - docker compose setup
  - postgres database initialization
  - dbt data modeling
  - prefect workflow orchestration
  - etl pipeline automation
seoOptimized: true
topicFamily: null
topicFamilyConfidence: null
kind: project
entryLayout: project
showInProjects: true
showInNotes: false
showInWriting: false
showInLogs: false
---

A Docker-based starter kit for deploying and managing the Unified Cardiology Registry Model (UCRM) environment. This repository provides containerized components including a PostgreSQL database, pgAdmin, dbt for data transformations, and Prefect for orchestration.

## Features

- Containerized PostgreSQL database with preloaded UCRM core schemas and extensions
- pgAdmin for database management and visualization
- dbt integration for data modeling, seeding, running, and testing
- Prefect orchestration flow to automate daily dbt tasks
- Migration scripts for schema creation, data loading, and ETL verification

## Tech Stack

- Docker & Docker Compose
- PostgreSQL 15
- pgAdmin 4
- dbt (data build tool)
- Prefect (workflow orchestration)
- Shell scripting for initialization and quick checks

## Getting Started

### Prerequisites

- Docker and Docker Compose installed

### Installation and Run

```bash
# Copy example environment variables
cp .env.example .env

# Build and start containers in detached mode
docker compose up -d --build

# Initialize database schema and seed data
# Run core UCRM migrations
docker exec -i ucrm-postgres psql -U ${POSTGRES_USER:-ucrm} -d ${POSTGRES_DB:-ucrm} -f /migrations/V0001__init_ucrm.sql

# Run dbt seed, run, and test inside the dbt container
docker exec -it ucrm-dbt bash -lc "dbt seed && dbt run && dbt test"
```

### Access pgAdmin

Open your browser and navigate to [http://localhost:8080](http://localhost:8080).
Use credentials from your `.env` file (default: admin@example.com / admin).

## Project Structure

```
├── 001_initialize_master.sh       # Script to initialize core database extensions and run base migrations
├── 002_cath_pci_tage.sh           # (Assumed) Script related to CathPCI tagging
├── 003_cath_pci_prod.sh           # (Assumed) Script related to CathPCI production data
├── 004_cath_pci_test_suite.sh     # (Assumed) Script to run CathPCI test suite
├── CathPCI_sample.csv             # Sample data file for CathPCI
├── dbt/                          # dbt project files and models
├── docker/                       # Dockerfiles and related configs
├── docker-compose.yml            # Docker Compose configuration
├── docs/                        # Documentation and SQL schema files
├── etl/                         # ETL scripts (assumed)
├── migrations/                  # SQL migration scripts for UCRM schema and ETL
├── orchestration/               # Prefect flow and orchestration scripts
├── quick_checks.sh              # Utility script for quick environment checks
├── README.md                    # This file
├── scripts/                     # Additional helper scripts
└── stg/                         # Staging area for raw data
```

## Future Work / Roadmap

- Expand documentation with detailed usage and contribution guidelines
- Automate full ETL pipeline execution and monitoring
- Add support for additional registry programs beyond CathPCI
- Enhance test coverage for dbt models and Prefect flows
- Implement CI/CD pipelines for automated builds and deployments
- Improve container health checks and logging

---

*Note: Some scripts and directories are assumed based on naming conventions and typical ETL project structures.*
