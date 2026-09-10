import uuid
from datetime import date
from decimal import Decimal
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Text, Integer, Numeric, Date, ForeignKey, Uuid, CheckConstraint
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class ExpenseCategoryEnum(str, enum.Enum):
    SAMPLE_COST = "SAMPLE_COST"
    TRAVEL = "TRAVEL"
    PROMOTIONAL = "PROMOTIONAL"
    OTHER = "OTHER"


class Expense(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Business investment/expense record associated with doctors, areas, or promotional efforts."""
    __tablename__ = "expenses"
    __table_args__ = (
        CheckConstraint("amount >= 0", name="chk_expense_amount_non_negative"),
    )

    category: Mapped[ExpenseCategoryEnum] = mapped_column(
        Enum(ExpenseCategoryEnum, native_enum=False, length=30),
        nullable=False,
        index=True
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    doctor_id: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id", ondelete="SET NULL"), nullable=True, index=True)
    area_id: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("areas.id", ondelete="SET NULL"), nullable=True, index=True)
    healix_product_id: Mapped[int | None] = mapped_column(Integer, nullable=True, index=True)
    user_id: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    expense_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Relationships
    doctor = relationship("Doctor")
    area = relationship("Area")
    user = relationship("User")
