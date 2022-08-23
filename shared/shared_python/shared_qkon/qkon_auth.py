import os
from dataclasses import dataclass
from enum import Enum
from typing import Optional

from jose import JWTError, jwt
from shared_qkon.qkon_aws import LambdaConsts
from shared_qkon.qkon_log import Log
from typeguard import typechecked

EMAIL_JWT_AUTH0 = "https://vizyah.aleet.co/email"

_CONTENT_TYPE = "Content-Type"

_APPLICATION_JSON = "application/json"

_SEC_TOKEN_SEPARATOR: str = "#"
_SEC_ROLE_SEPARATOR: str = ":"

M2M_PASSWORD_ENV_VARIABLE = "M2M_PASSWORD"

COGNITO_TOKEN_URL = "https://vizyah-dev.auth.eu-central-1.amazoncognito.com/oauth2/token"
COGNITO_AUTHORIZATION_URL = "https://vizyah-dev.auth.eu-central-1.amazoncognito.com/authorize"
COGNITO_VIZYAH_CLIENT_ID = "1c6tnv36hslllcu6lh94q10pjb"
AUTH_SCOPES = {"openid": "OpenId access"}


@dataclass(frozen=True)
class SecurityRole(Enum):
    VIZYAH_ADMIN = f"VIZYAH{_SEC_ROLE_SEPARATOR}ADMIN"
    ADMIN_FLEET = "ADMIN"
    DRIVER_FLEET = "DRIVER"
    CUSTOMER_FLEET = "CUSTOMER"

    def __str__(self):
        return self.value


class SecurityUtils:
    @staticmethod
    def no_fleet_token_gateway_response() -> dict:
        return SecurityUtils.create_gateway_response(400, "No fleet provided")

    @staticmethod
    @typechecked
    def create_gateway_response(
        response_code: int = 200, response_body: Optional[str] = None, message: Optional[str] = None
    ) -> dict:
        response: dict = dict()
        response["statusCode"] = response_code
        if response_body:
            response["body"] = response_body
        if message:
            response["headers"] = {_CONTENT_TYPE: _APPLICATION_JSON, "message": message}
        else:
            response["headers"] = {_CONTENT_TYPE: _APPLICATION_JSON}
        return response

    @staticmethod
    @typechecked
    def create_gateway_response_with_object(response_body: Optional[str] = None) -> dict:
        response: dict = dict()
        response["statusCode"] = 200 if response_body else 404
        if response_body:
            response["body"] = response_body
        return response

    @staticmethod
    @typechecked
    def create_custom_gateway_response(
        response_code: int = 200, response_body: Optional[str] = None, content_type: Optional[str] = "application/json"
    ) -> dict:
        response: dict = dict()
        response["statusCode"] = response_code
        if response_body:
            response["body"] = response_body
        if content_type:
            response["headers"] = {"Content-Type": content_type}
        return response

    @staticmethod
    @typechecked
    def build_simple_token(
        user_email: str, user_role: SecurityRole, fleet: Optional[str] = None, attach_prefix: bool = False
    ) -> str:
        """
        Helper for building security tokens for tests. It build security token working ONLY for environments where
        _simple_security_enabled in AuthService is True
        """
        prefix: str = "Bearer " if attach_prefix else ""
        return (
            f"{prefix}{user_email}{_SEC_TOKEN_SEPARATOR}{user_role.value}"
            if str(user_role) == str(SecurityRole.VIZYAH_ADMIN)
            else f"{prefix}{user_email}{_SEC_TOKEN_SEPARATOR}{fleet}{_SEC_ROLE_SEPARATOR}{user_role.value}"
        )


@dataclass(frozen=True)
class User:
    user_name: str
    email: Optional[str]
    roles: list

    def __has_role(self, role: str) -> bool:
        return self.roles and role in self.roles

    def has_role(self, role: SecurityRole, fleet_token: Optional[str] = None) -> bool:
        role_str = role.value
        if fleet_token:
            role_str = fleet_token + _SEC_ROLE_SEPARATOR + role.value

        return self.__has_role(role_str)

    def is_admin(self, fleet_token: Optional[str] = None) -> bool:
        return self.has_role(SecurityRole.VIZYAH_ADMIN) or self.is_fleet_admin(fleet_token=fleet_token)

    def is_driver(self, fleet_token: Optional[str] = None, admin_allowed: bool = True) -> bool:
        return (self.is_admin(fleet_token) and admin_allowed) or (
            fleet_token and self.has_role(role=SecurityRole.DRIVER_FLEET, fleet_token=fleet_token)
        )

    def is_customer(self, fleet_token: Optional[str] = None) -> bool:
        return self.is_admin(fleet_token) or (
            fleet_token and self.has_role(role=SecurityRole.CUSTOMER_FLEET, fleet_token=fleet_token)
        )

    def is_fleet_admin(self, fleet_token: Optional[str] = None) -> bool:
        return fleet_token and self.has_role(role=SecurityRole.ADMIN_FLEET, fleet_token=fleet_token)


class AuthError(Exception):
    def __init__(self, error, status_code):
        self.error = error
        self.status_code = status_code


class AuthService:
    _simple_security_enabled: bool
    _current_user: Optional[User] = None

    def __init__(self, simple_security_enabled: bool = False) -> None:
        super().__init__()
        self._simple_security_enabled = simple_security_enabled

    def authorize(self, bearer_token_value: str) -> bool:
        is_auth: bool = (
            self._simple_security_enabled and self.__authorize_simple(bearer_token_value)
        ) or self.__authorize_m2m(bearer_token_value)
        if not is_auth:
            return self.__authorize_jwt(bearer_token_value)
        return is_auth

    def authorize_from_lambda_event(self, event: dict) -> bool:
        authorization: Optional[str] = (
            event.get(LambdaConsts.HEADERS).get(LambdaConsts.AUTHORIZATION) if event.get(LambdaConsts.HEADERS) else None
        )
        if authorization is None:
            authorization: Optional[str] = (
                event.get(LambdaConsts.HEADERS).get(LambdaConsts.AUTHORIZATION_2)
                if event.get(LambdaConsts.HEADERS)
                else None
            )
        return authorization and self.authorize(authorization)

    def __authorize_m2m(self, bearer_token_value: str) -> bool:
        m2m_password: Optional[str] = os.getenv(M2M_PASSWORD_ENV_VARIABLE, None)
        if m2m_password and self.__get_token_auth_header(bearer_token_value) == m2m_password:
            self._current_user = User(user_name="system", roles=[str(SecurityRole.VIZYAH_ADMIN)], email=None)
            return True
        return False

    def __authorize_simple(self, bearer_token_value: str) -> bool:
        try:
            token = self.__get_token_auth_header(bearer_token_value)
            split = token.split(_SEC_TOKEN_SEPARATOR)
            if len(split) > 1:
                self._current_user = User(user_name=split[0], roles=[split[1]], email=split[0])
                return True
        except AuthError:
            Log.error(f"Could not parse simple token: {bearer_token_value}")
            self._current_user = None
        return False

    def __authorize_jwt(self, bearer_token_value: str) -> bool:
        try:
            token = self.__get_token_auth_header(bearer_token_value)
            unverified_claims = jwt.get_unverified_claims(token)
            self._current_user = User(
                user_name=unverified_claims.get(EMAIL_JWT_AUTH0)
                or unverified_claims.get("email")
                or unverified_claims.get("sub"),
                roles=unverified_claims.get("permissions") or unverified_claims.get("cognito:groups"),
                email=unverified_claims.get(EMAIL_JWT_AUTH0) or unverified_claims.get("email"),
            )
            print()

            return True
        except JWTError:
            Log.warning("Could not check the user rights from JWT token")
            self._current_user = None
        except AuthError:
            Log.warning(f"Could not parse  JWT token: {bearer_token_value}")
            self._current_user = None
        return False

    def has_role(self, role: SecurityRole, fleet_token: Optional[str] = None) -> bool:
        return self.is_authorized() and self._current_user.has_role(role, fleet_token)

    def is_authorized(self) -> bool:
        return self._current_user is not None

    def get_username(self) -> str:
        if not self.is_authorized:
            raise AuthError({"code": "no user", "description": "No user"}, 401)
        return self._current_user.email if self._current_user.email else self._current_user.user_name

    @staticmethod
    def __get_token_auth_header(bearer_token_value: str):
        """Obtains the Access Token from the Authorization Header"""
        return bearer_token_value.replace("Bearer", "").replace("bearer", "").strip()

    def is_admin(self, fleet_token: Optional[str] = None) -> bool:
        return self.is_authorized() and (
            self._current_user.has_role(SecurityRole.VIZYAH_ADMIN)
            or self._current_user.is_fleet_admin(fleet_token=fleet_token)
        )

    def is_fleet_admin(self, fleet_token: Optional[str] = None) -> bool:
        return self.is_authorized() and self._current_user.has_role(
            role=SecurityRole.ADMIN_FLEET, fleet_token=fleet_token
        )

    def get_fleets_user_has_any_role_in(self) -> list[str]:
        result: list = []
        role: str
        for role in self._current_user.roles:
            if role != str(SecurityRole.VIZYAH_ADMIN):
                fleet = (
                    role.replace(_SEC_ROLE_SEPARATOR + str(SecurityRole.DRIVER_FLEET), "")
                    .replace(_SEC_ROLE_SEPARATOR + str(SecurityRole.CUSTOMER_FLEET), "")
                    .replace(_SEC_ROLE_SEPARATOR + str(SecurityRole.ADMIN_FLEET), "")
                )
                result.append(fleet)
        return result
