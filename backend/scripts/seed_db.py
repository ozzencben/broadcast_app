import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from passlib.context import CryptContext

from core.config import settings
from models.user import User, Gender
from database import Base

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
engine = create_async_engine(settings.DATABASE_URL)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

async def seed_data():
    async with AsyncSessionLocal() as session:
        async with session.begin():
            print("🚀 Sadece kullanıcılar oluşturuluyor...")
            
            common_password = hash_password("password123")
            
            # 1. ADMIN
            admin = User(
                email="ozzencben@gmail.com",
                username="ozencc",
                hashed_password=common_password,
                first_name="Özenç",
                last_name="Dönmezer",
                gender=Gender.MALE,
                is_admin=True,
                is_active=True,
                is_streamer=False,
                is_verified_streamer=False
            )
            session.add(admin)

            # 2. STREAMERS
            for i in range(1, 3):
                s = User(
                    email=f"streamer{i}@test.com",
                    username=f"pro_streamer_{i}",
                    hashed_password=common_password,
                    first_name=f"Streamer",
                    last_name=str(i),
                    gender=Gender.OTHER,
                    is_streamer=True,
                    is_verified_streamer=True,
                    is_active=True,
                    bio=f"Gaming is my life! #{i}"
                )
                session.add(s)

            # 3. USERS
            for i in range(1, 8):
                u = User(
                    email=f"user{i}@test.com",
                    username=f"watcher_{i}",
                    hashed_password=common_password,
                    first_name=f"User",
                    last_name=str(i),
                    gender=Gender.PREFER_NOT_TO_SAY,
                    is_streamer=False,
                    is_active=True
                )
                session.add(u)

        await session.commit()
        print("\n✅ Kullanıcılar başarıyla oluşturuldu! (Takip ilişkileri atlandı)")

if __name__ == "__main__":
    asyncio.run(seed_data())