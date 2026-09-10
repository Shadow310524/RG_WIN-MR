import re
import uuid
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator
from app.models.doctor import DoctorStatusEnum


def normalize_phone(v: str) -> str:
    """Normalizes phone numbers by stripping whitespace, hyphens, parentheses, and dots."""
    cleaned = re.sub(r"[\s\-\(\)\.]", "", v)
    if not cleaned:
        raise ValueError("Phone number cannot be empty")
    # Digits check (allowing leading +)
    if not re.match(r"^\+?[0-9]{10,15}$", cleaned):
        raise ValueError("Invalid phone number format. Must contain 10 to 15 digits.")
    return cleaned


def normalize_license(v: str) -> str:
    """Normalizes medical license numbers by stripping whitespace and upper-casing."""
    cleaned = re.sub(r"\s+", " ", v.strip()).upper()
    if not cleaned or len(cleaned) < 3:
        raise ValueError("Medical license number must be at least 3 characters")
    return cleaned


class DoctorCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=255, description="Doctor full name, e.g. Dr. Anitha Ramesh")
    phone: str = Field(..., description="Primary phone number (normalized)")
    alternate_phone: Optional[str] = Field(None, description="Optional alternate contact phone")
    email: Optional[EmailStr] = Field(None, description="Doctor email address")
    medical_license_number: str = Field(..., min_length=3, max_length=100, description="Unique medical registration license")
    specialization: str = Field(..., min_length=2, max_length=150, description="Medical specialization, e.g. Cardiology, Pediatrics")
    qualification: Optional[str] = Field(None, max_length=150, description="Qualifications, e.g. MBBS, MD, DM")
    clinic_name: Optional[str] = Field(None, max_length=255, description="Clinic or hospital name")
    address: Optional[str] = Field(None, max_length=500)
    area_id: uuid.UUID = Field(..., description="Assigned territory Area UUID")
    association_id: Optional[uuid.UUID] = Field(None, description="Primary medical association affiliation UUID")
    notes: Optional[str] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        trimmed = v.strip()
        if not trimmed:
            raise ValueError("Doctor name cannot be blank")
        return trimmed

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        return normalize_phone(v)

    @field_validator("alternate_phone")
    @classmethod
    def validate_alt_phone(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v.strip():
            return normalize_phone(v)
        return None

    @field_validator("medical_license_number")
    @classmethod
    def validate_license(cls, v: str) -> str:
        return normalize_license(v)

    @field_validator("specialization")
    @classmethod
    def validate_specialization(cls, v: str) -> str:
        trimmed = v.strip()
        if not trimmed:
            raise ValueError("Specialization cannot be blank")
        return trimmed

    @field_validator("clinic_name", "qualification", "address")
    @classmethod
    def trim_optional_strings(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip()
            return trimmed if trimmed else None
        return None


class DoctorUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=255)
    phone: Optional[str] = None
    alternate_phone: Optional[str] = None
    email: Optional[EmailStr] = None
    medical_license_number: Optional[str] = None
    specialization: Optional[str] = Field(None, min_length=2, max_length=150)
    qualification: Optional[str] = Field(None, max_length=150)
    clinic_name: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = Field(None, max_length=500)
    area_id: Optional[uuid.UUID] = None
    association_id: Optional[uuid.UUID] = None
    notes: Optional[str] = None
    status: Optional[DoctorStatusEnum] = None

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip()
            if not trimmed:
                raise ValueError("Doctor name cannot be blank")
            return trimmed
        return v

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            return normalize_phone(v)
        return None

    @field_validator("alternate_phone")
    @classmethod
    def validate_alt_phone(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v.strip():
            return normalize_phone(v)
        return None

    @field_validator("medical_license_number")
    @classmethod
    def validate_license(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            return normalize_license(v)
        return None

    @field_validator("specialization")
    @classmethod
    def validate_specialization(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip()
            if not trimmed:
                raise ValueError("Specialization cannot be blank")
            return trimmed
        return v

    @field_validator("clinic_name", "qualification", "address")
    @classmethod
    def trim_optional_strings(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            trimmed = v.strip()
            return trimmed if trimmed else None
        return None


class DoctorStatusUpdate(BaseModel):
    status: DoctorStatusEnum


class DoctorRead(BaseModel):
    id: uuid.UUID
    name: str
    phone: str
    alternate_phone: Optional[str] = None
    email: Optional[str] = None
    medical_license_number: str
    specialization: str
    qualification: Optional[str] = None
    clinic_name: Optional[str] = None
    address: Optional[str] = None
    area_id: uuid.UUID
    area_name: Optional[str] = None
    association_id: Optional[uuid.UUID] = None
    association_name: Optional[str] = None
    status: DoctorStatusEnum
    is_active: bool
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class DoctorListResponse(BaseModel):
    items: List[DoctorRead]
    total: int
    page: int
    page_size: int
    total_pages: int


class DoctorDuplicateCheckRequest(BaseModel):
    phone: Optional[str] = None
    medical_license_number: Optional[str] = None
    exclude_doctor_id: Optional[uuid.UUID] = None

    @field_validator("phone")
    @classmethod
    def normalize_phone_check(cls, v: Optional[str]) -> Optional[str]:
        if v and v.strip():
            return normalize_phone(v)
        return None

    @field_validator("medical_license_number")
    @classmethod
    def normalize_license_check(cls, v: Optional[str]) -> Optional[str]:
        if v and v.strip():
            return normalize_license(v)
        return None


class DoctorDuplicateCheckResponse(BaseModel):
    is_duplicate: bool
    duplicate_field: Optional[str] = None
    message: Optional[str] = None
    existing_doctor_id: Optional[uuid.UUID] = None
    existing_doctor_name: Optional[str] = None
    existing_doctor_status: Optional[str] = None
