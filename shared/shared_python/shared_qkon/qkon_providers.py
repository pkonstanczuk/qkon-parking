from typing import Callable

import boto3

from contract.models import VehicleStatusExternalMessage, DriverExternalMessageType
from shared_qkon.qkon_aws import AwsClientProvider
from shared_qkon.qkon_dates import VTime
from shared_qkon.qkon_log import Log
from shared_qkon.qkon_utils import VUtil


class SqsProviderSender:
    """
    Provider pusher to Vizyah SQS
    """

    _boto3_sqs: boto3.client
    _driver_sqs_url: str
    _fleet: str
    _encoder: Callable[[VehicleStatusExternalMessage], str]

    def __init__(self, driver_sqs_url: str, fleet: str, encoder: Callable[[VehicleStatusExternalMessage], str]):
        self._driver_sqs_url = driver_sqs_url
        self._fleet = fleet
        self._boto3_sqs = AwsClientProvider.sqs_client()
        self._encoder = encoder

    def send(self, message: VehicleStatusExternalMessage) -> None:
        if not message.statuses or len(message.statuses) == 0:
            Log.warning("No statuses to send skipping sending message")
        else:
            self.__send_message(message=message, queue_url=self._driver_sqs_url)

    def __send_message(
        self,
        message: VehicleStatusExternalMessage,
        queue_url: str,
        message_type: str = DriverExternalMessageType.EXTERNAL_VEHICLE_STATUS,
    ) -> None:
        raw_json: str = self._encoder(message)
        if queue_url:
            self._boto3_sqs.send_message(
                QueueUrl=queue_url,
                MessageBody=raw_json,
                MessageAttributes={"messageType": {"DataType": "String", "StringValue": message_type}},
                MessageDeduplicationId=VUtil.generate_random_token(),
                MessageGroupId=f"{message_type}_{self._fleet}",
            )
            Log.info(
                f"Successfully send message to queue: {queue_url} with createdAt: {VTime.printable_time(message.created_at)}. Message content: {raw_json} "
            )
        else:
            Log.error(f"Cannot send  message f{raw_json} of type {message_type} to {queue_url}")
