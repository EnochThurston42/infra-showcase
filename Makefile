.PHONY: help dev prod test lint build clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Development ──────────────────────────────────────────────────────

dev: ## Start development stack
	docker compose -f docker/docker-compose.yml up --build

dev-down: ## Stop development stack
	docker compose -f docker/docker-compose.yml down

dev-logs: ## Tail development logs
	docker compose -f docker/docker-compose.yml logs -f api

# ── Production ───────────────────────────────────────────────────────

prod: ## Start production stack
	docker compose -f docker/docker-compose.prod.yml up -d --build

prod-down: ## Stop production stack
	docker compose -f docker/docker-compose.prod.yml down

prod-logs: ## Tail production logs
	docker compose -f docker/docker-compose.prod.yml logs -f

# ── Testing ──────────────────────────────────────────────────────────

test: ## Run tests
	pytest tests/ -v

test-cov: ## Run tests with coverage
	pytest tests/ -v --cov=app --cov-report=term-missing

# ── Code Quality ─────────────────────────────────────────────────────

lint: ## Run linter
	ruff check app/ tests/

format: ## Format code
	ruff format app/ tests/

# ── Docker ───────────────────────────────────────────────────────────

build: ## Build production image
	docker build -f docker/Dockerfile -t taskflow-api:latest ..

build-dev: ## Build development image
	docker build -f docker/Dockerfile.dev -t taskflow-api:dev ..

# ── Database ─────────────────────────────────────────────────────────

backup: ## Backup production database
	./scripts/backup-db.sh

seed: ## Seed development data
	./scripts/seed-dev.sh

migrate: ## Run database migrations
	docker compose -f docker/docker-compose.yml exec api alembic upgrade head

# ── Health ───────────────────────────────────────────────────────────

health: ## Run health check
	./scripts/health-check.sh

# ── Cleanup ──────────────────────────────────────────────────────────

clean: ## Remove containers, volumes, and images
	docker compose -f docker/docker-compose.yml down -v --rmi all
	docker compose -f docker/docker-compose.prod.yml down -v --rmi all
