FROM python:3.13-slim-bookworm@sha256:a1165e272e578941b84abc79e4ab38a0305cd12803a5c4247979ac7655f4d641 AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/python -m pip install \
        --no-cache-dir \
        --requirement requirements.txt \
    && /opt/venv/bin/python -m pip uninstall \
        --yes \
        pip \
        setuptools \
        wheel

FROM python:3.13-slim-bookworm@sha256:a1165e272e578941b84abc79e4ab38a0305cd12803a5c4247979ac7655f4d641 AS runtime

ARG SERVICE_VERSION=development

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    OTEL_SERVICE_NAME=observability-demo \
    SERVICE_VERSION="${SERVICE_VERSION}" \
    DEPLOYMENT_ENVIRONMENT=development \
    LOG_LEVEL=INFO

RUN groupadd \
        --gid 10001 \
        observability \
    && useradd \
        --uid 10001 \
        --gid 10001 \
        --no-create-home \
        --home-dir /nonexistent \
        --shell /usr/sbin/nologin \
        observability \
    && python -m pip uninstall \
        --yes \
        pip \
        setuptools \
        wheel \
    && rm -rf \
        /root/.cache \
        /usr/local/bin/pip \
        /usr/local/bin/pip3 \
        /usr/local/bin/pip3.13 \
        /usr/local/lib/python3.13/site-packages/pip \
        /usr/local/lib/python3.13/site-packages/pip-*.dist-info \
        /usr/local/lib/python3.13/site-packages/setuptools \
        /usr/local/lib/python3.13/site-packages/setuptools-*.dist-info

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app

COPY --chown=10001:10001 app ./app

USER 10001:10001

EXPOSE 8080

CMD [  "uvicorn",  "app.main:app",  "--host",  "0.0.0.0",  "--port",  "8080",  "--no-access-log"]
