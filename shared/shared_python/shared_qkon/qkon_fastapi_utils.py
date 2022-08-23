import traceback

from fastapi import FastAPI, HTTPException, Depends
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.security import OAuth2AuthorizationCodeBearer
from starlette import status

from shared_qkon.qkon_utils import BusinessException
from shared_qkon.qkon_log import Log
from shared_qkon.qkon_auth import (
    AuthService,
    User,
)
from shared_qkon.qkon_aws import simple_security_enabled_from_os


__COGNITO_TOKEN_URL = "https://vizyah-dev.auth.eu-central-1.amazoncognito.com/oauth2/token"
__COGNITO_AUTHORIZATION_URL = "https://vizyah-dev.auth.eu-central-1.amazoncognito.com/authorize"
__COGNITO_VIZYAH_CLIENT_ID = "1c6tnv36hslllcu6lh94q10pjb"
__AUTH_SCOPES = {"openid": "OpenId access"}

__SECURITY_SCHEMA = OAuth2AuthorizationCodeBearer(
    tokenUrl=__COGNITO_TOKEN_URL, authorizationUrl=__COGNITO_AUTHORIZATION_URL, scopes=__AUTH_SCOPES
)


def getFastAPI(
    title: str = "FastApi",
    description: str = f"For clientId use:{__COGNITO_VIZYAH_CLIENT_ID} .\n Select openId profile to make it work properly",
) -> FastAPI:
    app: FastAPI = FastAPI(title=title, description=description)
    app.add_exception_handler(BusinessException, fastapi_handle_business_exceptions)
    app.add_exception_handler(Exception, fastapi_handle_exceptions)
    return app


def create_fastapi_exception(detail: str = "", status_code: int = status.HTTP_401_UNAUTHORIZED):
    return HTTPException(
        status_code=status_code,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"} if status_code == status.HTTP_401_UNAUTHORIZED else {},
    )


def get_logged_user(token: str = Depends(__SECURITY_SCHEMA)) -> User:
    auth: AuthService = AuthService(simple_security_enabled=simple_security_enabled_from_os())
    authorized: bool = auth.authorize(token)
    if not authorized:
        raise create_fastapi_exception(detail="Invalid authentication credentials")
    return auth._current_user


async def fastapi_handle_business_exceptions(request: Request, e: BusinessException):
    stacktrace: str = f"Stacktrace: ${traceback.format_exc()}" if Log.is_debug_enabled() else ""
    message: str = f"StatusCode: {e.status_code}. {e.message}. {stacktrace}"
    if e.status_code >= 500:
        Log.critical(message)
    elif e.status_code >= 400:
        Log.warning(message)
    else:
        Log.error(message)
    headers = getattr(e, "headers", None)
    if headers:
        return JSONResponse({"detail": e.message}, status_code=e.status_code, headers=headers)
    else:
        return JSONResponse({"detail": e.message}, status_code=e.status_code)


async def fastapi_handle_exceptions(request: Request, e: Exception):
    stacktrace: str = f"Stacktrace: ${traceback.format_exc()}" if Log.is_debug_enabled() else ""
    message: str = f"{str(e)}. {stacktrace}"
    Log.error(message)
    headers = getattr(e, "headers", None)
    if headers:
        return JSONResponse({"detail": str(e)}, status_code=500, headers=headers)
    else:
        return JSONResponse({"detail": str(e)}, status_code=500)
