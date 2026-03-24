from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.endpoints import router as auth_router
from app.db.database import engine, Base

# Create the database tables on startup. 
# (In a real production environment, you would use Alembic migrations instead, 
# but this is perfect for our current stage).
Base.metadata.create_all(bind=engine)

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
