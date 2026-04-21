"""Tests for health check and deploy scripts."""

import os
import stat

import pytest


SCRIPTS_DIR = os.path.join(os.path.dirname(__file__), "..", "scripts")
DEPLOY_DIR = os.path.join(os.path.dirname(__file__), "..", "deploy")


def test_health_check_script_exists():
    """Health check script exists."""
    assert os.path.exists(os.path.join(SCRIPTS_DIR, "health-check.sh"))


def test_health_check_script_executable():
    """Health check script is executable."""
    script = os.path.join(SCRIPTS_DIR, "health-check.sh")
    assert os.access(script, os.X_OK)


def test_backup_script_exists():
    """Backup script exists."""
    assert os.path.exists(os.path.join(SCRIPTS_DIR, "backup-db.sh"))


def test_backup_script_executable():
    """Backup script is executable."""
    script = os.path.join(SCRIPTS_DIR, "backup-db.sh")
    assert os.access(script, os.X_OK)


def test_seed_script_exists():
    """Seed script exists."""
    assert os.path.exists(os.path.join(SCRIPTS_DIR, "seed-dev.sh"))


def test_deploy_script_exists():
    """Deploy script exists."""
    assert os.path.exists(os.path.join(DEPLOY_DIR, "deploy.sh"))


def test_deploy_script_executable():
    """Deploy script is executable."""
    script = os.path.join(DEPLOY_DIR, "deploy.sh")
    assert os.access(script, os.X_OK)


def test_env_production_example_exists():
    """Production env template exists."""
    env_file = os.path.join(DEPLOY_DIR, ".env.production.example")
    assert os.path.exists(env_file)


def test_env_production_example_has_required_vars():
    """Production env template has all required variables."""
    env_file = os.path.join(DEPLOY_DIR, ".env.production.example")
    with open(env_file) as f:
        content = f.read()
    required_vars = ["SECRET_KEY", "DATABASE_URL", "POSTGRES_PASSWORD", "REDIS_URL"]
    for var in required_vars:
        assert var in content, f"Missing required var: {var}"


def test_ci_workflow_exists():
    """CI GitHub Actions workflow exists."""
    ci = os.path.join(os.path.dirname(__file__), "..", ".github", "workflows", "ci.yml")
    assert os.path.exists(ci)


def test_cd_workflow_exists():
    """CD GitHub Actions workflow exists."""
    cd = os.path.join(os.path.dirname(__file__), "..", ".github", "workflows", "cd.yml")
    assert os.path.exists(cd)


def test_ci_workflow_has_lint_test_build():
    """CI workflow has lint, test, and build jobs."""
    ci = os.path.join(os.path.dirname(__file__), "..", ".github", "workflows", "ci.yml")
    with open(ci) as f:
        content = f.read()
    assert "lint:" in content
    assert "test:" in content
    assert "build:" in content


def test_cd_workflow_has_deploy():
    """CD workflow has deploy job."""
    cd = os.path.join(os.path.dirname(__file__), "..", ".github", "workflows", "cd.yml")
    with open(cd) as f:
        content = f.read()
    assert "deploy:" in content


def test_ci_uses_service_containers():
    """CI workflow uses PostgreSQL and Redis service containers."""
    ci = os.path.join(os.path.dirname(__file__), "..", ".github", "workflows", "ci.yml")
    with open(ci) as f:
        content = f.read()
    assert "postgres:" in content
    assert "redis:" in content


def test_makefile_exists():
    """Makefile exists with common operations."""
    makefile = os.path.join(os.path.dirname(__file__), "..", "Makefile")
    assert os.path.exists(makefile)
    with open(makefile) as f:
        content = f.read()
    assert "dev:" in content
    assert "prod:" in content
    assert "test:" in content
    assert "lint:" in content
