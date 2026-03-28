from fastapi import FastAPI
from fastapi.responses import RedirectResponse, JSONResponse
from app.routes import router
import warnings
warnings.filterwarnings("ignore", category=UserWarning)

app = FastAPI(
    title="Satellite Zoning Service",
    description="API for NDVI analysis and field zoning",
    version="1.0.0"
)

# Add a root endpoint
@app.get("/")
async def root():
    return {
        "message": "Welcome to Satellite Zoning Service",
        "version": "1.0.0",
        "endpoints": {
            "analyze_field": "/analyze (POST)",
            "documentation": "/docs",
            "alternative_docs": "/redoc"
        },
        "usage": {
            "example": {
                "polygon": {
                    "type": "Polygon", 
                    "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]]  # ← Fixed: replaced ... with actual coordinates
                },
                "start_date": "2024-01-01",
                "end_date": "2024-01-31"
            }
        }
    }

# Add a health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "satellite-zoning",
        "version": "1.0.0"
    }

# Include your router (still at root level since you didn't specify prefix)
app.include_router(router)