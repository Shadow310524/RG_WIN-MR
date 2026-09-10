import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user
from app.models.user import User
from app.schemas.visit import VisitCreate, VisitRead, VisitListResponse
from app.services.visit_service import VisitService

router = APIRouter(prefix="/visits", tags=["Field Visits & Detailing"])


@router.get("", response_model=VisitListResponse, summary="List Field Visits")
async def list_visits(
    doctor_id: Optional[uuid.UUID] = Query(None, description="Filter visits for specific doctor"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> VisitListResponse:
    """
    Returns field visits with server-side territory enforcement.
    MRs only see visits within their assigned territory or recorded by themselves.
    """
    service = VisitService(db)
    return await service.list_visits(
        current_user=current_user,
        doctor_id=doctor_id,
        page=page,
        page_size=page_size,
    )


@router.post("", response_model=VisitRead, status_code=status.HTTP_201_CREATED, summary="Record Field Visit")
async def record_visit(
    data: VisitCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> VisitRead:
    """
    Records a doctor visit.
    Guarded by BOLA/IDOR: MR can only record visits for doctors in assigned territories.
    """
    service = VisitService(db)
    return await service.create_visit(data, current_user)


@router.get("/{visit_id}", response_model=VisitRead, summary="Get Visit by ID")
async def get_visit(
    visit_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> VisitRead:
    """
    Returns visit details guarded by server-side territory boundaries.
    """
    service = VisitService(db)
    return await service.get_visit_by_id(visit_id, current_user)
