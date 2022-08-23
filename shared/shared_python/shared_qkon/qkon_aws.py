"""Methods and statics to standardize AWS access approach"""
import json
import os
from typing import Optional, Union, Tuple
from unittest.mock import Mock

import boto3
from botocore.client import BaseClient
from botocore.config import Config

from shared_qkon.qkon_log import Log

CACHE_CONFIG_VALIDITY_IN_SECONDS = 15

_AWS_REGION_NAME = "eu-central-1"
_ENVIRONMENT_NAME = "ENVIRONMENT_NAME"
_boto_config = Config(
    connect_timeout=5,
    read_timeout=5,
    retries={"total_max_attempts": 3, "max_attempts": 3},
    region_name=_AWS_REGION_NAME,
)
CONFIG_CACHE_FILE = "/vizyah-config.json"
_VPC_S3_ENDPOINT = "S3_VPC_ENDPOINT"

# Time to live for TEST records in seconds
TTL_TEST: int = 3600 * 24 * 7


class AwsClientProvider:
    __sns_client = None
    __lambda_client = None
    __sqs_client = None

    @classmethod
    def reset(cls):
        cls.__sqs_client = None
        cls.__lambda_client = None
        cls.__sns_client = None

    @classmethod
    def sns_client(cls, mocked: bool = False) -> BaseClient:
        if not cls.__sns_client:
            cls.__sns_client = (
                boto3.client("sns", region_name=_AWS_REGION_NAME, config=_boto_config) if not mocked else Mock()
            )
        return cls.__sns_client

    @classmethod
    def sqs_client(cls, mocked: bool = False) -> BaseClient:
        if not cls.__sqs_client:
            cls.__sqs_client = (
                boto3.client("sqs", region_name=_AWS_REGION_NAME, config=_boto_config) if not mocked else Mock()
            )
        return cls.__sqs_client

    @classmethod
    def lambda_client(cls, mocked: bool = False) -> BaseClient:
        if not cls.__lambda_client:
            cls.__lambda_client = (
                boto3.client("lambda", region_name=_AWS_REGION_NAME, config=_boto_config) if not mocked else Mock()
            )
        return cls.__lambda_client

    @classmethod
    def s3_client_create_with_vpc(cls):
        vpc_endpoint_url = os.getenv(_VPC_S3_ENDPOINT, None)
        if vpc_endpoint_url:
            return boto3.client("s3", config=_boto_config, endpoint_url=vpc_endpoint_url)
        return boto3.client("s3", config=_boto_config)

    @classmethod
    def s3_resource_create_with_vpc(cls):
        vpc_endpoint_url = os.getenv(_VPC_S3_ENDPOINT, None)
        return AwsClientProvider.s3_resource_create(vpc_endpoint_url=vpc_endpoint_url)

    @classmethod
    def s3_resource_create(cls, vpc_endpoint_url: Optional[str] = None):
        if vpc_endpoint_url:
            return boto3.resource("s3", config=_boto_config, endpoint_url=vpc_endpoint_url)
        return boto3.resource("s3", config=_boto_config)


class LambdaConsts:
    ATTRIBUTES = "messageAttributes"
    BODY = "body"
    STATUS_CODE = "statusCode"
    EVENT_SOURCE_ARN = "eventSourceARN"
    RECORDS_SQS_LAMBDA: str = "Records"
    ROUTE_KEY: str = "routeKey"
    HEADERS = "headers"
    HOST = "host"
    PATH_PARAMETERS = "pathParameters"
    AUTHORIZATION = "authorization"
    AUTHORIZATION_2 = "Authorization"
    MESSAGE_TYPE_HEADER = "messageType"
    STRING_VALUE = "stringValue"
    MESSAGE_GROUP_ID: str = "aleet"
    SOURCE = "source"
    SOURCE_SCHEDULER = "aws.events"
    SQS_MESSAGE_ID = "messageId"
    _SOURCE_S3 = "aws:s3"
    _S3_CREATED = "ObjectCreated:Put"
    AWS_ATTRIBUTES = "attributes"
    QUERY_PARAMETERS = "queryStringParameters"
    FLEET_FOR_SNAPSHOT = "fleetForSnapshot"

    @staticmethod
    def get_query_param(event: dict, param_name: str) -> Optional[str]:
        params: dict = event.get(LambdaConsts.QUERY_PARAMETERS)
        if params:
            return params.get(param_name)
        return None

    @staticmethod
    def get_path_param(event: dict, param_name: str) -> Optional[str]:
        params: dict = event.get(LambdaConsts.PATH_PARAMETERS)
        if params:
            return params.get(param_name)
        return None

    @staticmethod
    def get_header_param(event: dict, param_name: str) -> Optional[str]:
        params: dict = event.get(LambdaConsts.HEADERS)
        if params:
            return params.get(param_name)
        return None

    @staticmethod
    def is_sqs_event(event: dict) -> bool:
        return LambdaConsts.RECORDS_SQS_LAMBDA in event.keys()

    @staticmethod
    def is_deployment(event: dict) -> bool:
        return "deploy" in event.keys()

    @staticmethod
    def is_api_event(event: dict) -> bool:
        return LambdaConsts.ROUTE_KEY in event.keys()

    @staticmethod
    def is_message_of_type(message: dict, expected_type: str) -> bool:
        try:
            return (
                message[LambdaConsts.ATTRIBUTES][LambdaConsts.MESSAGE_TYPE_HEADER][LambdaConsts.STRING_VALUE]
                == expected_type
            )
        except ValueError:
            return False

    @staticmethod
    def is_scheduled_event(event: dict):
        return LambdaConsts.SOURCE in event.keys() and event.get(LambdaConsts.SOURCE) == LambdaConsts.SOURCE_SCHEDULER

    @staticmethod
    def is_s3_created_event(event: dict) -> Optional[Tuple[str, str]]:
        try:
            return event["Records"][0]["s3"]["bucket"]["name"], event["Records"][0]["s3"]["object"]["key"]
        except KeyError:
            return None


def env_name() -> str:
    value = os.getenv(_ENVIRONMENT_NAME, "test")
    return value


_SIMPLE_SECURITY_ENABLED = "SIMPLE_SECURITY_ENABLED"


def build_message_group_id(fleet: str, vehicle_token: Optional[str] = None) -> str:
    return f"{fleet}-{vehicle_token if vehicle_token else 'NA'}"


def simple_security_enabled_from_os() -> bool:
    value = os.getenv(_SIMPLE_SECURITY_ENABLED, "False")
    return value and value.lower() == "true"


def enable_simple_security() -> None:
    os.environ[_SIMPLE_SECURITY_ENABLED] = str(True)


_current_config: Optional[str] = None
_current_config_time: int = 0

_DEFAULT_SNAPSHOT_INTERVAL = 1


def get_config_bucket() -> str:
    return os.getenv("CONFIG_S3", f"vizyah-{env_name()}-config")


class CommonConfiguration:
    __fleet_configs: dict[str, str] = dict()
    _aws_disabled: bool = False
    _env_name: str = env_name()
    _s3_client: boto3.client = None
    aws_region_name: str = os.getenv("AWS_REGION_NAME", _AWS_REGION_NAME)
    simple_security_enabled: bool = simple_security_enabled_from_os()

    def __init__(
        self, aws_disabled: bool = False, simple_security_enabled: bool = False, fetch_fleet_config: bool = True
    ) -> None:
        super().__init__()
        self._aws_disabled = aws_disabled
        if simple_security_enabled:
            self.simple_security_enabled = simple_security_enabled
        self.tfout = None

    def add_test_fleet(self, fleet_config: str):
        self.add_test_fleet_v2(fleet_config=fleet_config)

    def add_test_fleet_v2(self, fleet_config: str):
        if self.is_aws_enabled():
            raise ValueError("Method to use only in tests with mocked AWS")
        config_as_dict: dict = json.loads(fleet_config)
        self.__fleet_configs[config_as_dict["token"]] = fleet_config

    def _get_config_file(self, fleet_config_key: str) -> Optional[str]:
        try:
            response = self.s3_client().get_object(Bucket=get_config_bucket(), Key=fleet_config_key)
            return response["Body"].read().decode("utf-8")
        except Exception as e:
            Log.error(f"Cannot fetch config for fleet {fleet_config_key} in bucket {get_config_bucket()} - {e}")
            return None

    def _list_fleets(self) -> dict[str, str]:
        bucket_data = self.s3_client().list_objects_v2(Bucket=get_config_bucket())
        if bucket_data.get("Contents"):
            return {entry["Key"].replace(".json", ""): entry["Key"] for entry in bucket_data["Contents"]}
        return {}

    def get_fleet_config(self, fleet_token: str) -> Optional[str]:
        return self.get_fleet_config_v2(fleet_token=fleet_token)

    def get_fleet_config_v2(self, fleet_token: str) -> Optional[str]:
        if self.__fleet_configs.get(fleet_token):
            return self.__fleet_configs.get(fleet_token)
        if self.is_aws_enabled():
            fleet_config = self._get_config_file(f"{fleet_token}.json")
            if fleet_config:
                self.__fleet_configs[fleet_token] = fleet_config
                return fleet_config
        return None

    def sns_client(self):
        return AwsClientProvider.sns_client(mocked=self._aws_disabled)

    def s3_client(self):
        if not self._s3_client:
            self._s3_client = AwsClientProvider.s3_client_create_with_vpc()
        return self._s3_client

    def sqs_client(self):
        return AwsClientProvider.sqs_client(mocked=self._aws_disabled)

    def lambda_client(self):
        return AwsClientProvider.lambda_client(mocked=self._aws_disabled)

    def get_fleets(self) -> list[str]:
        cached_fleets: list[str] = list(self.__fleet_configs.keys())
        if self._aws_disabled:
            return cached_fleets
        active_fleets: list[str] = list(self._list_fleets().keys())
        return active_fleets

    def is_aws_enabled(self) -> bool:
        return not self._aws_disabled

    def get_tf_output(self, key: str) -> Union[str, dict]:
        """Returns values from terraform output.

        Args:
            key: The name of the output, may contain dots if the output is an object

        Examples:
            config.get_tf_output("ss_daily_report.bucket.name")

        Returns:
            The value of the terraform output.
            Object values in terraform will be mapped into dictionaries in python.
        """
        if self.tfout is None:
            env = env_name()
            obj = self.s3_client().get_object(Bucket="vizyah-artifacts", Key=f"devops/{env}/tfout.json")
            self.tfout = json.load(obj["Body"])
        result = self.tfout
        first_part = True
        for key_part in key.split("."):
            result = result[key_part]
            if first_part and "value" in result:
                result = result["value"]
            first_part = False
        return result


def parse_arn(arn: str) -> dict:
    # http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
    elements = arn.split(":")
    result = {
        "arn": elements[0],
        "partition": elements[1],
        "service": elements[2],
        "region": elements[3],
        "account": elements[4],
    }
    if len(elements) == 7:
        result["resourcetype"], result["resource"] = elements[5:]
    elif "/" not in elements[5]:
        result["resource"] = elements[5]
        result["resourcetype"] = None
    else:
        result["resourcetype"], result["resource"] = elements[5].split("/")
    return result
