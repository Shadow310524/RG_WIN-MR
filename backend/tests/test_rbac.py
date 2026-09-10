import uuid
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password
from app.models.user import User, RoleEnum, UserStatusEnum


@pytest_asyncio.fixture
async def seed_rbac_users(db_session: AsyncSession):
    """Seeds test database with Admin and MR accounts."""
    admin = User(
        id=uuid.uuid4(),
        email="admin_rbac@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Admin Supervisor",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr = User(
        id=uuid.uuid4(),
        email="mr_rbac@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="Field MR",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    db_session.add_all([admin, mr])
    await db_session.commit()
    return {"admin": admin, "mr": mr}


@pytest.mark.asyncio
async def test_unauthorized_request_rejected(async_client: AsyncClient):
    """Verifies that protected routes reject unauthenticated requests with 401."""
    response = await async_client.get("/api/v1/auth/me")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_admin_authorization_allowed(async_client: AsyncClient, seed_rbac_users):
    """Verifies that ADMIN user is authorized on admin-only endpoints."""
    # Login as Admin
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "admin_rbac@healix.com", "password": "AdminPass123!"},
    )
    admin_token = login_res.json()["access_token"]

    response = await async_client.get(
        "/api/v1/auth/admin-only",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert response.status_code == 200
    assert response.json()["status"] == "authorized"
    assert response.json()["role"] == "ADMIN"


@pytest.mark.asyncio
async def test_mr_forbidden_on_admin_endpoint(async_client: AsyncClient, seed_rbac_users):
    """
    CRITICAL OWASP BOLA/IDOR RULE:
    Server-side authorization must reject MR users attempting to access ADMIN-only routes with 403 Forbidden.
    """
    # Login as MR
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "mr_rbac@healix.com", "password": "MrPass123!"},
    )
    mr_token = login_res.json()["access_token"]

    response = await async_client.get(
        "/api/v1/auth/admin-only",
        headers={"Authorization": f"Bearer {mr_token}"},
    )
    assert response.status_code == 403
    error_data = response.json()
    assert error_data["error"]["code"] == "INSUFFICIENT_PERMISSIONS"


@pytest.mark.asyncio
async def test_rate_limiting_enforced(async_client: AsyncClient):
    """
    Verifies that excessive login attempts from the same client IP trigger 429 Too Many Requests.
    """
    # Limit is 20/minute. We trigger requests until 429 occurs
    hit_429 = False
    for _ in range(25):
        res = await async_client.post(
            "/api/v1/auth/login",
            json={"email": "attempt@healix.com", "password": "BadPassword123!"},
        )
        if res.status_code == 429:
            hit_429 = True
            assert res.json()["error"]["code"] == "RATE_LIMIT_EXCEEDED"
            break

    assert hit_429 is True, "Rate limiter should have returned 429 on excessive requests"
