from unittest import TestCase
from unittest.mock import Mock

from boto3.resources.base import ServiceResource
from botocore.client import BaseClient

from shared_qkon.qkon_aws import AwsClientProvider, CommonConfiguration, LambdaConsts, parse_arn


class AwsTest(TestCase):
    @staticmethod
    def test_parse_arn() -> None:
        arn: dict = parse_arn("arn:aws:sqs:eu-central-1:139620956858:DS-integration.fifo")
        assert arn["resource"] == "DS-integration.fifo"

    @staticmethod
    def test_params() -> None:
        assert LambdaConsts.get_path_param(dict(), "x") is None
        assert LambdaConsts.get_header_param(dict(), "x") is None
        assert LambdaConsts.get_query_param(dict(), "x") is None

        assert LambdaConsts.get_path_param({LambdaConsts.PATH_PARAMETERS: dict()}, "x") is None
        assert LambdaConsts.get_query_param({LambdaConsts.QUERY_PARAMETERS: dict()}, "x") is None
        assert LambdaConsts.get_header_param({LambdaConsts.HEADERS: dict()}, "x") is None

        assert LambdaConsts.get_path_param({LambdaConsts.PATH_PARAMETERS: {"x": "y"}}, "x") == "y"
        assert LambdaConsts.get_query_param({LambdaConsts.QUERY_PARAMETERS: {"x": "y"}}, "x") == "y"
        assert LambdaConsts.get_header_param({LambdaConsts.HEADERS: {"x": "y"}}, "x") == "y"

    @staticmethod
    def test_no_mock() -> None:
        AwsClientProvider().reset()
        assert isinstance(AwsClientProvider().lambda_client(), BaseClient)
        assert isinstance(AwsClientProvider().sns_client(), BaseClient)
        assert isinstance(AwsClientProvider().sqs_client(), BaseClient)
        assert isinstance(AwsClientProvider().s3_resource_create(vpc_endpoint_url="https://X"), ServiceResource)

    @staticmethod
    def test_config() -> None:
        AwsClientProvider().reset()
        mocked_configuration: CommonConfiguration = CommonConfiguration(aws_disabled=True)
        assert isinstance(mocked_configuration.lambda_client(), Mock)
        assert isinstance(mocked_configuration.sns_client(), Mock)

    @staticmethod
    def test_utils() -> None:
        assert not LambdaConsts.is_sqs_event(dict())
        assert LambdaConsts.is_sqs_event({"Records": None})

        assert not LambdaConsts.is_api_event(dict())
        assert LambdaConsts.is_api_event({"routeKey": None})

        assert not LambdaConsts.is_deployment(dict())
        assert LambdaConsts.is_deployment({"deploy": None})

        assert not LambdaConsts.is_scheduled_event(dict())
        assert LambdaConsts.is_scheduled_event({"source": "aws.events"})
