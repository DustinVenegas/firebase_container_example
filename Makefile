# Makefile for managing services and running integration tests

# Sets shell to bin/sh
SHELL := /bin/sh

# Variables
COMPOSE_FILE := docker-compose.yml
ROOT_DIR := $(shell pwd)
INTEGRATION_TEST_SCRIPT := ./scripts/integration_test.sh

# Configurable parameters with default values
FIRESTORE_EMULATOR_HOST ?= localhost:8080
fshost ?= $(shell echo '$(FIRESTORE_EMULATOR_HOST)' | cut -d':' -f1)
fsport ?= $(shell echo '$(FIRESTORE_EMULATOR_HOST)' | cut -d':' -f2)
API_HOST ?= localhost
API_PORT ?= 3000

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  start-docker-compose   Start services using Docker Compose"
	@echo "  start-localhost        Start services on localhost"
	@echo "  validate-endpoints     Validate service endpoints"
	@echo "  run-tests              Run integration tests against a configured host"

# Start services using Docker Compose
.PHONY: start-docker-compose
start-docker-compose:
	docker-compose -f $(COMPOSE_FILE) up --build -d

# Start services on localhost (placeholder for actual commands)
.PHONY: start-localhost
start-localhost:
	@echo "Starting services on localhost..."
	npm start

# Validate service endpoints
.PHONY: validate-endpoints
validate-endpoints:
	@echo "Validating Firestore emulator on $(fshost):$(fsport)..."
	@nc -zv $(fshost) $(fsport) || (echo "Firestore emulator not reachable" && exit 1)
	@echo "Validating API on $(API_HOST):$(API_PORT)..."
	@nc -zv $(API_HOST) $(API_PORT) || (echo "API not reachable" && exit 1)

.PHONY: validate-emulator-db-documents-name
validate-emulator-db-documents-name:
	@curl -s "http://${FIRESTORE_EMULATOR_HOST}/v1/projects/emu-project/databases/\(default\)/documents" | grep -q name

validate-api-endpoint:
	@curl -s "http://${API_HOST}:${API_PORT}/health" | grep -q "OK"

container-seed-emulator: validate-emulator-db-documents-name
	@echo "Seeding Firestore emulator with initial data..."
	@docker-compose -f "${COMPOSE_FILE}" exec -T -e FIRESTORE_EMULATOR_HOST=${FIRESTORE_EMULATOR_HOST} -e GOOGLE_CLOUD_PROJECT=emu-project api npm run seed

http-seed-emulator: validate-emulator-db-documents-name
	@echo "Seeding Firestore emulator with initial data..."
	@curl -X POST "http://${FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/emu-project/databases/(default)/documents:import" \
	-H "Content-Type: application/json" \
	--data-binary @./scripts/seed_data.json

# Run integration tests
.PHONY: run-tests
run-tests:
	@echo "Running integration tests..."
	$(INTEGRATION_TEST_SCRIPT)
