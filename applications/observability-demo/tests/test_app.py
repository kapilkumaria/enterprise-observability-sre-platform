"""API and telemetry behavior tests."""

from __future__ import annotations

import os

os.environ["OTEL_SDK_DISABLED"] = "true"
os.environ["OTEL_SERVICE_NAME"] = "observability-demo-test"
os.environ["SERVICE_VERSION"] = "test"
os.environ["DEPLOYMENT_ENVIRONMENT"] = "test"

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_returns_service_identity() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "service": "observability-demo-test",
        "version": "test",
        "environment": "test",
        "status": "ok",
    }


def test_health_endpoint() -> None:
    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json() == {
        "status": "healthy",
    }


def test_readiness_endpoint() -> None:
    response = client.get("/readyz")

    assert response.status_code == 200
    assert response.json() == {
        "status": "ready",
    }


def test_work_endpoint() -> None:
    response = client.get("/work")

    assert response.status_code == 200
    assert response.json()["result"] == "success"
    assert response.json()["duration_seconds"] == 0.05


def test_slow_endpoint() -> None:
    response = client.get(
        "/slow",
        params={
            "delay": 0.0,
        },
    )

    assert response.status_code == 200
    assert response.json() == {
        "result": "success",
        "delay_seconds": 0.0,
    }


def test_slow_endpoint_rejects_excessive_delay() -> None:
    response = client.get(
        "/slow",
        params={
            "delay": 10,
        },
    )

    assert response.status_code == 422


def test_controlled_error_endpoint() -> None:
    response = client.get("/error")

    assert response.status_code == 500
    assert response.json() == {
        "detail": "Controlled demonstration error",
    }


def test_metrics_endpoint_exposes_application_metrics() -> None:
    client.get("/")
    client.get("/work")

    response = client.get("/metrics")

    assert response.status_code == 200
    assert (
        "observability_demo_http_requests_total"
        in response.text
    )
    assert (
        "observability_demo_http_request_duration_seconds"
        in response.text
    )
    assert "observability_demo_work_items_total" in response.text
