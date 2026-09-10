import uuid
from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.association import Association, AssociationStatusEnum
from app.repositories.base import BaseRepository


class AssociationRepository(BaseRepository[Association]):
    """Data access repository for medical associations."""

    def __init__(self, db: AsyncSession):
        super().__init__(Association, db)

    async def get_by_name(self, name: str) -> Optional[Association]:
        result = await self.db.execute(select(Association).where(Association.name == name.strip()))
        return result.scalars().first()

    async def get_by_code(self, code: str) -> Optional[Association]:
        result = await self.db.execute(select(Association).where(Association.code == code.strip().upper()))
        return result.scalars().first()

    async def list_associations(
        self,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Association]:
        query = select(Association)
        if is_active is not None:
            status = AssociationStatusEnum.ACTIVE if is_active else AssociationStatusEnum.ARCHIVED
            query = query.where(Association.status == status)
        query = query.order_by(Association.name.asc()).offset(skip).limit(limit)
        result = await self.db.execute(query)
        return list(result.scalars().all())
