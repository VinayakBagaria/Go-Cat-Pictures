# source: https://btree.dev/golang-makefile

.DEFAULT_GOAL := help

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

## Build Commands
build: ## builds for current OS and architecture
	docker-compose down
	docker-compose build

## Run Commands
server: ## runs the essential services env in Docker
	go run main.go

whole: ## runs the whole env in Docker
	docker-compose down
	docker-compose up -d
	go run main.go


## Service Commands
services: ## runs the main services required to start an api server: db, broker, cache
	docker-compose down
	docker-compose up -d db

test: ## runs the test cases
	docker-compose down
	docker-compose up -d db
	go test

refreshdb: ## refreshes the database by removing the existing database and recreating it
	docker-compose down
	docker-compose up -d db
	sleep 3
	docker-compose exec -T db psql -h localhost --user postgres -c 'drop database if exists pictures'
	docker-compose exec -T db psql -h localhost --user postgres -c 'create database pictures'

## Help Commands
.PHONY: help
help: ## shows this help
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-30s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)