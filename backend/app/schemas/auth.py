import uuid
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from app.models.user import RoleEnum, UserStatusEnum


class LoginRequest(BaseModel):
    email: EmailStr = Field(description="User account email address")
    password: str = Field(min_length=6, max_length=128, description="Plaintext password")


class RefreshTokenRequest(BaseModel):
    refresh_token: str = Field(description="Valid JWT refresh token")


class UserRead(BaseModel):
    id: uuid.UUID
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    role: RoleEnum
    status: UserStatusEnum

    model_config = ConfigDict(from_attributes=True)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = Field(default=900, description="Access token expiration in seconds (15 minutes)")
    user: UserRead


class LogoutRequest(BaseModel):
    refresh_token: Optional[str] = Field(
        default=None,
        description="Optional active refresh token to revoke alongside session"
    )


class LogoutResponse(BaseModel):
    success: bool = True
    message: str = "Logged out successfully. Token has been revoked."
