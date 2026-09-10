import uuid
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, create_access_token
from app.models.user import User, RoleEnum, UserStatusEnum


@pytest_asyncio.fixture
async def setup_association_users(db_session: AsyncSession):
    admin = User(
        id=uuid.uuid4(),
        email="admin_assoc@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Admin Assoc",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr = User(
        id=uuid.uuid4(),
        email="mr_assoc@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="MR Assoc Rep",
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
async def test_admin_association_crud(async_client: AsyncClient, setup_association_users):
    headers = setup_association_users["admin_headers"]

    # 1. Create
    res = await async_client.post(
        "/api/v1/associations",
        headers=headers,
        json={
            "name": "Indian Medical Association",
            "code": "IMA",
            "description": "National organization of doctors",
        },
    )
    assert res.status_code == 201
    data = res.json()
    assert data["name"] == "Indian Medical Association"
    assert data["code"] == "IMA"
    assert data["is_active"] is True
    assoc_id = data["id"]

    # 2. Update
    up_res = await async_client.put(
        f"/api/v1/associations/{assoc_id}",
        headers=headers,
        json={"notes": "Key partner for clinical seminars"},
    )
    assert up_res.status_code == 200
    assert up_res.json()["notes"] == "Key partner for clinical seminars"

    # 3. Duplicate name check
    dup_res = await async_client.post(
        "/api/v1/associations",
        headers=headers,
        json={"name": "Indian Medical Association", "code": "IMA2"},
    )
    assert dup_res.status_code == 409
    assert dup_res.json()["error"]["code"] == "DUPLICATE_ASSOCIATION_NAME"

    # 4. Status change
    st_res = await async_client.patch(
        f"/api/v1/associations/{assoc_id}/status",
        headers=headers,
        json={"status": "ARCHIVED"},
    )
    assert st_res.status_code == 200
    assert st_res.json()["is_active"] is False


@pytest.mark.asyncio
async def test_mr_association_permissions(async_client: AsyncClient, setup_association_users):
    admin_headers = setup_association_users["admin_headers"]
    mr_headers = setup_association_users["mr_headers"]

    # Admin creates association
    create_res = await async_client.post(
        "/api/v1/associations",
        headers=admin_headers,
        json={"name": "Federation of Obstetric and Gynaecological Societies", "code": "FOGSI"},
    )
    assert create_res.status_code == 201
    assoc_id = create_res.json()["id"]

    # MR can list associations
    list_res = await async_client.get("/api/v1/associations", headers=mr_headers)
    assert list_res.status_code == 200
    names = [a["name"] for a in list_res.json()]
    assert "Federation of Obstetric and Gynaecological Societies" in names

    # MR can view association
    view_res = await async_client.get(f"/api/v1/associations/{assoc_id}", headers=mr_headers)
    assert view_res.status_code == 200

    # MR cannot create association
    mr_create = await async_client.post(
        "/api/v1/associations",
        headers=mr_headers,
        json={"name": "Unauthorized Assoc"},
    )
    assert mr_create.status_code == 403

    # MR cannot update association
    mr_update = await async_client.put(
        f"/api/v1/associations/{assoc_id}",
        headers=mr_headers,
        json={"name": "Hacked Name"},
    )
    assert mr_update.status_code == 403
