import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class AreaStatusEnum(str, enum.Enum):
    ACTIVE = "ACTIVE"
    ARCHIVED = "ARCHIVED"


class Area(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Territory/Area Master (e.g. Anna Nagar, T Nagar)."""
    __tablename__ = "areas"

    name: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    code: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    description: Mapped[str | None] = mapped_column(String(255), nullable=True)
    status: Mapped[AreaStatusEnum] = mapped_column(
        Enum(AreaStatusEnum, native_enum=False, length=20),
        default=AreaStatusEnum.ACTIVE,
        nullable=False,
        index=True
    )

    @property
    def is_active(self) -> bool:
        return self.status == AreaStatusEnum.ACTIVE

    # Relationships
    doctors = relationship("Doctor", back_populates="area")
    mr_assignments = relationship("MRAreaAssignment", back_populates="area", cascade="all, delete-orphan")
