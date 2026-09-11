import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user
from app.models.user import User
from app.schemas.analytics import (
    DoctorCommercialSummary,
    AreaCommercialSummary,
    OverallCommercialSummary,
)
from app.services.financial_analytics_service import FinancialAnalyticsService

router = APIRouter(prefix="/analytics", tags=["Commercial Financial Analytics"])


@router.get("/doctor/{doctor_id}", response_model=DoctorCommercialSummary, summary="Doctor Commercial Summary")
async def get_doctor_commercial_summary(
    doctor_id: uuid.UUID,
    period: str = Query("all", pattern="^(today|this_week|this_month|all)$", description="Filter period"),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorCommercialSummary:
    """
    Answers: 'Is calling and promoting this doctor commercially worth it?'
    Aggregates business value vs promotional investment, with full financial data provenance.
    """
    service = FinancialAnalyticsService(db)
    return await service.get_doctor_summary(doctor_id, current_user, period=period)


@router.get("/area/{area_id}", response_model=AreaCommercialSummary, summary="Area Commercial Summary & Doctor Drill-down")
async def get_area_commercial_summary(
    area_id: uuid.UUID,
    period: str = Query("all", pattern="^(today|this_week|this_month|all)$", description="Filter period"),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> AreaCommercialSummary:
    """
    Area-level commercial rollup derived purely from its assigned doctors.
    Includes doctor ranking drill-down by business value and promotional spend.
    """
    service = FinancialAnalyticsService(db)
    return await service.get_area_summary(area_id, current_user, period=period)


@router.get("/overall", response_model=OverallCommercialSummary, summary="Overall Business Commercial Summary")
async def get_overall_commercial_summary(
    period: str = Query("this_month", pattern="^(today|this_week|this_month|all)$", description="Filter period"),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> OverallCommercialSummary:
    """
    Overall business commercial rollup across assigned areas.
    Maintains financial honesty: Revenue unavailable, Profit/Loss insufficient data.
    """
    service = FinancialAnalyticsService(db)
    return await service.get_overall_summary(current_user, period=period)
