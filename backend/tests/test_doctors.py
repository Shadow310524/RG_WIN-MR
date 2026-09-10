import uuid
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, create_access_token
from app.models.user import User, RoleEnum, UserStatusEnum
from app.models.area import Area, AreaStatusEnum
from app.models.association import Association, AssociationStatusEnum
from app.models.mr_assignment import MRAreaAssignment


@pytest_asyncio.fixture
async def setup_doctor_env(db_session: AsyncSession):
    admin = User(
        id=uuid.uuid4(),
        email="admin_doc@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Admin Chief",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr_a = User(
        id=uuid.uuid4(),
        email="mr_a@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Alpha",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    mr_b = User(
        id=uuid.uuid4(),
        email="mr_b@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Beta",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    area_1 = Area(
        id=uuid.uuid4(),
        name="Area North (Assigned to A)",
        code="NORTH-01",
        status=AreaStatusEnum.ACTIVE,
    )
    area_2 = Area(
        id=uuid.uuid4(),
        name="Area South (Assigned to B)",
        code="SOUTH-01",
        status=AreaStatusEnum.ACTIVE,
    )
    assoc = Association(
        id=uuid.uuid4(),
        name="Cardiology Association of India",
        code="CAI",
        status=AssociationStatusEnum.ACTIVE,
    )

    db_session.add_all([admin, mr_a, mr_b, area_1, area_2, assoc])
    await db_session.flush()

    # Territory assignments
    assign_a = MRAreaAssignment(id=uuid.uuid4(), mr_id=mr_a.id, area_id=area_1.id, is_active=True)
    assign_b = MRAreaAssignment(id=uuid.uuid4(), mr_id=mr_b.id, area_id=area_2.id, is_active=True)
    db_session.add_all([assign_a, assign_b])
    await db_session.commit()

    admin_token, _, _ = create_access_token(admin.id, admin.email, admin.role.value)
    mr_a_token, _, _ = create_access_token(mr_a.id, mr_a.email, mr_a.role.value)
    mr_b_token, _, _ = create_access_token(mr_b.id, mr_b.email, mr_b.role.value)

    return {
        "admin": admin,
        "mr_a": mr_a,
        "mr_b": mr_b,
        "area_1": area_1,
        "area_2": area_2,
        "assoc": assoc,
        "admin_headers": {"Authorization": f"Bearer {admin_token}"},
        "mr_a_headers": {"Authorization": f"Bearer {mr_a_token}"},
        "mr_b_headers": {"Authorization": f"Bearer {mr_b_token}"},
    }


@pytest.mark.asyncio
async def test_create_valid_doctor_and_read(async_client: AsyncClient, setup_doctor_env):
    mr_a_headers = setup_doctor_env["mr_a_headers"]
    area_1 = setup_doctor_env["area_1"]
    assoc = setup_doctor_env["assoc"]

    # MR A creates doctor in assigned area 1
    create_payload = {
        "name": "Dr. Anitha Ramesh",
        "phone": "+91 98765-43210",
        "alternate_phone": "044-24567890",
        "email": "anitha.ramesh@gmail.com",
        "medical_license_number": "MCI/2012/12345",
        "specialization": "Cardiology",
        "qualification": "MBBS, MD (Cardio)",
        "clinic_name": "Apollo Heart Centre",
        "address": "21 Greams Road, Chennai",
        "area_id": str(area_1.id),
        "association_id": str(assoc.id),
        "notes": "Interested in Healix cardiac portfolio",
    }
    res = await async_client.post("/api/v1/doctors", headers=mr_a_headers, json=create_payload)
    assert res.status_code == 201
    doc = res.json()
    assert doc["name"] == "Dr. Anitha Ramesh"
    assert doc["phone"] == "+919876543210"  # Normalized
    assert doc["medical_license_number"] == "MCI/2012/12345"
    assert doc["area_name"] == area_1.name
    assert doc["association_name"] == assoc.name
    assert doc["is_active"] is True

    # Read back
    doc_id = doc["id"]
    get_res = await async_client.get(f"/api/v1/doctors/{doc_id}", headers=mr_a_headers)
    assert get_res.status_code == 200
    assert get_res.json()["clinic_name"] == "Apollo Heart Centre"


@pytest.mark.asyncio
async def test_doctor_validation_errors(async_client: AsyncClient, setup_doctor_env):
    mr_a_headers = setup_doctor_env["mr_a_headers"]
    area_1 = setup_doctor_env["area_1"]

    # Invalid phone (too short)
    bad_phone_res = await async_client.post(
        "/api/v1/doctors",
        headers=mr_a_headers,
        json={
            "name": "Dr. Invalid",
            "phone": "123",
            "medical_license_number": "LIC-1234",
            "specialization": "General Medicine",
            "area_id": str(area_1.id),
        },
    )
    assert bad_phone_res.status_code == 422

    # Blank doctor name
    blank_name_res = await async_client.post(
        "/api/v1/doctors",
        headers=mr_a_headers,
        json={
            "name": "   ",
            "phone": "+919876543210",
            "medical_license_number": "LIC-1234",
            "specialization": "General Medicine",
            "area_id": str(area_1.id),
        },
    )
    assert blank_name_res.status_code == 422


@pytest.mark.asyncio
async def test_duplicate_phone_and_license_detection(async_client: AsyncClient, setup_doctor_env):
    admin_headers = setup_doctor_env["admin_headers"]
    area_1 = setup_doctor_env["area_1"]

    # Create first doctor
    res1 = await async_client.post(
        "/api/v1/doctors",
        headers=admin_headers,
        json={
            "name": "Dr. First Doctor",
            "phone": "+919811122233",
            "medical_license_number": "MCI-UNIQUE-01",
            "specialization": "Pediatrics",
            "area_id": str(area_1.id),
        },
    )
    assert res1.status_code == 201
    first_id = res1.json()["id"]

    # Pre-flight duplicate check on phone
    check_phone_res = await async_client.post(
        "/api/v1/doctors/check-duplicate",
        headers=admin_headers,
        json={"phone": "+91 98111-22233"},
    )
    assert check_phone_res.status_code == 200
    assert check_phone_res.json()["is_duplicate"] is True
    assert check_phone_res.json()["duplicate_field"] == "phone"

    # Attempt to create duplicate phone
    dup_phone = await async_client.post(
        "/api/v1/doctors",
        headers=admin_headers,
        json={
            "name": "Dr. Duplicate Phone",
            "phone": "+91 98111 22233",
            "medical_license_number": "MCI-DIFFERENT-02",
            "specialization": "Pediatrics",
            "area_id": str(area_1.id),
        },
    )
    assert dup_phone.status_code == 409
    assert dup_phone.json()["error"]["code"] == "DUPLICATE_DOCTOR"

    # Pre-flight duplicate check on license
    check_lic_res = await async_client.post(
        "/api/v1/doctors/check-duplicate",
        headers=admin_headers,
        json={"medical_license_number": "mci-unique-01"},
    )
    assert check_lic_res.status_code == 200
    assert check_lic_res.json()["is_duplicate"] is True
    assert check_lic_res.json()["duplicate_field"] == "medical_license_number"

    # Attempt to create duplicate license
    dup_lic = await async_client.post(
        "/api/v1/doctors",
        headers=admin_headers,
        json={
            "name": "Dr. Duplicate License",
            "phone": "+919999988888",
            "medical_license_number": "mci-unique-01",
            "specialization": "Pediatrics",
            "area_id": str(area_1.id),
        },
    )
    assert dup_lic.status_code == 409
    assert dup_lic.json()["error"]["code"] == "DUPLICATE_DOCTOR"

    # Excluding own doctor_id during update check should report is_duplicate=False
    exclude_check = await async_client.post(
        "/api/v1/doctors/check-duplicate",
        headers=admin_headers,
        json={"phone": "+919811122233", "exclude_doctor_id": first_id},
    )
    assert exclude_check.status_code == 200
    assert exclude_check.json()["is_duplicate"] is False


@pytest.mark.asyncio
async def test_update_and_status_change(async_client: AsyncClient, setup_doctor_env):
    admin_headers = setup_doctor_env["admin_headers"]
    area_1 = setup_doctor_env["area_1"]

    create_res = await async_client.post(
        "/api/v1/doctors",
        headers=admin_headers,
        json={
            "name": "Dr. Vijay Anand",
            "phone": "+919777766666",
            "medical_license_number": "MCI-VIJAY-01",
            "specialization": "Orthopedics",
            "area_id": str(area_1.id),
        },
    )
    doc_id = create_res.json()["id"]

    # Update doctor
    up_res = await async_client.put(
        f"/api/v1/doctors/{doc_id}",
        headers=admin_headers,
        json={"clinic_name": "Vijaya Hospital", "qualification": "MS (Ortho)"},
    )
    assert up_res.status_code == 200
    assert up_res.json()["clinic_name"] == "Vijaya Hospital"
    assert up_res.json()["qualification"] == "MS (Ortho)"

    # Change status to INACTIVE
    st_res = await async_client.patch(
        f"/api/v1/doctors/{doc_id}/status",
        headers=admin_headers,
        json={"status": "INACTIVE"},
    )
    assert st_res.status_code == 200
    assert st_res.json()["status"] == "INACTIVE"
    assert st_res.json()["is_active"] is False


@pytest.mark.asyncio
async def test_doctor_search_and_pagination(async_client: AsyncClient, setup_doctor_env):
    admin_headers = setup_doctor_env["admin_headers"]
    area_1 = setup_doctor_env["area_1"]

    # Seed 3 doctors
    names = ["Dr. Aarav Sharma", "Dr. Bhuvanesh Kumar", "Dr. Chitra Raman"]
    for i, n in enumerate(names):
        await async_client.post(
            "/api/v1/doctors",
            headers=admin_headers,
            json={
                "name": n,
                "phone": f"+91980000000{i}",
                "medical_license_number": f"MCI-SEARCH-0{i}",
                "specialization": "Neurology" if i == 0 else "Dermatology",
                "clinic_name": f"City Clinic {i}",
                "area_id": str(area_1.id),
            },
        )

    # Search by name
    res_name = await async_client.get("/api/v1/doctors?search=Aarav", headers=admin_headers)
    assert res_name.status_code == 200
    assert res_name.json()["total"] == 1
    assert res_name.json()["items"][0]["name"] == "Dr. Aarav Sharma"

    # Search by clinic
    res_clinic = await async_client.get("/api/v1/doctors?search=City Clinic 2", headers=admin_headers)
    assert res_clinic.status_code == 200
    assert res_clinic.json()["total"] == 1

    # Filter by specialization
    res_spec = await async_client.get("/api/v1/doctors?search=Neurology", headers=admin_headers)
    assert res_spec.status_code == 200
    assert res_spec.json()["total"] == 1


# ====================================================================
# CRITICAL OWASP / BOLA / IDOR SECURITY TESTS
# ====================================================================

@pytest.mark.asyncio
async def test_bola_idor_mr_territory_isolation(async_client: AsyncClient, setup_doctor_env):
    """
    CRITICAL OWASP BOLA/IDOR TEST SUITE:
    MR A is assigned strictly to Area 1 (North).
    MR B is assigned strictly to Area 2 (South).

    Test 1: MR A cannot create a doctor in Area 2 -> 403 Forbidden.
    Test 2: MR A cannot fetch Doctor 2 (in Area 2) by UUID -> 403 Forbidden.
    Test 3: MR A cannot update Doctor 2 -> 403 Forbidden.
    Test 4: MR A cannot move Doctor 1 into Area 2 -> 403 Forbidden.
    Test 5: MR A query list strictly excludes Area 2 doctors.
    Test 6: Admin can access and manage both Area 1 and Area 2 doctors globally.
    """
    admin_headers = setup_doctor_env["admin_headers"]
    mr_a_headers = setup_doctor_env["mr_a_headers"]
    mr_b_headers = setup_doctor_env["mr_b_headers"]
    area_1 = setup_doctor_env["area_1"]
    area_2 = setup_doctor_env["area_2"]

    # 1. MR A tries to create doctor in Area 2 -> MUST BE REJECTED 403
    mr_a_unauth_create = await async_client.post(
        "/api/v1/doctors",
        headers=mr_a_headers,
        json={
            "name": "Dr. Intruder",
            "phone": "+919555544444",
            "medical_license_number": "MCI-INTRUDE-01",
            "specialization": "Oncology",
            "area_id": str(area_2.id),  # Unassigned area for MR A!
        },
    )
    assert mr_a_unauth_create.status_code == 403
    assert mr_a_unauth_create.json()["error"]["code"] == "TERRITORY_UNAUTHORIZED"

    # 2. Setup legitimate doctors: Doctor 1 in Area 1 (by MR A), Doctor 2 in Area 2 (by MR B)
    doc1_res = await async_client.post(
        "/api/v1/doctors",
        headers=mr_a_headers,
        json={
            "name": "Dr. North Specialist",
            "phone": "+919111100001",
            "medical_license_number": "MCI-NORTH-01",
            "specialization": "General",
            "area_id": str(area_1.id),
        },
    )
    assert doc1_res.status_code == 201
    doc_1_id = doc1_res.json()["id"]

    doc2_res = await async_client.post(
        "/api/v1/doctors",
        headers=mr_b_headers,
        json={
            "name": "Dr. South Specialist",
            "phone": "+919222200002",
            "medical_license_number": "MCI-SOUTH-02",
            "specialization": "General",
            "area_id": str(area_2.id),
        },
    )
    assert doc2_res.status_code == 201
    doc_2_id = doc2_res.json()["id"]

    # 3. BOLA Fetch Attempt: MR A attempts to GET Doctor 2 by UUID -> MUST BE 403
    mr_a_bola_get = await async_client.get(f"/api/v1/doctors/{doc_2_id}", headers=mr_a_headers)
    assert mr_a_bola_get.status_code == 403
    assert mr_a_bola_get.json()["error"]["code"] == "TERRITORY_UNAUTHORIZED"

    # 4. BOLA Update Attempt: MR A attempts to PUT Doctor 2 -> MUST BE 403
    mr_a_bola_put = await async_client.put(
        f"/api/v1/doctors/{doc_2_id}",
        headers=mr_a_headers,
        json={"name": "Hacked South Doctor"},
    )
    assert mr_a_bola_put.status_code == 403
    assert mr_a_bola_put.json()["error"]["code"] == "TERRITORY_UNAUTHORIZED"

    # 5. Unauthorized Territory Transfer: MR A attempts to move Doctor 1 to Area 2 -> MUST BE 403
    mr_a_transfer_attempt = await async_client.put(
        f"/api/v1/doctors/{doc_1_id}",
        headers=mr_a_headers,
        json={"area_id": str(area_2.id)},
    )
    assert mr_a_transfer_attempt.status_code == 403
    assert mr_a_transfer_attempt.json()["error"]["code"] == "TERRITORY_UNAUTHORIZED"

    # 6. Listing Scoping: MR A only sees Doctor 1; Doctor 2 is completely excluded
    mr_a_list = await async_client.get("/api/v1/doctors", headers=mr_a_headers)
    assert mr_a_list.status_code == 200
    mr_a_doc_ids = [d["id"] for d in mr_a_list.json()["items"]]
    assert doc_1_id in mr_a_doc_ids
    assert doc_2_id not in mr_a_doc_ids

    # MR B only sees Doctor 2; Doctor 1 is completely excluded
    mr_b_list = await async_client.get("/api/v1/doctors", headers=mr_b_headers)
    assert mr_b_list.status_code == 200
    mr_b_doc_ids = [d["id"] for d in mr_b_list.json()["items"]]
    assert doc_2_id in mr_b_doc_ids
    assert doc_1_id not in mr_b_doc_ids

    # 7. Admin sees BOTH doctors globally
    admin_list = await async_client.get("/api/v1/doctors", headers=admin_headers)
    assert admin_list.status_code == 200
    admin_doc_ids = [d["id"] for d in admin_list.json()["items"]]
    assert doc_1_id in admin_doc_ids
    assert doc_2_id in admin_doc_ids
