"""
Cleanup script to remove all mock data seeded by seed_mock_data.py.
Leaves user accounts intact while safely removing seeded CRM & financial demo records.

Usage:
    python scripts/clear_mock_data.py
"""
import asyncio
import os
import sys

# Ensure backend root is in sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import select, delete

from app.core.database import async_session_maker, engine
from app.models.area import Area
from app.models.association import Association
from app.models.doctor import Doctor
from app.models.visit import Visit
from app.models.promotional_investment import DoctorPromotionalInvestment
from app.models.sale import Sale
from app.models.follow_up import FollowUp
from app.models.expense import Expense
from app.core.logging import logger

MOCK_TAG = "[MOCK_DATA]"


async def clear_mock_data():
    async with async_session_maker() as session:
        logger.info("Starting RG WIN mock data removal...")

        # 1. Clear Mock Expenses
        stmt_exp = delete(Expense).where(Expense.notes.contains(MOCK_TAG))
        res_exp = await session.execute(stmt_exp)

        # 2. Clear Mock Promotional Investments
        stmt_pi = delete(DoctorPromotionalInvestment).where(
            DoctorPromotionalInvestment.notes.contains(MOCK_TAG)
        )
        res_pi = await session.execute(stmt_pi)

        # 3. Clear Mock Follow-ups
        stmt_fu = delete(FollowUp).where(FollowUp.notes.contains(MOCK_TAG))
        res_fu = await session.execute(stmt_fu)

        # 4. Clear Mock Visits
        stmt_vis = delete(Visit).where(Visit.notes.contains(MOCK_TAG))
        res_vis = await session.execute(stmt_vis)

        # 5. Clear Mock Sales
        # Delete sales linked to mock doctors
        stmt_mock_docs = select(Doctor.id).where(Doctor.notes.contains(MOCK_TAG))
        mock_doc_ids = (await session.execute(stmt_mock_docs)).scalars().all()
        if mock_doc_ids:
            stmt_sales = delete(Sale).where(Sale.doctor_id.in_(mock_doc_ids))
            res_sales = await session.execute(stmt_sales)
        else:
            res_sales = None

        # 6. Clear Mock Doctors
        stmt_doc = delete(Doctor).where(Doctor.notes.contains(MOCK_TAG))
        res_doc = await session.execute(stmt_doc)

        # 7. Clear Mock Associations
        stmt_asc = delete(Association).where(Association.description.contains(MOCK_TAG))
        res_asc = await session.execute(stmt_asc)

        # 8. Clear Mock Areas
        stmt_area = delete(Area).where(Area.description.contains(MOCK_TAG))
        res_area = await session.execute(stmt_area)

        await session.commit()
        logger.info("Mock data removal complete.")
        print("\n=======================================================")
        print("  RG WIN MOCK DATA CLEARED SUCCESSFULLY!")
        print("=======================================================")
        print(f"  Expenses removed: {res_exp.rowcount}")
        print(f"  Promotional Investments removed: {res_pi.rowcount}")
        print(f"  Follow-ups removed: {res_fu.rowcount}")
        print(f"  Visits removed: {res_vis.rowcount}")
        print(f"  Sales removed: {res_sales.rowcount if res_sales else 0}")
        print(f"  Doctors removed: {res_doc.rowcount}")
        print(f"  Associations removed: {res_asc.rowcount}")
        print(f"  Areas removed: {res_area.rowcount}")
        print("  (MR and Admin user accounts preserved)")
        print("=======================================================\n")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(clear_mock_data())
