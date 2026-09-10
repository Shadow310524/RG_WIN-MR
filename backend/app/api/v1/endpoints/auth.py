from typing import Optional
from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.rate_limit import limiter
from app.dependencies.auth import (
    get_current_user,
    get_current_active_user,
    get_current_token_payload,
    get_token_payload_for_logout,
    get_user_for_logout,
    require_role,
)
from app.models.user import User, RoleEnum
from app.schemas.auth import (
    LoginRequest,
    RefreshTokenRequest,
    TokenResponse,
    UserRead,
    LogoutRequest,
    LogoutResponse,
)
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication & RBAC"])


@router.post("/login", response_model=TokenResponse, summary="Authenticate User")
@limiter.limit("20/minute")
async def login(
    request: Request,
    response: Response,
    login_data: LoginRequest,
    db: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Authenticates credentials using Argon2id and returns rotating token pair."""
    ip_address = request.client.host if request.client else None
    service = AuthService(db)
    return await service.authenticate(login_data, ip_address=ip_address)


@router.post("/refresh", response_model=TokenResponse, summary="Rotate Refresh Token")
@limiter.limit("30/minute")
async def refresh_token(
    request: Request,
    response: Response,
    refresh_data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Rotates refresh token and issues a new access token, invalidating the old refresh token."""
    ip_address = request.client.host if request.client else None
    service = AuthService(db)
    return await service.refresh_tokens(refresh_data.refresh_token, ip_address=ip_address)


@router.post("/logout", response_model=LogoutResponse, summary="Revoke Tokens & Logout")
async def logout(
    request: Request,
    logout_req: Optional[LogoutRequest] = None,
    token_payload: dict = Depends(get_token_payload_for_logout),
    current_user: User = Depends(get_user_for_logout),
    db: AsyncSession = Depends(get_db),
) -> LogoutResponse:
    """Revokes active access token and associated refresh token in the database blacklist."""
    ip_address = request.client.host if request.client else None
    service = AuthService(db)
    refresh_token = logout_req.refresh_token if logout_req else None
    return await service.logout(
        token_payload=token_payload,
        user=current_user,
        refresh_token=refresh_token,
        ip_address=ip_address,
    )


@router.get("/me", response_model=UserRead, summary="Get Current Authenticated Profile")
async def get_my_profile(
    current_user: User = Depends(get_current_active_user),
) -> UserRead:
    """Returns the authenticated user profile and roles."""
    return UserRead.model_validate(current_user)


@router.get(
    "/admin-only",
    response_model=dict,
    summary="RBAC Test: Admin Protected Endpoint",
    dependencies=[Depends(require_role([RoleEnum.ADMIN]))],
)
async def admin_only_check(
    current_user: User = Depends(get_current_active_user),
) -> dict:
    """Verifies that an endpoint is strictly guarded by server-side ADMIN role authorization."""
    return {
        "status": "authorized",
        "message": f"Welcome Admin {current_user.full_name}",
        "role": current_user.role.value,
    }
