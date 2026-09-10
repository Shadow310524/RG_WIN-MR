import uuid
from datetime import date
from decimal import Decimal
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text, Numeric, Date, ForeignKey, Uuid, CheckConstraint
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class PromotionalInvestmentTypeEnum(str, enum.Enum):
    SAMPLE = "SAMPLE"
    PROMOTIONAL_UNIT = "PROMOTIONAL_UNIT"
    FREE_SUPPLY = "FREE_SUPPLY"
    PROMOTIONAL_MATERIAL = "PROMOTIONAL_MATERIAL"
    OTHER = "OTHER"


class DoctorPromotionalInvestment(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """
    Authoritative doctor-specific promotional investment record.
    Captures direct monetary costs incurred specifically to support/promote a doctor.
    Critical: Doctor-specific promotional investment != General field operating expense.
    """
    __tablename__ = "doctor_promotional_investments"
    __table_args__ = (
        CheckConstraint("amount > 0", name="chk_promotional_investment_amount_positive"),
    )

    doctor_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False, index=True
    )
    visit_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("visits.id", ondelete="SET NULL"), nullable=True, index=True
    )
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    investment_type: Mapped[PromotionalInvestmentTypeEnum] = mapped_column(
        Enum(PromotionalInvestmentTypeEnum, native_enum=False, length=30),
        default=PromotionalInvestmentTypeEnum.SAMPLE,
        nullable=False,
        index=True,
    )
    investment_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Offline synchronization idempotency key
    client_operation_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid(as_uuid=True),
        unique=True,
        index=True,
        nullable=True
    )

    # Relationships
    doctor = relationship("Doctor", back_populates="promotional_investments")
    visit = relationship("Visit", back_populates="promotional_investments")
    user = relationship("User")
