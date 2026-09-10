"""0003_phase5_promotions

Revision ID: 0003_phase5_promotions
Revises: 0002_phase3_doctor_area
Create Date: 2026-09-11 02:15:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0003_phase5_promotions"
down_revision: Union[str, None] = "0002_phase3_doctor_area"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "doctor_promotional_investments",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("visit_id", sa.Uuid(as_uuid=True), sa.ForeignKey("visits.id", ondelete="SET NULL"), nullable=True),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("amount", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("investment_type", sa.String(length=30), nullable=False),
        sa.Column("investment_date", sa.Date(), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("client_operation_id", sa.Uuid(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("amount > 0", name="chk_promotional_investment_amount_positive"),
    )
    op.create_index("ix_doctor_promotional_investments_doctor_id", "doctor_promotional_investments", ["doctor_id"])
    op.create_index("ix_doctor_promotional_investments_visit_id", "doctor_promotional_investments", ["visit_id"])
    op.create_index("ix_doctor_promotional_investments_user_id", "doctor_promotional_investments", ["user_id"])
    op.create_index("ix_doctor_promotional_investments_investment_date", "doctor_promotional_investments", ["investment_date"])
    op.create_index("ix_doctor_promotional_investments_investment_type", "doctor_promotional_investments", ["investment_type"])
    op.create_index("ix_doctor_promotional_investments_client_operation_id", "doctor_promotional_investments", ["client_operation_id"], unique=True)


def downgrade() -> None:
    op.drop_table("doctor_promotional_investments")
