import uuid
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text, ForeignKey, Uuid
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class DoctorStatusEnum(str, enum.Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    ARCHIVED = "ARCHIVED"


class Doctor(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Doctor entity tracking medical professionals, territory, and association affiliations."""
    __tablename__ = "doctors"

    full_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    specialty: Mapped[str] = mapped_column(String(150), nullable=False, index=True)
    area_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("areas.id"), nullable=False, index=True)
    clinic_hospital: Mapped[str | None] = mapped_column(String(255), nullable=True, index=True)
    phone: Mapped[str | None] = mapped_column(String(50), nullable=True, index=True)
    email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[DoctorStatusEnum] = mapped_column(
        Enum(DoctorStatusEnum, native_enum=False, length=20),
        default=DoctorStatusEnum.ACTIVE,
        nullable=False,
        index=True
    )
    created_by: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True)

    # Relationships
    area = relationship("Area", back_populates="doctors")
    creator = relationship("User", foreign_keys=[created_by])
    associations = relationship("DoctorAssociation", back_populates="doctor", cascade="all, delete-orphan")
    visits = relationship("Visit", back_populates="doctor")
    follow_ups = relationship("FollowUp", back_populates="doctor")
    prescriptions = relationship("Prescription", back_populates="doctor")
    orders = relationship("Order", back_populates="doctor")
    sales = relationship("Sale", back_populates="doctor")


class DoctorAssociation(Base):
    """Many-to-many relationship linking doctors to medical associations."""
    __tablename__ = "doctor_associations"

    doctor_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id", ondelete="CASCADE"), primary_key=True)
    association_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("associations.id", ondelete="CASCADE"), primary_key=True)

    doctor = relationship("Doctor", back_populates="associations")
    association = relationship("Association", back_populates="doctor_associations")
