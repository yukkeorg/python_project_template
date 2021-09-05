FROM python:3.9-slim as python-base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_CREATE=false \
    PYSETUP_PATH=/opt/pysetup
ENV PATH="$POETRY_HOME/bin:$PATH"


FROM python-base as initial
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl build-essential git && \
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python


FROM initial as development-base
ENV POETRY_NO_INTERACTION=1
WORKDIR $PYSETUP_PATH
COPY pyproject.toml poetry.lock ./


FROM development-base as development
RUN poetry install
ENV PYTHONPATH=/app
WORKDIR /app
ENTRYPOINT ["python"]
CMD []


FROM development-base as builder
RUN poetry install --no-dev


FROM python-base as production
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
WORKDIR /app
COPY ./src ./
ENTRYPOINT ["python"]
CMD []
