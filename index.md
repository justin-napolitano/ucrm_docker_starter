---
slug: github-ucrm-docker-starter
title: 'UCRM Docker Starter: Containerized Platform for Clinical Data ETL'
repo: justin-napolitano/ucrm_docker_starter
githubUrl: https://github.com/justin-napolitano/ucrm_docker_starter
generatedAt: '2025-11-23T09:48:44.856306Z'
source: github-auto
summary: >-
  Dockerized environment deploying PostgreSQL, dbt, and Prefect to orchestrate ETL workflows for the
  Unified Cardiology Registry Model clinical data platform.
tags:
  - docker
  - postgresql
  - dbt
  - prefect
  - etl-pipeline
  - clinical-data
seoPrimaryKeyword: ucrm docker starter
seoSecondaryKeywords:
  - dockerized etl
  - postgresql
  - dbt
  - prefect
  - clinical data platform
seoOptimized: true
topicFamily: datascience
topicFamilyConfidence: 0.9
topicFamilyNotes: >-
  The post describes building a containerized ETL pipeline for clinical data involving PostgreSQL,
  dbt, and Prefect orchestration, which aligns closely with data analysis, ETL pipelines, and
  scientific data workflows typical of the 'datascience' family.
---

# Technical Overview: UCRM Docker Starter

## Motivation

The Unified Cardiology Registry Model (UCRM) aims to standardize and centralize cardiology-related clinical data for analytics and reporting. This project provides a Dockerized environment to deploy, initialize, and orchestrate the UCRM data platform, enabling consistent development and testing workflows.

## Problem Addressed

Deploying complex clinical data models and ETL pipelines often requires managing multiple dependencies and services. Manual setup can lead to inconsistencies and environment drift. This starter repository addresses these issues by containerizing the core database, data transformation tools, and orchestration workflows.

## Architecture and Components

- **PostgreSQL Database**: Runs as a Docker container with persistent volume storage. It hosts the UCRM schema, including core dimensions (patients, providers, encounters), program-specific extensions, and staging tables.

- **pgAdmin**: Provides a web-based GUI for database administration, accessible at localhost:8080.

- **dbt (Data Build Tool)**: Runs in a dedicated container built from a Dockerfile. It manages data transformations, seeds, runs models, and tests within the UCRM schema.

- **Prefect**: A lightweight orchestration container runs a Python script that sequentially executes dbt seed, run, and test commands. This flow can be extended for scheduling and monitoring.

- **Migrations**: SQL scripts in the migrations directory define the schema, indexes, views, and ETL logic. They are applied in sequence to build and maintain the data warehouse.

- **Shell Scripts**: Provide automation for initializing the database with required extensions and running core migrations.

## Implementation Details

- **Database Initialization**: The `001_initialize_master.sh` script enables the `pgcrypto` extension and runs core DDL migrations. It skips seeding value sets initially to avoid unwanted data.

- **Docker Compose Configuration**: Defines four main services:
  - `postgres`: PostgreSQL 15 with environment variables for user, password, and database.
  - `pgadmin`: Web interface for database management.
  - `dbt`: Custom build context running dbt commands with environment variables for connection.
  - `prefect`: Runs a Python-based Prefect flow to orchestrate dbt tasks.

- **Migrations**: Include core dimension tables (`ucrm_patient`, `ucrm_facility`, `ucrm_provider`, `ucrm_encounter`), procedure tables, device and condition extensions, and value set mappings.

- **ETL Proof of Concept**: Scripts like `V2001__cathpci_poc_load.sql` demonstrate normalization of CathPCI registry data into UCRM core tables using staging data.

- **Data Quality and Integrity**: Unique indexes and conflict-handling strategies (`ON CONFLICT DO NOTHING`) ensure idempotent and consistent data loading.

- **Orchestration Flow**: The Prefect flow (`prefect_flow.py`) is minimalistic, running dbt seed, run, and test tasks sequentially. This can be expanded for more complex workflows.

## Practical Notes

- The environment variables are managed via a `.env` file, allowing customization of credentials and ports.

- The project assumes familiarity with Docker, PostgreSQL, dbt, and Prefect.

- The migration scripts are written to be idempotent and compatible with PostgreSQL and potentially Snowflake with minor adjustments.

- The repository includes sample data and staging schemas to facilitate development and testing.

## Conclusion

This repository serves as a foundational platform for deploying and managing the UCRM data environment. It balances containerization for reproducibility with modular SQL migrations and orchestration scripts. The design prioritizes idempotency, extensibility, and practical workflows for data engineering teams working with clinical registry data.

Future enhancements should focus on expanding automation, improving documentation, and integrating additional registry programs and data sources.

