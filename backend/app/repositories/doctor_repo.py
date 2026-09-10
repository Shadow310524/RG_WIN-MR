import uuid
from typing import List, Optional, Tuple
from sqlalchemy import select, func, or_
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.doctor import Doctor, DoctorStatusEnum
from app.repositories.base import BaseRepository


class DoctorRepository(BaseRepository[Doctor]):
    """Data access repository for doctors with search, filtering, and territory scoping."""

    def __init__(self, db: AsyncSession):
        super().__init__(Doctor, db)

    async def get_by_id_with_relations(self, doctor_id: uuid.UUID) -> Optional[Doctor]:
        result = await self.db.execute(
            select(Doctor)
            .where(Doctor.id == doctor_id)
            .options(selectinload(Doctor.area), selectinload(Doctor.association))
        )
        return result.scalars().first()

    async def get_by_phone(self, phone: str, active_only: bool = True) -> Optional[Doctor]:
        query = select(Doctor).where(Doctor.phone == phone)
        if active_only:
            query = query.where(Doctor.status == DoctorStatusEnum.ACTIVE)
        result = await self.db.execute(query)
        return result.scalars().first()

    async def get_by_license(self, license_number: str, active_only: bool = True) -> Optional[Doctor]:
        query = select(Doctor).where(Doctor.medical_license_number == license_number.strip().upper())
        if active_only:
            query = query.where(Doctor.status == DoctorStatusEnum.ACTIVE)
        result = await self.db.execute(query)
        return result.scalars().first()

    async def check_duplicate(
        self,
        phone: Optional[str] = None,
        license_number: Optional[str] = None,
        exclude_doctor_id: Optional[uuid.UUID] = None,
    ) -> Optional[Tuple[str, Doctor]]:
        """
        Checks whether another active doctor already exists with the given phone or license number.
        Returns (field_name, doctor) if a duplicate is found, else None.
        """
        if phone:
            query = select(Doctor).where(
                Doctor.phone == phone,
                Doctor.status == DoctorStatusEnum.ACTIVE,
            )
            if exclude_doctor_id:
                query = query.where(Doctor.id != exclude_doctor_id)
            res = await self.db.execute(query)
            doc = res.scalars().first()
            if doc:
                return ("phone", doc)

        if license_number:
            query = select(Doctor).where(
                Doctor.medical_license_number == license_number.strip().upper(),
                Doctor.status == DoctorStatusEnum.ACTIVE,
            )
            if exclude_doctor_id:
                query = query.where(Doctor.id != exclude_doctor_id)
            res = await self.db.execute(query)
            doc = res.scalars().first()
            if doc:
                return ("medical_license_number", doc)

        return None

    async def search_and_list(
        self,
        allowed_area_ids: Optional[List[uuid.UUID]] = None,
        area_id: Optional[uuid.UUID] = None,
        association_id: Optional[uuid.UUID] = None,
        status: Optional[DoctorStatusEnum] = None,
        search_query: Optional[str] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> Tuple[List[Doctor], int]:
        """
        Queries doctors with territory scoping, multi-field search, and pagination.
        If allowed_area_ids is provided (e.g. for MR users), strictly filters by those areas.
        """
        base_query = select(Doctor)
        count_query = select(func.count()).select_from(Doctor)

        filters = []

        # Territory restriction (server-side boundary enforcement)
        if allowed_area_ids is not None:
            if not allowed_area_ids:
                return ([], 0)
            filters.append(Doctor.area_id.in_(allowed_area_ids))

        # Filter by specific area
        if area_id:
            filters.append(Doctor.area_id == area_id)

        # Filter by association
        if association_id:
            filters.append(Doctor.association_id == association_id)

        # Filter by status
        if status:
            filters.append(Doctor.status == status)

        # Search across name, phone, license, clinic
        if search_query:
            term = f"%{search_query.strip()}%"
            filters.append(
                or_(
                    Doctor.name.ilike(term),
                    Doctor.phone.ilike(term),
                    Doctor.medical_license_number.ilike(term),
                    Doctor.clinic_name.ilike(term),
                    Doctor.specialization.ilike(term),
                )
            )

        for f in filters:
            base_query = base_query.where(f)
            count_query = count_query.where(f)

        # Count total matching
        total_res = await self.db.execute(count_query)
        total = total_res.scalar() or 0

        # Fetch page with eager loaded relations
        base_query = (
            base_query.options(selectinload(Doctor.area), selectinload(Doctor.association))
            .order_by(Doctor.name.asc())
            .offset(skip)
            .limit(limit)
        )
        res = await self.db.execute(base_query)
        items = list(res.scalars().all())

        return (items, total)
