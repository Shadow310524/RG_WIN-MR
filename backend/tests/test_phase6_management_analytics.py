import uuid
from datetime import date, datetime, timezone, timedelta
from decimal import Decimal
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.area import Area
from app.models.mr_assignment import MRAreaAssignment
from app.models.doctor import Doctor, DoctorStatusEnum
from app.models.sale import Sale, SaleStatusEnum
from app.models.visit import Visit, VisitTypeEnum, DoctorResponseEnum, PrescriptionPotentialEnum
from app.models.follow_up import FollowUp, FollowUpStatusEnum
from app.models.promotional_investment import DoctorPromotionalInvestment, PromotionalInvestmentTypeEnum
from app.models.user import User, RoleEnum, UserStatusEnum
from app.core.security import hash_password, create_access_token


@pytest_asyncio.fixture
async def seed_analytics_env(db_session: AsyncSession):
    # 1. Users
    mr_user = User(
        id=uuid.uuid4(),
        email="mr_analytics@healix.com",
        password_hash=hash_password("AnalyticsPass123!"),
        full_name="Analytics MR",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    unauth_mr = User(
        id=uuid.uuid4(),
        email="unauth_mr@healix.com",
        password_hash=hash_password("AnalyticsPass123!"),
        full_name="Other MR",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    db_session.add_all([mr_user, unauth_mr])

    # 2. Areas
    assigned_area = Area(id=uuid.uuid4(), name="Metro Central", code="METRO-01")
    unassigned_area = Area(id=uuid.uuid4(), name="Metro West", code="METRO-02")
    db_session.add_all([assigned_area, unassigned_area])
    await db_session.flush()

    # 3. Territory assignment
    db_session.add(MRAreaAssignment(
        id=uuid.uuid4(),
        mr_id=mr_user.id,
        area_id=assigned_area.id,
        is_active=True,
    ))

    # 4. Doctors
    # doc1: High business value, top prescriber
    doc1 = Doctor(
        id=uuid.uuid4(),
        name="Dr. Rajesh Kumar",
        phone="+919876540001",
        medical_license_number="ANL-LIC-001",
        specialization="Cardiology",
        clinic_name="Heart Care Clinic",
        area_id=assigned_area.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    # doc2: High promo spend, 0 purchases -> attention signal HIGH_PROMO_SPEND
    doc2 = Doctor(
        id=uuid.uuid4(),
        name="Dr. Ananya Sen",
        phone="+919876540002",
        medical_license_number="ANL-LIC-002",
        specialization="Neurology",
        clinic_name="Brain Wellness",
        area_id=assigned_area.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    # doc3: Unassigned area doctor
    doc_unassigned = Doctor(
        id=uuid.uuid4(),
        name="Dr. Unassigned Doc",
        phone="+919876540003",
        medical_license_number="ANL-LIC-003",
        specialization="General",
        clinic_name="West Clinic",
        area_id=unassigned_area.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    db_session.add_all([doc1, doc2, doc_unassigned])
    await db_session.flush()

    today = datetime.now(timezone.utc).date()

    # 5. Visits
    v1 = Visit(
        id=uuid.uuid4(),
        doctor_id=doc1.id,
        user_id=mr_user.id,
        visit_datetime=datetime.now(timezone.utc) - timedelta(days=2),
        visit_type=VisitTypeEnum.REGULAR_VISIT,
        doctor_response=DoctorResponseEnum.PRESCRIBING,
        prescription_potential=PrescriptionPotentialEnum.HIGH,
    )
    v2 = Visit(
        id=uuid.uuid4(),
        doctor_id=doc2.id,
        user_id=mr_user.id,
        visit_datetime=datetime.now(timezone.utc) - timedelta(days=5),
        visit_type=VisitTypeEnum.PRODUCT_DISCUSSION,
        doctor_response=DoctorResponseEnum.HESITANT,
        prescription_potential=PrescriptionPotentialEnum.LOW,
    )
    db_session.add_all([v1, v2])

    # 6. Sales
    s1 = Sale(
        id=uuid.uuid4(),
        doctor_id=doc1.id,
        user_id=mr_user.id,
        sale_date=today - timedelta(days=1),
        status=SaleStatusEnum.CONFIRMED,
        total_amount=Decimal("12500.00"),
    )
    db_session.add(s1)

    # 7. Promotional Investments
    p1 = DoctorPromotionalInvestment(
        id=uuid.uuid4(),
        doctor_id=doc1.id,
        user_id=mr_user.id,
        amount=Decimal("1200.00"),
        investment_type=PromotionalInvestmentTypeEnum.SAMPLE,
        investment_date=today - timedelta(days=2),
        notes="High-potency samples",
    )
    p2 = DoctorPromotionalInvestment(
        id=uuid.uuid4(),
        doctor_id=doc2.id,
        user_id=mr_user.id,
        amount=Decimal("2500.00"),
        investment_type=PromotionalInvestmentTypeEnum.PROMOTIONAL_UNIT,
        investment_date=today - timedelta(days=5),
        notes="Display stand & brochures",
    )
    db_session.add_all([p1, p2])

    # 8. Follow-up
    f1 = FollowUp(
        id=uuid.uuid4(),
        doctor_id=doc2.id,
        assigned_user_id=mr_user.id,
        due_date=today + timedelta(days=3),
        status=FollowUpStatusEnum.PENDING,
        notes="Follow up on sample evaluation",
    )
    db_session.add(f1)
    await db_session.commit()

    mr_token, _, _ = create_access_token(user_id=mr_user.id, email=mr_user.email, role=mr_user.role.value)
    unauth_token, _, _ = create_access_token(user_id=unauth_mr.id, email=unauth_mr.email, role=unauth_mr.role.value)

    return {
        "mr_user": mr_user,
        "unauth_mr": unauth_mr,
        "assigned_area": assigned_area,
        "unassigned_area": unassigned_area,
        "doc1": doc1,
        "doc2": doc2,
        "doc_unassigned": doc_unassigned,
        "mr_token": mr_token,
        "unauth_token": unauth_token,
    }


@pytest.mark.asyncio
async def test_doctor_commercial_summary(async_client: AsyncClient, seed_analytics_env: dict):
    env = seed_analytics_env
    doc1 = env["doc1"]
    doc2 = env["doc2"]
    token = env["mr_token"]

    # Test Doc 1 (High BV, Prescribing)
    resp = await async_client.get(
        f"/api/v1/analytics/doctor/{doc1.id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["doctor_name"] == "Dr. Rajesh Kumar"
    assert float(data["business_value"]) == 12500.00
    assert float(data["promotional_investment"]) == 1200.00
    assert data["revenue"] is None
    assert data["commercial_result"] is None
    assert "TOP_PRESCRIBER" in data["attention_signals"]
    assert "PRESCRIBING" in data["response_distribution"]
    assert data["provenance"]["business_value"]["status"] == "AUTHORITATIVE"

    # Test Doc 2 (High promo spend, 0 purchases, pending follow-up)
    resp2 = await async_client.get(
        f"/api/v1/analytics/doctor/{doc2.id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp2.status_code == 200, resp2.text
    data2 = resp2.json()
    assert float(data2["business_value"]) == 0.00
    assert float(data2["promotional_investment"]) == 2500.00
    assert "NO_PURCHASE_RECENTLY" in data2["attention_signals"]
    assert "HIGH_PROMO_SPEND" in data2["attention_signals"]
    assert "PENDING_FOLLOWUP" in data2["attention_signals"]


@pytest.mark.asyncio
async def test_area_commercial_summary(async_client: AsyncClient, seed_analytics_env: dict):
    env = seed_analytics_env
    assigned_area = env["assigned_area"]
    token = env["mr_token"]

    resp = await async_client.get(
        f"/api/v1/analytics/area/{assigned_area.id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["area_name"] == "Metro Central"
    assert data["doctor_count"] == 2
    assert float(data["business_value"]) == 12500.00
    assert float(data["promotional_investment"]) == 3700.00  # 1200 + 2500
    assert data["visits_count"] == 2
    assert data["purchase_count"] == 1
    assert float(data["avg_purchase_value"]) == 12500.00
    assert len(data["doctors"]) == 2
    # Ranked with doc1 first (12500 > 0)
    assert data["doctors"][0]["doctor_name"] == "Dr. Rajesh Kumar"


@pytest.mark.asyncio
async def test_overall_commercial_summary(async_client: AsyncClient, seed_analytics_env: dict):
    env = seed_analytics_env
    token = env["mr_token"]

    resp = await async_client.get(
        "/api/v1/analytics/overall?period=this_month",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["period"] == "this_month"
    assert data["field_activity"]["total_doctors"] == 2
    assert data["field_activity"]["total_visits"] == 2
    assert data["field_activity"]["total_purchases"] == 1
    assert data["field_activity"]["pending_followups"] == 1
    assert float(data["business_value"]) == 12500.00
    assert float(data["promotional_investment"]) == 3700.00
    assert data["revenue"] is None
    assert data["profit_loss"] is None

    # Response distribution
    assert data["response_distribution"].get("PRESCRIBING") == 1
    assert data["response_distribution"].get("HESITANT") == 1

    # Category investments
    assert len(data["category_investments"]) == 2

    # Trends (4 weeks)
    assert len(data["trends"]) == 4

    # Top doctors & Attention doctors
    assert len(data["top_doctors"]) >= 1
    assert any("HIGH_PROMO_SPEND" in d["attention_signals"] for d in data["attention_doctors"])


@pytest.mark.asyncio
async def test_analytics_bola_territory_security(async_client: AsyncClient, seed_analytics_env: dict):
    env = seed_analytics_env
    doc1 = env["doc1"]
    assigned_area = env["assigned_area"]
    token = env["unauth_token"]

    # Accessing doctor outside territory
    resp = await async_client.get(
        f"/api/v1/analytics/doctor/{doc1.id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403

    # Accessing area outside territory
    resp2 = await async_client.get(
        f"/api/v1/analytics/area/{assigned_area.id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp2.status_code == 403
