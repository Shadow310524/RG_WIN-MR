import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user
from app.models.user import User
from app.schemas.promotional_investment import (
    PromotionalInvestmentCreate,
    PromotionalInvestmentRead,
    PromotionalInvestmentListResponse,
)
from app.services.promotional_investment_service import PromotionalInvestmentService

router = APIRouter(prefix="/promotional-investments", tags=["Doctor Promotional Investments"])


@router.get("", response_model=PromotionalInvestmentListResponse, summary="List Promotional Investments")
async def list_investments(
    doctor_id: Optional[uuid.UUID] = Query(None, description="Filter investments for specific doctor"),
    visit_id: Optional[uuid.UUID] = Query(None, description="Filter investments for specific visit"),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> PromotionalInvestmentListResponse:
    """
    List doctor-specific promotional investments.
    Enforces territory scoping (MR can only view assigned doctors).
    """
    service = PromotionalInvestmentService(db)
    return await service.list_investments(
        current_user=current_user,
        doctor_id=doctor_id,
        visit_id=visit_id,
        page=page,
        page_size=page_size,
    )


@router.post("", response_model=PromotionalInvestmentRead, status_code=status.HTTP_201_CREATED, summary="Record Promotional Investment")
async def record_investment(
    data: PromotionalInvestmentCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> PromotionalInvestmentRead:
    """
    Record an authoritative doctor-specific promotional investment (Samples, Promotional Units, Free Supplies).
    Enforces Decimal validation, territory authorization (BOLA), and audit trail.
    """
    service = PromotionalInvestmentService(db)
    return await service.record_investment(data, current_user)


@router.delete("/{investment_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete Promotional Investment")
async def delete_investment(
    investment_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete a promotional investment with territory scoping and audit logging.
    """
    service = PromotionalInvestmentService(db)
    await service.delete_investment(investment_id, current_user)
    return None
