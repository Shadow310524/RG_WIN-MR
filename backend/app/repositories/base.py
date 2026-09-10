from typing import Generic, TypeVar, Type, Optional, List, Any
import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, func
from app.models.base import Base

ModelT = TypeVar("ModelT", bound=Base)


class BaseRepository(Generic[ModelT]):
    """Generic async repository providing standard CRUD access patterns."""

    def __init__(self, model: Type[ModelT], db: AsyncSession):
        self.model = model
        self.db = db

    async def get_by_id(self, id: uuid.UUID | int) -> Optional[ModelT]:
        """Retrieves a single entity by its primary key."""
        result = await self.db.execute(select(self.model).where(self.model.id == id))
        return result.scalars().first()

    async def list(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[List[Any]] = None,
        order_by: Optional[Any] = None,
    ) -> List[ModelT]:
        """Returns paginated entities matching given filters."""
        query = select(self.model)
        if filters:
            for f in filters:
                query = query.where(f)
        if order_by is not None:
            query = query.order_by(order_by)
        query = query.offset(skip).limit(limit)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def count(self, filters: Optional[List[Any]] = None) -> int:
        """Returns the total number of records matching filters."""
        query = select(func.count()).select_from(self.model)
        if filters:
            for f in filters:
                query = query.where(f)
        result = await self.db.execute(query)
        return result.scalar() or 0

    async def create(self, entity: ModelT) -> ModelT:
        """Persists a new entity to the database."""
        self.db.add(entity)
        await self.db.flush()
        await self.db.refresh(entity)
        return entity

    async def delete(self, id: uuid.UUID | int) -> bool:
        """Deletes an entity by its primary key."""
        result = await self.db.execute(delete(self.model).where(self.model.id == id))
        return (result.rowcount or 0) > 0
