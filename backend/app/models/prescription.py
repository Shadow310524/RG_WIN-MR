import uuid
from datetime import date
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import Text, Integer, Date, ForeignKey, Uuid
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class Prescription(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """
    Manually recorded commercial prescription observations.
    NOTE: Business CRM tracking record, NOT an electronic health record (EHR).
    """
    __tablename__ = "prescriptions"

    doctor_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id"), nullable=False, index=True)
    healix_product_id: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    recorded_by: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False)
    record_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    estimated_quantity: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Relationships
    doctor = relationship("Doctor", back_populates="prescriptions")
    recorder = relationship("User")
