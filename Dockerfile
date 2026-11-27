FROM python:3.13-slim-trixie
LABEL maintainer="Christopher Smith <chris-x86-64@users.noreply.github.com>"

RUN apt-get update && \
    apt-get install --no-install-recommends -y jq wget && \
    rm -rf /var/cache/apt/lists/*

RUN wget https://github.com/harelba/q/releases/download/v3.1.6/q-text-as-data-3.1.6-1.x86_64.deb && \
    dpkg -i q-text-as-data-3.1.6-1.x86_64.deb && \
    rm q-text-as-data-3.1.6-1.x86_64.deb

RUN useradd -m -d /sgq sgq
USER sgq
WORKDIR /sgq

COPY --from=ghcr.io/astral-sh/uv:0.13.10 --chown=sgq:sgq /uv /uvx /sgq/.local/bin/
ENV UV_PROJECT_ENVIRONMENT=/sgq/.venv \
    PATH="/sgq/.local/bin:${PATH}"

COPY pyproject.toml uv.lock /sgq/
RUN uv sync
COPY sgq.py /sgq/bin/sgq.py

VOLUME ["/sgq/csvs"]
WORKDIR /sgq/csvs

ENTRYPOINT ["uv", "run", "/sgq/bin/sgq.py"]
