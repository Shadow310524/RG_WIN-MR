from datetime import datetime, timezone
from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = Field(default="healthy", description="Application health status")
    version: str
    environment: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ReadinessResponse(BaseModel):
    status: str = Field(description="'ready' when all dependencies are healthy, else 'not_ready'")
    database: str = Field(description="'connected' or 'disconnected'")
    version: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
