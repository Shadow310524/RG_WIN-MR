import uuid
from typing import List, Optional
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.mr_assignment import MRAreaAssignment
from app.repositories.base import BaseRepository


class MRAssignmentRepository(BaseRepository[MRAreaAssignment]):
    """Data access repository for MR <-> Area territory assignments."""

    def __init__(self, db: AsyncSession):
        super().__init__(MRAreaAssignment, db)

    async def get_assignment(self, mr_id: uuid.UUID, area_id: uuid.UUID) -> Optional[MRAreaAssignment]:
        result = await self.db.execute(
            select(MRAreaAssignment)
            .where(MRAreaAssignment.mr_id == mr_id, MRAreaAssignment.area_id == area_id)
        )
        return result.scalars().first()

    async def is_area_assigned_to_mr(self, mr_id: uuid.UUID, area_id: uuid.UUID) -> bool:
        """Verifies server-side whether an MR is actively assigned to an Area."""
        result = await self.db.execute(
            select(MRAreaAssignment.id).where(
                MRAreaAssignment.mr_id == mr_id,
                MRAreaAssignment.area_id == area_id,
                MRAreaAssignment.is_active.is_(True),
            )
        )
        return result.scalars().first() is not None

    async def get_assigned_area_ids_for_mr(self, mr_id: uuid.UUID) -> List[uuid.UUID]:
        """Returns the list of active area UUIDs assigned to an MR."""
        result = await self.db.execute(
            select(MRAreaAssignment.area_id).where(
                MRAreaAssignment.mr_id == mr_id,
                MRAreaAssignment.is_active.is_(True),
            )
        )
        return list(result.scalars().all())

    async def list_assignments_for_area(self, area_id: uuid.UUID) -> List[MRAreaAssignment]:
        result = await self.db.execute(
            select(MRAreaAssignment)
            .where(MRAreaAssignment.area_id == area_id)
            .options(selectinload(MRAreaAssignment.mr), selectinload(MRAreaAssignment.area))
            .order_by(MRAreaAssignment.created_at.desc())
        )
        return list(result.scalars().all())

    async def list_assignments_for_mr(self, mr_id: uuid.UUID) -> List[MRAreaAssignment]:
        result = await self.db.execute(
            select(MRAreaAssignment)
            .where(MRAreaAssignment.mr_id == mr_id)
            .options(selectinload(MRAreaAssignment.area))
            .order_by(MRAreaAssignment.created_at.desc())
        )
        return list(result.scalars().all())

    async def unassign_mr_from_area(self, mr_id: uuid.UUID, area_id: uuid.UUID) -> bool:
        result = await self.db.execute(
            delete(MRAreaAssignment).where(
                MRAreaAssignment.mr_id == mr_id,
                MRAreaAssignment.area_id == area_id,
            )
        )
        return (result.rowcount or 0) > 0
