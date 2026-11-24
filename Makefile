# airflow-stac-eo-pipeline: local ladder control surface (docker compose).
#
#   make check     # are Docker, docker compose and uv available?
#   make up        # data services: S3 store (RustFS), pgSTAC, STAC API, stac-browser (+ the bucket)
#   make seed      # seed the logbook with two missions and deliberate gaps
#   make clean     # clear the logbook and empty the bucket (keeps the containers)
#   make down      # stop and remove everything, volumes included

SHELL := /usr/bin/env bash
COMPOSE ?= docker compose

# Every value the eo_ingest scripts read, pinned so an ambient S3_* or AWS_* in the caller's shell
# (a real cloud profile, say) cannot leak into this local demo. Loopback endpoints only: the reset
# refuses anything else.
LOCAL_ENV := SOURCE_TYPE=synthetic \
	S3_ENDPOINT_URL=http://localhost:9100 S3_BUCKET=eo-assets \
	AWS_ACCESS_KEY_ID=minioadmin AWS_SECRET_ACCESS_KEY=minioadmin AWS_REGION=us-east-1 \
	STAC_URL=http://localhost:8081 ASSET_BASE_URL=http://localhost:9100/eo-assets

.DEFAULT_GOAL := help
.PHONY: help check up down status browse seed clean reset

help: ## Show this help
	@grep -E '^[a-z][a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

check: ## Preflight: Docker running, docker compose v2, uv installed
	@scripts/check_tools.sh

up: ## Start the data services and create the asset bucket (idempotent)
	$(COMPOSE) up -d --wait
	$(LOCAL_ENV) uv run --locked python scripts/bootstrap_bucket.py
	@echo "data services up: STAC API http://localhost:8081 · stac-browser http://localhost:8082 · S3 console http://localhost:9101"

down: ## Stop and remove all containers and volumes
	$(COMPOSE) down -v --remove-orphans

status: ## Show the services and their health
	$(COMPOSE) ps

browse: ## Print the local URLs
	@echo "STAC API      http://localhost:8081"
	@echo "stac-browser  http://localhost:8082"
	@echo "S3 console    http://localhost:9101  (minioadmin / minioadmin)"

seed: ## Seed the logbook: two missions with planted gaps
	$(LOCAL_ENV) uv run --locked python -m eo_ingest.seed

clean: ## Clear the logbook and empty the asset bucket (keeps the containers)
	$(LOCAL_ENV) uv run --locked python -m eo_ingest.reset

reset: clean seed ## clean, then seed
