from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError

from app.core.config import settings
from app.core.logging import logger
from app.core.middleware import SecurityHeadersMiddleware, RequestIdMiddleware
from app.core.exceptions import (
    RGWinException,
    rgwin_exception_handler,
    validation_exception_handler,
    unhandled_exception_handler,
)
from app.core.rate_limit import limiter, rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.core.database import check_database_connection
from app.api.v1.router import api_router
from app.api.v1.endpoints.health import router as health_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager for application startup and shutdown procedures."""
    logger.info(
        f"Starting {settings.PROJECT_NAME} v{settings.VERSION} [{settings.ENVIRONMENT}]",
        extra={"extra": {"environment": settings.ENVIRONMENT, "version": settings.VERSION}},
    )
    # Check DB connection on startup
    db_connected = await check_database_connection()
    if db_connected:
        logger.info("Database connectivity established successfully.")
    else:
        logger.warning("Database connectivity could not be verified on startup. Check DATABASE_URL.")

    yield

    logger.info(f"Shutting down {settings.PROJECT_NAME}.")


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
    lifespan=lifespan,
)

# 1. Request ID Correlation (First to trace everything)
app.add_middleware(RequestIdMiddleware)

# 2. Security Headers (OWASP)
app.add_middleware(SecurityHeadersMiddleware)

# 3. CORS Configuration (Explicit origins, never allow_origins=['*'])
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["X-Request-ID"],
)

# 4. Centralized Exception Handlers (Safe client errors, server logging)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)
app.add_exception_handler(RGWinException, rgwin_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, unhandled_exception_handler)

# 5. Root-level Health Probes (for Docker/K8s/Load Balancers)
app.include_router(health_router)

# 6. Versioned API Router (/api/v1)
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", tags=["Root"])
def root():
    """Root metadata endpoint."""
    return {
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "api_docs": f"{settings.API_V1_STR}/docs",
    }
