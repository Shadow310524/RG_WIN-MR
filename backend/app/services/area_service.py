import uuid
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.exceptions import NotFoundException, ConflictException, ForbiddenException
from app.models.area import Area, AreaStatusEnum
from app.models.mr_assignment import MRAreaAssignment
from app.models.user import User, RoleEnum, UserStatusEnum
from app.repositories.area_repo import AreaRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.repositories.user_repo import UserRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.area import AreaCreate, AreaUpdate, MRAssignmentRead


class AreaService:
    """Business logic and authorization boundary for Area and territory assignment management."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.area_repo = AreaRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)
        self.user_repo = UserRepository(db)
        self.audit_repo = AuditLogRepository(db)

    async def create_area(self, data: AreaCreate, actor_id: uuid.UUID) -> Area:
        # Check duplicate code
        existing_code = await self.area_repo.get_by_code(data.code)
        if existing_code:
            raise ConflictException(
                f"Area with code '{data.code}' already exists.",
                code="DUPLICATE_AREA_CODE",
            )

        # Check duplicate name
        existing_name = await self.area_repo.get_by_name(data.name)
        if existing_name:
            raise ConflictException(
                f"Area with name '{data.name}' already exists.",
                code="DUPLICATE_AREA_NAME",
            )

        area = Area(
            name=data.name,
            code=data.code,
            description=data.description,
            status=AreaStatusEnum.ACTIVE,
        )
        created = await self.area_repo.create(area)

        await self.audit_repo.log_event(
            action="AREA_CREATED",
            entity_type="area",
            actor_id=actor_id,
            entity_id=str(created.id),
            metadata_json={"name": created.name, "code": created.code},
        )
        await self.db.commit()
        await self.db.refresh(created)
        return created

    async def update_area(self, area_id: uuid.UUID, data: AreaUpdate, actor_id: uuid.UUID) -> Area:
        area = await self.area_repo.get_by_id(area_id)
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        if data.code and data.code != area.code:
            existing_code = await self.area_repo.get_by_code(data.code)
            if existing_code and existing_code.id != area.id:
                raise ConflictException(
                    f"Area with code '{data.code}' already exists.",
                    code="DUPLICATE_AREA_CODE",
                )
            area.code = data.code

        if data.name and data.name != area.name:
            existing_name = await self.area_repo.get_by_name(data.name)
            if existing_name and existing_name.id != area.id:
                raise ConflictException(
                    f"Area with name '{data.name}' already exists.",
                    code="DUPLICATE_AREA_NAME",
                )
            area.name = data.name

        if data.description is not None:
            area.description = data.description

        if data.status is not None:
            area.status = data.status

        await self.audit_repo.log_event(
            action="AREA_UPDATED",
            entity_type="area",
            actor_id=actor_id,
            entity_id=str(area.id),
            metadata_json={"name": area.name, "code": area.code, "status": area.status.value},
        )
        await self.db.commit()
        await self.db.refresh(area)
        return area

    async def set_area_status(self, area_id: uuid.UUID, status: AreaStatusEnum, actor_id: uuid.UUID) -> Area:
        area = await self.area_repo.get_by_id(area_id)
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        area.status = status
        await self.audit_repo.log_event(
            action="AREA_STATUS_CHANGED",
            entity_type="area",
            actor_id=actor_id,
            entity_id=str(area.id),
            metadata_json={"status": status.value},
        )
        await self.db.commit()
        await self.db.refresh(area)
        return area

    async def get_area_by_id(self, area_id: uuid.UUID, current_user: User) -> Area:
        area = await self.area_repo.get_by_id(area_id)
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        # Territory restriction for MR
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, area_id)
            if not is_assigned:
                await self.audit_repo.log_event(
                    action="UNAUTHORIZED_AREA_ACCESS_ATTEMPT",
                    entity_type="area",
                    actor_id=current_user.id,
                    entity_id=str(area_id),
                    metadata_json={"user_email": current_user.email},
                )
                await self.db.commit()
                raise ForbiddenException("You are not assigned to this territory area.", code="TERRITORY_UNAUTHORIZED")

        return area

    async def list_areas(
        self,
        current_user: User,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Area]:
        """
        Admins list all areas.
        MRs are strictly restricted to areas assigned to them in the database.
        """
        if current_user.role == RoleEnum.ADMIN:
            return await self.area_repo.list_areas(is_active=is_active, skip=skip, limit=limit)
        else:
            assigned_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
            return await self.area_repo.list_by_ids(assigned_ids, is_active=is_active)

    async def assign_mr_to_area(self, area_id: uuid.UUID, mr_id: uuid.UUID, actor_id: uuid.UUID) -> MRAssignmentRead:
        area = await self.area_repo.get_by_id(area_id)
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        target_user = await self.user_repo.get_by_id(mr_id)
        if not target_user or target_user.role != RoleEnum.MR:
            raise NotFoundException(f"Medical Representative '{mr_id}' not found.", code="MR_NOT_FOUND")

        existing = await self.mr_assign_repo.get_assignment(mr_id, area_id)
        if existing and existing.is_active:
            raise ConflictException(
                "MR is already actively assigned to this area.",
                code="DUPLICATE_ASSIGNMENT",
            )

        if existing:
            existing.is_active = True
            assignment = existing
        else:
            assignment = MRAreaAssignment(
                mr_id=mr_id,
                area_id=area_id,
                is_active=True,
            )
            assignment = await self.mr_assign_repo.create(assignment)

        await self.audit_repo.log_event(
            action="MR_AREA_ASSIGNED",
            entity_type="mr_area_assignment",
            actor_id=actor_id,
            entity_id=str(assignment.id),
            metadata_json={"mr_id": str(mr_id), "area_id": str(area_id), "area_name": area.name},
        )
        await self.db.commit()
        await self.db.refresh(assignment)

        return MRAssignmentRead(
            id=assignment.id,
            mr_id=assignment.mr_id,
            area_id=assignment.area_id,
            is_active=assignment.is_active,
            created_at=assignment.created_at,
            mr_name=target_user.full_name,
            mr_email=target_user.email,
            area_name=area.name,
        )

    async def unassign_mr_from_area(self, area_id: uuid.UUID, mr_id: uuid.UUID, actor_id: uuid.UUID) -> bool:
        area = await self.area_repo.get_by_id(area_id)
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        deleted = await self.mr_assign_repo.unassign_mr_from_area(mr_id, area_id)
        if not deleted:
            raise NotFoundException("Assignment record not found.", code="ASSIGNMENT_NOT_FOUND")

        await self.audit_repo.log_event(
            action="MR_AREA_UNASSIGNED",
            entity_type="mr_area_assignment",
            actor_id=actor_id,
            entity_id=f"{mr_id}:{area_id}",
            metadata_json={"mr_id": str(mr_id), "area_id": str(area_id)},
        )
        await self.db.commit()
        return True

    async def list_area_assignments(self, area_id: uuid.UUID) -> List[MRAssignmentRead]:
        area = await self.area_repo.get_by_id(area_id)
        if not area:
            raise NotFoundException(f"Area '{area_id}' not found.", code="AREA_NOT_FOUND")

        assignments = await self.mr_assign_repo.list_assignments_for_area(area_id)
        return [
            MRAssignmentRead(
                id=a.id,
                mr_id=a.mr_id,
                area_id=a.area_id,
                is_active=a.is_active,
                created_at=a.created_at,
                mr_name=a.mr.full_name if a.mr else None,
                mr_email=a.mr.email if a.mr else None,
                area_name=area.name,
            )
            for a in assignments
        ]
