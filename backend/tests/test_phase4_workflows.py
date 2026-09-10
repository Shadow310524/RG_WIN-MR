import uuid
from datetime import datetime, date, timezone
from decimal import Decimal
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, create_access_token
from app.models.user import User, RoleEnum, UserStatusEnum
from app.models.area import Area, AreaStatusEnum
from app.models.doctor import Doctor, DoctorStatusEnum
from app.models.mr_assignment import MRAreaAssignment
from app.models.follow_up import FollowUpStatusEnum


@pytest_asyncio.fixture
async def setup_phase4_env(db_session: AsyncSession):
    admin = User(
        id=uuid.uuid4(),
        email="admin_phase4@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Admin Chief",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr_a = User(
        id=uuid.uuid4(),
        email="mr_a_p4@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Alpha",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    mr_b = User(
        id=uuid.uuid4(),
        email="mr_b_p4@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Beta",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    area_a = Area(
        id=uuid.uuid4(),
        name="Area North (Assigned to MR A)",
        code="P4-NORTH",
        status=AreaStatusEnum.ACTIVE,
    )
    area_b = Area(
        id=uuid.uuid4(),
        name="Area South (Assigned to MR B)",
        code="P4-SOUTH",
        status=AreaStatusEnum.ACTIVE,
    )

    db_session.add_all([admin, mr_a, mr_b, area_a, area_b])
    await db_session.flush()

    assign_a = MRAreaAssignment(
        mr_id=mr_a.id,
        area_id=area_a.id,
        is_active=True,
    )
    assign_b = MRAreaAssignment(
        mr_id=mr_b.id,
        area_id=area_b.id,
        is_active=True,
    )

    doc_a = Doctor(
        id=uuid.uuid4(),
        name="Dr. Anil Kumar",
        phone="+919876543210",
        medical_license_number="MCI-98765",
        specialization="Cardiology",
        area_id=area_a.id,
        status=DoctorStatusEnum.ACTIVE,
    )
    doc_b = Doctor(
        id=uuid.uuid4(),
        name="Dr. Sunita Rao",
        phone="+919876543211",
        medical_license_number="MCI-98766",
        specialization="Neurology",
        area_id=area_b.id,
        status=DoctorStatusEnum.ACTIVE,
    )

    db_session.add_all([assign_a, assign_b, doc_a, doc_b])
    await db_session.commit()

    return {
        "admin": admin,
        "mr_a": mr_a,
        "mr_b": mr_b,
        "area_a": area_a,
        "area_b": area_b,
        "doc_a": doc_a,
        "doc_b": doc_b,
    }


def auth_headers(user: User) -> dict:
    token, _, _ = create_access_token(
        user_id=user.id,
        email=user.email,
        role=user.role.value,
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_visit_workflow_and_territory_authorization(async_client: AsyncClient, setup_phase4_env: dict):
    env = setup_phase4_env
    mr_a_headers = auth_headers(env["mr_a"])
    mr_b_headers = auth_headers(env["mr_b"])
    admin_headers = auth_headers(env["admin"])

    # 1. MR A records visit for assigned Doctor A -> 201 Created
    visit_payload = {
        "doctor_id": str(env["doc_a"].id),
        "visit_datetime": datetime.now(timezone.utc).isoformat(),
        "visit_type": "REGULAR_VISIT",
        "doctor_response": "POSITIVE",
        "prescription_potential": "HIGH",
        "notes": "Discussed antibiotic line",
        "discussed_products": "Healix-500, Dermashine",
        "samples_given": "2 strips Healix-500",
        "purchase_opportunity": True,
    }
    res = await async_client.post("/api/v1/visits", json=visit_payload, headers=mr_a_headers)
    assert res.status_code == 201
    data = res.json()
    assert data["doctor_name"] == "Dr. Anil Kumar"
    assert data["doctor_response"] == "POSITIVE"
    assert data["discussed_products"] == "Healix-500, Dermashine"
    assert data["samples_given"] == "2 strips Healix-500"
    assert data["purchase_opportunity"] is True
    visit_id = data["id"]

    # 2. BOLA: MR A attempts to record visit for MR B's Doctor B -> 403 Forbidden
    unauthorized_visit = {
        "doctor_id": str(env["doc_b"].id),
        "visit_datetime": datetime.now(timezone.utc).isoformat(),
        "doctor_response": "POSITIVE",
    }
    res_unauth = await async_client.post("/api/v1/visits", json=unauthorized_visit, headers=mr_a_headers)
    assert res_unauth.status_code == 403

    # 3. MR A fetches own visit by ID -> 200 OK
    res_get = await async_client.get(f"/api/v1/visits/{visit_id}", headers=mr_a_headers)
    assert res_get.status_code == 200

    # 4. BOLA: MR B attempts to fetch MR A's visit by ID -> 403 Forbidden
    res_b_get = await async_client.get(f"/api/v1/visits/{visit_id}", headers=mr_b_headers)
    assert res_b_get.status_code == 403

    # 5. List visits filter by doctor_id
    res_list = await async_client.get(f"/api/v1/visits?doctor_id={env['doc_a'].id}", headers=mr_a_headers)
    assert res_list.status_code == 200
    assert res_list.json()["total"] == 1


@pytest.mark.asyncio
async def test_follow_up_workflow_and_lifecycle(async_client: AsyncClient, setup_phase4_env: dict):
    env = setup_phase4_env
    mr_a_headers = auth_headers(env["mr_a"])
    mr_b_headers = auth_headers(env["mr_b"])

    # 1. MR A schedules follow-up for Doctor A -> 201 Created
    follow_up_payload = {
        "doctor_id": str(env["doc_a"].id),
        "due_date": "2026-09-20",
        "notes": "Follow up on clinical trial feedback",
    }
    res = await async_client.post("/api/v1/follow-ups", json=follow_up_payload, headers=mr_a_headers)
    assert res.status_code == 201
    fu_data = res.json()
    assert fu_data["status"] == "PENDING"
    assert fu_data["doctor_name"] == "Dr. Anil Kumar"
    fu_id = fu_data["id"]

    # 2. BOLA: MR A schedules follow-up for MR B's Doctor B -> 403 Forbidden
    unauth_payload = {
        "doctor_id": str(env["doc_b"].id),
        "due_date": "2026-09-20",
        "notes": "Unauthorized follow-up",
    }
    res_unauth = await async_client.post("/api/v1/follow-ups", json=unauth_payload, headers=mr_a_headers)
    assert res_unauth.status_code == 403

    # 3. MR A marks follow-up as COMPLETED
    res_update = await async_client.patch(
        f"/api/v1/follow-ups/{fu_id}/status",
        json={"status": "COMPLETED"},
        headers=mr_a_headers,
    )
    assert res_update.status_code == 200
    updated_data = res_update.json()
    assert updated_data["status"] == "COMPLETED"
    assert updated_data["completed_at"] is not None

    # 4. Filter follow-ups by status
    res_completed = await async_client.get("/api/v1/follow-ups?status=COMPLETED", headers=mr_a_headers)
    assert res_completed.status_code == 200
    assert len(res_completed.json()["items"]) >= 1


@pytest.mark.asyncio
async def test_purchase_workflow_and_financial_integrity(async_client: AsyncClient, setup_phase4_env: dict):
    env = setup_phase4_env
    mr_a_headers = auth_headers(env["mr_a"])
    mr_b_headers = auth_headers(env["mr_b"])
    admin_headers = auth_headers(env["admin"])

    # 1. MR A records commercial purchase for Doctor A with Decimal amount -> 201 Created
    purchase_payload = {
        "doctor_id": str(env["doc_a"].id),
        "sale_date": "2026-09-12",
        "purchase_amount": "50000.00",
        "gst_amount": "9000.00",
        "total_amount": "59000.00",
        "notes": "Direct stockist order",
    }
    res = await async_client.post("/api/v1/sales", json=purchase_payload, headers=mr_a_headers)
    assert res.status_code == 201
    data = res.json()
    assert Decimal(str(data["total_amount"])) == Decimal("59000.00")
    assert data["doctor_name"] == "Dr. Anil Kumar"
    assert data["status"] == "CONFIRMED"

    # 2. BOLA: MR A attempts to record purchase for MR B's Doctor B -> 403 Forbidden
    unauth_sale = {
        "doctor_id": str(env["doc_b"].id),
        "sale_date": "2026-09-12",
        "total_amount": "10000.00",
    }
    res_unauth = await async_client.post("/api/v1/sales", json=unauth_sale, headers=mr_a_headers)
    assert res_unauth.status_code == 403

    # 3. List purchases: MR A sees own Doctor A purchases, MR B sees 0
    res_a_list = await async_client.get(f"/api/v1/sales?doctor_id={env['doc_a'].id}", headers=mr_a_headers)
    assert res_a_list.status_code == 200
    assert res_a_list.json()["total"] == 1

    # MR B cannot query Doctor A purchases -> 403 Forbidden
    res_b_list = await async_client.get(f"/api/v1/sales?doctor_id={env['doc_a'].id}", headers=mr_b_headers)
    assert res_b_list.status_code == 403

    # Admin can view all purchases globally
    res_admin = await async_client.get(f"/api/v1/sales?doctor_id={env['doc_a'].id}", headers=admin_headers)
    assert res_admin.status_code == 200
    assert res_admin.json()["total"] == 1
