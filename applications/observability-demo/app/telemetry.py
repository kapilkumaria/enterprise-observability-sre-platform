"""OpenTelemetry tracing configuration."""

from __future__ import annotations

import os

from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.instrumentation.fastapi import (
    FastAPIInstrumentor,
)
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


def _is_true(value: str | None) -> bool:
    return (value or "").strip().lower() in {
        "1",
        "true",
        "yes",
        "on",
    }


def configure_tracing(app: FastAPI) -> None:
    """Configure OTLP/HTTP trace export and FastAPI instrumentation."""

    if _is_true(os.getenv("OTEL_SDK_DISABLED")):
        return

    resource = Resource.create(
        {
            "service.name": os.getenv(
                "OTEL_SERVICE_NAME",
                "observability-demo",
            ),
            "service.version": os.getenv(
                "SERVICE_VERSION",
                "development",
            ),
            "deployment.environment.name": os.getenv(
                "DEPLOYMENT_ENVIRONMENT",
                "development",
            ),
            "service.namespace": "enterprise-observability",
        },
    )

    provider = TracerProvider(resource=resource)

    exporter = OTLPSpanExporter(
        endpoint=os.getenv(
            "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT",
            (
                "http://alloy-collector.opentelemetry."
                "svc.cluster.local:4318/v1/traces"
            ),
        ),
        timeout=5,
    )

    provider.add_span_processor(
        BatchSpanProcessor(exporter),
    )

    trace.set_tracer_provider(provider)

    FastAPIInstrumentor.instrument_app(
        app,
        tracer_provider=provider,
        excluded_urls="healthz,readyz,metrics",
    )
