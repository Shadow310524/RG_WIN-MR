import uuid
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, create_access_token
from app.models.user import User, RoleEnum, UserStatusEnum
from app.models.area import Area, AreaStatusEnum
from app.models.mr_assignment import MRAreaAssignment


@pytest_asyncio.fixture
async def setup_area_test_users(db_session: AsyncSession):
    admin = User(
        id=uuid.uuid4(),
        email="admin_area@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Admin Area Mgr",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr = User(
        id=uuid.uuid4(),
        email="mr_area@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Area Rep",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    db_session.add_all([admin, mr])
    await db_session.commit()

    admin_token, _, _ = create_access_token(admin.id, admin.email, admin.role.value)
    mr_token, _, _ = create_access_token(mr.id, mr.email, mr.role.value)

    return {
        "admin": admin,
        "mr": mr,
        "admin_headers": {"Authorization": f"Bearer {admin_token}"},
        "mr_headers": {"Authorization": f"Bearer {mr_token}"},
    }


@pytest.mark.asyncio
async def test_admin_can_create_and_update_area(async_client: AsyncClient, setup_area_test_users):
    headers = setup_area_test_users["admin_headers"]

    # 1. Create Area
    create_res = await async_client.post(
        "/api/v1/areas",
        headers=headers,
        json={
            "name": "Anna Nagar",
            "code": "CHEN-AN-01",
            "description": "Prime residential & commercial doctor hub",
        },
    )
    assert create_res.status_code == 201
    area_data = create_res.json()
    assert area_data["name"] == "Anna Nagar"
    assert area_data["code"] == "CHEN-AN-01"
    assert area_data["is_active"] is True
    area_id = area_data["id"]

    # 2. Update Area
    update_res = await async_client.put(
        f"/api/v1/areas/{area_id}",
        headers=headers,
        json={"description": "Updated doctor territory hub"},
    )
    assert update_res.status_code == 200
    assert update_res.json()["description"] == "Updated doctor territory hub"

    # 3. Change Status
    status_res = await async_client.patch(
        f"/api/v1/areas/{area_id}/status",
        headers=headers,
        json={"status": "ARCHIVED"},
    )
    assert status_res.status_code == 200
    assert status_res.json()["status"] == "ARCHIVED"
    assert status_res.json()["is_active"] is False


@pytest.mark.asyncio
async def test_duplicate_area_code_and_name_rejected(async_client: AsyncClient, setup_area_test_users):
    headers = setup_area_test_users["admin_headers"]

    # Create initial area
    res1 = await async_client.post(
        "/api/v1/areas",
        headers=headers,
        json={"name": "T Nagar", "code": "CHEN-TN-01"},
    )
    assert res1.status_code == 201

    # Duplicate code
    dup_code_res = await async_client.post(
        "/api/v1/areas",
        headers=headers,
        json={"name": "Different Name", "code": "CHEN-TN-01"},
    )
    assert dup_code_res.status_code == 409
    assert dup_code_res.json()["error"]["code"] == "DUPLICATE_AREA_CODE"

    # Duplicate name
    dup_name_res = await async_client.post(
        "/api/v1/areas",
        headers=headers,
        json={"name": "T Nagar", "code": "CHEN-DIFF-02"},
    )
    assert dup_name_res.status_code == 409
    assert dup_name_res.json()["error"]["code"] == "DUPLICATE_AREA_NAME"


@pytest.mark.asyncio
async def test_mr_cannot_modify_areas(async_client: AsyncClient, setup_area_test_users, db_session: AsyncSession):
    mr_headers = setup_area_test_users["mr_headers"]

    # Pre-create an area in DB
    area = Area(id=uuid.uuid4(), name="Velachery", code="CHEN-VEL-01", status=AreaStatusEnum.ACTIVE)
    db_session.add(area)
    await db_session.commit()

    # MR cannot create area
    create_res = await async_client.post(
        "/api/v1/areas",
        headers=mr_headers,
        json={"name": "MR Area", "code": "MR-01"},
    )
    assert create_res.status_code == 403

    # MR cannot update area
    update_res = await async_client.put(
        f"/api/v1/areas/{area.id}",
        headers=mr_headers,
        json={"name": "Hacked Name"},
    )
    assert update_res.status_code == 403

    # MR cannot change status
    status_res = await async_client.patch(
        f"/api/v1/areas/{area.id}/status",
        headers=mr_headers,
        json={"status": "ARCHIVED"},
    )
    assert status_res.status_code == 403


@pytest.mark.asyncio
async def test_mr_territory_scoping_for_areas(async_client: AsyncClient, setup_area_test_users, db_session: AsyncSession):
    """
    CRITICAL TERRITORY RULE:
    When an MR lists areas, they must ONLY receive areas that have been assigned to them.
    Admins receive all areas.
    """
    admin_headers = setup_area_test_users["admin_headers"]
    mr_headers = setup_area_test_users["mr_headers"]
    mr = setup_area_test_users["mr"]

    # Create 3 areas
    area1 = Area(id=uuid.uuid4(), name="Area Assigned", code="AREA-01", status=AreaStatusEnum.ACTIVE)
    area2 = Area(id=uuid.uuid4(), name="Area Unassigned", code="AREA-02", status=AreaStatusEnum.ACTIVE)
    db_session.add_all([area1, area2])
    await db_session.commit()

    # Assign only area1 to MR
    assignment = MRAreaAssignment(id=uuid.uuid4(), mr_id=mr.id, area_id=area1.id, is_active=True)
    db_session.add(assignment)
    await db_session.commit()

    # Admin listing: sees both
    admin_res = await async_client.get("/api/v1/areas", headers=admin_headers)
    assert admin_res.status_code == 200
    admin_names = [a["name"] for a in admin_res.json()]
    assert "Area Assigned" in admin_names
    assert "Area Unassigned" in admin_names

    # MR listing: strictly sees only Area Assigned
    mr_res = await async_client.get("/api/v1/areas", headers=mr_headers)
    assert mr_res.status_code == 200
    mr_areas = mr_res.json()
    assert len(mr_areas) == 1
    assert mr_areas[0]["name"] == "Area Assigned"

    # MR direct fetch on unassigned area -> 403 Forbidden
    unassigned_fetch = await async_client.get(f"/api/v1/areas/{area2.id}", headers=mr_headers)
    assert unassigned_fetch.status_code == 403
    assert unassigned_fetch.json()["error"]["code"] == "TERRITORY_UNAUTHORIZED"
