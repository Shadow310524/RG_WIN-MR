import uuid
from typing import Optional, List
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from app.core.exceptions import NotFoundException, ForbiddenException
from app.models.doctor import Doctor
from app.models.sale import Sale, SaleStatusEnum
from app.models.user import User, RoleEnum
from app.repositories.doctor_repo import DoctorRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.sale import SaleCreate, SaleRead, SaleListResponse


class SaleService:
    """
    Business logic and territory authorization (BOLA/IDOR) enforcement for Realized Sales / Purchases.
    Enforces Decimal financial integrity.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)
        self.audit_repo = AuditLogRepository(db)

    def _to_read_dto(self, sale: Sale) -> SaleRead:
        return SaleRead(
            id=sale.id,
            doctor_id=sale.doctor_id,
            doctor_name=sale.doctor.name if sale.doctor else None,
            clinic_name=sale.doctor.clinic_name if sale.doctor else None,
            user_id=sale.user_id,
            sale_date=sale.sale_date,
            status=sale.status,
            purchase_amount=None,
            gst_amount=None,
            total_amount=sale.total_amount,
            notes=None,
            created_at=sale.created_at,
            updated_at=sale.updated_at,
        )

    async def record_sale(self, data: SaleCreate, current_user: User) -> SaleRead:
        doctor = None
        if data.doctor_id:
            doctor = await self.doctor_repo.get_by_id(data.doctor_id)
            if not doctor:
                raise NotFoundException(f"Doctor '{data.doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

            # BOLA / Territory authorization check
            if current_user.role == RoleEnum.MR:
                is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doctor.area_id)
                if not is_assigned:
                    raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        sale = Sale(
            id=uuid.uuid4(),
            doctor_id=data.doctor_id,
            user_id=current_user.id,
            sale_date=data.sale_date,
            status=SaleStatusEnum.CONFIRMED,
            total_amount=Decimal(str(data.total_amount)),
        )

        self.db.add(sale)
        await self.db.flush()

        await self.audit_repo.log_event(
            actor_id=current_user.id,
            action="PURCHASE_RECORDED",
            entity_type="Sale",
            entity_id=str(sale.id),
            metadata_json={
                "doctor_id": str(data.doctor_id) if data.doctor_id else None,
                "total_amount": str(data.total_amount),
            },
        )

        loaded = await self.db.execute(
            select(Sale).options(selectinload(Sale.doctor)).where(Sale.id == sale.id)
        )
        return self._to_read_dto(loaded.scalars().first())

    async def list_sales(
        self,
        current_user: User,
        doctor_id: Optional[uuid.UUID] = None,
        page: int = 1,
        page_size: int = 50,
    ) -> SaleListResponse:
        query = select(Sale).options(selectinload(Sale.doctor))
        count_query = select(func.count()).select_from(Sale)

        if doctor_id:
            doc = await self.doctor_repo.get_by_id(doctor_id)
            if not doc:
                raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")
            if current_user.role == RoleEnum.MR:
                is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
                if not is_assigned:
                    raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")
            query = query.where(Sale.doctor_id == doctor_id)
            count_query = count_query.where(Sale.doctor_id == doctor_id)
        elif current_user.role == RoleEnum.MR:
            assigned_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
            query = query.outerjoin(Doctor, Sale.doctor_id == Doctor.id).where(
                (Doctor.area_id.in_(assigned_area_ids)) | (Sale.user_id == current_user.id)
            )
            count_query = count_query.outerjoin(Doctor, Sale.doctor_id == Doctor.id).where(
                (Doctor.area_id.in_(assigned_area_ids)) | (Sale.user_id == current_user.id)
            )

        total_res = await self.db.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * page_size
        query = query.order_by(Sale.sale_date.desc(), Sale.created_at.desc()).offset(offset).limit(page_size)
        items_res = await self.db.execute(query)
        sales = items_res.scalars().all()

        return SaleListResponse(
            items=[self._to_read_dto(s) for s in sales],
            total=total,
            page=page,
            page_size=page_size,
        )
