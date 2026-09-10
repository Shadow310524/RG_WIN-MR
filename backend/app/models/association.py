import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class AssociationStatusEnum(str, enum.Enum):
    ACTIVE = "ACTIVE"
    ARCHIVED = "ARCHIVED"


class Association(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Medical Association Master (e.g. IMA, FOGSI)."""
    __tablename__ = "associations"

    name: Mapped[str] = mapped_column(String(200), unique=True, index=True, nullable=False)
    code: Mapped[str | None] = mapped_column(String(50), unique=True, index=True, nullable=True)
    short_name: Mapped[str | None] = mapped_column(String(50), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[AssociationStatusEnum] = mapped_column(
        Enum(AssociationStatusEnum, native_enum=False, length=20),
        default=AssociationStatusEnum.ACTIVE,
        nullable=False,
        index=True
    )
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    @property
    def is_active(self) -> bool:
        return self.status == AssociationStatusEnum.ACTIVE

    doctor_associations = relationship("DoctorAssociation", back_populates="association")
    doctors = relationship("Doctor", back_populates="association")
