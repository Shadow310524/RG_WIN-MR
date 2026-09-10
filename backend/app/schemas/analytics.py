import uuid
from decimal import Decimal
from typing import Optional, List, Dict
from pydantic import BaseModel, ConfigDict
from app.schemas.promotional_investment import PromotionalInvestmentRead


class FigureProvenance(BaseModel):
    """
    Explicit provenance metadata tracing the authoritative origin of every monetary figure.
    Guarantees financial integrity:
    - Purchase -> RECORDED_PURCHASE
    - Promotional Investment -> EXPLICIT_PROMOTIONAL_INVESTMENT
    - Revenue -> PENDING_BUSINESS_RULES (Revenue unavailable)
    - PTS -> PENDING_FORMULA (PTS unconfigured)
    - General Operating Expense -> SEPARATELY_TRACKED (never mixed with doctor profitability)
    """
    source: str
    status: str
    description: str


class DoctorCommercialSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    doctor_id: uuid.UUID
    doctor_name: str
    clinic_name: Optional[str] = None
    specialization: str
    area_id: uuid.UUID
    area_name: Optional[str] = None

    # Quantitative Activity Counts
    visit_count: int = 0
    purchase_count: int = 0

    # Financial Aggregates
    business_value: Decimal = Decimal("0.00")
    promotional_investment: Decimal = Decimal("0.00")

    # Honest Uncalculated Placeholders (never fake ₹0)
    revenue: Optional[Decimal] = None
    commercial_result: Optional[Decimal] = None

    # Compact Promotional Investment History
    recent_investments: List[PromotionalInvestmentRead] = []

    # Financial Provenance Mapping
    provenance: Dict[str, FigureProvenance] = {}


class DoctorRankItem(BaseModel):
    doctor_id: uuid.UUID
    doctor_name: str
    clinic_name: Optional[str] = None
    specialization: str
    visit_count: int = 0
    purchase_count: int = 0
    business_value: Decimal = Decimal("0.00")
    promotional_investment: Decimal = Decimal("0.00")
    commercial_result: Optional[Decimal] = None
    provenance: Dict[str, FigureProvenance] = {}


class AreaCommercialSummary(BaseModel):
    area_id: uuid.UUID
    area_name: str
    area_code: str
    doctor_count: int = 0

    # Aggregate Financials (derived purely from assigned doctors)
    business_value: Decimal = Decimal("0.00")
    promotional_investment: Decimal = Decimal("0.00")
    commercial_result: Optional[Decimal] = None

    # Doctors Drill-down (ranked by business_value descending)
    doctors: List[DoctorRankItem] = []

    # Financial Provenance Mapping
    provenance: Dict[str, FigureProvenance] = {}


class OverallCommercialSummary(BaseModel):
    period: str  # today | this_week | this_month | all
    total_doctors: int = 0
    total_visits: int = 0
    total_purchases: int = 0

    # Macro Financials
    business_value: Decimal = Decimal("0.00")
    promotional_investment: Decimal = Decimal("0.00")
    revenue: Optional[Decimal] = None  # Revenue unavailable
    profit_loss: Optional[Decimal] = None  # Insufficient data

    # Area Breakdown
    areas: List[AreaCommercialSummary] = []

    # Top Performing Doctors across territory
    top_doctors: List[DoctorRankItem] = []

    # Financial Provenance Mapping
    provenance: Dict[str, FigureProvenance] = {}
