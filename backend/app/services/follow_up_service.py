import uuid
from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from app.core.exceptions import NotFoundException, ForbiddenException
from app.models.doctor import Doctor
from app.models.follow_up import FollowUp, FollowUpStatusEnum
from app.models.user import User, RoleEnum
from app.repositories.doctor_repo import DoctorRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.follow_up import FollowUpCreate, FollowUpUpdate, FollowUpRead, FollowUpListResponse


class FollowUpService:
    """
    Business logic and territory authorization (BOLA/IDOR) enforcement for Follow-ups.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)
        self.audit_repo = AuditLogRepository(db)

    def _to_read_dto(self, f: FollowUp) -> FollowUpRead:
        return FollowUpRead(
            id=f.id,
            doctor_id=f.doctor_id,
            doctor_name=f.doctor.name if f.doctor else None,
            clinic_name=f.doctor.clinic_name if f.doctor else None,
            visit_id=f.visit_id,
            assigned_user_id=f.assigned_user_id,
            due_date=f.due_date,
            status=f.status,
            notes=f.notes,
            completed_at=f.completed_at,
            created_at=f.created_at,
            updated_at=f.updated_at,
        )

    async def create_follow_up(self, data: FollowUpCreate, current_user: User) -> FollowUpRead:
        doctor = await self.doctor_repo.get_by_id(data.doctor_id)
        if not doctor:
            raise NotFoundException(f"Doctor '{data.doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA / Territory authorization check
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doctor.area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        follow_up = FollowUp(
            id=uuid.uuid4(),
            doctor_id=data.doctor_id,
            visit_id=data.visit_id,
            assigned_user_id=current_user.id,
            due_date=data.due_date,
            status=data.status or FollowUpStatusEnum.PENDING,
            notes=data.notes,
        )

        self.db.add(follow_up)
        await self.db.flush()

        await self.audit_repo.log_event(
            actor_id=current_user.id,
            action="FOLLOW_UP_CREATED",
            entity_type="FollowUp",
            entity_id=str(follow_up.id),
            metadata_json={"doctor_id": str(doctor.id), "due_date": str(data.due_date)},
        )

        loaded = await self.db.execute(
            select(FollowUp).options(selectinload(FollowUp.doctor)).where(FollowUp.id == follow_up.id)
        )
        return self._to_read_dto(loaded.scalars().first())

    async def list_follow_ups(
        self,
        current_user: User,
        doctor_id: Optional[uuid.UUID] = None,
        status: Optional[FollowUpStatusEnum] = None,
        page: int = 1,
        page_size: int = 50,
    ) -> FollowUpListResponse:
        query = select(FollowUp).options(selectinload(FollowUp.doctor))
        count_query = select(func.count()).select_from(FollowUp)

        if doctor_id:
            doc = await self.doctor_repo.get_by_id(doctor_id)
            if not doc:
                raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")
            if current_user.role == RoleEnum.MR:
                is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
                if not is_assigned:
                    raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")
            query = query.where(FollowUp.doctor_id == doctor_id)
            count_query = count_query.where(FollowUp.doctor_id == doctor_id)
        elif current_user.role == RoleEnum.MR:
            assigned_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
            query = query.join(Doctor, FollowUp.doctor_id == Doctor.id).where(
                (Doctor.area_id.in_(assigned_area_ids)) | (FollowUp.assigned_user_id == current_user.id)
            )
            count_query = count_query.join(Doctor, FollowUp.doctor_id == Doctor.id).where(
                (Doctor.area_id.in_(assigned_area_ids)) | (FollowUp.assigned_user_id == current_user.id)
            )

        if status:
            query = query.where(FollowUp.status == status)
            count_query = count_query.where(FollowUp.status == status)

        total_res = await self.db.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * page_size
        query = query.order_by(FollowUp.due_date.asc(), FollowUp.created_at.desc()).offset(offset).limit(page_size)
        items_res = await self.db.execute(query)
        follow_ups = items_res.scalars().all()

        return FollowUpListResponse(
            items=[self._to_read_dto(f) for f in follow_ups],
            total=total,
            page=page,
            page_size=page_size,
        )

    async def update_status(
        self,
        follow_up_id: uuid.UUID,
        new_status: FollowUpStatusEnum,
        current_user: User,
    ) -> FollowUpRead:
        res = await self.db.execute(
            select(FollowUp).options(selectinload(FollowUp.doctor)).where(FollowUp.id == follow_up_id)
        )
        follow_up = res.scalars().first()
        if not follow_up:
            raise NotFoundException(f"Follow-up '{follow_up_id}' not found.", code="FOLLOW_UP_NOT_FOUND")

        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, follow_up.doctor.area_id)
            if not is_assigned and follow_up.assigned_user_id != current_user.id:
                raise ForbiddenException("Access denied to this follow-up record.")

        follow_up.status = new_status
        if new_status == FollowUpStatusEnum.COMPLETED:
            follow_up.completed_at = datetime.now(timezone.utc)
        else:
            follow_up.completed_at = None

        await self.db.flush()

        await self.audit_repo.log_event(
            actor_id=current_user.id,
            action="FOLLOW_UP_STATUS_UPDATED",
            entity_type="FollowUp",
            entity_id=str(follow_up.id),
            metadata_json={"status": new_status.value},
        )

        return self._to_read_dto(follow_up)
