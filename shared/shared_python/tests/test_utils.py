from unittest import TestCase

from shared_qkon.qkon_utils import (
    UnauthorizedException,
    BusinessException,
    NoParamDefinedException,
    check_mandatory_fleet,
    check_mandatory_param,
    VUtil,
)


class UtilsTest(TestCase):
    def test_unauthorized(self) -> None:
        with self.assertRaises(UnauthorizedException) as context:
            raise UnauthorizedException()
        assert context.exception.status_code == 401
        assert context.exception.message == "Unauthorized"
        assert isinstance(context.exception, BusinessException)

        with self.assertRaises(UnauthorizedException) as context:
            raise UnauthorizedException(message="X")
        assert context.exception.status_code == 401
        assert context.exception.message == "X"
        assert isinstance(context.exception, BusinessException)

    def test_no_param(self) -> None:
        with self.assertRaises(NoParamDefinedException) as context:
            raise NoParamDefinedException("x")
        assert context.exception.status_code == 409
        assert context.exception.message == "No x passed"
        assert isinstance(context.exception, BusinessException)

        assert check_mandatory_fleet("X") is None
        with self.assertRaises(NoParamDefinedException) as context:
            raise check_mandatory_fleet(None)
        assert context.exception.status_code == 409
        assert context.exception.message == "No fleet passed"
        assert isinstance(context.exception, BusinessException)

        assert check_mandatory_fleet("X") is None
        with self.assertRaises(NoParamDefinedException) as context:
            raise check_mandatory_param(param_value=None, param_name="x")
        assert context.exception.status_code == 409
        assert context.exception.message == "No x passed"
        assert isinstance(context.exception, BusinessException)

    @staticmethod
    def test_generate_random_token() -> None:
        token = VUtil.generate_random_token()
        token2 = VUtil.generate_random_token()
        assert token
        assert token2
        assert token != token2
