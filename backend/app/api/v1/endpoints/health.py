from fastapi import APIRouter, status, Response
from app.schemas.health import HealthResponse, ReadinessResponse
from app.services.health_service import HealthService

router = APIRouter(tags=["Health & Diagnostics"])


@router.get("/health", response_model=HealthResponse, summary="Liveness Probe")
def get_health() -> HealthResponse:
    """Returns application liveness state."""
    return HealthService.get_health()


@router.get("/ready", response_model=ReadinessResponse, summary="Readiness Probe")
async def get_readiness(response: Response) -> ReadinessResponse:
    """Verifies that all required dependencies (database) are ready to accept traffic."""
    readiness = await HealthService.get_readiness()
    if readiness.status != "ready":
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    return readiness
