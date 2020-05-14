# sgq
Query AWS VPC security groups like SQL.

## Building

```shell
docker build \
    -t chrisx86/sgq \
    .
```

Sorry, it's not ready on docker.io (yet).

## Prerequisites

* Configure your AWS credentials on your host using awscli
    ```
    aws configure
    ```

* All VPCs you wish to examine must have the `Name` tags.

* (Recommended) You have Docker or an alternative like Podman ready.

* (Alternative) You can execute `python3 sgq.py` without Docker as long as you have:
    * Python 3.7 or later along with the following packages:
        * [boto3](https://github.com/boto/boto3)
        * [ec2-security-groups-dumper](https://github.com/percolate/ec2-security-groups-dumper)
    * [q](https://github.com/harelba/q)

## Usage

### Download security group lists

```shell
docker run \
    --rm \
    -v $HOME/.aws:/root/.aws:Z,ro \
    -v $(pwd)/csvs:/var/lib/sgq:Z \
    chrisx86/sgq \
    refresh
```

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
