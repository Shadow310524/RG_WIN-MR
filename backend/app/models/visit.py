import uuid
from datetime import datetime, timezone
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text, Integer, ForeignKey, DateTime, Uuid, CheckConstraint
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class VisitTypeEnum(str, enum.Enum):
    NEW_DOCTOR = "NEW_DOCTOR"
    REGULAR_VISIT = "REGULAR_VISIT"
    FOLLOW_UP = "FOLLOW_UP"
    PRODUCT_DISCUSSION = "PRODUCT_DISCUSSION"
    ORDER_DISCUSSION = "ORDER_DISCUSSION"


class DoctorResponseEnum(str, enum.Enum):
    POSITIVE = "POSITIVE"
    NEUTRAL = "NEUTRAL"
    CRITICAL = "CRITICAL"
    INTERESTED = "INTERESTED"


class PrescriptionPotentialEnum(str, enum.Enum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"
    NONE = "NONE"


class DistributionTypeEnum(str, enum.Enum):
    SAMPLE = "SAMPLE"
    PROMOTIONAL_UNIT = "PROMOTIONAL_UNIT"
    FREE_SUPPLY = "FREE_SUPPLY"
    PAID_SALE = "PAID_SALE"
    RETURN = "RETURN"


class Visit(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Authoritative field visit record."""
    __tablename__ = "visits"

    doctor_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id"), nullable=False, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    visit_datetime: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    visit_type: Mapped[VisitTypeEnum] = mapped_column(
        Enum(VisitTypeEnum, native_enum=False, length=30),
        default=VisitTypeEnum.REGULAR_VISIT,
        nullable=False
    )
    doctor_response: Mapped[DoctorResponseEnum] = mapped_column(
        Enum(DoctorResponseEnum, native_enum=False, length=20),
        default=DoctorResponseEnum.POSITIVE,
        nullable=False
    )
    prescription_potential: Mapped[PrescriptionPotentialEnum] = mapped_column(
        Enum(PrescriptionPotentialEnum, native_enum=False, length=20),
        default=PrescriptionPotentialEnum.MEDIUM,
        nullable=False
    )
    doctor_feedback: Mapped[str | None] = mapped_column(Text, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Offline synchronization idempotency key
    client_operation_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True),
        unique=True,
        index=True,
        nullable=True
    )

    # Relationships
    doctor = relationship("Doctor", back_populates="visits")
    user = relationship("User")
    discussed_products = relationship("VisitDiscussedProduct", back_populates="visit", cascade="all, delete-orphan")
    distributed_products = relationship("VisitProduct", back_populates="visit", cascade="all, delete-orphan")
    follow_ups = relationship("FollowUp", back_populates="visit")


class VisitDiscussedProduct(Base):
    """
    Tracks products presented or detailed to the doctor during a visit.
    CRITICAL: A product discussed is NOT automatically a product given.
    """
    __tablename__ = "visit_discussed_products"

    visit_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("visits.id", ondelete="CASCADE"), primary_key=True)
    healix_product_id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    visit = relationship("Visit", back_populates="discussed_products")


class VisitProduct(Base, UUIDPrimaryKeyMixin):
    """
    Tracks physical samples or promotional products given to the doctor.
    CRITICAL BUSINESS RULE: Product given != Sale. Samples/promotional units create NO immediate revenue.
    """
    __tablename__ = "visit_products"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="chk_visit_product_quantity_positive"),
    )

    visit_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("visits.id", ondelete="CASCADE"), nullable=False, index=True)
    healix_product_id: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    distribution_type: Mapped[DistributionTypeEnum] = mapped_column(
        Enum(DistributionTypeEnum, native_enum=False, length=30),
        default=DistributionTypeEnum.SAMPLE,
        nullable=False
    )
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    unit_type: Mapped[str] = mapped_column(String(50), default="Packs", nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    visit = relationship("Visit", back_populates="distributed_products")
