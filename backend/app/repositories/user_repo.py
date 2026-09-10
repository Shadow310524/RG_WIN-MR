import uuid
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User, RevokedToken
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """Data access repository for User entities."""

    def __init__(self, db: AsyncSession):
        super().__init__(User, db)

    async def get_by_email(self, email: str) -> Optional[User]:
        """Looks up a user by their unique email (case-insensitive)."""
        result = await self.db.execute(
            select(User).where(User.email == email.lower().strip())
        )
        return result.scalars().first()


class RevokedTokenRepository(BaseRepository[RevokedToken]):
    """Data access repository for revoked JWT token blacklist."""

    def __init__(self, db: AsyncSession):
        super().__init__(RevokedToken, db)

    async def is_token_revoked(self, jti: str) -> bool:
        """Returns True if the token's jti exists in the revoked_tokens table."""
        result = await self.db.execute(
            select(RevokedToken.id).where(RevokedToken.jti == jti)
        )
        return result.scalar() is not None

    async def revoke_token(
        self,
        jti: str,
        user_id: uuid.UUID,
        expires_at: datetime,
    ) -> Optional[RevokedToken]:
        """Inserts a token jti into the revoked_tokens blacklist if not already revoked."""
        if await self.is_token_revoked(jti):
            return None
        revoked = RevokedToken(
            jti=jti,
            user_id=user_id,
            expires_at=expires_at,
        )
        return await self.create(revoked)

    async def cleanup_expired(self) -> int:
        """Housekeeping: deletes expired revoked token entries to keep table compact."""
        now = datetime.now(timezone.utc)
        result = await self.db.execute(
            delete(RevokedToken).where(RevokedToken.expires_at < now)
        )
        return result.rowcount or 0
