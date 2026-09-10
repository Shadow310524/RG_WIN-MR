import uuid
from datetime import datetime, timezone
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, DateTime, ForeignKey, Uuid
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class RoleEnum(str, enum.Enum):
    ADMIN = "ADMIN"
    MR = "MR"


class UserStatusEnum(str, enum.Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"


class User(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(50), nullable=True)
    role: Mapped[RoleEnum] = mapped_column(
        Enum(RoleEnum, native_enum=False, length=20),
        default=RoleEnum.MR,
        nullable=False,
        index=True
    )
    status: Mapped[UserStatusEnum] = mapped_column(
        Enum(UserStatusEnum, native_enum=False, length=20),
        default=UserStatusEnum.ACTIVE,
        nullable=False,
        index=True
    )

    # Relationships
    revoked_tokens = relationship("RevokedToken", back_populates="user", cascade="all, delete-orphan")


class RevokedToken(Base, UUIDPrimaryKeyMixin):
    """Stores invalidated JWT token identifiers (jti) for instant logout/revocation."""
    __tablename__ = "revoked_tokens"

    jti: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    user = relationship("User", back_populates="revoked_tokens")
