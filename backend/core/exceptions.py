from typing import Any, Dict, Optional


class AppException(Exception):
    """Tüm uygulama hataları için temel sınıf."""

    def __init__(
        self,
        status_code: int,
        message: str,
        details: Optional[Dict[str, Any]] = None,
    ):
        self.status_code = status_code
        self.message = message
        self.details = details
        super().__init__(message)


class NotFoundException(AppException):
    def __init__(
        self,
        message: str = "Resource not found",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(status_code=404, message=message, details=details)


class ConflictException(AppException):
    """Idempotency ve DB Unique Constraint hataları için"""

    def __init__(
        self,
        message: str = "Resource already exists",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(status_code=409, message=message, details=details)


class UnauthorizedException(AppException):
    def __init__(
        self,
        message: str = "Authentication failed",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(status_code=401, message=message, details=details)

class UploadOnlyImageException(AppException):
    def __init__(
        self,
        message: str = "Only image files are allowed for upload",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(status_code=400, message=message, details=details)

class UserNotFoundException(NotFoundException):
    def __init__(
        self,
        message: str = "User not found",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(message=message, details=details)

class UsernameAlreadyExistsException(ConflictException):
    def __init__(
        self,
        message: str = "Username already exists",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(message=message, details=details)

class EmailAlreadyExistsException(ConflictException):
    def __init__(
        self,
        message: str = "Email already exists",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(message=message, details=details)

class NotFollowYourselfException(AppException):
    def __init__(
        self,
        message: str = "You cannot follow yourself",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(status_code=400, message=message, details=details)