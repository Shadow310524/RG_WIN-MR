import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user, require_role
from app.models.user import User, RoleEnum
from app.schemas.association import (
    AssociationCreate,
    AssociationUpdate,
    AssociationRead,
    AssociationStatusUpdate,
)
from app.services.association_service import AssociationService

router = APIRouter(prefix="/associations", tags=["Medical Associations"])


@router.get("", response_model=List[AssociationRead], summary="List Medical Associations")
async def list_associations(
    is_active: Optional[bool] = Query(None, description="Filter active associations"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> List[AssociationRead]:
    """Returns medical associations (IMA, FOGSI, etc.) for doctor profiles."""
    service = AssociationService(db)
    assocs = await service.list_associations(is_active=is_active, skip=skip, limit=limit)
    return [AssociationRead.model_validate(a) for a in assocs]


@router.get("/{association_id}", response_model=AssociationRead, summary="Get Association by ID")
async def get_association(
    association_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> AssociationRead:
    """Returns details of a medical association."""
    service = AssociationService(db)
    assoc = await service.get_association_by_id(association_id)
    return AssociationRead.model_validate(assoc)


@router.post("", response_model=AssociationRead, status_code=status.HTTP_201_CREATED, summary="Create Association (Admin Only)")
async def create_association(
    data: AssociationCreate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> AssociationRead:
    """Registers a new medical association master."""
    service = AssociationService(db)
    assoc = await service.create_association(data, actor_id=current_user.id)
    return AssociationRead.model_validate(assoc)


@router.put("/{association_id}", response_model=AssociationRead, summary="Update Association (Admin Only)")
async def update_association(
    association_id: uuid.UUID,
    data: AssociationUpdate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> AssociationRead:
    """Updates medical association information."""
    service = AssociationService(db)
    assoc = await service.update_association(association_id, data, actor_id=current_user.id)
    return AssociationRead.model_validate(assoc)


@router.patch("/{association_id}/status", response_model=AssociationRead, summary="Change Association Status (Admin Only)")
async def set_association_status(
    association_id: uuid.UUID,
    data: AssociationStatusUpdate,
    current_user: User = Depends(require_role([RoleEnum.ADMIN])),
    db: AsyncSession = Depends(get_db),
) -> AssociationRead:
    """Archives or activates a medical association."""
    service = AssociationService(db)
    assoc = await service.set_association_status(association_id, data.status, actor_id=current_user.id)
    return AssociationRead.model_validate(assoc)
