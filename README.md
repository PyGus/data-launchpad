# Data Launchpad

A lightweight analytics engineering foundation with PostgreSQL (OLTP source), DuckDB (embedded OLAP warehouse), and dbt for transformations and data tests, automated via GitHub Actions CI.

---

## Architecture & Data Flow

```
┌─────────────────────────┐
│ Docker: PostgreSQL 16   │ (Source / OLTP)
│ - raw.customers         │
│ - raw.orders            │
└────────────┬────────────┘
             │  DuckDB postgres extension (direct attach)
             ▼
┌─────────────────────────┐
│ DuckDB 2.0 (Warehouse)  │ (warehouse.duckdb)
│                         │
│  Staging (Views)        │
│  - stg_customers        │
│  - stg_orders           │
│            │            │
│            ▼            │
│  Marts (Tables)         │
│  - fct_orders           │
│  - dim_customers        │
└────────────┬────────────┘
             │  dbt build (transforms + schema & integrity tests)
             ▼
┌─────────────────────────┐
│ GitHub Actions CI       │ (Automated verification on push & PR)
│ - Ruff lint & format    │
│ - Docker DB healthcheck │
│ - dbt build & tests     │
└─────────────────────────┘
```

---

## Tech Stack

* **Package & Environment Manager:** `uv` (Python 3.15)
* **Source Database:** PostgreSQL 16 Alpine (Docker)
* **Data Warehouse:** DuckDB 2.0
* **Transformation & Testing:** `dbt-duckdb`
* **Linter & Formatter:** Ruff
* **Database Clients:** `psql`, `pgcli`
* **CI/CD:** GitHub Actions

---

## Repository Structure

```text
data-launchpad/
├── .github/workflows/
│   └── ci.yml               # GitHub Actions CI pipeline
├── .zed/
│   └── settings.json        # Zed editor formatting & Ruff hooks on save
├── docker/
│   ├── docker-compose.yml   # PostgreSQL container configuration
│   └── init/                # Auto-executed seed scripts on container initialization
│       ├── 01_schema.sql    # DDL schema (raw.customers, raw.orders)
│       └── 02_seed_data.sql # Initial sample dataset
├── dbt_project/
│   ├── dbt_project.yml      # dbt project configurations & materialization rules
│   ├── profiles.yml         # DuckDB profile attaching PostgreSQL
│   └── models/
│       ├── sources.yml      # Source declarations and data quality tests
│       ├── staging/         # 1:1 cleaned views (stg_customers, stg_orders)
│       └── marts/           # Business tables (dim_customers, fct_orders, schema.yml)
├── Makefile                 # CLI shortcuts for Docker, dbt, and DuckDB
├── pyproject.toml           # Project dependencies and tool configurations
├── uv.lock                  # Pinned dependency lockfile
└── README.md
```

---

## Quickstart

### 1. Prerequisites
* Docker Desktop or Docker Engine
* `uv`

### 2. Environment Setup
Install dependencies into the local virtual environment:
```bash
uv sync
```

### 3. Start PostgreSQL
Start the database container and wait for healthchecks:
```bash
make up
```

### 4. Build & Test Transformations
Compile SQL, build DuckDB views and physical tables, and run all data quality tests:
```bash
make dbt-build
```

---

## Data Inspection

### Querying DuckDB (Warehouse)
```bash
# List all tables and views in DuckDB
make duckdb-tables

# Query mart tables
make duckdb-query q="SELECT * FROM dim_customers;"
make duckdb-query q="SELECT * FROM fct_orders;"
```

### Querying PostgreSQL (Source)
```bash
# Open interactive psql shell inside the container
make psql

# Open interactive shell with autocompletion (pgcli)
make pgcli

# Run a single query
make query q="SELECT * FROM raw.orders;"
```

### Lineage Graph & Documentation
Generate and serve the interactive dbt documentation site and DAG viewer:
```bash
make dbt-docs
```
Accessible at `http://localhost:8080`.

---

## Maintenance & Commands Reference

* **Reset database:** Destroys the Postgres volume and re-runs seed scripts from scratch:
  ```bash
  make reset
  ```
* **Clean dbt artifacts:** Removes `target/` and local `warehouse.duckdb`:
  ```bash
  make dbt-clean
  ```
* **Lint & format code:**
  ```bash
  make lint
  make format
  ```

---

## Roadmap & Next Steps

* **Lakehouse Storage (MinIO & Apache Iceberg):**
  * Deploy MinIO in Docker for local S3-compatible object storage.
  * Store and partition analytics tables using Apache Iceberg format, queried via DuckDB's `iceberg` extension.
* **Pipeline Orchestration (Apache Airflow + Astronomer Cosmos):**
  * Automate pipeline runs using a lightweight `LocalExecutor` Airflow setup.
  * Use Astronomer Cosmos to parse dbt models into granular, retryable Airflow DAG task nodes.
* **Streaming Ingestion & Caching (Redis):**
  * *Pub/Sub & Streams:* Streaming ingestion pipeline for real-time event capture into staging.
  * *KPI & Query Cache:* Sub-millisecond cache for pre-computed metrics and dashboard queries.
* **Semantic Layer & Metrics (dbt):**
  * Model centralized metrics, dimensions, and semantic definitions via dbt Semantic Layer / MetricFlow.
* **Agentic API & MCP Layer (Model Context Protocol):**
  * Implement a FastMCP server exposing tools (`query_warehouse`, `get_metric`, `inspect_schema`) for custom AI agents running locally or in containers.
* **Ontology Layer:**
  * Define domain entities, relationships, and business semantics into an explicit knowledge model connecting operational and analytical domains.
