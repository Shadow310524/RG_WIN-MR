import uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import Boolean, ForeignKey, Uuid, UniqueConstraint
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class MRAreaAssignment(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Represents server-side territory assignment between a Medical Representative (MR) and an Area."""
    __tablename__ = "mr_area_assignments"
    __table_args__ = (
        UniqueConstraint("mr_id", "area_id", name="uq_mr_area_assignment"),
    )

    mr_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    area_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("areas.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False, index=True)

    # Relationships
    mr = relationship("User", back_populates="area_assignments")
    area = relationship("Area", back_populates="mr_assignments")
