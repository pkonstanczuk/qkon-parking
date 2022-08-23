import datetime as datetime
from unittest import TestCase

from shared_qkon.qkon_dates import VTime


class Test(TestCase):
    def test_conversion_test(self):
        epoch: int = VTime.now_in_epoch()
        to_datetime = VTime.epoch_to_datetime(epoch)
        to_epoch = VTime.epoch_from_datetime(to_datetime)
        assert epoch == to_epoch
        datetime = VTime.now_in_datetime()
        from_datetime = VTime.epoch_from_datetime(datetime)
        to_datetime = VTime.epoch_to_datetime(from_datetime)
        assert datetime == to_datetime

    def test_now_in_epoch(self):
        epoch: int = VTime.now_in_epoch()
        assert epoch > 1623245808
        as_datetime: datetime = VTime.epoch_to_datetime(epoch)
        assert epoch == VTime.epoch_from_datetime(as_datetime)

    def test_now_in_datetime(self):
        date_time: datetime.datetime = VTime.now_in_datetime()
        epoch: int = VTime.epoch_from_datetime(date_time)
        assert date_time == VTime.epoch_to_datetime(epoch)

    def test_printable_time(self):
        time: str = VTime.printable_time(VTime.now_in_epoch())
        assert "20" in time

    def test_epoch_from_string(self):
        # Explicitly set the timezone to a non-trivial value.
        tz_offset: datetime.timezone = datetime.timezone(datetime.timedelta(hours=2))
        date_time: datetime.datetime = datetime.datetime(
            year=2020,
            month=1,
            day=2,
            hour=3,
            minute=4,
            second=5,
            microsecond=0,  # We do not expect sub-second precision.
            tzinfo=tz_offset,
        )
        date_time_str: str = str(date_time).replace(" ", "T")
        epoch: int = VTime.epoch_from_string(date_time_str)
        assert epoch == VTime.epoch_from_datetime(date_time)
