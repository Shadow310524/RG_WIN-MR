import uuid
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text, ForeignKey, Uuid, Index
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class DoctorStatusEnum(str, enum.Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    ARCHIVED = "ARCHIVED"


class Doctor(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Doctor entity tracking medical professionals, territory, and association affiliations."""
    __tablename__ = "doctors"
    __table_args__ = (
        Index("ix_doctors_phone_status", "phone", "status"),
        Index("ix_doctors_license_status", "medical_license_number", "status"),
    )

    name: Mapped[str] = mapped_column("full_name", String(255), nullable=False, index=True)
    phone: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    alternate_phone: Mapped[str | None] = mapped_column(String(50), nullable=True)
    email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    medical_license_number: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    specialization: Mapped[str] = mapped_column("specialty", String(150), nullable=False, index=True)
    qualification: Mapped[str | None] = mapped_column(String(150), nullable=True)
    clinic_name: Mapped[str | None] = mapped_column("clinic_hospital", String(255), nullable=True, index=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    area_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("areas.id"), nullable=False, index=True)
    association_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("associations.id"), nullable=True, index=True
    )
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[DoctorStatusEnum] = mapped_column(
        Enum(DoctorStatusEnum, native_enum=False, length=20),
        default=DoctorStatusEnum.ACTIVE,
        nullable=False,
        index=True,
    )
    created_by: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True)

    @property
    def is_active(self) -> bool:
        return self.status == DoctorStatusEnum.ACTIVE

    @property
    def full_name(self) -> str:
        return self.name

    @full_name.setter
    def full_name(self, value: str) -> None:
        self.name = value

    @property
    def specialty(self) -> str:
        return self.specialization

    @specialty.setter
    def specialty(self, value: str) -> None:
        self.specialization = value

    @property
    def clinic_hospital(self) -> str | None:
        return self.clinic_name

    @clinic_hospital.setter
    def clinic_hospital(self, value: str | None) -> None:
        self.clinic_name = value

    # Relationships
    area = relationship("Area", back_populates="doctors")
    association = relationship("Association", back_populates="doctors")
    associations = relationship("DoctorAssociation", back_populates="doctor", cascade="all, delete-orphan")
    creator = relationship("User", foreign_keys=[created_by])
    visits = relationship("Visit", back_populates="doctor")
    follow_ups = relationship("FollowUp", back_populates="doctor")
    prescriptions = relationship("Prescription", back_populates="doctor")
    orders = relationship("Order", back_populates="doctor")
    sales = relationship("Sale", back_populates="doctor")
    promotional_investments = relationship("DoctorPromotionalInvestment", back_populates="doctor", cascade="all, delete-orphan")


class DoctorAssociation(Base):
    """Many-to-many relationship linking doctors to medical associations."""
    __tablename__ = "doctor_associations"

    doctor_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id", ondelete="CASCADE"), primary_key=True)
    association_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("associations.id", ondelete="CASCADE"), primary_key=True)

    doctor = relationship("Doctor", back_populates="associations")
    association = relationship("Association", back_populates="doctor_associations")
