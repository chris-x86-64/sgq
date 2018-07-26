# sgq
Query AWS VPC security groups like SQL.

## Usage

### Build

```shell
docker build \
    -t chrisx86/sgq \
    .
```

Sorry, it's not ready on docker.io (yet).

### Prerequisite(s)

* Configure your AWS credentials on your host using awscli
    ```
    aws configure
    ```

* All VPCs you wish to examine must have the `Name` tags.

* You have access to Docker.
    * You can still execute `python2 sgq.py` directly as long as you have:
        * Python 2.7.15
        * boto3
        * ec2-security-groups-dumper
        * q-text-as-data

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
    -v $HOME/.aws:/root/.aws:Z,ro \
    -v $(pwd)/csvs:/var/lib/sgq:Z \
    chrisx86/sgq \
    query 'SELECT * FROM $vpc_name WHERE rules_grants_cidr_ip = "203.0.113.0/24"'
```


### How this works

* Uses [ec2-security-groups-dumper](https://github.com/percolate/ec2-security-groups-dumper) and [q](https://github.com/harelba/q) under the hood.
