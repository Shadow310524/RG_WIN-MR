import uuid
from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.area import Area, AreaStatusEnum
from app.repositories.base import BaseRepository


class AreaRepository(BaseRepository[Area]):
    """Data access repository for territory areas."""

    def __init__(self, db: AsyncSession):
        super().__init__(Area, db)

    async def get_by_code(self, code: str) -> Optional[Area]:
        result = await self.db.execute(select(Area).where(Area.code == code.strip().upper()))
        return result.scalars().first()

    async def get_by_name(self, name: str) -> Optional[Area]:
        result = await self.db.execute(select(Area).where(Area.name == name.strip()))
        return result.scalars().first()

    async def list_areas(
        self,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Area]:
        query = select(Area)
        if is_active is not None:
            status = AreaStatusEnum.ACTIVE if is_active else AreaStatusEnum.ARCHIVED
            query = query.where(Area.status == status)
        query = query.order_by(Area.name.asc()).offset(skip).limit(limit)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def list_by_ids(
        self,
        area_ids: List[uuid.UUID],
        is_active: Optional[bool] = None,
    ) -> List[Area]:
        if not area_ids:
            return []
        query = select(Area).where(Area.id.in_(area_ids))
        if is_active is not None:
            status = AreaStatusEnum.ACTIVE if is_active else AreaStatusEnum.ARCHIVED
            query = query.where(Area.status == status)
        query = query.order_by(Area.name.asc())
        result = await self.db.execute(query)
        return list(result.scalars().all())
