import uuid
from datetime import date, datetime
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict
from app.models.follow_up import FollowUpStatusEnum


class FollowUpBase(BaseModel):
    doctor_id: uuid.UUID
    visit_id: Optional[uuid.UUID] = None
    due_date: date
    status: FollowUpStatusEnum = FollowUpStatusEnum.PENDING
    notes: Optional[str] = None


class FollowUpCreate(FollowUpBase):
    pass


class FollowUpUpdate(BaseModel):
    status: Optional[FollowUpStatusEnum] = None
    due_date: Optional[date] = None
    notes: Optional[str] = None


class FollowUpStatusUpdate(BaseModel):
    status: FollowUpStatusEnum


class FollowUpRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    doctor_id: uuid.UUID
    doctor_name: Optional[str] = None
    clinic_name: Optional[str] = None
    visit_id: Optional[uuid.UUID] = None
    assigned_user_id: uuid.UUID
    due_date: date
    status: FollowUpStatusEnum
    notes: Optional[str] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime


class FollowUpListResponse(BaseModel):
    items: List[FollowUpRead]
    total: int
    page: int
    page_size: int
