import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.area import AreaStatusEnum


class AreaCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100, description="Unique area name, e.g. Anna Nagar")
    code: str = Field(..., min_length=2, max_length=50, description="Unique territory code, e.g. CHEN-AN-01")
    description: Optional[str] = Field(None, max_length=255)

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        trimmed = v.strip()
        if not trimmed:
            raise ValueError("Area name cannot be blank")
        return trimmed

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: str) -> str:
        trimmed = v.strip().upper()
        if not trimmed:
            raise ValueError("Area code cannot be blank")
        return trimmed


class AreaUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    code: Optional[str] = Field(None, min_length=2, max_length=50)
    description: Optional[str] = Field(None, max_length=255)
    status: Optional[AreaStatusEnum] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip()
            if not trimmed:
                raise ValueError("Area name cannot be blank")
            return trimmed
        return v

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip().upper()
            if not trimmed:
                raise ValueError("Area code cannot be blank")
            return trimmed
        return v


class AreaStatusUpdate(BaseModel):
    status: AreaStatusEnum


class AreaRead(BaseModel):
    id: uuid.UUID
    name: str
    code: str
    description: Optional[str] = None
    status: AreaStatusEnum
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MRAssignmentCreate(BaseModel):
    mr_id: uuid.UUID


class MRAssignmentRead(BaseModel):
    id: uuid.UUID
    mr_id: uuid.UUID
    area_id: uuid.UUID
    is_active: bool
    created_at: datetime
    mr_name: Optional[str] = None
    mr_email: Optional[str] = None
    area_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
