from ec2_security_groups_dumper.main import Firewall as Fw
import argparse
import boto3
import logging
import sys
import subprocess


logging.basicConfig(stream=sys.stderr, level=logging.INFO)


class SecurityGroupQuery():
    def __init__(self):
        self.args = self.parse_options()
        self.action = self.args.action_name

    def parse_options(self):
        parser = argparse.ArgumentParser()
        subparsers = parser.add_subparsers(dest="action_name", help="subcommands")

        parser_refresh = subparsers.add_parser('refresh', help="Refreshes CSV")
        parser_refresh.add_argument(
                '-r',
                '--region',
                metavar="AWS_REGION",
                type=str,
                help="AWS Region",
                default='')

        parser_query = subparsers.add_parser('query', help="Queries CSV")
        parser_query.add_argument(
                'query',
                metavar="SQL_QUERY",
                type=str,
                help="SQL-style query (ex. SELECT * FROM production)",
                nargs='+')

        args = parser.parse_args()
        return args

    def _init_ec2_client(self):
        try:
            if self.args.region:
                region = self.args.region
            else:
                region = None
            session = boto3.session.Session(region_name=region)
            self.region_name = session.region_name
            logging.info("Selected region: {}".format(self.region_name))
            self.ec2 = session.client('ec2')
            return True
        except:
            logging.exception("""
                SGQ was not able to use a valid AWS credential.
                Please mount your .aws directory to /root/.aws, set environment variables, etc.
                """)
            sys.exit(1)

    def _get_vpcs(self):
        self._init_ec2_client()
        vpcs = {}
        for vpc in self.ec2.describe_vpcs()['Vpcs']:
            for tag in vpc['Tags']:
                if 'Name' in tag['Key']:
                    logging.info("Found VPC: {} (Name: {})".format(vpc['VpcId'], tag['Value']))
                    vpcs[tag['Value']] = vpc['VpcId']
        return vpcs

    def dump_secgroup_csvs(self):
        vpcs = self._get_vpcs()
        for vname, vid in vpcs.items():
            firewall = Fw(region=self.region_name, profile=None, vpc=vid)
            with open(vname, 'w') as f:
                f.write(firewall.csv)
            logging.info("CSV dump completed: {}".format(vname))


def query(query_string):
    subprocess.call(["/usr/bin/q", "-H", "-d,", "-O", query_string], stdout=sys.stdout)


if __name__ == "__main__":
    sgq = SecurityGroupQuery()

    if sgq.action == 'refresh':
        sgq.dump_secgroup_csvs()

    elif sgq.action == 'query':
        query_string = ' '.join(sgq.args.query)
        query(query_string)
