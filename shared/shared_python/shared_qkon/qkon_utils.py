"""Methods to provide an abstraction layer over logging and some application scope util methods"""
import uuid
from typing import Optional
import traceback

from shared_qkon.qkon_auth import SecurityUtils
from shared_qkon.qkon_log import Log


def handle_business_exceptions(func):
    def wrap(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except BusinessException as e:
            stacktrace: str = f"Stacktrace: ${traceback.format_exc()}" if Log.is_debug_enabled() else ""
            message: str = f"StatusCode: {e.status_code}. {e.message}. Method: {func.__name__}. Params: {str(kwargs)}. {stacktrace}"
            if e.status_code >= 500:
                Log.critical(message)
            elif e.status_code >= 400:
                Log.warning(message)
            else:
                Log.error(message)
            return SecurityUtils.create_gateway_response(response_code=e.status_code, response_body=e.message)
        except Exception as e:
            stacktrace: str = f"Stacktrace: ${traceback.format_exc()}" if Log.is_debug_enabled() else ""
            message: str = f"{str(e)}. Method: {func.__name__}. Params: {str(kwargs)}. {stacktrace}"
            Log.error(message)
            return SecurityUtils.create_gateway_response(response_code=500, response_body=str(e))

    return wrap


class BusinessException(Exception):
    status_code: int
    message: str

    def __init__(self, message: str, status_code: int = 409):
        self.message = message
        self.status_code = status_code


class UnauthorizedException(BusinessException):
    def __init__(self, message: Optional[str] = "Unauthorized"):
        super().__init__(message=message, status_code=401)


class NoParamDefinedException(BusinessException):
    def __init__(self, param_name: str):
        super().__init__(message=f"No {param_name} passed", status_code=409)


def check_mandatory_param(param_value: Optional[str], param_name: str):
    if param_value is None or len(param_value) == 0:
        raise NoParamDefinedException(param_name)


def check_mandatory_fleet(fleet_token: Optional[str]):
    if fleet_token is None or len(fleet_token) == 0:
        raise NoParamDefinedException("fleet")


class VUtil:
    @staticmethod
    def generate_random_token(prefix: str = "") -> str:
        return prefix + str(uuid.uuid4())
