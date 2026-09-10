import asyncio
import asyncpg

async def ensure_database():
    conn = await asyncpg.connect("postgresql://postgres:devpassword@localhost:5432/postgres")
    exists = await conn.fetchval("SELECT 1 FROM pg_database WHERE datname = 'rg_win_dev'")
    if not exists:
        print("Creating database 'rg_win_dev'...")
        await conn.execute("CREATE DATABASE rg_win_dev")
        print("Database 'rg_win_dev' created successfully.")
    else:
        print("Database 'rg_win_dev' already exists.")
    await conn.close()

if __name__ == "__main__":
    asyncio.run(ensure_database())
