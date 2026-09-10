import uuid
from decimal import Decimal
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from app.core.exceptions import NotFoundException, ForbiddenException, BadRequestException
from app.models.doctor import Doctor
from app.models.visit import Visit
from app.models.promotional_investment import DoctorPromotionalInvestment, PromotionalInvestmentTypeEnum
from app.models.user import User, RoleEnum
from app.repositories.doctor_repo import DoctorRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.promotional_investment import (
    PromotionalInvestmentCreate,
    PromotionalInvestmentRead,
    PromotionalInvestmentListResponse,
)


class PromotionalInvestmentService:
    """
    Authoritative service enforcing Decimal precision, BOLA territory authorization,
    and audit logging for Doctor-specific Promotional Investments.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)
        self.audit_repo = AuditLogRepository(db)

    def _to_read_dto(self, inv: DoctorPromotionalInvestment) -> PromotionalInvestmentRead:
        return PromotionalInvestmentRead(
            id=inv.id,
            doctor_id=inv.doctor_id,
            doctor_name=inv.doctor.name if inv.doctor else None,
            visit_id=inv.visit_id,
            user_id=inv.user_id,
            amount=inv.amount,
            investment_type=inv.investment_type,
            investment_date=inv.investment_date,
            notes=inv.notes,
            client_operation_id=inv.client_operation_id,
            created_at=inv.created_at,
            updated_at=inv.updated_at,
            provenance_source="EXPLICIT_PROMOTIONAL_INVESTMENT",
        )

    async def record_investment(
        self, data: PromotionalInvestmentCreate, current_user: User
    ) -> PromotionalInvestmentRead:
        if data.amount <= Decimal("0.00"):
            raise BadRequestException("Promotional investment amount must be greater than zero.", code="INVALID_AMOUNT")

        # 1. Verify doctor existence
        doctor = await self.doctor_repo.get_by_id(data.doctor_id)
        if not doctor:
            raise NotFoundException(f"Doctor '{data.doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # 2. BOLA Territory Authorization
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doctor.area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        # 3. Optional visit validation
        if data.visit_id:
            visit_res = await self.db.execute(select(Visit).where(Visit.id == data.visit_id))
            visit = visit_res.scalars().first()
            if not visit:
                raise NotFoundException(f"Visit '{data.visit_id}' not found.", code="VISIT_NOT_FOUND")
            if visit.doctor_id != data.doctor_id:
                raise BadRequestException("Visit does not belong to the specified doctor.", code="VISIT_DOCTOR_MISMATCH")

        # 4. Check idempotency for offline sync
        if data.client_operation_id:
            existing = await self.db.execute(
                select(DoctorPromotionalInvestment).where(
                    DoctorPromotionalInvestment.client_operation_id == data.client_operation_id
                )
            )
            found = existing.scalars().first()
            if found:
                loaded = await self.db.execute(
                    select(DoctorPromotionalInvestment)
                    .options(selectinload(DoctorPromotionalInvestment.doctor))
                    .where(DoctorPromotionalInvestment.id == found.id)
                )
                return self._to_read_dto(loaded.scalars().first())

        investment = DoctorPromotionalInvestment(
            id=uuid.uuid4(),
            doctor_id=data.doctor_id,
            visit_id=data.visit_id,
            user_id=current_user.id,
            amount=data.amount,
            investment_type=data.investment_type,
            investment_date=data.investment_date,
            notes=data.notes,
            client_operation_id=data.client_operation_id,
        )

        self.db.add(investment)
        await self.db.flush()

        await self.audit_repo.log_event(
            actor_id=current_user.id,
            action="PROMOTIONAL_INVESTMENT_CREATED",
            entity_type="DoctorPromotionalInvestment",
            entity_id=str(investment.id),
            metadata_json={
                "doctor_id": str(data.doctor_id),
                "visit_id": str(data.visit_id) if data.visit_id else None,
                "amount": str(data.amount),
                "type": data.investment_type.value,
            },
        )

        loaded = await self.db.execute(
            select(DoctorPromotionalInvestment)
            .options(selectinload(DoctorPromotionalInvestment.doctor))
            .where(DoctorPromotionalInvestment.id == investment.id)
        )
        return self._to_read_dto(loaded.scalars().first())

    async def list_investments(
        self,
        current_user: User,
        doctor_id: Optional[uuid.UUID] = None,
        visit_id: Optional[uuid.UUID] = None,
        page: int = 1,
        page_size: int = 50,
    ) -> PromotionalInvestmentListResponse:
        query = select(DoctorPromotionalInvestment).options(selectinload(DoctorPromotionalInvestment.doctor))
        count_query = select(func.count()).select_from(DoctorPromotionalInvestment)
        sum_query = select(func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")))

        if doctor_id:
            doc = await self.doctor_repo.get_by_id(doctor_id)
            if not doc:
                raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")
            if current_user.role == RoleEnum.MR:
                is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
                if not is_assigned:
                    raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")
            query = query.where(DoctorPromotionalInvestment.doctor_id == doctor_id)
            count_query = count_query.where(DoctorPromotionalInvestment.doctor_id == doctor_id)
            sum_query = sum_query.where(DoctorPromotionalInvestment.doctor_id == doctor_id)
        elif current_user.role == RoleEnum.MR:
            assigned_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
            query = query.join(Doctor, DoctorPromotionalInvestment.doctor_id == Doctor.id).where(
                Doctor.area_id.in_(assigned_area_ids)
            )
            count_query = count_query.join(Doctor, DoctorPromotionalInvestment.doctor_id == Doctor.id).where(
                Doctor.area_id.in_(assigned_area_ids)
            )
            sum_query = sum_query.join(Doctor, DoctorPromotionalInvestment.doctor_id == Doctor.id).where(
                Doctor.area_id.in_(assigned_area_ids)
            )

        if visit_id:
            query = query.where(DoctorPromotionalInvestment.visit_id == visit_id)
            count_query = count_query.where(DoctorPromotionalInvestment.visit_id == visit_id)
            sum_query = sum_query.where(DoctorPromotionalInvestment.visit_id == visit_id)

        total_res = await self.db.execute(count_query)
        total = total_res.scalar() or 0

        total_amt_res = await self.db.execute(sum_query)
        total_amount = total_amt_res.scalar() or Decimal("0.00")

        offset = (page - 1) * page_size
        query = query.order_by(
            DoctorPromotionalInvestment.investment_date.desc(),
            DoctorPromotionalInvestment.created_at.desc(),
        ).offset(offset).limit(page_size)

        items_res = await self.db.execute(query)
        investments = items_res.scalars().all()

        return PromotionalInvestmentListResponse(
            items=[self._to_read_dto(inv) for inv in investments],
            total=total,
            total_amount=total_amount,
            page=page,
            page_size=page_size,
        )

    async def delete_investment(self, investment_id: uuid.UUID, current_user: User) -> bool:
        inv_res = await self.db.execute(
            select(DoctorPromotionalInvestment)
            .options(selectinload(DoctorPromotionalInvestment.doctor))
            .where(DoctorPromotionalInvestment.id == investment_id)
        )
        investment = inv_res.scalars().first()
        if not investment:
            raise NotFoundException(f"Promotional investment '{investment_id}' not found.", code="INVESTMENT_NOT_FOUND")

        # BOLA Territory Authorization
        if current_user.role == RoleEnum.MR and investment.doctor:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, investment.doctor.area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        await self.audit_repo.log_event(
            actor_id=current_user.id,
            action="PROMOTIONAL_INVESTMENT_DELETED",
            entity_type="DoctorPromotionalInvestment",
            entity_id=str(investment.id),
            metadata_json={
                "doctor_id": str(investment.doctor_id),
                "amount": str(investment.amount),
            },
        )

        await self.db.delete(investment)
        await self.db.flush()
        return True
