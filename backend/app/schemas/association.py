import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.association import AssociationStatusEnum


class AssociationCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=200, description="Full association name, e.g. Indian Medical Association")
    code: Optional[str] = Field(None, max_length=50, description="Unique short association code, e.g. IMA")
    short_name: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = None
    notes: Optional[str] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        trimmed = v.strip()
        if not trimmed:
            raise ValueError("Association name cannot be blank")
        return trimmed

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip().upper()
            return trimmed if trimmed else None
        return None


class AssociationUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=200)
    code: Optional[str] = Field(None, max_length=50)
    short_name: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = None
    status: Optional[AssociationStatusEnum] = None
    notes: Optional[str] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip()
            if not trimmed:
                raise ValueError("Association name cannot be blank")
            return trimmed
        return v

    @field_validator("code")
    @classmethod
    def validate_code(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip().upper()
            return trimmed if trimmed else None
        return None


class AssociationStatusUpdate(BaseModel):
    status: AssociationStatusEnum


class AssociationRead(BaseModel):
    id: uuid.UUID
    name: str
    code: Optional[str] = None
    short_name: Optional[str] = None
    description: Optional[str] = None
    status: AssociationStatusEnum
    is_active: bool
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
