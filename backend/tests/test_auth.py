import uuid
from datetime import timedelta
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, create_token
from app.models.user import User, RoleEnum, UserStatusEnum


@pytest_asyncio.fixture
async def seed_users(db_session: AsyncSession):
    """Seeds test database with active admin and MR accounts."""
    admin_user = User(
        id=uuid.uuid4(),
        email="admin@healix.com",
        password_hash=hash_password("AdminPass123!"),
        full_name="Dr. Admin",
        phone="+919876543210",
        role=RoleEnum.ADMIN,
        status=UserStatusEnum.ACTIVE,
    )
    mr_user = User(
        id=uuid.uuid4(),
        email="mr@healix.com",
        password_hash=hash_password("MrPass123!"),
        full_name="Ravi Kumar (MR)",
        phone="+919876543211",
        role=RoleEnum.MR,
        status=UserStatusEnum.ACTIVE,
    )
    inactive_user = User(
        id=uuid.uuid4(),
        email="inactive@healix.com",
        password_hash=hash_password("InactivePass123!"),
        full_name="Inactive User",
        phone="+919876543212",
        role=RoleEnum.MR,
        status=UserStatusEnum.INACTIVE,
    )

    db_session.add_all([admin_user, mr_user, inactive_user])
    await db_session.commit()
    return {"admin": admin_user, "mr": mr_user, "inactive": inactive_user}


@pytest.mark.asyncio
async def test_successful_login(async_client: AsyncClient, seed_users):
    """Verifies that valid credentials return access token, refresh token, and user profile."""
    response = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "admin@healix.com", "password": "AdminPass123!"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in"] == 900
    assert data["user"]["email"] == "admin@healix.com"
    assert data["user"]["role"] == "ADMIN"


@pytest.mark.asyncio
async def test_login_invalid_password(async_client: AsyncClient, seed_users):
    """Verifies that invalid password returns 401 with generic error message."""
    response = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "admin@healix.com", "password": "WrongPassword!"},
    )
    assert response.status_code == 401
    data = response.json()
    assert data["error"]["message"] == "Invalid email or password"


@pytest.mark.asyncio
async def test_login_unknown_user(async_client: AsyncClient, seed_users):
    """Verifies that non-existent user returns 401 with generic error message."""
    response = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "nonexistent@healix.com", "password": "AnyPassword123!"},
    )
    assert response.status_code == 401
    data = response.json()
    assert data["error"]["message"] == "Invalid email or password"


@pytest.mark.asyncio
async def test_login_inactive_user(async_client: AsyncClient, seed_users):
    """Verifies that inactive user account cannot log in."""
    response = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "inactive@healix.com", "password": "InactivePass123!"},
    )
    assert response.status_code == 403
    data = response.json()
    assert "inactive" in data["error"]["message"].lower()


@pytest.mark.asyncio
async def test_get_current_user_me(async_client: AsyncClient, seed_users):
    """Verifies GET /api/v1/auth/me returns authenticated profile."""
    # 1. Login
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "mr@healix.com", "password": "MrPass123!"},
    )
    token = login_res.json()["access_token"]

    # 2. Access /me with Bearer token
    me_res = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert me_res.status_code == 200
    user_data = me_res.json()
    assert user_data["email"] == "mr@healix.com"
    assert user_data["role"] == "MR"


@pytest.mark.asyncio
async def test_expired_token_rejected(async_client: AsyncClient, seed_users):
    """Verifies that an expired JWT token returns 401."""
    expired_token, _, _ = create_token(
        subject=str(seed_users["admin"].id),
        token_type="access",
        expires_delta=timedelta(seconds=-10),  # expired 10 seconds ago
        additional_claims={"email": "admin@healix.com", "role": "ADMIN"},
    )

    response = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {expired_token}"},
    )
    assert response.status_code == 401
    assert "expired" in response.json()["error"]["message"].lower()


@pytest.mark.asyncio
async def test_refresh_token_rotation_and_revocation(async_client: AsyncClient, seed_users):
    """
    Verifies:
    1. Refresh token exchange issues new access + refresh token
    2. Old refresh token is revoked
    3. Replay of old refresh token fails with 401
    """
    # 1. Login
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "admin@healix.com", "password": "AdminPass123!"},
    )
    refresh_token_1 = login_res.json()["refresh_token"]

    # 2. Refresh token rotation
    refresh_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token_1},
    )
    assert refresh_res.status_code == 200
    refresh_data = refresh_res.json()
    refresh_token_2 = refresh_data["refresh_token"]
    assert refresh_token_2 != refresh_token_1

    # 3. Attempt replay of old refresh token 1 -> MUST BE REJECTED
    replay_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token_1},
    )
    assert replay_res.status_code == 401
    assert "revoked" in replay_res.json()["error"]["message"].lower()


@pytest.mark.asyncio
async def test_logout_and_revocation(async_client: AsyncClient, seed_users):
    """Verifies that logging out revokes active token, blocking subsequent requests."""
    # 1. Login
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "mr@healix.com", "password": "MrPass123!"},
    )
    access_token = login_res.json()["access_token"]

    # 2. Verify token works
    pre_logout_res = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert pre_logout_res.status_code == 200

    # 3. Logout
    logout_res = await async_client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert logout_res.status_code == 200

    # 4. Attempt to use revoked access token -> MUST BE REJECTED
    post_logout_res = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert post_logout_res.status_code == 401
    assert "revoked" in post_logout_res.json()["error"]["message"].lower()


@pytest.mark.asyncio
async def test_refresh_token_revoked_on_logout(async_client: AsyncClient, seed_users):
    """
    SECURITY AUDIT TEST:
    Verifies that /auth/logout revokes both the access token AND the active refresh token.
    A previously stolen or preserved refresh token CANNOT be used after logout.
    """
    # 1. Authenticate user
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "mr@healix.com", "password": "MrPass123!"},
    )
    assert login_res.status_code == 200
    tokens = login_res.json()
    access_token = tokens["access_token"]
    refresh_token = tokens["refresh_token"]

    # 2. Logout providing both access token in auth header and refresh token in body
    logout_res = await async_client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {access_token}"},
        json={"refresh_token": refresh_token},
    )
    assert logout_res.status_code == 200

    # 3. Access token MUST be rejected
    me_res = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert me_res.status_code == 401
    assert "revoked" in me_res.json()["error"]["message"].lower()

    # 4. Refresh token MUST be rejected on /auth/refresh
    refresh_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_res.status_code == 401
    assert "revoked" in refresh_res.json()["error"]["message"].lower()


@pytest.mark.asyncio
async def test_refresh_token_revoked_on_logout_via_session_claim(async_client: AsyncClient, seed_users):
    """
    SECURITY AUDIT TEST (DEFENSE IN DEPTH):
    Verifies that even if the client calls /auth/logout without a body, the server-side
    session correlation claim (refresh_jti) embedded in the access token ensures the
    companion refresh token is revoked on the server.
    """
    # 1. Authenticate user
    login_res = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "admin@healix.com", "password": "AdminPass123!"},
    )
    assert login_res.status_code == 200
    tokens = login_res.json()
    access_token = tokens["access_token"]
    refresh_token = tokens["refresh_token"]

    # 2. Logout with header ONLY (no JSON body)
    logout_res = await async_client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert logout_res.status_code == 200

    # 3. Attempt to use the refresh token -> MUST BE REJECTED
    refresh_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_res.status_code == 401
    assert "revoked" in refresh_res.json()["error"]["message"].lower()


@pytest.mark.asyncio
async def test_logout_with_expired_access_token_revokes_refresh_token(async_client: AsyncClient, seed_users):
    """
    EDGE-CASE SECURITY VERIFICATION:
    1. Valid login session with valid refresh token.
    2. Access token expires.
    3. Verify that accessing /me with expired token returns 401 (access validation is not weakened).
    4. Client calls /auth/logout with expired access token and valid refresh token.
    5. Server verifies cryptographic signature of expired access token and revokes both tokens.
    6. Refresh token cannot subsequently be used to obtain new access tokens on /auth/refresh.
    """
    mr_user = seed_users["mr"]

    # 1. Create a valid refresh token (valid for 7 days)
    refresh_token, refresh_jti, _ = create_token(
        subject=str(mr_user.id),
        token_type="refresh",
        expires_delta=timedelta(days=7),
        additional_claims={"email": mr_user.email, "role": mr_user.role.value},
    )

    # 2. Create an expired access token (expired 60 seconds ago) linked to the refresh token
    expired_access_token, expired_jti, _ = create_token(
        subject=str(mr_user.id),
        token_type="access",
        expires_delta=timedelta(seconds=-60),
        additional_claims={
            "email": mr_user.email,
            "role": mr_user.role.value,
            "refresh_jti": refresh_jti,
        },
    )

    # 3. Verify that standard protected endpoint strictly rejects the expired token
    me_res = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {expired_access_token}"},
    )
    assert me_res.status_code == 401
    assert "expired" in me_res.json()["error"]["message"].lower()

    # 4. Attempt logout using the expired access token + active refresh token
    logout_res = await async_client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {expired_access_token}"},
        json={"refresh_token": refresh_token},
    )
    assert logout_res.status_code == 200
    assert logout_res.json()["success"] is True

    # 5. CRITICAL: Verify the refresh token is now revoked and cannot be used
    refresh_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_res.status_code == 401
    assert "revoked" in refresh_res.json()["error"]["message"].lower()


@pytest.mark.asyncio
async def test_logout_with_expired_access_token_via_session_linkage(async_client: AsyncClient, seed_users):
    """
    EDGE-CASE SECURITY VERIFICATION (SIGNED SESSION LINKAGE):
    Verifies that even if the client only supplies an expired access token without a body,
    the signed session linkage (refresh_jti in the access token's verified claims)
    ensures the active companion refresh token is revoked upon logout.
    """
    admin_user = seed_users["admin"]

    # 1. Create a valid refresh token (valid for 7 days)
    refresh_token, refresh_jti, _ = create_token(
        subject=str(admin_user.id),
        token_type="refresh",
        expires_delta=timedelta(days=7),
        additional_claims={"email": admin_user.email, "role": admin_user.role.value},
    )

    # 2. Create an expired access token (expired 2 hours ago) containing the signed session linkage
    expired_access_token, _, _ = create_token(
        subject=str(admin_user.id),
        token_type="access",
        expires_delta=timedelta(hours=-2),
        additional_claims={
            "email": admin_user.email,
            "role": admin_user.role.value,
            "refresh_jti": refresh_jti,
        },
    )

    # 3. Call logout with only the expired access token header
    logout_res = await async_client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {expired_access_token}"},
    )
    assert logout_res.status_code == 200

    # 4. Verify that the refresh token cannot subsequently be used on /auth/refresh
    refresh_res = await async_client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_res.status_code == 401
    assert "revoked" in refresh_res.json()["error"]["message"].lower()
