import uuid
from typing import Callable, List
from fastapi import Depends, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import UnauthorizedException, ForbiddenException
from app.core.security import decode_token
from app.models.user import User, RoleEnum, UserStatusEnum
from app.repositories.user_repo import UserRepository, RevokedTokenRepository
from app.repositories.audit_repo import AuditLogRepository

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/login",
    auto_error=True,
)


async def get_current_token_payload(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Decodes JWT and verifies token is not revoked."""
    payload = decode_token(token)

    # Ensure access token
    if payload.get("type") != "access":
        raise UnauthorizedException("Invalid token type. Access token required.", code="INVALID_TOKEN_TYPE")

    jti = payload.get("jti")
    if not jti:
        raise UnauthorizedException("Token missing identifier.", code="MALFORMED_TOKEN")

    # Check revocation blacklist
    revoked_repo = RevokedTokenRepository(db)
    if await revoked_repo.is_token_revoked(jti):
        raise UnauthorizedException("Token has been revoked. Please log in again.", code="TOKEN_REVOKED")

    return payload


async def get_current_user(
    payload: dict = Depends(get_current_token_payload),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Retrieves the authenticated user from the database."""
    sub = payload.get("sub")
    if not sub:
        raise UnauthorizedException("Token subject missing.", code="MALFORMED_TOKEN")

    try:
        user_id = uuid.UUID(sub)
    except ValueError:
        raise UnauthorizedException("Invalid user ID in token.", code="INVALID_SUBJECT")

    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise UnauthorizedException("User not found.", code="USER_NOT_FOUND")

    return user


async def get_token_payload_for_logout(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """
    Decodes JWT access token specifically for logout and revocation.
    Verifies cryptographic signature using the secret key, but allows expired access tokens
    so that the companion active refresh session can be safely revoked on logout.
    """
    payload = decode_token(token, verify_exp=False)

    if payload.get("type") != "access":
        raise UnauthorizedException("Invalid token type. Access token required.", code="INVALID_TOKEN_TYPE")

    jti = payload.get("jti")
    if not jti:
        raise UnauthorizedException("Token missing identifier.", code="MALFORMED_TOKEN")

    return payload


async def get_user_for_logout(
    payload: dict = Depends(get_token_payload_for_logout),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Retrieves user for logout and audit logging, accepting signature-verified access tokens."""
    sub = payload.get("sub")
    if not sub:
        raise UnauthorizedException("Token subject missing.", code="MALFORMED_TOKEN")

    try:
        user_id = uuid.UUID(sub)
    except ValueError:
        raise UnauthorizedException("Invalid user ID in token.", code="INVALID_SUBJECT")

    user_repo = UserRepository(db)
    user = await user_repo.get_by_id(user_id)
    if not user:
        raise UnauthorizedException("User not found.", code="USER_NOT_FOUND")

    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Ensures user account is currently active."""
    if current_user.status != UserStatusEnum.ACTIVE:
        raise ForbiddenException("User account is inactive.", code="ACCOUNT_INACTIVE")
    return current_user


def require_role(allowed_roles: List[RoleEnum]) -> Callable:
    """
    Role-Based Access Control (RBAC) dependency factory.
    Enforces server-side authorization: returns 403 Forbidden if user lacks permitted role.
    """
    async def role_checker(
        request: Request,
        current_user: User = Depends(get_current_active_user),
        db: AsyncSession = Depends(get_db),
    ) -> User:
        if current_user.role not in allowed_roles:
            audit_repo = AuditLogRepository(db)
            await audit_repo.log_event(
                action="FORBIDDEN_ROLE_ACCESS",
                entity_type="rbac",
                actor_id=current_user.id,
                metadata_json={
                    "user_role": current_user.role.value,
                    "required_roles": [r.value for r in allowed_roles],
                    "path": request.url.path,
                },
                ip_address=request.client.host if request.client else None,
            )
            await db.commit()
            raise ForbiddenException(
                f"Action restricted to [{', '.join(r.value for r in allowed_roles)}] roles.",
                code="INSUFFICIENT_PERMISSIONS",
            )
        return current_user

    return role_checker
