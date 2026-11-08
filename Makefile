# Variables
COMPOSE_FILE = docker/docker-compose.yml
CONTAINER_NAME = data_launchpad_postgres
DB_USER = postgres
DB_NAME = dev

export DBT_PROJECT_DIR = dbt_project
export DBT_PROFILES_DIR = dbt_project
DBT = uv run dbt

# Database controls
.PHONY: help up down restart reset logs psql query pgcli

# dbt operations
.PHONY: dbt-debug dbt-run dbt-test dbt-build dbt-clean dbt-parse dbt-docs

# Quality & DuckDB inspection
.PHONY: lint format duckdb-tables duckdb-query

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Start the database container and wait until healthy
	docker compose -f $(COMPOSE_FILE) up -d --wait

down: ## Stop the database container
	docker compose -f $(COMPOSE_FILE) down

restart: down up ## Restart the database

reset: ## Destroy database volume and re-run all init/seed scripts from scratch
	docker compose -f $(COMPOSE_FILE) down -v
	docker compose -f $(COMPOSE_FILE) up -d --wait

logs: ## Tail database container logs
	docker compose -f $(COMPOSE_FILE) logs -f

psql: ## Open an interactive psql shell inside the container
	docker exec -it $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME)

query: ## Run a one-off query: make query q="SELECT * FROM raw.customers;"
	@docker exec -i $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME) -c "$(q)"

pgcli: ## Open rich interactive shell with autocompletion via uv
	uv run pgcli postgresql://postgres:postgrespassword@localhost:5432/dev

dbt-debug: ## Test dbt connection to DuckDB and Postgres
	$(DBT) debug

dbt-run: ## Run dbt models
	$(DBT) run

dbt-test: ## Run dbt tests
	$(DBT) test

dbt-build: ## Build models and run tests together in DAG order
	$(DBT) build

dbt-clean: ## Clean dbt artifacts and local DuckDB files
	$(DBT) clean

dbt-parse: ## Parse the dbt files
	$(DBT) parse

dbt-docs: ## genereate and serve docs
	$(DBT) docs generate
	$(DBT) docs serve

# linting & formatting
lint: ## Check Python code with ruff
	uv run ruff check .

format: ## Format Python code with ruff
	uv run ruff format .

# duckdb
duckdb-tables: ## List all tables and views in DuckDB
	@uv run python -c "import duckdb; con = duckdb.connect('warehouse.duckdb'); print(con.sql('SHOW TABLES;'))"

duckdb-query: ## Query DuckDB: make duckdb-query q="SELECT * FROM dim_customers;"
	@uv run python -c "import duckdb; con = duckdb.connect('warehouse.duckdb'); print(con.sql('$(q)'))"
