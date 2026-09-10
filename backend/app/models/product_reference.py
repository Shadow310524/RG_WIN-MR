from datetime import datetime, timezone
from decimal import Decimal
from typing import List, Any
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Integer, Numeric, Text, JSON, DateTime
from app.models.base import Base, TimestampMixin, UUIDPrimaryKeyMixin


class ProductReference(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """
    Read-Only product reference mirror synchronized with the authoritative Healix Product Master.
    RG WIN does NOT own this product master data; it only tracks interactions against it.
    """
    __tablename__ = "product_references"

    # Preserves the exact authoritative integer ID from Healix
    healix_product_id: Mapped[int] = mapped_column(Integer, unique=True, index=True, nullable=False)
    cached_name: Mapped[str] = mapped_column(String(255), index=True, nullable=False)
    cached_category: Mapped[str | None] = mapped_column(String(100), index=True, nullable=True)

    # CRITICAL: Must be NULL when unavailable. Never default to 0.00 to prevent fabricating financial values.
    cached_mrp: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)

    cached_image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    cached_description: Mapped[str | None] = mapped_column(Text, nullable=True)
    cached_ingredients: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    cached_benefits: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="ACTIVE", index=True, nullable=False)
    last_synced_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
