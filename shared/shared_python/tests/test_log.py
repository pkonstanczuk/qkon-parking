from typing import Optional
from unittest import TestCase

from shared_qkon.qkon_log import Log
from shared_qkon.qkon_utils import VUtil


class FmLogTest(TestCase):
    def test_logging(self) -> None:
        self.__test_logs()
        self.__test_logs("X")
        assert VUtil.generate_random_token()

    @staticmethod
    def __test_logs(source: Optional[str] = None) -> None:
        Log.debug("X", source)
        Log.info("X", source)
        Log.warning("X", source)
        Log.error("X", source)
