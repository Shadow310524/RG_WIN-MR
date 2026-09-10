import uuid
from datetime import date, datetime, timezone
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
from app.models.promotional_investment import DoctorPromotionalInvestment, PromotionalInvestmentTypeEnum
from app.models.audit_log import AuditLog
from app.models.user import User, RoleEnum, UserStatusEnum
from app.core.security import hash_password, create_access_token


@pytest_asyncio.fixture
async def seed_financial_data(db_session: AsyncSession):
    """Seed users, areas, territory assignments, doctors, visits, and sales."""
    # 1. Users
    mr_user = User(
        id=uuid.uuid4(),
        email="mr_fin@healix.com",
        password_hash=hash_password("FinPass123!"),
        full_name="Financial MR",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    admin_user = User(
        id=uuid.uuid4(),
        email="admin_fin@healix.com",
        password_hash=hash_password("AdminFin123!"),
        full_name="Financial Admin",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    db_session.add_all([mr_user, admin_user])

    # 2. Areas
    area_assigned = Area(id=uuid.uuid4(), name="North Territory", code="NORTH-FIN")
    area_unassigned = Area(id=uuid.uuid4(), name="South Territory", code="SOUTH-FIN")
    db_session.add_all([area_assigned, area_unassigned])
    await db_session.flush()

    # 3. Territory assignment for MR
    assignment = MRAreaAssignment(
        id=uuid.uuid4(),
        mr_id=mr_user.id,
        area_id=area_assigned.id,
        is_active=True,
    )
    db_session.add(assignment)

    # 4. Doctors
    doc_1 = Doctor(
        id=uuid.uuid4(),
        name="Dr. Arvind Swamy",
        phone="+919888800001",
        medical_license_number="FIN-LIC-001",
        specialization="Cardiology",
        clinic_name="Swamy Heart Clinic",
        area_id=area_assigned.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    doc_2 = Doctor(
        id=uuid.uuid4(),
        name="Dr. Kavitha Raman",
        phone="+919888800002",
        medical_license_number="FIN-LIC-002",
        specialization="Pediatrics",
        clinic_name="Care Hospital",
        area_id=area_assigned.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    doc_unauth = Doctor(
        id=uuid.uuid4(),
        name="Dr. Rogue Doctor",
        phone="+919888800003",
        medical_license_number="FIN-LIC-003",
        specialization="Orthopedics",
        clinic_name="South Clinic",
        area_id=area_unassigned.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    db_session.add_all([doc_1, doc_2, doc_unauth])
    await db_session.flush()

    # 5. Visit for Doc 1
    visit_1 = Visit(
        id=uuid.uuid4(),
        doctor_id=doc_1.id,
        user_id=mr_user.id,
        visit_datetime=datetime.now(timezone.utc),
        visit_type=VisitTypeEnum.REGULAR_VISIT,
        doctor_response=DoctorResponseEnum.POSITIVE,
        prescription_potential=PrescriptionPotentialEnum.HIGH,
    )
    db_session.add(visit_1)

    # 6. Sales for Doc 1 (₹15,000) and Doc 2 (₹25,000)
    sale_1 = Sale(
        id=uuid.uuid4(),
        doctor_id=doc_1.id,
        user_id=mr_user.id,
        sale_date=date.today(),
        status=SaleStatusEnum.CONFIRMED,
        total_amount=Decimal("15000.00"),
    )
    sale_2 = Sale(
        id=uuid.uuid4(),
        doctor_id=doc_2.id,
        user_id=mr_user.id,
        sale_date=date.today(),
        status=SaleStatusEnum.CONFIRMED,
        total_amount=Decimal("25000.00"),
    )
    db_session.add_all([sale_1, sale_2])
    await db_session.commit()

    mr_token, _, _ = create_access_token(user_id=mr_user.id, email=mr_user.email, role=mr_user.role.value)
    admin_token, _, _ = create_access_token(user_id=admin_user.id, email=admin_user.email, role=admin_user.role.value)

    return {
        "mr_user": mr_user,
        "admin_user": admin_user,
        "mr_token": mr_token,
        "admin_token": admin_token,
        "area_assigned": area_assigned,
        "area_unassigned": area_unassigned,
        "doc_1": doc_1,
        "doc_2": doc_2,
        "doc_unauth": doc_unauth,
        "visit_1": visit_1,
        "sale_1": sale_1,
        "sale_2": sale_2,
    }


@pytest.mark.asyncio
async def test_record_promotional_investment_and_validation(async_client: AsyncClient, seed_financial_data, db_session: AsyncSession):
    data = seed_financial_data
    headers = {"Authorization": f"Bearer {data['mr_token']}"}

    # 1. Successful creation linked to doctor and visit
    payload = {
        "doctor_id": str(data["doc_1"].id),
        "visit_id": str(data["visit_1"].id),
        "amount": "750.50",
        "investment_type": "SAMPLE",
        "investment_date": str(date.today()),
        "notes": "Provided 5 Healix-500 sample strips",
    }
    res = await async_client.post("/api/v1/promotional-investments", json=payload, headers=headers)
    assert res.status_code == 201, res.text
    body = res.json()
    assert body["amount"] == "750.50"
    assert body["doctor_id"] == str(data["doc_1"].id)
    assert body["doctor_name"] == "Dr. Arvind Swamy"
    assert body["provenance_source"] == "EXPLICIT_PROMOTIONAL_INVESTMENT"

    # 2. Rejection of zero or negative amount
    bad_payload = {**payload, "amount": "0.00"}
    res_bad = await async_client.post("/api/v1/promotional-investments", json=bad_payload, headers=headers)
    assert res_bad.status_code == 422 or res_bad.status_code == 400

    neg_payload = {**payload, "amount": "-150.00"}
    res_neg = await async_client.post("/api/v1/promotional-investments", json=neg_payload, headers=headers)
    assert res_neg.status_code == 422 or res_neg.status_code == 400

    # 3. BOLA / Territory isolation rejection
    unauth_payload = {
        **payload,
        "doctor_id": str(data["doc_unauth"].id),
        "visit_id": None,
    }
    res_unauth = await async_client.post("/api/v1/promotional-investments", json=unauth_payload, headers=headers)
    assert res_unauth.status_code == 403


@pytest.mark.asyncio
async def test_promotional_investment_audit_trail(async_client: AsyncClient, seed_financial_data, db_session: AsyncSession):
    data = seed_financial_data
    headers = {"Authorization": f"Bearer {data['mr_token']}"}

    # Record investment
    res = await async_client.post(
        "/api/v1/promotional-investments",
        json={
            "doctor_id": str(data["doc_1"].id),
            "amount": "1200.00",
            "investment_type": "PROMOTIONAL_UNIT",
            "investment_date": str(date.today()),
            "notes": "Medical brochure and promotional display unit",
        },
        headers=headers,
    )
    assert res.status_code == 201
    inv_id = res.json()["id"]

    # Verify audit log exists
    audit_res = await db_session.execute(
        select(AuditLog).where(AuditLog.action == "PROMOTIONAL_INVESTMENT_CREATED", AuditLog.entity_id == inv_id)
    )
    audit = audit_res.scalars().first()
    assert audit is not None
    assert audit.actor_id == data["mr_user"].id


@pytest.mark.asyncio
async def test_doctor_commercial_summary_and_provenance(async_client: AsyncClient, seed_financial_data):
    data = seed_financial_data
    headers = {"Authorization": f"Bearer {data['mr_token']}"}

    # Add 2 investments to Doc 1
    await async_client.post(
        "/api/v1/promotional-investments",
        json={
            "doctor_id": str(data["doc_1"].id),
            "amount": "500.00",
            "investment_type": "SAMPLE",
            "investment_date": str(date.today()),
        },
        headers=headers,
    )
    await async_client.post(
        "/api/v1/promotional-investments",
        json={
            "doctor_id": str(data["doc_1"].id),
            "amount": "1000.00",
            "investment_type": "PROMOTIONAL_MATERIAL",
            "investment_date": str(date.today()),
        },
        headers=headers,
    )

    # Fetch Doctor Commercial Summary
    res = await async_client.get(f"/api/v1/analytics/doctor/{data['doc_1'].id}", headers=headers)
    assert res.status_code == 200
    summary = res.json()

    assert summary["doctor_id"] == str(data["doc_1"].id)
    assert summary["business_value"] == "15000.00"
    assert summary["promotional_investment"] == "1500.00"
    assert summary["visit_count"] == 1
    assert summary["purchase_count"] == 1
    # Honest placeholders
    assert summary["revenue"] is None
    assert summary["commercial_result"] is None

    # Verify Financial Provenance
    provenance = summary["provenance"]
    assert provenance["business_value"]["source"] == "RECORDED_PURCHASE"
    assert provenance["business_value"]["status"] == "AUTHORITATIVE"
    assert provenance["promotional_investment"]["source"] == "EXPLICIT_PROMOTIONAL_INVESTMENT"
    assert provenance["promotional_investment"]["status"] == "AUTHORITATIVE"
    assert provenance["revenue"]["status"] == "PENDING_BUSINESS_RULES"
    assert provenance["commercial_result"]["status"] == "PENDING_BUSINESS_RULES"
    assert provenance["general_expenses"]["source"] == "EXCLUDED_OPERATING_EXPENSE"


@pytest.mark.asyncio
async def test_area_commercial_summary_and_doctor_ranking(async_client: AsyncClient, seed_financial_data):
    data = seed_financial_data
    headers = {"Authorization": f"Bearer {data['mr_token']}"}

    # Add investment for Doc 2 as well
    await async_client.post(
        "/api/v1/promotional-investments",
        json={
            "doctor_id": str(data["doc_2"].id),
            "amount": "2000.00",
            "investment_type": "FREE_SUPPLY",
            "investment_date": str(date.today()),
        },
        headers=headers,
    )

    # Fetch Area Summary
    res = await async_client.get(f"/api/v1/analytics/area/{data['area_assigned'].id}", headers=headers)
    assert res.status_code == 200
    area_summary = res.json()

    assert area_summary["area_id"] == str(data["area_assigned"].id)
    assert area_summary["doctor_count"] == 2
    # Area Business Value = ₹15,000 (Doc 1) + ₹25,000 (Doc 2) = ₹40,000
    assert Decimal(area_summary["business_value"]) == Decimal("40000.00")
    # Area Promotional Investment = ₹2,000
    assert Decimal(area_summary["promotional_investment"]) >= Decimal("2000.00")

    # Verify Doctor Ranking: Doc 2 (₹25k) should be first, Doc 1 (₹15k) should be second
    ranked_docs = area_summary["doctors"]
    assert len(ranked_docs) == 2
    assert ranked_docs[0]["doctor_id"] == str(data["doc_2"].id)
    assert ranked_docs[0]["business_value"] == "25000.00"
    assert ranked_docs[1]["doctor_id"] == str(data["doc_1"].id)
    assert ranked_docs[1]["business_value"] == "15000.00"


@pytest.mark.asyncio
async def test_overall_commercial_summary(async_client: AsyncClient, seed_financial_data):
    data = seed_financial_data
    headers = {"Authorization": f"Bearer {data['mr_token']}"}

    res = await async_client.get("/api/v1/analytics/overall?period=this_month", headers=headers)
    assert res.status_code == 200
    overall = res.json()

    assert overall["period"] == "this_month"
    assert Decimal(overall["business_value"]) == Decimal("40000.00")
    assert overall["revenue"] is None
    assert overall["profit_loss"] is None
    assert len(overall["areas"]) == 1
    assert len(overall["top_doctors"]) == 2
