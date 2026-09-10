import uuid
from datetime import datetime, timezone
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, DateTime, ForeignKey, Uuid
from app.models.base import Base, UUIDPrimaryKeyMixin


class SyncOperationStatusEnum(str, enum.Enum):
    PROCESSED = "PROCESSED"
    FAILED = "FAILED"


class SyncOperation(Base, UUIDPrimaryKeyMixin):
    """
    Tracks client-side offline operation UUIDs to guarantee server-side idempotency.
    Prevents duplicate visits, follow-ups, or orders during network retries.
    """
    __tablename__ = "sync_operations"

    client_operation_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        unique=True,
        index=True,
        nullable=False
    )
    user_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    entity_type: Mapped[str] = mapped_column(String(50), nullable=False)
    status: Mapped[SyncOperationStatusEnum] = mapped_column(
        Enum(SyncOperationStatusEnum, native_enum=False, length=20),
        default=SyncOperationStatusEnum.PROCESSED,
        nullable=False
    )
    processed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    user = relationship("User")
