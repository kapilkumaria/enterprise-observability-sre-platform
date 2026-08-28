"""Structured JSON logging with OpenTelemetry trace correlation."""

from __future__ import annotations

import json
import logging
import os
import sys
from datetime import UTC, datetime
from typing import Any

from opentelemetry import trace


class JsonFormatter(logging.Formatter):
    """Render application logs as single-line JSON records."""

    def format(self, record: logging.LogRecord) -> str:
        span = trace.get_current_span()
        span_context = span.get_span_context()

        payload: dict[str, Any] = {
            "timestamp": datetime.now(UTC).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "service": os.getenv(
                "OTEL_SERVICE_NAME",
                "observability-demo",
            ),
            "environment": os.getenv(
                "DEPLOYMENT_ENVIRONMENT",
                "development",
            ),
            "event": getattr(record, "event", "application_log"),
            "message": record.getMessage(),
        }

        if span_context.is_valid:
            payload["trace_id"] = format(
                span_context.trace_id,
                "032x",
            )
            payload["span_id"] = format(
                span_context.span_id,
                "016x",
            )

        fields = getattr(record, "fields", None)

        if isinstance(fields, dict):
            payload.update(fields)

        if record.exc_info:
            payload["exception"] = self.formatException(
                record.exc_info,
            )

        return json.dumps(
            payload,
            separators=(",", ":"),
            default=str,
        )


def configure_logging() -> logging.Logger:
    """Configure the application logger without changing root handlers."""

    logger = logging.getLogger("observability_demo")
    logger.setLevel(
        os.getenv(
            "LOG_LEVEL",
            "INFO",
        ).upper(),
    )
    logger.propagate = False

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(JsonFormatter())
        logger.addHandler(handler)

    return logger
