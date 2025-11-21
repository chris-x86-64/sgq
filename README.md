# sgq

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Python 3.11](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/downloads/)

Query AWS VPC security groups like SQL.

## How It Works

`sgq` is a two-step workflow tool for analyzing AWS VPC security groups:

1. **Refresh**: Downloads all security groups from your AWS VPCs and saves them as CSV files (one per VPC)
2. **Query**: Use SQL syntax to search across the downloaded security group data

This approach allows you to run complex queries against your security groups without repeatedly hitting AWS APIs.
It also provides a consistent inventory of your security groups for easy comparison over time.

## Installation

### Using Docker (Recommended)

Build the Docker image:
```shell
docker build -t chrisx86/sgq .
```

### Using Python and uv

If you prefer to run without Docker:

```shell
# Install uv if you don't have it
pipx install uv

# Install dependencies
uv sync

# Run sgq
uv run sgq.py <command>
```

## Prerequisites

* **AWS Credentials**: Configure AWS credentials on your host using awscli:
    ```
    aws configure
    ```
    You can also use AWS SSO login.

* **VPC Name Tags**: All VPCs you wish to examine must have `Name` tags set. The VPC name becomes the table name in SQL queries.

* **Docker or Podman**: Recommended for the easiest setup.

* **For non-Docker usage**:
    * Python 3.11 (specifically >=3.11, <3.12)
    * [uv](https://github.com/astral-sh/uv) as package/project manager
    * [q](https://github.com/harelba/q) command-line tool for SQL queries on CSV files

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
