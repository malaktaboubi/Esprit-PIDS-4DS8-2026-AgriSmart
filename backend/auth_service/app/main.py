import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.endpoints import router as auth_router
from app.db.database import engine, Base, SessionLocal
from app.db import models
from app.core import security

# Create the database tables on startup. 
# (In a real production environment, you would use Alembic migrations instead, 
# but this is perfect for our current stage).
Base.metadata.create_all(bind=engine)
def _seed_admin_user() -> None:
    admin_email = os.getenv("ADMIN_EMAIL", "admin@agrismart.com")
    admin_password = os.getenv("ADMIN_PASSWORD", "Admin@12345")
    admin_name = os.getenv("ADMIN_FULL_NAME", "AgriSmart Admin")

    db = SessionLocal()
    try:
        existing_admin = db.query(models.User).filter(models.User.email == admin_email).first()
        if existing_admin:
            if existing_admin.role != "admin":
                existing_admin.role = "admin"
                existing_admin.is_active = True
                db.commit()
            return

        db_user = models.User(
            email=admin_email,
            full_name=admin_name,
            phone_number="-",
            region="HQ",
            hashed_password=security.get_password_hash(admin_password),
            role="admin",
            is_active=True,
        )
        db.add(db_user)
        db.commit()
    finally:
        db.close()


_seed_admin_user()

app = FastAPI(
    title="AgriSmart Authentication Service",
    description="Microservice managing Users, Roles, and JWTs",
    version="1.0.0"
)

# Allow Flutter app to talk to the backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # For dev. In production, restrict to your app's domains.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Connect our router to the main app under the /api/v1/auth path
app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "auth_service"}
