FROM python:3.11-slim
USER root
RUN pip install poetry
RUN apt-get update
RUN apt-get install gcc -y
RUN apt-get install libpq-dev -y
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache
WORKDIR /app
COPY pyproject.toml poetry.lock ./
COPY api ./api
RUN poetry install
ENTRYPOINT ["poetry", "run", "python", "-m", "api.main"]