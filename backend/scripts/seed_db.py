"""
Seed script to initialize default Admin and MR user accounts in the RG WIN database.
Usage:
    python scripts/seed_db.py
"""
import asyncio
import uuid
from sqlalchemy import select

from app.core.database import async_session_maker, engine
from app.core.security import hash_password
from app.models.user import User, RoleEnum, UserStatusEnum
from app.core.logging import logger


async def seed():
    async with async_session_maker() as session:
        # 1. Default Admin Account
        admin_email = "admin@healix.com"
        admin_res = await session.execute(select(User).where(User.email == admin_email))
        admin = admin_res.scalars().first()

        if not admin:
            admin = User(
                id=uuid.uuid4(),
                email=admin_email,
                password_hash=hash_password("AdminHealix2026!"),
                full_name="Dr. Harish Renganathan (Admin)",
                phone="+919876543210",
                role=RoleEnum.ADMIN,
                status=UserStatusEnum.ACTIVE,
            )
            session.add(admin)
            logger.info(f"Created default ADMIN account: {admin_email}")

        # 2. Default MR Account
        mr_email = "mr.ravi@healix.com"
        mr_res = await session.execute(select(User).where(User.email == mr_email))
        mr = mr_res.scalars().first()

        if not mr:
            mr = User(
                id=uuid.uuid4(),
                email=mr_email,
                password_hash=hash_password("MrHealix2026!"),
                full_name="Ravi Kumar (MR)",
                phone="+919876543211",
                role=RoleEnum.MR,
                status=UserStatusEnum.ACTIVE,
            )
            session.add(mr)
            logger.info(f"Created default MR account: {mr_email}")

        await session.commit()
        logger.info("Database seeding completed successfully.")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed())
