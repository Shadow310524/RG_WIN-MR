"""0001_initial_schema

Revision ID: 0001_initial_schema
Revises: 
Create Date: 2026-09-10 12:40:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0001_initial_schema"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. users
    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("full_name", sa.String(length=255), nullable=False),
        sa.Column("phone", sa.String(length=50), nullable=True),
        sa.Column("role", sa.String(length=20), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)
    op.create_index("ix_users_role", "users", ["role"])
    op.create_index("ix_users_status", "users", ["status"])

    # 2. revoked_tokens
    op.create_table(
        "revoked_tokens",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("jti", sa.String(length=255), nullable=False),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_revoked_tokens_jti", "revoked_tokens", ["jti"], unique=True)
    op.create_index("ix_revoked_tokens_expires_at", "revoked_tokens", ["expires_at"])

    # 3. areas
    op.create_table(
        "areas",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("code", sa.String(length=50), nullable=True),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_areas_name", "areas", ["name"], unique=True)
    op.create_index("ix_areas_status", "areas", ["status"])

    # 4. associations
    op.create_table(
        "associations",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("short_name", sa.String(length=50), nullable=True),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_associations_name", "associations", ["name"], unique=True)
    op.create_index("ix_associations_status", "associations", ["status"])

    # 5. doctors
    op.create_table(
        "doctors",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("full_name", sa.String(length=255), nullable=False),
        sa.Column("specialty", sa.String(length=150), nullable=False),
        sa.Column("area_id", sa.Uuid(as_uuid=True), sa.ForeignKey("areas.id"), nullable=False),
        sa.Column("clinic_hospital", sa.String(length=255), nullable=True),
        sa.Column("phone", sa.String(length=50), nullable=True),
        sa.Column("email", sa.String(length=255), nullable=True),
        sa.Column("address", sa.Text(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("created_by", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_doctors_full_name", "doctors", ["full_name"])
    op.create_index("ix_doctors_specialty", "doctors", ["specialty"])
    op.create_index("ix_doctors_area_id", "doctors", ["area_id"])
    op.create_index("ix_doctors_clinic_hospital", "doctors", ["clinic_hospital"])
    op.create_index("ix_doctors_phone", "doctors", ["phone"])
    op.create_index("ix_doctors_status", "doctors", ["status"])

    # 6. doctor_associations
    op.create_table(
        "doctor_associations",
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("association_id", sa.Uuid(as_uuid=True), sa.ForeignKey("associations.id", ondelete="CASCADE"), primary_key=True),
    )

    # 7. product_references (Healix product mirror)
    op.create_table(
        "product_references",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("healix_product_id", sa.Integer(), nullable=False),
        sa.Column("cached_name", sa.String(length=255), nullable=False),
        sa.Column("cached_category", sa.String(length=100), nullable=True),
        sa.Column("cached_mrp", sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column("cached_image_url", sa.String(length=512), nullable=True),
        sa.Column("cached_description", sa.Text(), nullable=True),
        sa.Column("cached_ingredients", sa.JSON(), nullable=False),
        sa.Column("cached_benefits", sa.JSON(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("last_synced_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_product_references_healix_id", "product_references", ["healix_product_id"], unique=True)
    op.create_index("ix_product_references_name", "product_references", ["cached_name"])
    op.create_index("ix_product_references_category", "product_references", ["cached_category"])
    op.create_index("ix_product_references_status", "product_references", ["status"])

    # 8. visits
    op.create_table(
        "visits",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id"), nullable=False),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("visit_datetime", sa.DateTime(timezone=True), nullable=False),
        sa.Column("visit_type", sa.String(length=30), nullable=False),
        sa.Column("doctor_response", sa.String(length=20), nullable=False),
        sa.Column("prescription_potential", sa.String(length=20), nullable=False),
        sa.Column("doctor_feedback", sa.Text(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("client_operation_id", sa.Uuid(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_visits_doctor_id", "visits", ["doctor_id"])
    op.create_index("ix_visits_user_id", "visits", ["user_id"])
    op.create_index("ix_visits_visit_datetime", "visits", ["visit_datetime"])
    op.create_index("ix_visits_client_operation_id", "visits", ["client_operation_id"], unique=True)

    # 9. visit_discussed_products
    op.create_table(
        "visit_discussed_products",
        sa.Column("visit_id", sa.Uuid(as_uuid=True), sa.ForeignKey("visits.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("healix_product_id", sa.Integer(), primary_key=True),
    )
    op.create_index("ix_visit_discussed_products_product", "visit_discussed_products", ["healix_product_id"])

    # 10. visit_products (samples, promotional units given)
    op.create_table(
        "visit_products",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("visit_id", sa.Uuid(as_uuid=True), sa.ForeignKey("visits.id", ondelete="CASCADE"), nullable=False),
        sa.Column("healix_product_id", sa.Integer(), nullable=False),
        sa.Column("distribution_type", sa.String(length=30), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("unit_type", sa.String(length=50), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("quantity > 0", name="chk_visit_product_quantity_positive"),
    )
    op.create_index("ix_visit_products_visit_id", "visit_products", ["visit_id"])
    op.create_index("ix_visit_products_product", "visit_products", ["healix_product_id"])

    # 11. follow_ups
    op.create_table(
        "follow_ups",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id"), nullable=False),
        sa.Column("visit_id", sa.Uuid(as_uuid=True), sa.ForeignKey("visits.id", ondelete="SET NULL"), nullable=True),
        sa.Column("assigned_user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("due_date", sa.Date(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_follow_ups_doctor_id", "follow_ups", ["doctor_id"])
    op.create_index("ix_follow_ups_assigned_user_id", "follow_ups", ["assigned_user_id"])
    op.create_index("ix_follow_ups_due_date", "follow_ups", ["due_date"])
    op.create_index("ix_follow_ups_status", "follow_ups", ["status"])

    # 12. prescriptions
    op.create_table(
        "prescriptions",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id"), nullable=False),
        sa.Column("healix_product_id", sa.Integer(), nullable=False),
        sa.Column("recorded_by", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("record_date", sa.Date(), nullable=False),
        sa.Column("estimated_quantity", sa.Integer(), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_prescriptions_doctor_id", "prescriptions", ["doctor_id"])
    op.create_index("ix_prescriptions_product_id", "prescriptions", ["healix_product_id"])
    op.create_index("ix_prescriptions_record_date", "prescriptions", ["record_date"])

    # 13. orders
    op.create_table(
        "orders",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id"), nullable=False),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("order_date", sa.Date(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("total_amount", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_orders_doctor_id", "orders", ["doctor_id"])
    op.create_index("ix_orders_user_id", "orders", ["user_id"])
    op.create_index("ix_orders_order_date", "orders", ["order_date"])
    op.create_index("ix_orders_status", "orders", ["status"])

    # 14. order_items
    op.create_table(
        "order_items",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("order_id", sa.Uuid(as_uuid=True), sa.ForeignKey("orders.id", ondelete="CASCADE"), nullable=False),
        sa.Column("healix_product_id", sa.Integer(), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("unit_price", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("subtotal", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.CheckConstraint("quantity > 0", name="chk_order_item_quantity_positive"),
        sa.CheckConstraint("unit_price >= 0", name="chk_order_item_unit_price_non_negative"),
    )
    op.create_index("ix_order_items_order_id", "order_items", ["order_id"])
    op.create_index("ix_order_items_product_id", "order_items", ["healix_product_id"])

    # 15. sales
    op.create_table(
        "sales",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id"), nullable=True),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("sale_date", sa.Date(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("total_amount", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_sales_doctor_id", "sales", ["doctor_id"])
    op.create_index("ix_sales_user_id", "sales", ["user_id"])
    op.create_index("ix_sales_sale_date", "sales", ["sale_date"])
    op.create_index("ix_sales_status", "sales", ["status"])

    # 16. sale_items
    op.create_table(
        "sale_items",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("sale_id", sa.Uuid(as_uuid=True), sa.ForeignKey("sales.id", ondelete="CASCADE"), nullable=False),
        sa.Column("healix_product_id", sa.Integer(), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("unit_price", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("discount_amount", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("total_amount", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.CheckConstraint("quantity > 0", name="chk_sale_item_quantity_positive"),
        sa.CheckConstraint("unit_price >= 0", name="chk_sale_item_unit_price_non_negative"),
        sa.CheckConstraint("discount_amount >= 0", name="chk_sale_item_discount_non_negative"),
    )
    op.create_index("ix_sale_items_sale_id", "sale_items", ["sale_id"])
    op.create_index("ix_sale_items_product_id", "sale_items", ["healix_product_id"])

    # 17. expenses
    op.create_table(
        "expenses",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("category", sa.String(length=30), nullable=False),
        sa.Column("amount", sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column("doctor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("doctors.id", ondelete="SET NULL"), nullable=True),
        sa.Column("area_id", sa.Uuid(as_uuid=True), sa.ForeignKey("areas.id", ondelete="SET NULL"), nullable=True),
        sa.Column("healix_product_id", sa.Integer(), nullable=True),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("expense_date", sa.Date(), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("amount >= 0", name="chk_expense_amount_non_negative"),
    )
    op.create_index("ix_expenses_category", "expenses", ["category"])
    op.create_index("ix_expenses_doctor_id", "expenses", ["doctor_id"])
    op.create_index("ix_expenses_area_id", "expenses", ["area_id"])
    op.create_index("ix_expenses_product_id", "expenses", ["healix_product_id"])
    op.create_index("ix_expenses_expense_date", "expenses", ["expense_date"])

    # 18. audit_logs
    op.create_table(
        "audit_logs",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("actor_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("action", sa.String(length=100), nullable=False),
        sa.Column("entity_type", sa.String(length=100), nullable=False),
        sa.Column("entity_id", sa.String(length=255), nullable=True),
        sa.Column("metadata_json", sa.JSON(), nullable=True),
        sa.Column("ip_address", sa.String(length=45), nullable=True),
        sa.Column("timestamp", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_audit_logs_actor_id", "audit_logs", ["actor_id"])
    op.create_index("ix_audit_logs_action", "audit_logs", ["action"])
    op.create_index("ix_audit_logs_entity_type", "audit_logs", ["entity_type"])
    op.create_index("ix_audit_logs_timestamp", "audit_logs", ["timestamp"])

    # 19. sync_operations
    op.create_table(
        "sync_operations",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column("client_operation_id", sa.Uuid(as_uuid=True), nullable=False),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("entity_type", sa.String(length=50), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("processed_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_sync_operations_client_op_id", "sync_operations", ["client_operation_id"], unique=True)
    op.create_index("ix_sync_operations_user_id", "sync_operations", ["user_id"])


def downgrade() -> None:
    op.drop_table("sync_operations")
    op.drop_table("audit_logs")
    op.drop_table("expenses")
    op.drop_table("sale_items")
    op.drop_table("sales")
    op.drop_table("order_items")
    op.drop_table("orders")
    op.drop_table("prescriptions")
    op.drop_table("follow_ups")
    op.drop_table("visit_products")
    op.drop_table("visit_discussed_products")
    op.drop_table("visits")
    op.drop_table("product_references")
    op.drop_table("doctor_associations")
    op.drop_table("doctors")
    op.drop_table("associations")
    op.drop_table("areas")
    op.drop_table("revoked_tokens")
    op.drop_table("users")
