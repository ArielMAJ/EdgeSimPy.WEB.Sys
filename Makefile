CONTAINER_ENGINE := $(shell which podman || which docker)
COMPOSE := $(CONTAINER_ENGINE) compose

.PHONY: up
up: ## Run the project.
	$(COMPOSE) up --force-recreate -d

.PHONY: recreate
recreate: ## Recreate containers.
	$(COMPOSE) up --build --force-recreate -d

.PHONY: up-follow-all
up-follow-all: ## Run the project and follow all logs.
	$(COMPOSE) up --force-recreate

.PHONY: recreate-follow-all
recreate-follow-all: ## Recreate containers.
	$(COMPOSE) up --build --force-recreate

.PHONY: down
down: ## Stop all containers.
	$(COMPOSE) down

.PHONY: up-dbs
up-dbs: ## Start all database containers.
	$(COMPOSE) up -d --force-recreate sso-db esp-db

.PHONY: migrate-sso
migrate-sso: ## Run database migrations.
	cd sso && make install && make migrate

.PHONY: migrate-logger
migrate-logger: ## Run database migrations.
	cd logger && make install && make migrate

.PHONY: remove-containers
remove-containers: ## Remove all containers.
	$(CONTAINER_ENGINE) rm -f $$($(CONTAINER_ENGINE) ps -a -q)

.PHONY: remove-container-images
remove-container-images: ## Remove all downloaded container images.
	$(CONTAINER_ENGINE) rmi -f $$($(CONTAINER_ENGINE) images -q)

.PHONY: clean
clean: ## Clean project's temporary files.
	find . -name '__pycache__' -exec rm -rf {} +
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.log' -exec rm -f {} +

.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed 's/Makefile://g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
