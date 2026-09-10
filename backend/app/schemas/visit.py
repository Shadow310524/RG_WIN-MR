import uuid
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict
from app.models.visit import VisitTypeEnum, DoctorResponseEnum, PrescriptionPotentialEnum


class VisitBase(BaseModel):
    doctor_id: uuid.UUID
    visit_datetime: datetime
    visit_type: VisitTypeEnum = VisitTypeEnum.REGULAR_VISIT
    doctor_response: DoctorResponseEnum = DoctorResponseEnum.POSITIVE
    prescription_potential: PrescriptionPotentialEnum = PrescriptionPotentialEnum.MEDIUM
    doctor_feedback: Optional[str] = None
    notes: Optional[str] = None
    discussed_products: Optional[str] = None
    samples_given: Optional[str] = None
    purchase_opportunity: bool = False
    client_operation_id: Optional[uuid.UUID] = None


class VisitCreate(VisitBase):
    pass


class VisitRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    doctor_id: uuid.UUID
    doctor_name: Optional[str] = None
    clinic_name: Optional[str] = None
    specialization: Optional[str] = None
    user_id: uuid.UUID
    visit_datetime: datetime
    visit_type: str
    doctor_response: str
    prescription_potential: str
    doctor_feedback: Optional[str] = None
    notes: Optional[str] = None
    discussed_products: Optional[str] = None
    samples_given: Optional[str] = None
    purchase_opportunity: bool = False
    client_operation_id: Optional[uuid.UUID] = None
    created_at: datetime
    updated_at: datetime


class VisitListResponse(BaseModel):
    items: List[VisitRead]
    total: int
    page: int
    page_size: int
