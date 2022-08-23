from typing import TypeVar, Generic, Optional
from mypy_boto3_s3.service_resource import Bucket
from io import BytesIO
from pydantic import BaseModel
from botocore.exceptions import ClientError

from shared_qkon.qkon_log import Log

T = TypeVar("T", bound=BaseModel)


class S3KeyValueStore(Generic[T]):
    """
    A simple, generic key-value store, backed by S3.
    Nothing fancy, just plain set and get operations.
    """

    # We have to store an actual reference to the type
    # in order to use its classmethods.
    value_type: type[T]

    def __init__(self, bucket: Bucket):
        self._bucket = bucket

    def set(self, key: str, value: T):
        """
        Overwrite value under `key`.
        """
        self._upload_file(key, BytesIO(value.json().encode("utf-8")))

    def get(self, key: str) -> Optional[T]:
        """
        Get value stored under `key`.
        """
        buffer = BytesIO()
        try:
            self._bucket.download_fileobj(key, buffer)
            return self.value_type.parse_raw(buffer.getvalue())
        # If object doesn't exist
        except ClientError as e:
            Log.error(f"Failed to fetch an object. key={key} error={e}")
            return None

    def _upload_file(self, key: str, file: BytesIO):
        """
        Upload a file-like object to `self._bucket`, under `key`.
        """
        self._bucket.upload_fileobj(Fileobj=file, Key=key)
