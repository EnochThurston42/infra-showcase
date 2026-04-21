# Infra Showcase 🏗️

Production-grade deployment infrastructure for the [TaskFlow API](https://github.com/sepulchralvoid666/taskflow-api) — demonstrating Docker best practices, CI/CD pipelines, and deployment configurations.

This project takes an existing FastAPI application and adds the infrastructure layer that turns "it works on my machine" into "it runs in production."

## What This Demonstrates

- **Multi-stage Docker builds** — small, secure production images
- **Docker Compose** — full stack (app + PostgreSQL + Redis + Nginx)
- **GitHub Actions CI** — lint, test, build on every push
- **GitHub Actions CD** — automated deployment on release
- **Environment-based config** — dev/staging/prod separation
- **Health checks** — application and infrastructure monitoring
- **Nginx reverse proxy** — SSL termination and static file serving

## Architecture

```
                    ┌───────────┐
                    │   Nginx   │ :80/:443
                    │  (proxy)  │
                    └─────┬─────┘
                          │
                    ┌─────▼─────┐
                    │  FastAPI   │ :8000
                    │ (TaskFlow) │
                    └─────┬─────┘
                          │
               ┌──────────┼──────────┐
               │          │          │
        ┌──────▼──┐ ┌─────▼────┐ ┌──▼──────┐
        │PostgreSQL│ │  Redis  │ │  Worker │
        │  :5432  │ │  :6379  │ │ (async) │
        └─────────┘ └─────────┘ └─────────┘
```

## Quick Start

### Development

```bash
docker compose -f docker/docker-compose.yml up --build
```

- API: http://localhost
- Docs: http://localhost/docs
- pgAdmin: http://localhost:5050 (dev only)

### Production

```bash
# Set environment variables
cp deploy/.env.production.example deploy/.env.production

# Deploy
docker compose -f docker/docker-compose.prod.yml up -d --build
```

## CI/CD Pipeline

### Continuous Integration (every push)

```
Push ──▶ Lint (ruff) ──▶ Test (pytest) ──▶ Build (Docker) ──▶ Push Image
```

### Continuous Deployment (on release)

```
Release ──▶ Build Production Image ──▶ Push to Registry ──▶ Deploy to Server
```

### Branch Strategy

- `main` — production deploys
- `develop` — staging deploys
- `feature/*` — CI only (lint + test)

## Project Structure

```
infra-showcase/
├── .github/workflows/
│   ├── ci.yml              # Lint, test, build on push
│   └── cd.yml              # Deploy on release
├── docker/
│   ├── Dockerfile          # Multi-stage production build
│   ├── Dockerfile.dev      # Development build with hot reload
│   ├── docker-compose.yml  # Development stack
│   ├── docker-compose.prod.yml  # Production stack
│   ├── nginx/
│   │   ├── nginx.conf      # Production Nginx config
│   │   └── nginx.dev.conf  # Dev Nginx config
│   └── entrypoint.sh       # Application entrypoint
├── deploy/
│   ├── .env.production.example
│   └── deploy.sh           # Zero-downtime deploy script
├── scripts/
│   ├── health-check.sh     # Comprehensive health check
│   ├── backup-db.sh        # Database backup script
│   └── seed-dev.sh         # Seed development data
├── tests/
│   ├── test_docker_build.py    # Docker build validation
│   └── test_health_endpoints.py # Health check endpoint tests
├── Makefile                # Common operations
└── README.md
```

## Multi-Stage Docker Build

The production Dockerfile uses three stages:

1. **Builder** — install dependencies in a virtual environment
2. **Runtime** — copy only the venv and app code (no build tools)
3. **Final** — minimal image with non-root user

Result: ~150MB image vs ~800MB single-stage build.

## Environment Configuration

| File | Purpose |
|------|---------|
| `.env.development` | Local dev defaults |
| `deploy/.env.production` | Production secrets (never committed) |
| `deploy/.env.production.example` | Template for production env |

Key variables:

```bash
DATABASE_URL=postgresql+asyncpg://user:pass@db:5432/taskflow
SECRET_KEY=your-secret-key-here
ENVIRONMENT=production
REDIS_URL=redis://redis:6379/0
```

## Health Checks

```bash
# Quick check
curl http://localhost/health

# Comprehensive check (all services)
./scripts/health-check.sh
```

## License

MIT
