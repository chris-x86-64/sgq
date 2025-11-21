# sgq

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Python 3.11](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/downloads/)

Query AWS VPC security groups like SQL.

## Building

```shell
docker build \
    -t chrisx86/sgq \
    .
```

## Prerequisites

* Configure your AWS credentials on your host using awscli
    ```
    aws configure
    ```
* You can also use AWS SSO login

* All VPCs you wish to examine must have the `Name` tags.

* (Recommended) You have Docker or an alternative like Podman ready.

* (Alternative) You can execute `uv run sgq.py` without Docker as long as you have:
    * Python 3.11 along with the following packages:
        * [uv](https://github.com/astral-sh/uv) as package/project manager, which will manage installing:
            * [boto3](https://github.com/boto/boto3)
            * [ec2-security-groups-dumper](https://github.com/percolate/ec2-security-groups-dumper)
    * [q](https://github.com/harelba/q)

## Usage

### Download security group lists

```shell
docker run \
    --rm \
    -v $HOME/.aws:/sgq/.aws:Z,ro \
    -v $(pwd)/csvs:/sgq/csvs:Z \
    -e AWS_PROFILE=default
    chrisx86/sgq \
    refresh
```

Change `AWS_PROFILE` if you use alternative profiles or SSO login.

### Query downloaded security groups

```shell
docker run \
    --rm \
    -v $(pwd)/csvs:/var/lib/sgq:Z \
    chrisx86/sgq \
    query 'SELECT * FROM $vpc_name WHERE rules_grants_cidr_ip = "203.0.113.0/24"'
```

## External dependencies

* This project depends on [ec2-security-groups-dumper](https://github.com/percolate/ec2-security-groups-dumper) and [q](https://github.com/harelba/q).
