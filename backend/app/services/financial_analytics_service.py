import uuid
from datetime import datetime, date, timedelta, timezone
from decimal import Decimal
from typing import Optional, List, Dict, Set, Tuple
from collections import defaultdict
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from sqlalchemy.orm import selectinload

from app.core.exceptions import NotFoundException, ForbiddenException
from app.models.area import Area, AreaStatusEnum
from app.models.doctor import Doctor, DoctorStatusEnum
from app.models.sale import Sale, SaleStatusEnum
from app.models.visit import Visit, DoctorResponseEnum
from app.models.follow_up import FollowUp, FollowUpStatusEnum
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
    FieldActivitySummary,
    CategoryInvestmentItem,
    TimeTrendPoint,
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
    Authoritative financial and management intelligence service.
    Aggregates doctor-level commercial performance into area and overall rollups.
    Uses bulk grouped queries to completely eliminate N+1 query patterns.
    Enforces honest placeholders (never fake ₹0) and strict data provenance.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)

    def _resolve_period_start_date(self, period: str) -> Optional[date]:
        today = datetime.now(timezone.utc).date()
        if period == "today":
            return today
        elif period == "this_week":
            return today - timedelta(days=today.weekday())  # Monday of current week
        elif period == "this_month":
            return date(today.year, today.month, 1)
        return None  # "all"

    async def get_doctor_summary(
        self,
        doctor_id: uuid.UUID,
        current_user: User,
        period: str = "all",
    ) -> DoctorCommercialSummary:
        doctor = await self.doctor_repo.get_by_id(doctor_id)
        if not doctor:
            raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA Territory Authorization
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doctor.area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Doctor is outside your assigned territory.")

        start_date = self._resolve_period_start_date(period)

        # 1. Total Purchases / Business Value
        sales_val_stmt = select(
            func.coalesce(func.sum(Sale.total_amount), Decimal("0.00")),
            func.count(Sale.id),
            func.max(Sale.sale_date),
        ).where(Sale.doctor_id == doctor_id, Sale.status == SaleStatusEnum.CONFIRMED)
        if start_date:
            sales_val_stmt = sales_val_stmt.where(Sale.sale_date >= start_date)
        sales_res = await self.db.execute(sales_val_stmt)
        business_value, purchase_count, last_purchase_date = sales_res.one()
        business_value = business_value or Decimal("0.00")
        purchase_count = purchase_count or 0

        # 2. Total Promotional Investment
        invest_val_stmt = select(
            func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00"))
        ).where(DoctorPromotionalInvestment.doctor_id == doctor_id)
        if start_date:
            invest_val_stmt = invest_val_stmt.where(DoctorPromotionalInvestment.investment_date >= start_date)
        invest_val_res = await self.db.execute(invest_val_stmt)
        promotional_investment = invest_val_res.scalar() or Decimal("0.00")

        # 3. Visits Count, Last Visit Date & Response Distribution
        visits_count_stmt = select(
            func.count(Visit.id),
            func.max(func.date(Visit.visit_datetime)),
        ).where(Visit.doctor_id == doctor_id)
        if start_date:
            visits_count_stmt = visits_count_stmt.where(func.date(Visit.visit_datetime) >= start_date)
        visits_count_res = await self.db.execute(visits_count_stmt)
        visit_count, last_visit_date = visits_count_res.one()
        visit_count = visit_count or 0

        # Response distribution for this doctor
        resp_stmt = select(
            Visit.doctor_response,
            func.count(Visit.id),
        ).where(Visit.doctor_id == doctor_id)
        if start_date:
            resp_stmt = resp_stmt.where(func.date(Visit.visit_datetime) >= start_date)
        resp_stmt = resp_stmt.group_by(Visit.doctor_response)
        resp_res = await self.db.execute(resp_stmt)
        response_distribution = {str(row[0].value if hasattr(row[0], "value") else row[0]): row[1] for row in resp_res.all()}

        # 4. Pending Follow-ups count
        pending_followup_stmt = select(func.count(FollowUp.id)).where(
            FollowUp.doctor_id == doctor_id,
            FollowUp.status == FollowUpStatusEnum.PENDING,
        )
        pending_followup_res = await self.db.execute(pending_followup_stmt)
        pending_followup_count = pending_followup_res.scalar() or 0

        # 5. Attention Signals
        attention_signals: List[str] = []
        if visit_count > 0 and purchase_count == 0:
            attention_signals.append("NO_PURCHASE_RECENTLY")
        if promotional_investment > Decimal("0.00") and (business_value == Decimal("0.00") or promotional_investment > business_value):
            attention_signals.append("HIGH_PROMO_SPEND")
        if response_distribution.get("PRESCRIBING", 0) > 0 or business_value >= Decimal("5000.00"):
            attention_signals.append("TOP_PRESCRIBER")
        if pending_followup_count > 0:
            attention_signals.append("PENDING_FOLLOWUP")

        # 6. Recent Promotional Investments
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
            attention_signals=attention_signals,
            last_visit_date=last_visit_date,
            last_purchase_date=last_purchase_date,
            response_distribution=response_distribution,
            recent_investments=recent_investments,
            provenance=_get_standard_provenance(),
        )

    async def get_area_summary(
        self,
        area_id: uuid.UUID,
        current_user: User,
        period: str = "all",
    ) -> AreaCommercialSummary:
        area_res = await self.db.execute(select(Area).where(Area.id == area_id))
        area = area_res.scalars().first()
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        # BOLA Territory Authorization
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, area_id)
            if not is_assigned:
                raise ForbiddenException("Access denied. Area is outside your assigned territory.")

        start_date = self._resolve_period_start_date(period)

        # Retrieve active doctors in this area
        docs_res = await self.db.execute(
            select(Doctor).where(Doctor.area_id == area_id, Doctor.status == DoctorStatusEnum.ACTIVE)
        )
        doctors = docs_res.scalars().all()
        doctor_ids = [d.id for d in doctors]

        standard_provenance = _get_standard_provenance()

        if not doctor_ids:
            return AreaCommercialSummary(
                area_id=area.id,
                area_name=area.name,
                area_code=area.code,
                doctor_count=0,
                visits_count=0,
                purchase_count=0,
                avg_purchase_value=Decimal("0.00"),
                business_value=Decimal("0.00"),
                promotional_investment=Decimal("0.00"),
                commercial_result=None,
                response_distribution={},
                doctors=[],
                provenance=standard_provenance,
            )

        # Bulk SQL 1: Sales grouped by doctor
        sales_stmt = select(
            Sale.doctor_id,
            func.coalesce(func.sum(Sale.total_amount), Decimal("0.00")),
            func.count(Sale.id),
            func.max(Sale.sale_date),
        ).where(
            Sale.doctor_id.in_(doctor_ids),
            Sale.status == SaleStatusEnum.CONFIRMED,
        )
        if start_date:
            sales_stmt = sales_stmt.where(Sale.sale_date >= start_date)
        sales_stmt = sales_stmt.group_by(Sale.doctor_id)
        sales_res = await self.db.execute(sales_stmt)
        sales_map = {row[0]: (row[1], row[2], row[3]) for row in sales_res.all()}

        # Bulk SQL 2: Promotional investments grouped by doctor
        invest_stmt = select(
            DoctorPromotionalInvestment.doctor_id,
            func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")),
        ).where(DoctorPromotionalInvestment.doctor_id.in_(doctor_ids))
        if start_date:
            invest_stmt = invest_stmt.where(DoctorPromotionalInvestment.investment_date >= start_date)
        invest_stmt = invest_stmt.group_by(DoctorPromotionalInvestment.doctor_id)
        invest_res = await self.db.execute(invest_stmt)
        invest_map = {row[0]: row[1] for row in invest_res.all()}

        # Bulk SQL 3: Visits grouped by doctor
        visits_stmt = select(
            Visit.doctor_id,
            func.count(Visit.id),
            func.max(func.date(Visit.visit_datetime)),
        ).where(Visit.doctor_id.in_(doctor_ids))
        if start_date:
            visits_stmt = visits_stmt.where(func.date(Visit.visit_datetime) >= start_date)
        visits_stmt = visits_stmt.group_by(Visit.doctor_id)
        visits_res = await self.db.execute(visits_stmt)
        visits_map = {row[0]: (row[1], row[2]) for row in visits_res.all()}

        # Bulk SQL 4: Pending Follow-ups grouped by doctor
        followup_stmt = select(
            FollowUp.doctor_id,
            func.count(FollowUp.id),
        ).where(
            FollowUp.doctor_id.in_(doctor_ids),
            FollowUp.status == FollowUpStatusEnum.PENDING,
        ).group_by(FollowUp.doctor_id)
        followup_res = await self.db.execute(followup_stmt)
        followup_map = {row[0]: row[1] for row in followup_res.all()}

        # Bulk SQL 5: Doctor Response distribution in this area
        resp_stmt = select(
            Visit.doctor_response,
            func.count(Visit.id),
        ).where(Visit.doctor_id.in_(doctor_ids))
        if start_date:
            resp_stmt = resp_stmt.where(func.date(Visit.visit_datetime) >= start_date)
        resp_stmt = resp_stmt.group_by(Visit.doctor_response)
        resp_res = await self.db.execute(resp_stmt)
        response_distribution = {str(row[0].value if hasattr(row[0], "value") else row[0]): row[1] for row in resp_res.all()}

        # Check prescribing doctors
        prescribing_docs_stmt = select(Visit.doctor_id).where(
            Visit.doctor_id.in_(doctor_ids),
            Visit.doctor_response == DoctorResponseEnum.PRESCRIBING,
        ).distinct()
        prescribing_docs_res = await self.db.execute(prescribing_docs_stmt)
        prescribing_doctor_ids = set(prescribing_docs_res.scalars().all())

        area_business_value = Decimal("0.00")
        area_promotional_investment = Decimal("0.00")
        area_visits_count = 0
        area_purchases_count = 0
        doctor_items: List[DoctorRankItem] = []

        for doc in doctors:
            bv, p_count, last_p_date = sales_map.get(doc.id, (Decimal("0.00"), 0, None))
            pi = invest_map.get(doc.id, Decimal("0.00"))
            v_count, last_v_date = visits_map.get(doc.id, (0, None))
            p_followup = followup_map.get(doc.id, 0)

            area_business_value += bv
            area_promotional_investment += pi
            area_visits_count += v_count
            area_purchases_count += p_count

            # Attention signals
            signals: List[str] = []
            if v_count > 0 and p_count == 0:
                signals.append("NO_PURCHASE_RECENTLY")
            if pi > Decimal("0.00") and (bv == Decimal("0.00") or pi > bv):
                signals.append("HIGH_PROMO_SPEND")
            if doc.id in prescribing_doctor_ids or bv >= Decimal("5000.00"):
                signals.append("TOP_PRESCRIBER")
            if p_followup > 0:
                signals.append("PENDING_FOLLOWUP")

            doctor_items.append(
                DoctorRankItem(
                    doctor_id=doc.id,
                    doctor_name=doc.name,
                    clinic_name=doc.clinic_name,
                    specialization=doc.specialization,
                    area_id=area.id,
                    area_name=area.name,
                    visit_count=v_count,
                    purchase_count=p_count,
                    business_value=bv,
                    promotional_investment=pi,
                    commercial_result=None,
                    attention_signals=signals,
                    last_visit_date=last_v_date,
                    last_purchase_date=last_p_date,
                    provenance=standard_provenance,
                )
            )

        # Rank doctors by business_value descending, then promotional_investment desc
        doctor_items.sort(key=lambda d: (d.business_value, d.promotional_investment), reverse=True)

        avg_purchase_val = (
            (area_business_value / Decimal(area_purchases_count)).quantize(Decimal("0.01"))
            if area_purchases_count > 0
            else Decimal("0.00")
        )

        return AreaCommercialSummary(
            area_id=area.id,
            area_name=area.name,
            area_code=area.code,
            doctor_count=len(doctors),
            visits_count=area_visits_count,
            purchase_count=area_purchases_count,
            avg_purchase_value=avg_purchase_val,
            business_value=area_business_value,
            promotional_investment=area_promotional_investment,
            commercial_result=None,
            response_distribution=response_distribution,
            doctors=doctor_items,
            provenance=standard_provenance,
        )

    async def get_overall_summary(self, current_user: User, period: str = "this_month") -> OverallCommercialSummary:
        # 1. Determine assigned areas for MR vs Admin
        if current_user.role == RoleEnum.MR:
            assigned_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
        else:
            all_areas_res = await self.db.execute(select(Area.id).where(Area.status == AreaStatusEnum.ACTIVE))
            assigned_area_ids = [row[0] for row in all_areas_res.all()]

        standard_provenance = _get_standard_provenance()

        if not assigned_area_ids:
            return OverallCommercialSummary(
                period=period,
                field_activity=FieldActivitySummary(),
                total_doctors=0,
                total_visits=0,
                total_purchases=0,
                business_value=Decimal("0.00"),
                promotional_investment=Decimal("0.00"),
                revenue=None,
                profit_loss=None,
                response_distribution={},
                category_investments=[],
                trends=[],
                areas=[],
                top_doctors=[],
                high_promo_doctors=[],
                attention_doctors=[],
                provenance=standard_provenance,
            )

        # 2. Fetch all assigned Areas and their Doctors
        areas_res = await self.db.execute(
            select(Area).where(Area.id.in_(assigned_area_ids), Area.status == AreaStatusEnum.ACTIVE)
        )
        areas_list = areas_res.scalars().all()
        area_map = {a.id: a for a in areas_list}

        docs_res = await self.db.execute(
            select(Doctor).where(Doctor.area_id.in_(assigned_area_ids), Doctor.status == DoctorStatusEnum.ACTIVE)
        )
        doctors = docs_res.scalars().all()
        doctor_ids = [d.id for d in doctors]

        start_date = self._resolve_period_start_date(period)

        # Initialize aggregations if no doctors
        if not doctor_ids:
            empty_areas = [
                AreaCommercialSummary(
                    area_id=a.id,
                    area_name=a.name,
                    area_code=a.code,
                    doctor_count=0,
                    visits_count=0,
                    purchase_count=0,
                    avg_purchase_value=Decimal("0.00"),
                    business_value=Decimal("0.00"),
                    promotional_investment=Decimal("0.00"),
                    commercial_result=None,
                    response_distribution={},
                    doctors=[],
                    provenance=standard_provenance,
                )
                for a in areas_list
            ]
            return OverallCommercialSummary(
                period=period,
                field_activity=FieldActivitySummary(total_doctors=0),
                total_doctors=0,
                total_visits=0,
                total_purchases=0,
                business_value=Decimal("0.00"),
                promotional_investment=Decimal("0.00"),
                revenue=None,
                profit_loss=None,
                response_distribution={},
                category_investments=[],
                trends=[],
                areas=empty_areas,
                top_doctors=[],
                high_promo_doctors=[],
                attention_doctors=[],
                provenance=standard_provenance,
            )

        # BULK SQL 1: Sales grouped by doctor (Zero N+1)
        sales_stmt = select(
            Sale.doctor_id,
            func.coalesce(func.sum(Sale.total_amount), Decimal("0.00")),
            func.count(Sale.id),
            func.max(Sale.sale_date),
        ).where(
            Sale.doctor_id.in_(doctor_ids),
            Sale.status == SaleStatusEnum.CONFIRMED,
        )
        if start_date:
            sales_stmt = sales_stmt.where(Sale.sale_date >= start_date)
        sales_stmt = sales_stmt.group_by(Sale.doctor_id)
        sales_res = await self.db.execute(sales_stmt)
        sales_map = {row[0]: (row[1], row[2], row[3]) for row in sales_res.all()}

        # BULK SQL 2: Promotional Investment grouped by doctor (Zero N+1)
        invest_stmt = select(
            DoctorPromotionalInvestment.doctor_id,
            func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")),
        ).where(DoctorPromotionalInvestment.doctor_id.in_(doctor_ids))
        if start_date:
            invest_stmt = invest_stmt.where(DoctorPromotionalInvestment.investment_date >= start_date)
        invest_stmt = invest_stmt.group_by(DoctorPromotionalInvestment.doctor_id)
        invest_res = await self.db.execute(invest_stmt)
        invest_map = {row[0]: row[1] for row in invest_res.all()}

        # BULK SQL 3: Visits grouped by doctor (Zero N+1)
        visits_stmt = select(
            Visit.doctor_id,
            func.count(Visit.id),
            func.max(func.date(Visit.visit_datetime)),
        ).where(Visit.doctor_id.in_(doctor_ids))
        if start_date:
            visits_stmt = visits_stmt.where(func.date(Visit.visit_datetime) >= start_date)
        visits_stmt = visits_stmt.group_by(Visit.doctor_id)
        visits_res = await self.db.execute(visits_stmt)
        visits_map = {row[0]: (row[1], row[2]) for row in visits_res.all()}

        # BULK SQL 4: Pending Follow-ups grouped by doctor (Zero N+1)
        followup_stmt = select(
            FollowUp.doctor_id,
            func.count(FollowUp.id),
        ).where(
            FollowUp.doctor_id.in_(doctor_ids),
            FollowUp.status == FollowUpStatusEnum.PENDING,
        ).group_by(FollowUp.doctor_id)
        followup_res = await self.db.execute(followup_stmt)
        followup_map = {row[0]: row[1] for row in followup_res.all()}

        # BULK SQL 5: Doctor Response distribution overall and by area (Zero N+1)
        resp_stmt = select(
            Visit.doctor_id,
            Visit.doctor_response,
            func.count(Visit.id),
        ).where(Visit.doctor_id.in_(doctor_ids))
        if start_date:
            resp_stmt = resp_stmt.where(func.date(Visit.visit_datetime) >= start_date)
        resp_stmt = resp_stmt.group_by(Visit.doctor_id, Visit.doctor_response)
        resp_res = await self.db.execute(resp_stmt)

        overall_response_distribution: Dict[str, int] = defaultdict(int)
        doctor_responses: Dict[uuid.UUID, Set[str]] = defaultdict(set)
        area_response_distribution: Dict[uuid.UUID, Dict[str, int]] = defaultdict(lambda: defaultdict(int))

        # Build doc_to_area mapping
        doc_to_area = {d.id: d.area_id for d in doctors}

        for doc_id, response_enum, count in resp_res.all():
            resp_key = str(response_enum.value if hasattr(response_enum, "value") else response_enum)
            overall_response_distribution[resp_key] += count
            doctor_responses[doc_id].add(resp_key)
            if doc_id in doc_to_area and doc_to_area[doc_id]:
                area_response_distribution[doc_to_area[doc_id]][resp_key] += count

        # BULK SQL 6: Promotional Investment by Category (Zero N+1)
        cat_stmt = select(
            DoctorPromotionalInvestment.investment_type,
            func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")),
            func.count(DoctorPromotionalInvestment.id),
        ).where(DoctorPromotionalInvestment.doctor_id.in_(doctor_ids))
        if start_date:
            cat_stmt = cat_stmt.where(DoctorPromotionalInvestment.investment_date >= start_date)
        cat_stmt = cat_stmt.group_by(DoctorPromotionalInvestment.investment_type)
        cat_res = await self.db.execute(cat_stmt)
        category_investments = [
            CategoryInvestmentItem(
                investment_type=str(row[0].value if hasattr(row[0], "value") else row[0]),
                total_amount=row[1] or Decimal("0.00"),
                count=row[2] or 0,
            )
            for row in cat_res.all()
        ]
        category_investments.sort(key=lambda c: c.total_amount, reverse=True)

        # BULK SQL 7: 4-Week Time Trends (Zero N+1)
        today = datetime.now(timezone.utc).date()
        week_ranges: List[Tuple[str, date, date]] = [
            ("3 wks ago", today - timedelta(days=27), today - timedelta(days=21)),
            ("2 wks ago", today - timedelta(days=20), today - timedelta(days=14)),
            ("Last week", today - timedelta(days=13), today - timedelta(days=7)),
            ("This week", today - timedelta(days=6), today),
        ]

        # Bulk query for visits across the 28 days
        trend_min_date = today - timedelta(days=27)
        trend_visits_stmt = select(
            func.date(Visit.visit_datetime),
            func.count(Visit.id),
        ).where(
            Visit.doctor_id.in_(doctor_ids),
            func.date(Visit.visit_datetime) >= trend_min_date,
        ).group_by(func.date(Visit.visit_datetime))
        trend_visits_res = await self.db.execute(trend_visits_stmt)
        daily_visits = {row[0]: row[1] for row in trend_visits_res.all()}

        # Bulk query for purchases across the 28 days
        trend_sales_stmt = select(
            Sale.sale_date,
            func.coalesce(func.sum(Sale.total_amount), Decimal("0.00")),
        ).where(
            Sale.doctor_id.in_(doctor_ids),
            Sale.sale_date >= trend_min_date,
            Sale.status == SaleStatusEnum.CONFIRMED,
        ).group_by(Sale.sale_date)
        trend_sales_res = await self.db.execute(trend_sales_stmt)
        daily_sales = {row[0]: row[1] for row in trend_sales_res.all()}

        # Bulk query for promo investments across the 28 days
        trend_invest_stmt = select(
            DoctorPromotionalInvestment.investment_date,
            func.coalesce(func.sum(DoctorPromotionalInvestment.amount), Decimal("0.00")),
        ).where(
            DoctorPromotionalInvestment.doctor_id.in_(doctor_ids),
            DoctorPromotionalInvestment.investment_date >= trend_min_date,
        ).group_by(DoctorPromotionalInvestment.investment_date)
        trend_invest_res = await self.db.execute(trend_invest_stmt)
        daily_invest = {row[0]: row[1] for row in trend_invest_res.all()}

        trends: List[TimeTrendPoint] = []
        for label, w_start, w_end in week_ranges:
            w_visits = 0
            w_sales = Decimal("0.00")
            w_invest = Decimal("0.00")
            curr = w_start
            while curr <= w_end:
                w_visits += daily_visits.get(curr, 0)
                w_sales += daily_sales.get(curr, Decimal("0.00"))
                w_invest += daily_invest.get(curr, Decimal("0.00"))
                curr += timedelta(days=1)
            trends.append(
                TimeTrendPoint(
                    label=label,
                    start_date=w_start,
                    end_date=w_end,
                    visits_count=w_visits,
                    purchase_amount=w_sales,
                    promo_amount=w_invest,
                )
            )

        # Assemble Doctors & Area Summaries
        area_doc_map: Dict[uuid.UUID, List[DoctorRankItem]] = defaultdict(list)
        all_doctor_items: List[DoctorRankItem] = []
        total_business_value = Decimal("0.00")
        total_promotional_investment = Decimal("0.00")
        total_visits_count = 0
        total_purchases_count = 0
        total_pending_followups = sum(followup_map.values())

        for doc in doctors:
            bv, p_count, last_p_date = sales_map.get(doc.id, (Decimal("0.00"), 0, None))
            pi = invest_map.get(doc.id, Decimal("0.00"))
            v_count, last_v_date = visits_map.get(doc.id, (0, None))
            p_followup = followup_map.get(doc.id, 0)

            total_business_value += bv
            total_promotional_investment += pi
            total_visits_count += v_count
            total_purchases_count += p_count

            # Doctor signals
            signals: List[str] = []
            if v_count > 0 and p_count == 0:
                signals.append("NO_PURCHASE_RECENTLY")
            if pi > Decimal("0.00") and (bv == Decimal("0.00") or pi > bv):
                signals.append("HIGH_PROMO_SPEND")
            if "PRESCRIBING" in doctor_responses[doc.id] or bv >= Decimal("5000.00"):
                signals.append("TOP_PRESCRIBER")
            if p_followup > 0:
                signals.append("PENDING_FOLLOWUP")

            area_obj = area_map.get(doc.area_id)
            rank_item = DoctorRankItem(
                doctor_id=doc.id,
                doctor_name=doc.name,
                clinic_name=doc.clinic_name,
                specialization=doc.specialization,
                area_id=doc.area_id,
                area_name=area_obj.name if area_obj else None,
                visit_count=v_count,
                purchase_count=p_count,
                business_value=bv,
                promotional_investment=pi,
                commercial_result=None,
                attention_signals=signals,
                last_visit_date=last_v_date,
                last_purchase_date=last_p_date,
                provenance=standard_provenance,
            )
            area_doc_map[doc.area_id].append(rank_item)
            all_doctor_items.append(rank_item)

        # Build area summaries
        area_summaries: List[AreaCommercialSummary] = []
        for area in areas_list:
            area_docs = area_doc_map.get(area.id, [])
            area_docs.sort(key=lambda d: (d.business_value, d.promotional_investment), reverse=True)
            a_bv = sum((d.business_value for d in area_docs), Decimal("0.00"))
            a_pi = sum((d.promotional_investment for d in area_docs), Decimal("0.00"))
            a_vc = sum(d.visit_count for d in area_docs)
            a_pc = sum(d.purchase_count for d in area_docs)
            a_avg = (a_bv / Decimal(a_pc)).quantize(Decimal("0.01")) if a_pc > 0 else Decimal("0.00")

            area_summaries.append(
                AreaCommercialSummary(
                    area_id=area.id,
                    area_name=area.name,
                    area_code=area.code,
                    doctor_count=len(area_docs),
                    visits_count=a_vc,
                    purchase_count=a_pc,
                    avg_purchase_value=a_avg,
                    business_value=a_bv,
                    promotional_investment=a_pi,
                    commercial_result=None,
                    response_distribution=dict(area_response_distribution[area.id]),
                    doctors=area_docs,
                    provenance=standard_provenance,
                )
            )

        # Rank areas by business value
        area_summaries.sort(key=lambda a: a.business_value, reverse=True)

        # Filter doctor lists
        # Top 10 by business value
        top_doctors = sorted(all_doctor_items, key=lambda d: (d.business_value, d.promotional_investment), reverse=True)[:10]

        # High promo doctors (sorted by promo spend)
        high_promo_doctors = sorted(
            [d for d in all_doctor_items if d.promotional_investment > Decimal("0.00")],
            key=lambda d: d.promotional_investment,
            reverse=True,
        )[:10]

        # Attention doctors (has at least one attention signal)
        attention_doctors = [
            d for d in all_doctor_items
            if any(s in d.attention_signals for s in ["NO_PURCHASE_RECENTLY", "HIGH_PROMO_SPEND", "PENDING_FOLLOWUP"])
        ]
        attention_doctors.sort(key=lambda d: (len(d.attention_signals), d.promotional_investment), reverse=True)

        field_activity = FieldActivitySummary(
            total_doctors=len(doctors),
            total_visits=total_visits_count,
            total_purchases=total_purchases_count,
            pending_followups=total_pending_followups,
        )

        return OverallCommercialSummary(
            period=period,
            field_activity=field_activity,
            total_doctors=len(doctors),
            total_visits=total_visits_count,
            total_purchases=total_purchases_count,
            business_value=total_business_value,
            promotional_investment=total_promotional_investment,
            revenue=None,  # Honest: Revenue unavailable
            profit_loss=None,  # Honest: Insufficient data
            response_distribution=dict(overall_response_distribution),
            category_investments=category_investments,
            trends=trends,
            areas=area_summaries,
            top_doctors=top_doctors,
            high_promo_doctors=high_promo_doctors,
            attention_doctors=attention_doctors,
            provenance=standard_provenance,
        )
