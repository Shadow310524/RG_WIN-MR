import uuid
from datetime import date, datetime, timezone
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text, Date, DateTime, ForeignKey, Uuid
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class FollowUpStatusEnum(str, enum.Enum):
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    OVERDUE = "OVERDUE"
    CANCELLED = "CANCELLED"


class FollowUp(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Actionable tasks and follow-up commitments generated from field visits or direct planning."""
    __tablename__ = "follow_ups"

    doctor_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id"), nullable=False, index=True)
    visit_id: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("visits.id", ondelete="SET NULL"), nullable=True)
    assigned_user_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    due_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    status: Mapped[FollowUpStatusEnum] = mapped_column(
        Enum(FollowUpStatusEnum, native_enum=False, length=20),
        default=FollowUpStatusEnum.PENDING,
        nullable=False,
        index=True
    )
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    doctor = relationship("Doctor", back_populates="follow_ups")
    visit = relationship("Visit", back_populates="follow_ups")
    assigned_user = relationship("User")
