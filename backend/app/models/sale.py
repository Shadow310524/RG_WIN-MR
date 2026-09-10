import uuid
from datetime import date
from decimal import Decimal
import enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Enum, Integer, Numeric, Date, ForeignKey, Uuid, CheckConstraint
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class SaleStatusEnum(str, enum.Enum):
    CONFIRMED = "CONFIRMED"
    REFUNDED = "REFUNDED"


class Sale(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Authoritative realized commercial sale."""
    __tablename__ = "sales"

    doctor_id: Mapped[uuid.UUID | None] = mapped_column(Uuid(as_uuid=True), ForeignKey("doctors.id"), nullable=True, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    sale_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    status: Mapped[SaleStatusEnum] = mapped_column(
        Enum(SaleStatusEnum, native_enum=False, length=20),
        default=SaleStatusEnum.CONFIRMED,
        nullable=False,
        index=True
    )
    total_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=Decimal("0.00"), nullable=False)

    # Relationships
    doctor = relationship("Doctor", back_populates="sales")
    user = relationship("User")
    items = relationship("SaleItem", back_populates="sale", cascade="all, delete-orphan")


class SaleItem(Base, UUIDPrimaryKeyMixin):
    """Line items for realized sales."""
    __tablename__ = "sale_items"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="chk_sale_item_quantity_positive"),
        CheckConstraint("unit_price >= 0", name="chk_sale_item_unit_price_non_negative"),
        CheckConstraint("discount_amount >= 0", name="chk_sale_item_discount_non_negative"),
    )

    sale_id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), ForeignKey("sales.id", ondelete="CASCADE"), nullable=False, index=True)
    healix_product_id: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    unit_price: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    discount_amount: Mapped[Decimal] = mapped_column(Numeric(10, 2), default=Decimal("0.00"), nullable=False)
    total_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)

    sale = relationship("Sale", back_populates="items")
