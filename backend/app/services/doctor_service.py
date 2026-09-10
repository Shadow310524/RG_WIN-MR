import uuid
from typing import List, Optional, Tuple
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.exceptions import NotFoundException, ConflictException, ForbiddenException
from app.models.doctor import Doctor, DoctorStatusEnum
from app.models.user import User, RoleEnum
from app.repositories.doctor_repo import DoctorRepository
from app.repositories.area_repo import AreaRepository
from app.repositories.association_repo import AssociationRepository
from app.repositories.mr_assignment_repo import MRAssignmentRepository
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.doctor import (
    DoctorCreate,
    DoctorUpdate,
    DoctorRead,
    DoctorListResponse,
    DoctorDuplicateCheckRequest,
    DoctorDuplicateCheckResponse,
)


class DoctorService:
    """
    Core business logic and authorization enforcement for Doctor CRM.
    Enforces strict server-side territory boundaries (BOLA/IDOR protection) and duplicate detection.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.doctor_repo = DoctorRepository(db)
        self.area_repo = AreaRepository(db)
        self.assoc_repo = AssociationRepository(db)
        self.mr_assign_repo = MRAssignmentRepository(db)
        self.audit_repo = AuditLogRepository(db)

    def _to_read_dto(self, doc: Doctor) -> DoctorRead:
        return DoctorRead(
            id=doc.id,
            name=doc.name,
            phone=doc.phone,
            alternate_phone=doc.alternate_phone,
            email=doc.email,
            medical_license_number=doc.medical_license_number,
            specialization=doc.specialization,
            qualification=doc.qualification,
            clinic_name=doc.clinic_name,
            address=doc.address,
            area_id=doc.area_id,
            area_name=doc.area.name if doc.area else None,
            association_id=doc.association_id,
            association_name=doc.association.name if doc.association else None,
            status=doc.status,
            is_active=doc.is_active,
            notes=doc.notes,
            created_at=doc.created_at,
            updated_at=doc.updated_at,
        )

    async def check_duplicate(self, req: DoctorDuplicateCheckRequest) -> DoctorDuplicateCheckResponse:
        dup = await self.doctor_repo.check_duplicate(
            phone=req.phone,
            license_number=req.medical_license_number,
            exclude_doctor_id=req.exclude_doctor_id,
        )
        if dup:
            field, doc = dup
            field_label = "Phone number" if field == "phone" else "Medical license number"
            return DoctorDuplicateCheckResponse(
                is_duplicate=True,
                duplicate_field=field,
                message=f"{field_label} is already registered to Dr. {doc.name}.",
                existing_doctor_id=doc.id,
                existing_doctor_name=doc.name,
                existing_doctor_status=doc.status.value,
            )
        return DoctorDuplicateCheckResponse(is_duplicate=False)

    async def create_doctor(self, data: DoctorCreate, current_user: User) -> DoctorRead:
        # 1. Territory boundary validation
        area = await self.area_repo.get_by_id(data.area_id)
        if not area:
            raise NotFoundException(f"Area '{data.area_id}' not found.", code="AREA_NOT_FOUND")

        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, data.area_id)
            if not is_assigned:
                await self.audit_repo.log_event(
                    action="UNAUTHORIZED_DOCTOR_CREATION_ATTEMPT",
                    entity_type="doctor",
                    actor_id=current_user.id,
                    metadata_json={
                        "target_area_id": str(data.area_id),
                        "doctor_name": data.name,
                    },
                )
                await self.db.commit()
                raise ForbiddenException(
                    "You cannot register a doctor in an area outside your assigned territory.",
                    code="TERRITORY_UNAUTHORIZED",
                )

        # 2. Association verification (if provided)
        if data.association_id:
            assoc = await self.assoc_repo.get_by_id(data.association_id)
            if not assoc:
                raise NotFoundException(f"Association '{data.association_id}' not found.", code="ASSOCIATION_NOT_FOUND")

        # 3. Server-side Duplicate Detection
        dup = await self.doctor_repo.check_duplicate(
            phone=data.phone,
            license_number=data.medical_license_number,
        )
        if dup:
            field, existing_doc = dup
            field_label = "Phone number" if field == "phone" else "Medical license number"
            raise ConflictException(
                f"{field_label} is already registered to Dr. {existing_doc.name}.",
                code="DUPLICATE_DOCTOR",
                details={
                    "field": field,
                    "existing_doctor_id": str(existing_doc.id),
                    "existing_doctor_name": existing_doc.name,
                    "existing_doctor_status": existing_doc.status.value,
                },
            )

        # 4. Create Doctor
        doctor = Doctor(
            name=data.name,
            phone=data.phone,
            alternate_phone=data.alternate_phone,
            email=str(data.email) if data.email else None,
            medical_license_number=data.medical_license_number,
            specialization=data.specialization,
            qualification=data.qualification,
            clinic_name=data.clinic_name,
            address=data.address,
            area_id=data.area_id,
            association_id=data.association_id,
            notes=data.notes,
            status=DoctorStatusEnum.ACTIVE,
            created_by=current_user.id,
        )
        created = await self.doctor_repo.create(doctor)

        await self.audit_repo.log_event(
            action="DOCTOR_CREATED",
            entity_type="doctor",
            actor_id=current_user.id,
            entity_id=str(created.id),
            metadata_json={
                "name": created.name,
                "phone": created.phone,
                "area_id": str(created.area_id),
                "medical_license": created.medical_license_number,
            },
        )
        await self.db.commit()

        # Reload with relations
        reloaded = await self.doctor_repo.get_by_id_with_relations(created.id)
        return self._to_read_dto(reloaded or created)

    async def get_doctor_by_id(self, doctor_id: uuid.UUID, current_user: User) -> DoctorRead:
        doc = await self.doctor_repo.get_by_id_with_relations(doctor_id)
        if not doc:
            raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA/IDOR protection for MR
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
            if not is_assigned:
                await self.audit_repo.log_event(
                    action="BOLA_UNAUTHORIZED_DOCTOR_ACCESS_ATTEMPT",
                    entity_type="doctor",
                    actor_id=current_user.id,
                    entity_id=str(doctor_id),
                    metadata_json={"area_id": str(doc.area_id), "user_email": current_user.email},
                )
                await self.db.commit()
                raise ForbiddenException(
                    "You do not have authorization to view this doctor (outside your assigned territory).",
                    code="TERRITORY_UNAUTHORIZED",
                )

        return self._to_read_dto(doc)

    async def update_doctor(self, doctor_id: uuid.UUID, data: DoctorUpdate, current_user: User) -> DoctorRead:
        doc = await self.doctor_repo.get_by_id_with_relations(doctor_id)
        if not doc:
            raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA/IDOR check: current area
        if current_user.role == RoleEnum.MR:
            is_current_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
            if not is_current_assigned:
                await self.audit_repo.log_event(
                    action="BOLA_UNAUTHORIZED_DOCTOR_UPDATE_ATTEMPT",
                    entity_type="doctor",
                    actor_id=current_user.id,
                    entity_id=str(doctor_id),
                    metadata_json={"current_area_id": str(doc.area_id)},
                )
                await self.db.commit()
                raise ForbiddenException(
                    "You cannot modify a doctor outside your assigned territory.",
                    code="TERRITORY_UNAUTHORIZED",
                )

            # Territory check: destination area
            if data.area_id and data.area_id != doc.area_id:
                is_target_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, data.area_id)
                if not is_target_assigned:
                    await self.audit_repo.log_event(
                        action="UNAUTHORIZED_DOCTOR_AREA_TRANSFER_ATTEMPT",
                        entity_type="doctor",
                        actor_id=current_user.id,
                        entity_id=str(doctor_id),
                        metadata_json={"target_area_id": str(data.area_id)},
                    )
                    await self.db.commit()
                    raise ForbiddenException(
                        "You cannot move a doctor to an unassigned territory area.",
                        code="TERRITORY_UNAUTHORIZED",
                    )

        # Destination area existence check
        if data.area_id and data.area_id != doc.area_id:
            area = await self.area_repo.get_by_id(data.area_id)
            if not area:
                raise NotFoundException(f"Area '{data.area_id}' not found.", code="AREA_NOT_FOUND")
            doc.area_id = data.area_id

        # Association check
        if data.association_id is not None:
            if data.association_id != doc.association_id:
                assoc = await self.assoc_repo.get_by_id(data.association_id)
                if not assoc:
                    raise NotFoundException(f"Association '{data.association_id}' not found.", code="ASSOCIATION_NOT_FOUND")
                doc.association_id = data.association_id

        # Duplicate check on phone or license if changed
        new_phone = data.phone if (data.phone and data.phone != doc.phone) else None
        new_license = (
            data.medical_license_number
            if (data.medical_license_number and data.medical_license_number != doc.medical_license_number)
            else None
        )
        if new_phone or new_license:
            dup = await self.doctor_repo.check_duplicate(
                phone=new_phone,
                license_number=new_license,
                exclude_doctor_id=doc.id,
            )
            if dup:
                field, existing_doc = dup
                field_label = "Phone number" if field == "phone" else "Medical license number"
                raise ConflictException(
                    f"{field_label} is already registered to Dr. {existing_doc.name}.",
                    code="DUPLICATE_DOCTOR",
                    details={
                        "field": field,
                        "existing_doctor_id": str(existing_doc.id),
                        "existing_doctor_name": existing_doc.name,
                    },
                )

        if data.name:
            doc.name = data.name
        if data.phone:
            doc.phone = data.phone
        if data.alternate_phone is not None:
            doc.alternate_phone = data.alternate_phone
        if data.email is not None:
            doc.email = str(data.email) if data.email else None
        if data.medical_license_number:
            doc.medical_license_number = data.medical_license_number
        if data.specialization:
            doc.specialization = data.specialization
        if data.qualification is not None:
            doc.qualification = data.qualification
        if data.clinic_name is not None:
            doc.clinic_name = data.clinic_name
        if data.address is not None:
            doc.address = data.address
        if data.notes is not None:
            doc.notes = data.notes
        if data.status is not None:
            doc.status = data.status

        await self.audit_repo.log_event(
            action="DOCTOR_UPDATED",
            entity_type="doctor",
            actor_id=current_user.id,
            entity_id=str(doc.id),
            metadata_json={"name": doc.name, "area_id": str(doc.area_id)},
        )
        await self.db.commit()

        reloaded = await self.doctor_repo.get_by_id_with_relations(doc.id)
        return self._to_read_dto(reloaded or doc)

    async def set_doctor_status(
        self,
        doctor_id: uuid.UUID,
        status: DoctorStatusEnum,
        current_user: User,
    ) -> DoctorRead:
        doc = await self.doctor_repo.get_by_id_with_relations(doctor_id)
        if not doc:
            raise NotFoundException(f"Doctor '{doctor_id}' not found.", code="DOCTOR_NOT_FOUND")

        # BOLA/IDOR protection
        if current_user.role == RoleEnum.MR:
            is_assigned = await self.mr_assign_repo.is_area_assigned_to_mr(current_user.id, doc.area_id)
            if not is_assigned:
                raise ForbiddenException(
                    "You cannot change the status of a doctor outside your assigned territory.",
                    code="TERRITORY_UNAUTHORIZED",
                )

        doc.status = status
        await self.audit_repo.log_event(
            action="DOCTOR_STATUS_CHANGED",
            entity_type="doctor",
            actor_id=current_user.id,
            entity_id=str(doc.id),
            metadata_json={"status": status.value},
        )
        await self.db.commit()

        reloaded = await self.doctor_repo.get_by_id_with_relations(doc.id)
        return self._to_read_dto(reloaded or doc)

    async def list_doctors(
        self,
        current_user: User,
        area_id: Optional[uuid.UUID] = None,
        association_id: Optional[uuid.UUID] = None,
        status: Optional[DoctorStatusEnum] = None,
        search: Optional[str] = None,
        page: int = 1,
        page_size: int = 50,
    ) -> DoctorListResponse:
        page = max(1, page)
        page_size = min(max(1, page_size), 100)
        skip = (page - 1) * page_size

        allowed_area_ids: Optional[List[uuid.UUID]] = None
        if current_user.role == RoleEnum.MR:
            allowed_area_ids = await self.mr_assign_repo.get_assigned_area_ids_for_mr(current_user.id)
            if area_id and area_id not in allowed_area_ids:
                # Requested specific area not in MR's territory
                return DoctorListResponse(items=[], total=0, page=page, page_size=page_size, total_pages=0)

        doctors, total = await self.doctor_repo.search_and_list(
            allowed_area_ids=allowed_area_ids,
            area_id=area_id,
            association_id=association_id,
            status=status,
            search_query=search,
            skip=skip,
            limit=page_size,
        )

        total_pages = (total + page_size - 1) // page_size if total > 0 else 0
        items = [self._to_read_dto(d) for d in doctors]

        return DoctorListResponse(
            items=items,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages,
        )
