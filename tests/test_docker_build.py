"""Tests for Docker build validation."""

import subprocess
import os

import pytest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def test_dockerfile_exists():
    """Production Dockerfile exists."""
    dockerfile = os.path.join(os.path.dirname(__file__), "..", "docker", "Dockerfile")
    assert os.path.exists(dockerfile)


def test_dockerfile_dev_exists():
    """Development Dockerfile exists."""
    dockerfile = os.path.join(os.path.dirname(__file__), "..", "docker", "Dockerfile.dev")
    assert os.path.exists(dockerfile)


def test_dockerfile_uses_multistage():
    """Production Dockerfile uses multi-stage builds."""
    dockerfile = os.path.join(os.path.dirname(__file__), "..", "docker", "Dockerfile")
    with open(dockerfile) as f:
        content = f.read()
    # Should have at least 2 FROM statements for multi-stage
    from_count = content.count("FROM ")
    assert from_count >= 2, f"Expected >=2 FROM statements, got {from_count}"


def test_dockerfile_non_root_user():
    """Production Dockerfile runs as non-root user."""
    dockerfile = os.path.join(os.path.dirname(__file__), "..", "docker", "Dockerfile")
    with open(dockerfile) as f:
        content = f.read()
    assert "USER appuser" in content


def test_dockerfile_has_healthcheck():
    """Production Dockerfile defines a health check."""
    dockerfile = os.path.join(os.path.dirname(__file__), "..", "docker", "Dockerfile")
    with open(dockerfile) as f:
        content = f.read()
    assert "HEALTHCHECK" in content


def test_entrypoint_script_exists():
    """Entrypoint script exists and is executable."""
    entrypoint = os.path.join(os.path.dirname(__file__), "..", "docker", "entrypoint.sh")
    assert os.path.exists(entrypoint)
    assert os.access(entrypoint, os.X_OK)


def test_docker_compose_dev_exists():
    """Development docker-compose.yml exists."""
    compose = os.path.join(os.path.dirname(__file__), "..", "docker", "docker-compose.yml")
    assert os.path.exists(compose)


def test_docker_compose_prod_exists():
    """Production docker-compose.prod.yml exists."""
    compose = os.path.join(os.path.dirname(__file__), "..", "docker", "docker-compose.prod.yml")
    assert os.path.exists(compose)


def test_compose_prod_has_resource_limits():
    """Production compose has resource limits."""
    compose = os.path.join(os.path.dirname(__file__), "..", "docker", "docker-compose.prod.yml")
    with open(compose) as f:
        content = f.read()
    assert "deploy" in content
    assert "limits" in content


def test_compose_prod_has_healthchecks():
    """Production compose services have health checks."""
    compose = os.path.join(os.path.dirname(__file__), "..", "docker", "docker-compose.prod.yml")
    with open(compose) as f:
        content = f.read()
    assert "healthcheck:" in content


def test_nginx_config_exists():
    """Nginx configuration exists."""
    nginx_conf = os.path.join(os.path.dirname(__file__), "..", "docker", "nginx", "nginx.conf")
    assert os.path.exists(nginx_conf)


def test_nginx_config_has_upstream():
    """Nginx config defines upstream proxy."""
    nginx_conf = os.path.join(os.path.dirname(__file__), "..", "docker", "nginx", "nginx.conf")
    with open(nginx_conf) as f:
        content = f.read()
    assert "upstream" in content
    assert "proxy_pass" in content


def test_nginx_config_has_rate_limiting():
    """Nginx config has rate limiting configured."""
    nginx_conf = os.path.join(os.path.dirname(__file__), "..", "docker", "nginx", "nginx.conf")
    with open(nginx_conf) as f:
        content = f.read()
    assert "limit_req_zone" in content
