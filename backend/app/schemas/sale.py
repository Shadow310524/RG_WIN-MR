import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict
from app.models.sale import SaleStatusEnum


class SaleCreate(BaseModel):
    doctor_id: Optional[uuid.UUID] = None
    sale_date: date
    purchase_amount: Optional[Decimal] = Field(default=None, decimal_places=2, max_digits=12)
    gst_amount: Optional[Decimal] = Field(default=Decimal("0.00"), decimal_places=2, max_digits=12)
    total_amount: Decimal = Field(..., decimal_places=2, max_digits=12)
    notes: Optional[str] = None


class SaleRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    doctor_id: Optional[uuid.UUID] = None
    doctor_name: Optional[str] = None
    clinic_name: Optional[str] = None
    user_id: uuid.UUID
    sale_date: date
    status: SaleStatusEnum
    purchase_amount: Optional[Decimal] = None
    gst_amount: Optional[Decimal] = None
    total_amount: Decimal
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class SaleListResponse(BaseModel):
    items: List[SaleRead]
    total: int
    page: int
    page_size: int
