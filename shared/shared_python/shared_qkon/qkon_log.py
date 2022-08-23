"""Methods to provide an abstraction layer over logging and some application scope util methods"""
import os
import time
from datetime import datetime
from typing import Optional

_DEBUG_ENABLED = "DEBUG_ENABLED"
_BUILD_VERSION = "BUILD_VERSION"
_SERVICE_NAME = "SERVICE_NAME"


class Log:
    @staticmethod
    def info(message: str, source: Optional[str] = None) -> None:
        Log.__log_message(str(message), source, "info")

    @staticmethod
    def debug(message: str, source: Optional[str] = None) -> None:
        if Log.is_debug_enabled():
            Log.__log_message(str(message), source, "debug")

    @staticmethod
    def metric(message: str, source: Optional[str] = None) -> None:
        Log.__log_message(str(message), source, "metric")

    @staticmethod
    def is_debug_enabled() -> bool:
        value = os.getenv(_DEBUG_ENABLED, "False")
        return value and value.lower() == "true"

    @staticmethod
    def get_build_version() -> Optional[str]:
        return os.getenv(_BUILD_VERSION)

    @staticmethod
    def get_service_name() -> Optional[str]:
        return os.getenv(_SERVICE_NAME)

    @staticmethod
    def error(message: str, source: Optional[str] = None) -> None:
        Log.__log_message(str(message), source, "error")

    @staticmethod
    def critical(message: str, source: Optional[str] = None) -> None:
        Log.__log_message(str(message), source, "critical error")

    @staticmethod
    def warning(message: str, source: Optional[str] = None) -> None:
        Log.__log_message(str(message), source, "warning")

    @staticmethod
    def __log_message(message: str, source: Optional[str] = None, message_type: str = "info") -> None:
        build_version: str = Log.get_build_version()
        build_version = f"[Build:{build_version}]" if build_version else ""
        service_name: str = Log.get_service_name()
        service_name = f"[Service:{service_name}]" if service_name else ""

        print(f"[{str(Log.__get_date())}]{build_version}{service_name}[{message_type}]{message}")

    @staticmethod
    def __get_date() -> str:
        return datetime.now().strftime("%m-%d-%Y %H:%M:%S")


def measured(func):
    def wrap(*args, **kwargs):
        start = _current_milli_time()
        result = func(*args, **kwargs)
        end = _current_milli_time()
        message = f"{func.__name__} - execution time {end - start} ms {'TOO long' if end - start > 5000 else ''}"
        Log.metric(message)
        return result

    return wrap


def _current_milli_time() -> int:
    return round(time.time() * 1000)
