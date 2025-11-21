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

### Download Security Group Lists

```shell
docker run \
    --rm \
    -v $HOME/.aws:/sgq/.aws:Z,ro \
    -v $(pwd)/csvs:/sgq/csvs:Z \
    -e AWS_PROFILE=default \
    chrisx86/sgq \
    refresh
```

**Options:**
- `-e AWS_PROFILE=<profile>`: Specify AWS profile (default or SSO profile name)
    - You may also specify desired regions in your AWS profile.

This creates CSV files in `./csvs/` named after your VPC Name tags (e.g., `production`, `staging`, `development`).

### Query Downloaded Security Groups

```shell
docker run \
    --rm \
    -v $(pwd)/csvs:/sgq/csvs:Z \
    chrisx86/sgq \
    query 'SELECT * FROM production WHERE rules_grants_cidr_ip = "203.0.113.0/24"'
```

The table name in your SQL query corresponds to the VPC's `Name` tag. Each CSV file becomes a queryable table.

## Examples

### Find all security groups allowing traffic from a specific IP
```shell
docker run --rm -v $(pwd)/csvs:/sgq/csvs:Z chrisx86/sgq \
    query 'SELECT * FROM production WHERE rules_grants_cidr_ip = "203.0.113.0/24"'
```

### Find security groups allowing SSH from anywhere
```shell
docker run --rm -v $(pwd)/csvs:/sgq/csvs:Z chrisx86/sgq \
    query 'SELECT * FROM production WHERE rules_to_port = "22" AND rules_grants_cidr_ip = "0.0.0.0/0"'
```

### List all security groups in a VPC
```shell
docker run --rm -v $(pwd)/csvs:/sgq/csvs:Z chrisx86/sgq \
    query 'SELECT security_group_id, security_group_name FROM production'
```

### Find security groups by name pattern
```shell
docker run --rm -v $(pwd)/csvs:/sgq/csvs:Z chrisx86/sgq \
    query 'SELECT * FROM staging WHERE security_group_name LIKE "%web%"'
```

### Query across multiple VPCs
```shell
docker run --rm -v $(pwd)/csvs:/sgq/csvs:Z chrisx86/sgq \
    query 'SELECT * FROM production UNION SELECT * FROM staging'
```

## CSV Schema

The security group CSV files contain the following columns (from [ec2-security-groups-dumper](https://github.com/percolate/ec2-security-groups-dumper)):
- `security_group_id`
- `security_group_name`
- `security_group_description`
- `vpc_id`
- `rules_direction` (ingress/egress)
- `rules_ip_protocol`
- `rules_from_port`
- `rules_to_port`
- `rules_grants_cidr_ip`
- `rules_grants_security_group_id`
- And more...

## Dependencies

This project uses:
* [boto3](https://github.com/boto/boto3) - AWS SDK for Python
* [ec2-security-groups-dumper](https://github.com/percolate/ec2-security-groups-dumper) - Exports security groups to CSV
* [q](https://github.com/harelba/q) - SQL engine for CSV files
* [uv](https://github.com/astral-sh/uv) - Fast Python package manager

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
