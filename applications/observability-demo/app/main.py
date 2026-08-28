"""Instrumented FastAPI demonstration service."""

from __future__ import annotations

import asyncio
import os
import time
from collections.abc import Awaitable, Callable
from typing import Any

from fastapi import FastAPI, HTTPException, Query, Request, Response
from opentelemetry import trace
from prometheus_client import Counter, Histogram, make_asgi_app

from app.logging_config import configure_logging
from app.telemetry import configure_tracing

SERVICE_NAME = os.getenv(
    "OTEL_SERVICE_NAME",
    "observability-demo",
)
SERVICE_VERSION = os.getenv(
    "SERVICE_VERSION",
    "development",
)
DEPLOYMENT_ENVIRONMENT = os.getenv(
    "DEPLOYMENT_ENVIRONMENT",
    "development",
)

logger = configure_logging()
tracer = trace.get_tracer(__name__)

REQUESTS = Counter(
    "observability_demo_http_requests_total",
    "Total HTTP requests handled by the demonstration service.",
    [
        "method",
        "route",
        "status_code",
    ],
)

REQUEST_DURATION = Histogram(
    "observability_demo_http_request_duration_seconds",
    "HTTP request duration in seconds.",
    [
        "method",
        "route",
    ],
    buckets=(
        0.005,
        0.01,
        0.025,
        0.05,
        0.1,
        0.25,
        0.5,
        1.0,
        2.5,
        5.0,
    ),
)

WORK_ITEMS = Counter(
    "observability_demo_work_items_total",
    "Number of simulated work items completed.",
    ["result"],
)

app = FastAPI(
    title="Enterprise Observability Demo",
    description=(
        "A purpose-built service demonstrating metrics, logs, "
        "traces and telemetry correlation."
    ),
    version=SERVICE_VERSION,
    docs_url="/docs",
    redoc_url=None,
)

app.mount(
    "/metrics",
    make_asgi_app(),
)


@app.middleware("http")
async def observe_request(
    request: Request,
    call_next: Callable[[Request], Awaitable[Response]],
) -> Response:
    """Record RED metrics and structured request logs."""

    started = time.perf_counter()
    status_code = 500
    response: Response | None = None

    try:
        response = await call_next(request)
        status_code = response.status_code
        return response
    except Exception:
        logger.exception(
            "Unhandled request failure",
            extra={
                "event": "http_request_failed",
                "fields": {
                    "http_method": request.method,
                    "http_path": request.url.path,
                    "http_status_code": status_code,
                },
            },
        )
        raise
    finally:
        duration = time.perf_counter() - started
        route = request.scope.get("route")
        route_path = getattr(
            route,
            "path",
            request.url.path,
        )

        REQUESTS.labels(
            method=request.method,
            route=route_path,
            status_code=str(status_code),
        ).inc()

        REQUEST_DURATION.labels(
            method=request.method,
            route=route_path,
        ).observe(duration)

        logger.info(
            "HTTP request completed",
            extra={
                "event": "http_request_completed",
                "fields": {
                    "http_method": request.method,
                    "http_route": route_path,
                    "http_path": request.url.path,
                    "http_status_code": status_code,
                    "duration_seconds": round(duration, 6),
                },
            },
        )


@app.get("/")
async def root() -> dict[str, str]:
    """Return service identity and deployment metadata."""

    return {
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "environment": DEPLOYMENT_ENVIRONMENT,
        "status": "ok",
    }


@app.get("/healthz")
async def health() -> dict[str, str]:
    """Kubernetes liveness endpoint."""

    return {
        "status": "healthy",
    }


@app.get("/readyz")
async def readiness() -> dict[str, str]:
    """Kubernetes readiness endpoint."""

    return {
        "status": "ready",
    }


@app.get("/work")
async def work() -> dict[str, Any]:
    """Perform deterministic simulated work with a custom child span."""

    with tracer.start_as_current_span(
        "process_work_item",
    ) as span:
        span.set_attribute(
            "work.type",
            "simulated",
        )
        span.set_attribute(
            "work.result",
            "success",
        )

        await asyncio.sleep(0.05)
        WORK_ITEMS.labels(result="success").inc()

        logger.info(
            "Simulated work item completed",
            extra={
                "event": "work_item_completed",
                "fields": {
                    "work_type": "simulated",
                    "work_result": "success",
                },
            },
        )

    return {
        "result": "success",
        "duration_seconds": 0.05,
    }


@app.get("/slow")
async def slow(
    delay: float = Query(
        default=0.5,
        ge=0.0,
        le=5.0,
    ),
) -> dict[str, Any]:
    """Introduce controlled latency for SLI and trace testing."""

    with tracer.start_as_current_span(
        "controlled_latency",
    ) as span:
        span.set_attribute(
            "delay.seconds",
            delay,
        )

        await asyncio.sleep(delay)

        logger.warning(
            "Controlled latency request completed",
            extra={
                "event": "controlled_latency_completed",
                "fields": {
                    "delay_seconds": delay,
                },
            },
        )

    return {
        "result": "success",
        "delay_seconds": delay,
    }


@app.get("/error")
async def controlled_error() -> None:
    """Generate a controlled HTTP 500 response."""

    current_span = trace.get_current_span()
    current_span.set_attribute(
        "error.type",
        "controlled_demo_error",
    )
    current_span.set_status(
        trace.Status(
            trace.StatusCode.ERROR,
            "Controlled demonstration error",
        ),
    )

    WORK_ITEMS.labels(result="error").inc()

    logger.error(
        "Controlled demonstration error generated",
        extra={
            "event": "controlled_error",
            "fields": {
                "error_type": "controlled_demo_error",
                "http_status_code": 500,
            },
        },
    )

    raise HTTPException(
        status_code=500,
        detail="Controlled demonstration error",
    )


configure_tracing(app)
