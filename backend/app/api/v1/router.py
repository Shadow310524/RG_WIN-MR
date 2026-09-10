from fastapi import APIRouter
from app.api.v1.endpoints import health, auth, areas, associations, doctors, visits, follow_ups, sales

api_router = APIRouter()

# Register endpoint routers
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(areas.router)
api_router.include_router(associations.router)
api_router.include_router(doctors.router)
api_router.include_router(visits.router)
api_router.include_router(follow_ups.router)
api_router.include_router(sales.router)
