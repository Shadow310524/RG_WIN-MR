import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user
from app.models.user import User
from app.models.follow_up import FollowUpStatusEnum
from app.schemas.follow_up import (
    FollowUpCreate,
    FollowUpStatusUpdate,
    FollowUpRead,
    FollowUpListResponse,
)
from app.services.follow_up_service import FollowUpService

router = APIRouter(prefix="/follow-ups", tags=["Follow-up Commitments"])


@router.get("", response_model=FollowUpListResponse, summary="List Follow-ups")
async def list_follow_ups(
    doctor_id: Optional[uuid.UUID] = Query(None, description="Filter by doctor UUID"),
    follow_up_status: Optional[FollowUpStatusEnum] = Query(None, alias="status", description="Filter by status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> FollowUpListResponse:
    """
    Returns follow-ups filtered by territory and optional doctor/status.
    """
    service = FollowUpService(db)
    return await service.list_follow_ups(
        current_user=current_user,
        doctor_id=doctor_id,
        status=follow_up_status,
        page=page,
        page_size=page_size,
    )


@router.post("", response_model=FollowUpRead, status_code=status.HTTP_201_CREATED, summary="Create Follow-up")
async def create_follow_up(
    data: FollowUpCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> FollowUpRead:
    """
    Creates a new actionable follow-up task.
    Guarded by BOLA: MR can only create follow-ups for assigned doctors.
    """
    service = FollowUpService(db)
    return await service.create_follow_up(data, current_user)


@router.patch("/{follow_up_id}/status", response_model=FollowUpRead, summary="Update Follow-up Status")
async def update_follow_up_status(
    follow_up_id: uuid.UUID,
    data: FollowUpStatusUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> FollowUpRead:
    """
    Toggles follow-up status (e.g. PENDING -> COMPLETED).
    """
    service = FollowUpService(db)
    return await service.update_status(follow_up_id, data.status, current_user)
