import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import UnauthorizedException, ForbiddenException
from app.core.security import (
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.models.user import User, UserStatusEnum
from app.repositories.user_repo import UserRepository, RevokedTokenRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.auth import LoginRequest, TokenResponse, UserRead, LogoutResponse


class AuthService:
    """Domain service managing user authentication, token issuance, rotation, and revocation."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.user_repo = UserRepository(db)
        self.revoked_repo = RevokedTokenRepository(db)
        self.audit_repo = AuditLogRepository(db)

    async def authenticate(
        self,
        login_req: LoginRequest,
        ip_address: Optional[str] = None,
    ) -> TokenResponse:
        """
        Authenticates user with email and Argon2id password.
        Returns short-lived access token and rotating refresh token.
        """
        user = await self.user_repo.get_by_email(login_req.email)

        # Generic authentication failure message (OWASP A07 mitigation)
        if not user or not verify_password(login_req.password, user.password_hash):
            await self.audit_repo.log_event(
                action="LOGIN_FAILED",
                entity_type="user",
                actor_id=user.id if user else None,
                metadata_json={"email": login_req.email, "reason": "invalid_credentials"},
                ip_address=ip_address,
            )
            await self.db.commit()
            raise UnauthorizedException("Invalid email or password", code="INVALID_CREDENTIALS")

        # Check account status
        if user.status != UserStatusEnum.ACTIVE:
            await self.audit_repo.log_event(
                action="LOGIN_FAILED_INACTIVE",
                entity_type="user",
                actor_id=user.id,
                metadata_json={"email": user.email, "status": user.status.value},
                ip_address=ip_address,
            )
            await self.db.commit()
            raise ForbiddenException("User account is inactive. Please contact the administrator.", code="ACCOUNT_INACTIVE")

        # Generate tokens with session correlation
        refresh_token, refresh_jti, _ = create_refresh_token(
            user_id=user.id,
            email=user.email,
            role=user.role.value,
        )
        access_token, access_jti, _ = create_access_token(
            user_id=user.id,
            email=user.email,
            role=user.role.value,
            refresh_jti=refresh_jti,
        )

        await self.audit_repo.log_event(
            action="LOGIN_SUCCESS",
            entity_type="user",
            actor_id=user.id,
            metadata_json={"role": user.role.value},
            ip_address=ip_address,
        )
        await self.db.commit()

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=900,  # 15 minutes
            user=UserRead.model_validate(user),
        )

    async def refresh_tokens(
        self,
        refresh_token_str: str,
        ip_address: Optional[str] = None,
    ) -> TokenResponse:
        """
        Rotates refresh token and generates a new access token.
        Old refresh token is immediately revoked.
        """
        payload = decode_token(refresh_token_str)

        # Ensure correct token type
        if payload.get("type") != "refresh":
            raise UnauthorizedException("Invalid token type. Refresh token required.", code="INVALID_TOKEN_TYPE")

        jti = payload.get("jti")
        sub = payload.get("sub")
        exp = payload.get("exp")

        if not jti or not sub or not exp:
            raise UnauthorizedException("Invalid token claims.", code="MALFORMED_TOKEN")

        # Check if refresh token has already been revoked (prevent replay attacks)
        if await self.revoked_repo.is_token_revoked(jti):
            await self.audit_repo.log_event(
                action="REVOKED_TOKEN_REUSE_ATTEMPT",
                entity_type="token",
                actor_id=uuid.UUID(sub),
                metadata_json={"jti": jti},
                ip_address=ip_address,
            )
            await self.db.commit()
            raise UnauthorizedException("Token has already been revoked.", code="TOKEN_REVOKED")

        user_id = uuid.UUID(sub)
        user = await self.user_repo.get_by_id(user_id)
        if not user or user.status != UserStatusEnum.ACTIVE:
            raise UnauthorizedException("User no longer active or found.", code="USER_INACTIVE")

        # 1. Revoke the old refresh token (ROTATION)
        expires_at = datetime.fromtimestamp(exp, tz=timezone.utc)
        await self.revoked_repo.revoke_token(jti=jti, user_id=user_id, expires_at=expires_at)

        # 2. Issue new token pair with session correlation
        new_refresh_token, new_refresh_jti, _ = create_refresh_token(
            user_id=user.id,
            email=user.email,
            role=user.role.value,
        )
        new_access_token, _, _ = create_access_token(
            user_id=user.id,
            email=user.email,
            role=user.role.value,
            refresh_jti=new_refresh_jti,
        )

        await self.audit_repo.log_event(
            action="TOKEN_REFRESH_SUCCESS",
            entity_type="user",
            actor_id=user.id,
            metadata_json={"old_jti": jti},
            ip_address=ip_address,
        )
        await self.db.commit()

        return TokenResponse(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
            expires_in=900,
            user=UserRead.model_validate(user),
        )

    async def logout(
        self,
        token_payload: dict,
        user: User,
        refresh_token: Optional[str] = None,
        ip_address: Optional[str] = None,
    ) -> LogoutResponse:
        """
        Revokes both the access-token JTI and the active refresh-token JTI.
        Prevents stolen refresh tokens from being reused after logout.
        """
        access_jti = token_payload.get("jti")
        access_exp = token_payload.get("exp")
        session_refresh_jti = token_payload.get("refresh_jti")

        now = datetime.now(timezone.utc)

        # 1. Revoke access token JTI
        if access_jti:
            exp_dt = datetime.fromtimestamp(access_exp, tz=timezone.utc) if access_exp else now
            revocation_expiry = max(exp_dt, now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS))
            await self.revoked_repo.revoke_token(
                jti=access_jti,
                user_id=user.id,
                expires_at=revocation_expiry,
            )

        # 2. Revoke active refresh token JTI linked to the session (signed session linkage)
        if session_refresh_jti:
            refresh_exp_dt = now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
            await self.revoked_repo.revoke_token(
                jti=session_refresh_jti,
                user_id=user.id,
                expires_at=refresh_exp_dt,
            )

        # 3. If explicit refresh token was sent in body, decode and revoke its JTI as well
        if refresh_token:
            try:
                rt_payload = decode_token(refresh_token, verify_exp=False)
                rt_jti = rt_payload.get("jti")
                rt_exp = rt_payload.get("exp")
                if rt_jti and rt_payload.get("type") == "refresh":
                    rt_exp_dt = datetime.fromtimestamp(rt_exp, tz=timezone.utc) if rt_exp else now
                    rt_revocation_expiry = max(rt_exp_dt, now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS))
                    await self.revoked_repo.revoke_token(
                        jti=rt_jti,
                        user_id=user.id,
                        expires_at=rt_revocation_expiry,
                    )
            except Exception:
                # Suppress token decode issues on logout, access JTI is already revoked
                pass

        await self.audit_repo.log_event(
            action="LOGOUT_SUCCESS",
            entity_type="user",
            actor_id=user.id,
            metadata_json={
                "access_jti": access_jti,
                "refresh_jti": session_refresh_jti,
            },
            ip_address=ip_address,
        )
        await self.db.commit()

        return LogoutResponse()
