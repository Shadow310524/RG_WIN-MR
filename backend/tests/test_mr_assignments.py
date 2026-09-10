import uuid
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, create_access_token
from app.models.user import User, RoleEnum, UserStatusEnum
from app.models.area import Area, AreaStatusEnum


@pytest_asyncio.fixture
async def setup_assignment_env(db_session: AsyncSession):
    admin = User(
        id=uuid.uuid4(),
        email="admin_assign@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Admin Director",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr = User(
        id=uuid.uuid4(),
        email="mr_assign@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Field Officer",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    area = Area(
        id=uuid.uuid4(),
        name="Mylapore",
        code="CHEN-MYL-01",
        status=AreaStatusEnum.ACTIVE,
    )
    db_session.add_all([admin, mr, area])
    await db_session.commit()

    admin_token, _, _ = create_access_token(admin.id, admin.email, admin.role.value)
    mr_token, _, _ = create_access_token(mr.id, mr.email, mr.role.value)

    return {
        "admin": admin,
        "mr": mr,
        "area": area,
        "admin_headers": {"Authorization": f"Bearer {admin_token}"},
        "mr_headers": {"Authorization": f"Bearer {mr_token}"},
    }


@pytest.mark.asyncio
async def test_admin_assign_and_unassign_mr(async_client: AsyncClient, setup_assignment_env):
    admin_headers = setup_assignment_env["admin_headers"]
    area = setup_assignment_env["area"]
    mr = setup_assignment_env["mr"]

    # 1. Assign MR to Area
    assign_res = await async_client.post(
        f"/api/v1/areas/{area.id}/assignments",
        headers=admin_headers,
        json={"mr_id": str(mr.id)},
    )
    assert assign_res.status_code == 201
    data = assign_res.json()
    assert data["mr_id"] == str(mr.id)
    assert data["area_id"] == str(area.id)
    assert data["is_active"] is True

    # 2. Duplicate Assignment Check
    dup_res = await async_client.post(
        f"/api/v1/areas/{area.id}/assignments",
        headers=admin_headers,
        json={"mr_id": str(mr.id)},
    )
    assert dup_res.status_code == 409
    assert dup_res.json()["error"]["code"] == "DUPLICATE_ASSIGNMENT"

    # 3. List Assignments
    list_res = await async_client.get(f"/api/v1/areas/{area.id}/assignments", headers=admin_headers)
    assert list_res.status_code == 200
    assert len(list_res.json()) == 1

    # 4. Unassign MR
    del_res = await async_client.delete(f"/api/v1/areas/{area.id}/assignments/{mr.id}", headers=admin_headers)
    assert del_res.status_code == 200

    # Verify empty list after deletion
    list_after = await async_client.get(f"/api/v1/areas/{area.id}/assignments", headers=admin_headers)
    assert len(list_after.json()) == 0


@pytest.mark.asyncio
async def test_mr_cannot_self_assign_or_manage_territory(async_client: AsyncClient, setup_assignment_env):
    mr_headers = setup_assignment_env["mr_headers"]
    area = setup_assignment_env["area"]
    mr = setup_assignment_env["mr"]

    # MR cannot assign themselves or others
    assign_attempt = await async_client.post(
        f"/api/v1/areas/{area.id}/assignments",
        headers=mr_headers,
        json={"mr_id": str(mr.id)},
    )
    assert assign_attempt.status_code == 403

    # MR cannot unassign
    unassign_attempt = await async_client.delete(
        f"/api/v1/areas/{area.id}/assignments/{mr.id}",
        headers=mr_headers,
    )
    assert unassign_attempt.status_code == 403
