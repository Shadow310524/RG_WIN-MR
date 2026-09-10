import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user
from app.models.user import User
from app.schemas.sale import SaleCreate, SaleRead, SaleListResponse
from app.services.sale_service import SaleService

router = APIRouter(prefix="/sales", tags=["Commercial Purchases & Sales"])


@router.get("", response_model=SaleListResponse, summary="List Realized Purchases / Sales")
async def list_sales(
    doctor_id: Optional[uuid.UUID] = Query(None, description="Filter purchases for doctor"),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> SaleListResponse:
    """
    Returns recorded purchases with server-side territory scoping.
    """
    service = SaleService(db)
    return await service.list_sales(
        current_user=current_user,
        doctor_id=doctor_id,
        page=page,
        page_size=page_size,
    )


@router.post("", response_model=SaleRead, status_code=status.HTTP_201_CREATED, summary="Record Purchase")
async def record_sale(
    data: SaleCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> SaleRead:
    """
    Records a commercial purchase.
    Enforces Decimal arithmetic and territory authorization for MRs.
    """
    service = SaleService(db)
    return await service.record_sale(data, current_user)
