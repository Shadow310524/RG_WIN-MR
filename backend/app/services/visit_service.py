import json
import uuid
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from app.core.exceptions import NotFoundException, ForbiddenException, ConflictException
from app.models.doctor import Doctor
from app.models.visit import Visit, VisitTypeEnum, DoctorResponseEnum, PrescriptionPotentialEnum
from app.models.user import User, RoleEnum
from app.repositories.doctor_repo import DoctorRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.visit import VisitCreate, VisitRead, VisitListResponse


class VisitService:
    """
    Business logic and territory authorization (BOLA/IDOR) enforcement for Field Visits.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)
        self.audit_repo = AuditLogRepository(db)

    def _to_read_dto(self, visit: Visit) -> VisitRead:
        discussed_val = None
        samples_val = None
        purchase_opp_val = False

        if visit.doctor_feedback:
            try:
                parsed = json.loads(visit.doctor_feedback)
                if isinstance(parsed, dict):
                    discussed_val = parsed.get("discussed_products")
                    samples_val = parsed.get("samples_given")
                    purchase_opp_val = parsed.get("purchase_opportunity", False)
            except Exception:
                pass

        return VisitRead(
            id=visit.id,
            doctor_id=visit.doctor_id,
            doctor_name=visit.doctor.name if visit.doctor else None,
            clinic_name=visit.doctor.clinic_name if visit.doctor else None,
            specialization=visit.doctor.specialization if visit.doctor else None,
            user_id=visit.user_id,
            visit_datetime=visit.visit_datetime,
            visit_type=visit.visit_type.value if hasattr(visit.visit_type, "value") else str(visit.visit_type),
            doctor_response=visit.doctor_response.value if hasattr(visit.doctor_response, "value") else str(visit.doctor_response),
            prescription_potential=visit.prescription_potential.value if hasattr(visit.prescription_potential, "value") else str(visit.prescription_potential),
            doctor_feedback=visit.doctor_feedback,
            notes=visit.notes,
            discussed_products=discussed_val or visit.notes,
            samples_given=samples_val,
            purchase_opportunity=purchase_opp_val,
            client_operation_id=visit.client_operation_id,
            created_at=visit.created_at,
            updated_at=visit.updated_at,
        )

    async def create_visit(self, data: VisitCreate, current_user: User) -> VisitRead:
        doctor = await self.doctor_repo.get_by_id(data.doctor_id)
        if not doctor:
            raise NotFoundException(f"Doctor '{data.doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA / Territory authorization check
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doctor.area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        # Client operation idempotency
        if data.client_operation_id:
            existing = await self.db.execute(
                select(Visit).options(selectinload(Visit.doctor)).where(Visit.client_operation_id == data.client_operation_id)
            )
            v = existing.scalars().first()
            if v:
                return self._to_read_dto(v)

        # Store metadata in feedback payload
        feedback_payload = json.dumps({
            "discussed_products": data.discussed_products,
            "samples_given": data.samples_given,
            "purchase_opportunity": data.purchase_opportunity,
            "feedback": data.doctor_feedback,
        })

        visit = Visit(
            id=uuid.uuid4(),
            doctor_id=data.doctor_id,
            user_id=current_user.id,
            visit_datetime=data.visit_datetime,
            visit_type=data.visit_type,
            doctor_response=data.doctor_response,
            prescription_potential=data.prescription_potential,
            doctor_feedback=feedback_payload,
            notes=data.notes,
            client_operation_id=data.client_operation_id,
        )

        self.db.add(visit)
        await self.db.flush()

        await self.audit_repo.log_event(
            actor_id=current_user.id,
            action="VISIT_RECORDED",
            entity_type="Visit",
            entity_id=str(visit.id),
            metadata_json={"doctor_id": str(doctor.id), "doctor_name": doctor.name},
        )

        # Re-fetch with relationship
        loaded = await self.db.execute(
            select(Visit).options(selectinload(Visit.doctor)).where(Visit.id == visit.id)
        )
        return self._to_read_dto(loaded.scalars().first())

    async def list_visits(
        self,
        current_user: User,
        doctor_id: Optional[uuid.UUID] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> VisitListResponse:
        query = select(Visit).options(selectinload(Visit.doctor))
        count_query = select(func.count()).select_from(Visit)

        if doctor_id:
            doc = await self.doctor_repo.get_by_id(doctor_id)
            if not doc:
                raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")
            if current_user.role == RoleEnum.MR:
                is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
                if not is_assigned:
                    raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")
            query = query.where(Visit.doctor_id == doctor_id)
            count_query = count_query.where(Visit.doctor_id == doctor_id)
        elif current_user.role == RoleEnum.MR:
            # MR can view visits for doctors in their assigned areas or created by them
            assigned_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
            query = query.join(Doctor, Visit.doctor_id == Doctor.id).where(
                (Doctor.area_id.in_(assigned_area_ids)) | (Visit.user_id == current_user.id)
            )
            count_query = count_query.join(Doctor, Visit.doctor_id == Doctor.id).where(
                (Doctor.area_id.in_(assigned_area_ids)) | (Visit.user_id == current_user.id)
            )

        total_res = await self.db.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * page_size
        query = query.order_by(Visit.visit_datetime.desc()).offset(offset).limit(page_size)
        items_res = await self.db.execute(query)
        visits = items_res.scalars().all()

        return VisitListResponse(
            items=[self._to_read_dto(v) for v in visits],
            total=total,
            page=page,
            page_size=page_size,
        )

    async def get_visit_by_id(self, visit_id: uuid.UUID, current_user: User) -> VisitRead:
        res = await self.db.execute(
            select(Visit).options(selectinload(Visit.doctor)).where(Visit.id == visit_id)
        )
        visit = res.scalars().first()
        if not visit:
            raise NotFoundException(f"Visit '{visit_id}' not found.", code="VISIT_NOT_FOUND")

        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, visit.doctor.area_id)
            if not is_assigned and visit.user_id != current_user.id:
                raise ForbiddenException("Access denied to this visit record.")

        return self._to_read_dto(visit)
