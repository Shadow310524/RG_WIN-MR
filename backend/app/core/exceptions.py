from typing import Any, Optional, Dict
from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from app.core.logging import logger


class RGWinException(Exception):
    """Base application exception."""
    def __init__(
        self,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        code: str = "INTERNAL_ERROR",
        details: Optional[Any] = None,
    ):
        self.message = message
        self.status_code = status_code
        self.code = code
        self.details = details
        super().__init__(message)


class BadRequestException(RGWinException):
    def __init__(self, message: str = "Bad request", details: Optional[Any] = None, code: str = "BAD_REQUEST"):
        super().__init__(
            message=message,
            status_code=status.HTTP_400_BAD_REQUEST,
            code=code,
            details=details,
        )


class NotFoundException(RGWinException):
    def __init__(self, message: str = "Resource not found", details: Optional[Any] = None, code: str = "NOT_FOUND"):
        super().__init__(
            message=message,
            status_code=status.HTTP_404_NOT_FOUND,
            code=code,
            details=details,
        )


class ConflictException(RGWinException):
    def __init__(self, message: str = "Resource conflict detected", details: Optional[Any] = None, code: str = "CONFLICT"):
        super().__init__(
            message=message,
            status_code=status.HTTP_409_CONFLICT,
            code=code,
            details=details,
        )


class ValidationException(RGWinException):
    def __init__(self, message: str = "Validation failed", details: Optional[Any] = None, code: str = "VALIDATION_ERROR"):
        super().__init__(
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            code=code,
            details=details,
        )


class UnauthorizedException(RGWinException):
    def __init__(self, message: str = "Authentication required", details: Optional[Any] = None, code: str = "UNAUTHORIZED"):
        super().__init__(
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
            code=code,
            details=details,
        )


class ForbiddenException(RGWinException):
    def __init__(self, message: str = "Access forbidden", details: Optional[Any] = None, code: str = "FORBIDDEN"):
        super().__init__(
            message=message,
            status_code=status.HTTP_403_FORBIDDEN,
            code=code,
            details=details,
        )


async def rgwin_exception_handler(request: Request, exc: RGWinException) -> JSONResponse:
    """Handles custom application exceptions with sanitized client payloads."""
    request_id = getattr(request.state, "request_id", None)
    logger.warning(
        f"Handled application exception [{exc.code}]: {exc.message}",
        extra={"extra": {"path": request.url.path, "code": exc.code, "request_id": request_id}},
    )
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": exc.code,
                "message": exc.message,
                "details": exc.details,
            },
            "request_id": request_id,
        },
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """Handles Pydantic request validation errors."""
    request_id = getattr(request.state, "request_id", None)
    errors = []
    for err in exc.errors():
        loc = " -> ".join(str(l) for l in err.get("loc", []))
        errors.append({"field": loc, "message": err.get("msg")})

    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "error": {
                "code": "REQUEST_VALIDATION_ERROR",
                "message": "Invalid input parameters provided.",
                "details": errors,
            },
            "request_id": request_id,
        },
    )


async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Catches all unexpected server errors.
    CRITICAL OWASP RULE: Never leak internal tracebacks, SQL statements, or server paths.
    """
    request_id = getattr(request.state, "request_id", None)
    logger.error(
        f"Unhandled server error on {request.method} {request.url.path}: {str(exc)}",
        exc_info=True,
        extra={"extra": {"request_id": request_id, "path": request.url.path}},
    )
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "An unexpected error occurred while processing your request. Please try again later.",
            },
            "request_id": request_id,
        },
    )
