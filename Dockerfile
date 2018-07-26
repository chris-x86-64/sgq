FROM python:2.7.15-stretch
MAINTAINER Christopher Smith <chris-x86-64@users.noreply.github.com>

RUN curl -LO https://github.com/harelba/q/releases/download/1.7.1/q-text-as-data_1.7.1-2_all.deb && \
    dpkg -i q-text-as-data_1.7.1-2_all.deb && \
    rm q-text-as-data_1.7.1-2_all.deb
RUN apt-get update && \
    apt-get install -y jq && \
    rm -rf /var/cache/apt/lists/*

COPY requirements.txt constraints.txt /sgq/
RUN pip install -r /sgq/requirements.txt -c /sgq/constraints.txt && \
    rm /sgq/requirements.txt /sgq/constraints.txt
COPY sgq.py /sgq/bin/sgq.py

VOLUME ["/var/lib/sgq"]
WORKDIR /var/lib/sgq

ENTRYPOINT ["python2", "/sgq/bin/sgq.py"]
