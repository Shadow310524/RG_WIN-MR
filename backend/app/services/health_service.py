from datetime import datetime, timezone
from app.core.config import settings
from app.core.database import check_database_connection
from app.schemas.health import HealthResponse, ReadinessResponse


class HealthService:
    """Service handling health and readiness assessments."""

    @staticmethod
    def get_health() -> HealthResponse:
        """Returns standard liveness health check data."""
        return HealthResponse(
            status="healthy",
            version=settings.VERSION,
            environment=settings.ENVIRONMENT,
            timestamp=datetime.now(timezone.utc),
        )

    @staticmethod
    async def get_readiness() -> ReadinessResponse:
        """Checks dependencies (PostgreSQL database) and returns readiness status."""
        db_ok = await check_database_connection()
        return ReadinessResponse(
            status="ready" if db_ok else "not_ready",
            database="connected" if db_ok else "disconnected",
            version=settings.VERSION,
            timestamp=datetime.now(timezone.utc),
        )
