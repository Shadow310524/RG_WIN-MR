import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dependencies.auth import get_current_active_user
from app.models.doctor import DoctorStatusEnum
from app.models.user import User
from app.schemas.doctor import (
    DoctorCreate,
    DoctorUpdate,
    DoctorRead,
    DoctorStatusUpdate,
    DoctorListResponse,
    DoctorDuplicateCheckRequest,
    DoctorDuplicateCheckResponse,
)
from app.services.doctor_service import DoctorService

router = APIRouter(prefix="/doctors", tags=["Doctor CRM & Directory"])


@router.get("", response_model=DoctorListResponse, summary="List Doctors with Search & Filters")
async def list_doctors(
    area_id: Optional[uuid.UUID] = Query(None, description="Filter by area UUID"),
    association_id: Optional[uuid.UUID] = Query(None, description="Filter by association UUID"),
    doctor_status: Optional[DoctorStatusEnum] = Query(None, alias="status", description="Filter by status"),
    search: Optional[str] = Query(None, description="Search query across name, phone, license, clinic"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorListResponse:
    """
    Returns a paginated list of doctors.
    - MR queries are strictly scoped to the MR's assigned territory areas server-side.
    - Admin queries access all doctors globally.
    """
    service = DoctorService(db)
    return await service.list_doctors(
        current_user=current_user,
        area_id=area_id,
        association_id=association_id,
        status=doctor_status,
        search=search,
        page=page,
        page_size=page_size,
    )


@router.post("/check-duplicate", response_model=DoctorDuplicateCheckResponse, summary="Pre-flight Duplicate Doctor Check")
async def check_duplicate_doctor(
    req: DoctorDuplicateCheckRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorDuplicateCheckResponse:
    """Checks whether a doctor phone number or medical license is already registered."""
    service = DoctorService(db)
    return await service.check_duplicate(req)


@router.get("/{doctor_id}", response_model=DoctorRead, summary="Get Doctor by ID")
async def get_doctor(
    doctor_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorRead:
    """
    Returns doctor profile details.
    Guarded by BOLA/IDOR protection: MRs can only fetch doctors in their assigned areas.
    """
    service = DoctorService(db)
    return await service.get_doctor_by_id(doctor_id, current_user)


@router.post("", response_model=DoctorRead, status_code=status.HTTP_201_CREATED, summary="Create Doctor")
async def create_doctor(
    data: DoctorCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorRead:
    """
    Registers a new doctor profile.
    - Enforces server-side duplicate detection on phone and medical license (409 Conflict).
    - MRs can only register doctors in territory areas assigned to them (403 Forbidden).
    """
    service = DoctorService(db)
    return await service.create_doctor(data, current_user)


@router.put("/{doctor_id}", response_model=DoctorRead, summary="Update Doctor")
async def update_doctor(
    doctor_id: uuid.UUID,
    data: DoctorUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorRead:
    """
    Updates an existing doctor profile.
    - Guarded against BOLA/IDOR: MR cannot edit doctors outside their assigned territory.
    - MR cannot transfer a doctor into an unassigned area.
    """
    service = DoctorService(db)
    return await service.update_doctor(doctor_id, data, current_user)


@router.patch("/{doctor_id}/status", response_model=DoctorRead, summary="Change Doctor Status")
async def set_doctor_status(
    doctor_id: uuid.UUID,
    data: DoctorStatusUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
) -> DoctorRead:
    """Activates, deactivates, or archives a doctor profile."""
    service = DoctorService(db)
    return await service.set_doctor_status(doctor_id, data.status, current_user)
