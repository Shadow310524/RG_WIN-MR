import uuid
from datetime import datetime, date, timedelta, timezone
from decimal import Decimal
from typing import Optional, List, Dict
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from app.core.exceptions import NotFoundException, ForbiddenException
from app.models.area import Area
from app.models.doctor import Doctor, DoctorStatusEnum
from app.models.sale import Sale, SaleStatusEnum
from app.models.visit import Visit
from app.models.promotional_investment import DoctorPromotionalInvestment
from app.models.user import User, RoleEnum
from app.repositories.doctor_repo import DoctorRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.schemas.analytics import (
    DoctorCommercialSummary,
    DoctorRankItem,
    AreaCommercialSummary,
    OverallCommercialSummary,
    FigureProvenance,
)
from app.schemas.promotional_investment import PromotionalInvestmentRead


def _get_standard_provenance() -> Dict[str, FigureProvenance]:
    return {
        "business_value": FigureProvenance(
            source="RECORDED_PURCHASE",
            status="AUTHORITATIVE",
            description="Sum of realized commercial purchases recorded for doctor/area.",
        ),
        "promotional_investment": FigureProvenance(
            source="EXPLICIT_PROMOTIONAL_INVESTMENT",
            status="AUTHORITATIVE",
            description="Direct monetary investment explicitly entered for doctor (samples, promotional units, free supplies).",
        ),
        "revenue": FigureProvenance(
            source="UNAVAILABLE",
            status="PENDING_BUSINESS_RULES",
            description="Revenue unavailable: Requires authoritative Healix margin and price-to-stockist (PTS) formula.",
        ),
        "commercial_result": FigureProvenance(
            source="INSUFFICIENT_DATA",
            status="PENDING_BUSINESS_RULES",
            description="Commercial result / profit unavailable: Requires product cost to calculate net contribution after promotional spend.",
        ),
        "general_expenses": FigureProvenance(
            source="EXCLUDED_OPERATING_EXPENSE",
            status="SEPARATELY_TRACKED",
            description="General operating expenses (food, fuel, travel) are strictly tracked separately and not deducted from doctor commercial worth.",
        ),
    }


class FinancialAnalyticsService:
    """
    Authoritative Financial Intelligence Engine for RG WIN.
    Aggregates: Doctor -> Area -> Overall Business.
    Enforces Decimal arithmetic, server-side aggregation, and strict data provenance.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)

    async def get_doctor_summary(self, doctor_id: uuid.UUID, current_user: User) -> DoctorCommercialSummary:
        doctor = await self.doctor_repo.get_by_id(doctor_id)
        if not doctor:
            raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA Territory Authorization
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doctor.area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        # 1. Total Purchases / Business Value
        sales_val_res = await self.db.execute(
            select(func.coalesce(func.sum(Sale.total_amount), Decimal("0.00")))
            .where(Sale.doctor_id == doctor_id)
        )
        business_value = sales_val_res.scalar() or Decimal("0.00")

        sales_count_res = await self.db.execute(
            select(func.count()).select_from(Sale).where(Sale.doctor_id == doctor_id)
        )
        purchase_count = sales_count_res.scalar() or 0

        # 2. Total Promotional Investment
        invest_val_res = await self.db.execute(
            select(func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")))
            .where(DoctorPromotionalInvestment.doctor_id == doctor_id)
        )
        promotional_investment = invest_val_res.scalar() or Decimal("0.00")

        # 3. Visits Count
        visits_count_res = await self.db.execute(
            select(func.count()).select_from(Visit).where(Visit.doctor_id == doctor_id)
        )
        visit_count = visits_count_res.scalar() or 0

        # 4. Recent Promotional Investments
        invest_list_res = await self.db.execute(
            select(DoctorPromotionalInvestment)
            .where(DoctorPromotionalInvestment.doctor_id == doctor_id)
            .order_by(DoctorPromotionalInvestment.investment_date.desc(), DoctorPromotionalInvestment.created_at.desc())
            .limit(10)
        )
        recent_investments = [
            PromotionalInvestmentRead(
                id=inv.id,
                doctor_id=inv.doctor_id,
                doctor_name=doctor.name,
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
            for inv in invest_list_res.scalars().all()
        ]

        # Area name lookup
        area_name = None
        if doctor.area_id:
            area_res = await self.db.execute(select(Area.name).where(Area.id == doctor.area_id))
            area_name = area_res.scalar()

        return DoctorCommercialSummary(
            doctor_id=doctor.id,
            doctor_name=doctor.name,
            clinic_name=doctor.clinic_name,
            specialization=doctor.specialization,
            area_id=doctor.area_id,
            area_name=area_name,
            visit_count=visit_count,
            purchase_count=purchase_count,
            business_value=business_value,
            promotional_investment=promotional_investment,
            revenue=None,  # Honest: Revenue unavailable
            commercial_result=None,  # Honest: Insufficient data
            recent_investments=recent_investments,
            provenance=_get_standard_provenance(),
        )

    async def get_area_summary(self, area_id: uuid.UUID, current_user: User) -> AreaCommercialSummary:
        area_res = await self.db.execute(select(Area).where(Area.id == area_id))
        area = area_res.scalars().first()
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        # BOLA Territory Authorization
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Area is outside your assigned territory.")

        # Active doctors in area
        docs_res = await self.db.execute(
            select(Doctor).where(Doctor.area_id == area_id, Doctor.status == DoctorStatusEnum.ACTIVE)
        )
        doctors = docs_res.scalars().all()

        doctor_items: List[DoctorRankItem] = []
        area_business_value = Decimal("0.00")
        area_promotional_investment = Decimal("0.00")

        standard_provenance = _get_standard_provenance()

        for doc in doctors:
            # Sales for doctor
            sales_res = await self.db.execute(
                select(
                    func.coalesce(func.sum(Sale.total_amount), Decimal("0.00")),
                    func.count(Sale.id)
                ).where(Sale.doctor_id == doc.id)
            )
            bv, p_count = sales_res.one()
            bv = bv or Decimal("0.00")
            p_count = p_count or 0

            # Promotional investment for doctor
            invest_res = await self.db.execute(
                select(func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")))
                .where(DoctorPromotionalInvestment.doctor_id == doc.id)
            )
            pi = invest_res.scalar() or Decimal("0.00")

            # Visits count
            visits_res = await self.db.execute(
                select(func.count()).select_from(Visit).where(Visit.doctor_id == doc.id)
            )
            v_count = visits_res.scalar() or 0

            area_business_value += bv
            area_promotional_investment += pi

            doctor_items.append(
                DoctorRankItem(
                    doctor_id=doc.id,
                    doctor_name=doc.name,
                    clinic_name=doc.clinic_name,
                    specialization=doc.specialization,
                    visit_count=v_count,
                    purchase_count=p_count,
                    business_value=bv,
                    promotional_investment=pi,
                    commercial_result=None,
                    provenance=standard_provenance,
                )
            )

        # Rank doctors by business_value descending, then promotional_investment desc
        doctor_items.sort(key=lambda d: (d.business_value, d.promotional_investment), reverse=True)

        return AreaCommercialSummary(
            area_id=area.id,
            area_name=area.name,
            area_code=area.code,
            doctor_count=len(doctors),
            business_value=area_business_value,
            promotional_investment=area_promotional_investment,
            commercial_result=None,
            doctors=doctor_items,
            provenance=standard_provenance,
        )

    async def get_overall_summary(self, current_user: User, period: str = "this_month") -> OverallCommercialSummary:
        # Determine assigned areas for MR
        if current_user.role == RoleEnum.MR:
            assigned_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
        else:
            all_areas_res = await self.db.execute(select(Area.id).where(Area.is_active == True))
            assigned_area_ids = [row[0] for row in all_areas_res.all()]

        # Filter by period date window
        now = datetime.now(timezone.utc)
        today = now.date()
        start_date: Optional[date] = None

        if period == "today":
            start_date = today
        elif period == "this_week":
            start_date = today - timedelta(days=today.weekday())  # Monday
        elif period == "this_month":
            start_date = date(today.year, today.month, 1)
        # "all" leaves start_date as None

        # Build area summaries
        area_summaries: List[AreaCommercialSummary] = []
        all_doctor_items: List[DoctorRankItem] = []
        total_business_value = Decimal("0.00")
        total_promotional_investment = Decimal("0.00")
        total_doctors_count = 0
        total_visits_count = 0
        total_purchases_count = 0

        standard_provenance = _get_standard_provenance()

        for area_id in assigned_area_ids:
            area_summary = await self.get_area_summary(area_id, current_user)
            area_summaries.append(area_summary)
            total_business_value += area_summary.business_value
            total_promotional_investment += area_summary.promotional_investment
            total_doctors_count += area_summary.doctor_count
            all_doctor_items.extend(area_summary.doctors)
            for d in area_summary.doctors:
                total_visits_count += d.visit_count
                total_purchases_count += d.purchase_count

        # Top 10 doctors across all assigned areas
        all_doctor_items.sort(key=lambda d: (d.business_value, d.promotional_investment), reverse=True)
        top_doctors = all_doctor_items[:10]

        return OverallCommercialSummary(
            period=period,
            total_doctors=total_doctors_count,
            total_visits=total_visits_count,
            total_purchases=total_purchases_count,
            business_value=total_business_value,
            promotional_investment=total_promotional_investment,
            revenue=None,  # Honest: Revenue unavailable
            profit_loss=None,  # Honest: Insufficient data
            areas=area_summaries,
            top_doctors=top_doctors,
            provenance=standard_provenance,
        )
