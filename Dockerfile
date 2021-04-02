FROM python:3.7
MAINTAINER Christopher Smith <chris-x86-64@users.noreply.github.com>

RUN curl -LO https://github.com/harelba/q/releases/download/2.0.19/q-text-as-data_2.0.19-2_amd64.deb && \
    dpkg -i q-text-as-data_2.0.19-2_amd64.deb && \
    rm q-text-as-data_2.0.19-2_amd64.deb
RUN apt-get update && \
    apt-get install -y jq pipenv && \
    rm -rf /var/cache/apt/lists/*

COPY Pipfile Pipfile.lock /sgq/
RUN cd /sgq && pipenv install --system --ignore-pipfile --deploy
COPY sgq.py /sgq/bin/sgq.py

VOLUME ["/var/lib/sgq"]
WORKDIR /var/lib/sgq

ENTRYPOINT ["python3", "/sgq/bin/sgq.py"]
