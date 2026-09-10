import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user, require_role
from app.models.user import User, RoleEnum
from app.schemas.area import (
    AreaCreate,
    AreaUpdate,
    AreaRead,
    AreaStatusUpdate,
    MRAssignmentCreate,
    MRAssignmentRead,
)
from app.services.area_service import AreaService

router = APIRouter(prefix="/areas", tags=["Area & Territory Management"])


@router.get("", response_model=List[AreaRead], summary="List Territory Areas")
async def list_areas(
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> List[AreaRead]:
    """
    Returns list of territory areas.
    - ADMIN: views all configured territory areas.
    - MR: returns strictly the territory areas assigned to the authenticated MR.
    """
    service = AreaService(db)
    areas = await service.list_areas(current_user, is_active=is_active, skip=skip, limit=limit)
    return [AreaRead.model_validate(a) for a in areas]


@router.get("/{area_id}", response_model=AreaRead, summary="Get Area by ID")
async def get_area(
    area_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> AreaRead:
    """Returns details of a specific territory area, enforcing MR territory assignment."""
    service = AreaService(db)
    area = await service.get_area_by_id(area_id, current_user)
    return AreaRead.model_validate(area)


@router.post("", response_model=AreaRead, status_code=status.HTTP_201_CREATED, summary="Create Area (Admin Only)")
async def create_area(
    data: AreaCreate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> AreaRead:
    """Creates a new territory master record. Enforces unique area code and name."""
    service = AreaService(db)
    area = await service.create_area(data, actor_id=current_user.id)
    return AreaRead.model_validate(area)


@router.put("/{area_id}", response_model=AreaRead, summary="Update Area (Admin Only)")
async def update_area(
    area_id: uuid.UUID,
    data: AreaUpdate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> AreaRead:
    """Updates territory area properties. Prevents duplicate code conflicts."""
    service = AreaService(db)
    area = await service.update_area(area_id, data, actor_id=current_user.id)
    return AreaRead.model_validate(area)


@router.patch("/{area_id}/status", response_model=AreaRead, summary="Change Area Status (Admin Only)")
async def set_area_status(
    area_id: uuid.UUID,
    data: AreaStatusUpdate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> AreaRead:
    """Archives or activates a territory area without destructive physical deletion."""
    service = AreaService(db)
    area = await service.set_area_status(area_id, data.status, actor_id=current_user.id)
    return AreaRead.model_validate(area)


@router.get("/{area_id}/assignments", response_model=List[MRAssignmentRead], summary="List MR Assignments for Area (Admin Only)")
async def list_area_assignments(
    area_id: uuid.UUID,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> List[MRAssignmentRead]:
    """Lists Medical Representatives assigned to the given territory area."""
    service = AreaService(db)
    return await service.list_area_assignments(area_id)


@router.post("/{area_id}/assignments", response_model=MRAssignmentRead, status_code=status.HTTP_201_CREATED, summary="Assign MR to Area (Admin Only)")
async def assign_mr_to_area(
    area_id: uuid.UUID,
    data: MRAssignmentCreate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> MRAssignmentRead:
    """Assigns an MR to a territory area, establishing the server-side authorization boundary."""
    service = AreaService(db)
    return await service.assign_mr_to_area(area_id, data.mr_id, actor_id=current_user.id)


@router.delete("/{area_id}/assignments/{mr_id}", summary="Remove MR Assignment (Admin Only)")
async def unassign_mr_from_area(
    area_id: uuid.UUID,
    mr_id: uuid.UUID,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> dict:
    """Unassigns an MR from a territory area."""
    service = AreaService(db)
    await service.unassign_mr_from_area(area_id, mr_id, actor_id=current_user.id)
    return {"status": "success", "message": "MR unassigned from area successfully."}
