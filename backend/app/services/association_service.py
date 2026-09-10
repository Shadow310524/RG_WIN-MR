import uuid
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.exceptions import NotFoundException, ConflictException
from app.models.association import Association, AssociationStatusEnum
from app.repositories.association_repo import AssociationRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.association import AssociationCreate, AssociationUpdate


class AssociationService:
    """Business logic for Medical Association masters."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.assoc_repo = AssociationRepository(db)
        self.audit_repo = AuditLogRepository(db)

    async def create_association(self, data: AssociationCreate, actor_id: uuid.UUID) -> Association:
        existing_name = await self.assoc_repo.get_by_name(data.name)
        if existing_name:
            raise ConflictException(
                f"Association with name '{data.name}' already exists.",
                code="DUPLICATE_ASSOCIATION_NAME",
            )

        if data.code:
            existing_code = await self.assoc_repo.get_by_code(data.code)
            if existing_code:
                raise ConflictException(
                    f"Association with code '{data.code}' already exists.",
                    code="DUPLICATE_ASSOCIATION_CODE",
                )

        assoc = Association(
            name=data.name,
            code=data.code,
            short_name=data.short_name or data.code,
            description=data.description,
            notes=data.notes,
            status=AssociationStatusEnum.ACTIVE,
        )
        created = await self.assoc_repo.create(assoc)

        await self.audit_repo.log_event(
            action="ASSOCIATION_CREATED",
            entity_type="association",
            actor_id=actor_id,
            entity_id=str(created.id),
            metadata_json={"name": created.name, "code": created.code},
        )
        await self.db.commit()
        await self.db.refresh(created)
        return created

    async def update_association(self, id: uuid.UUID, data: AssociationUpdate, actor_id: uuid.UUID) -> Association:
        assoc = await self.assoc_repo.get_by_id(id)
        if not assoc:
            raise NotFoundException(f"Association '{id}' not found.", code="ASSOCIATION_NOT_FOUND")

        if data.name and data.name != assoc.name:
            existing_name = await self.assoc_repo.get_by_name(data.name)
            if existing_name and existing_name.id != assoc.id:
                raise ConflictException(
                    f"Association with name '{data.name}' already exists.",
                    code="DUPLICATE_ASSOCIATION_NAME",
                )
            assoc.name = data.name

        if data.code and data.code != assoc.code:
            existing_code = await self.assoc_repo.get_by_code(data.code)
            if existing_code and existing_code.id != assoc.id:
                raise ConflictException(
                    f"Association with code '{data.code}' already exists.",
                    code="DUPLICATE_ASSOCIATION_CODE",
                )
            assoc.code = data.code

        if data.short_name is not None:
            assoc.short_name = data.short_name
        if data.description is not None:
            assoc.description = data.description
        if data.notes is not None:
            assoc.notes = data.notes
        if data.status is not None:
            assoc.status = data.status

        await self.audit_repo.log_event(
            action="ASSOCIATION_UPDATED",
            entity_type="association",
            actor_id=actor_id,
            entity_id=str(assoc.id),
            metadata_json={"name": assoc.name, "status": assoc.status.value},
        )
        await self.db.commit()
        await self.db.refresh(assoc)
        return assoc

    async def set_association_status(self, id: uuid.UUID, status: AssociationStatusEnum, actor_id: uuid.UUID) -> Association:
        assoc = await self.assoc_repo.get_by_id(id)
        if not assoc:
            raise NotFoundException(f"Association '{id}' not found.", code="ASSOCIATION_NOT_FOUND")

        assoc.status = status
        await self.audit_repo.log_event(
            action="ASSOCIATION_STATUS_CHANGED",
            entity_type="association",
            actor_id=actor_id,
            entity_id=str(assoc.id),
            metadata_json={"status": status.value},
        )
        await self.db.commit()
        await self.db.refresh(assoc)
        return assoc

    async def get_association_by_id(self, id: uuid.UUID) -> Association:
        assoc = await self.assoc_repo.get_by_id(id)
        if not assoc:
            raise NotFoundException(f"Association '{id}' not found.", code="ASSOCIATION_NOT_FOUND")
        return assoc

    async def list_associations(
        self,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Association]:
        return await self.assoc_repo.list_associations(is_active=is_active, skip=skip, limit=limit)
