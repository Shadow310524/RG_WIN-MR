"""0002_phase3_doctor_area

Revision ID: 0002_phase3_doctor_area
Revises: 0001_initial_schema
Create Date: 2026-09-10 13:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0002_phase3_doctor_area"
down_revision: Union[str, None] = "0001_initial_schema"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Update areas table
    op.add_column("areas", sa.Column("description", sa.String(length=255), nullable=True))
    op.create_index("ix_areas_code", "areas", ["code"], unique=True)

    # 2. Update associations table
    op.add_column("associations", sa.Column("code", sa.String(length=50), nullable=True))
    op.add_column("associations", sa.Column("description", sa.Text(), nullable=True))
    op.create_index("ix_associations_code", "associations", ["code"], unique=True)

    # 3. Create mr_area_assignments table
    op.create_table(
        "mr_area_assignments",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("mr_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("area_id", sa.Uuid(as_uuid=True), sa.ForeignKey("areas.id", ondelete="CASCADE"), nullable=False),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("mr_id", "area_id", name="uq_mr_area_assignment"),
    )
    op.create_index("ix_mr_area_assignments_mr_id", "mr_area_assignments", ["mr_id"])
    op.create_index("ix_mr_area_assignments_area_id", "mr_area_assignments", ["area_id"])
    op.create_index("ix_mr_area_assignments_is_active", "mr_area_assignments", ["is_active"])

    # 4. Update doctors table
    op.add_column("doctors", sa.Column("alternate_phone", sa.String(length=50), nullable=True))
    op.add_column("doctors", sa.Column("medical_license_number", sa.String(length=100), server_default="", nullable=False))
    op.add_column("doctors", sa.Column("qualification", sa.String(length=150), nullable=True))
    op.add_column("doctors", sa.Column("association_id", sa.Uuid(as_uuid=True), sa.ForeignKey("associations.id"), nullable=True))

    op.create_index("ix_doctors_medical_license_number", "doctors", ["medical_license_number"])
    op.create_index("ix_doctors_association_id", "doctors", ["association_id"])
    op.create_index("ix_doctors_phone_status", "doctors", ["phone", "status"])
    op.create_index("ix_doctors_license_status", "doctors", ["medical_license_number", "status"])


def downgrade() -> None:
    op.drop_index("ix_doctors_license_status", table_name="doctors")
    op.drop_index("ix_doctors_phone_status", table_name="doctors")
    op.drop_index("ix_doctors_association_id", table_name="doctors")
    op.drop_index("ix_doctors_medical_license_number", table_name="doctors")
    op.drop_column("doctors", "association_id")
    op.drop_column("doctors", "qualification")
    op.drop_column("doctors", "medical_license_number")
    op.drop_column("doctors", "alternate_phone")

    op.drop_index("ix_mr_area_assignments_is_active", table_name="mr_area_assignments")
    op.drop_index("ix_mr_area_assignments_area_id", table_name="mr_area_assignments")
    op.drop_index("ix_mr_area_assignments_mr_id", table_name="mr_area_assignments")
    op.drop_table("mr_area_assignments")

    op.drop_index("ix_associations_code", table_name="associations")
    op.drop_column("associations", "description")
    op.drop_column("associations", "code")

    op.drop_index("ix_areas_code", table_name="areas")
    op.drop_column("areas", "description")
