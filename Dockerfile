FROM python:3.11
LABEL maintainer="Christopher Smith <chris-x86-64@users.noreply.github.com>"

RUN curl -LO https://github.com/harelba/q/releases/download/v3.1.6/q-text-as-data-3.1.6-1.x86_64.deb && \
    dpkg -i q-text-as-data_3.1.6-1_amd64.deb && \
    rm q-text-as-data_3.1.6-1_amd64.deb
RUN apt-get update && \
    apt-get install --no-install-recommends -y jq pipenv && \
    rm -rf /var/cache/apt/lists/*

RUN useradd -m -d /sgq sgq
USER sgq
WORKDIR /sgq

COPY Pipfile Pipfile.lock /sgq/
RUN cd /sgq && pipenv install --system --ignore-pipfile --deploy
COPY sgq.py /sgq/bin/sgq.py

VOLUME ["/var/lib/sgq"]
WORKDIR /var/lib/sgq

ENTRYPOINT ["python3", "/sgq/bin/sgq.py"]
