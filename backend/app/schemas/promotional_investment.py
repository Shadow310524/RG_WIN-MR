import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict
from app.models.promotional_investment import PromotionalInvestmentTypeEnum


class PromotionalInvestmentCreate(BaseModel):
    doctor_id: uuid.UUID
    visit_id: Optional[uuid.UUID] = None
    amount: Decimal = Field(..., gt=0, decimal_places=2, max_digits=12, description="Monetary promotional investment amount in INR")
    investment_type: PromotionalInvestmentTypeEnum = Field(default=PromotionalInvestmentTypeEnum.SAMPLE)
    investment_date: date
    notes: Optional[str] = None
    client_operation_id: Optional[uuid.UUID] = None


class PromotionalInvestmentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    doctor_id: uuid.UUID
    doctor_name: Optional[str] = None
    visit_id: Optional[uuid.UUID] = None
    user_id: Optional[uuid.UUID] = None
    amount: Decimal
    investment_type: PromotionalInvestmentTypeEnum
    investment_date: date
    notes: Optional[str] = None
    client_operation_id: Optional[uuid.UUID] = None
    created_at: datetime
    updated_at: datetime

    # Financial Provenance
    provenance_source: str = "EXPLICIT_PROMOTIONAL_INVESTMENT"


class PromotionalInvestmentListResponse(BaseModel):
    items: List[PromotionalInvestmentRead]
    total: int
    total_amount: Decimal
    page: int
    page_size: int
