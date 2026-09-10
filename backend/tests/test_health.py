import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_root_endpoint(async_client: AsyncClient):
    """Verifies root metadata endpoint."""
    response = await async_client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "service" in data
    assert data["version"] == "1.0.0"
    assert "/api/v1/docs" in data["api_docs"]


@pytest.mark.asyncio
async def test_liveness_health_endpoint(async_client: AsyncClient):
    """Verifies that the root /health and /api/v1/health endpoints report healthy state."""
    for path in ["/health", "/api/v1/health"]:
        response = await async_client.get(path)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["version"] == "1.0.0"
        assert "timestamp" in data


@pytest.mark.asyncio
async def test_readiness_probe(async_client: AsyncClient):
    """Verifies that readiness probes report status and database connectivity."""
    for path in ["/ready", "/api/v1/ready"]:
        response = await async_client.get(path)
        # In test mode or when DB is connected, status should return 200
        assert response.status_code in (200, 503)
        data = response.json()
        assert "status" in data
        assert "database" in data
        assert "version" in data


@pytest.mark.asyncio
async def test_security_headers(async_client: AsyncClient):
    """Verifies OWASP security headers on all HTTP responses."""
    response = await async_client.get("/")
    assert response.headers.get("X-Content-Type-Options") == "nosniff"
    assert response.headers.get("X-Frame-Options") == "DENY"
    assert response.headers.get("X-XSS-Protection") == "1; mode=block"
    assert response.headers.get("Referrer-Policy") == "strict-origin-when-cross-origin"
    assert "X-Request-ID" in response.headers
