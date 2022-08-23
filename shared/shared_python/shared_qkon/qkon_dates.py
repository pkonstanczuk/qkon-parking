"""Methods to provide an abstraction layer over logging and some application scope util methods"""
from datetime import datetime
import time

from dateutil import tz

_DEFAULT_DATE_FORMAT = "%Y-%m-%dT%H:%M:%S%z"
_NO_SPACES_FORMAT = "%Y-%m-%d--%H-%M-%S"
_DEFAULT_DATE_FORMAT_2 = "%Y-%m-%dT%H:%M:%SZ"
_DEFAULT_DATE_FORMAT_3 = "%Y-%m-%d %H:%M:%S"


def _validate_date_format(date_text, date_format):
    try:
        datetime.strptime(date_text, date_format)
    except ValueError:
        return False
    return True


class VTime:
    @staticmethod
    def epoch_to_datetime(epoch: int) -> datetime:
        return datetime.utcfromtimestamp(epoch)

    @staticmethod
    def epoch_from_datetime(value: datetime) -> int:
        value = value.replace(tzinfo=tz.gettz("UTC"))
        outcome = int(value.timestamp())
        value.replace(tzinfo=None)
        return outcome

    @staticmethod
    def epoch_from_string(value: str) -> int:
        if _validate_date_format(value, _DEFAULT_DATE_FORMAT):
            date_format = _DEFAULT_DATE_FORMAT
        elif _validate_date_format(value, _DEFAULT_DATE_FORMAT_2):
            date_format = _DEFAULT_DATE_FORMAT_2
        elif _validate_date_format(value, _DEFAULT_DATE_FORMAT_3):
            date_format = _DEFAULT_DATE_FORMAT_3
        else:
            raise TypeError
        dt = datetime.strptime(value, date_format)
        return VTime.epoch_from_datetime(dt)

    @staticmethod
    def epoch_to_string(value: int) -> str:
        dt = datetime.fromtimestamp(value)
        return datetime.strftime(dt, _DEFAULT_DATE_FORMAT)

    @staticmethod
    def now_in_datetime() -> datetime:
        u = VTime.epoch_to_datetime(VTime.now_in_epoch())
        return u.replace(microsecond=0)

    @staticmethod
    def now_in_epoch() -> int:
        return int(datetime.now().timestamp())

    @staticmethod
    def printable_time(epoch: int, no_spaces: bool = False) -> str:
        return time.strftime(_NO_SPACES_FORMAT if no_spaces else _DEFAULT_DATE_FORMAT_3, time.localtime(epoch))
