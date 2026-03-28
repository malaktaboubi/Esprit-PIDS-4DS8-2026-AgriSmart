# app/schemas.py
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional

class FieldRequest(BaseModel):
    polygon: Dict[str, Any] = Field(..., description="GeoJSON polygon or coordinate list")
    start_date: str = Field(..., description="Start date in YYYY-MM-DD format", pattern=r"^\d{4}-\d{2}-\d{2}$")
    end_date: str = Field(..., description="End date in YYYY-MM-DD format", pattern=r"^\d{4}-\d{2}-\d{2}$")
    
    class Config:
        schema_extra = {
            "example": {
                "polygon": {
                    "type": "Polygon",
                    "coordinates": [[
                        [-122.084, 37.422],
                        [-122.084, 37.423],
                        [-122.083, 37.423],
                        [-122.083, 37.422],
                        [-122.084, 37.422]
                    ]]
                },
                "start_date": "2024-06-01",
                "end_date": "2024-06-30"
            }
        }

# Add response schemas
class ZoneInfo(BaseModel):
    zone_id: int
    pixel_count: int
    percentage: float
    area_hectares: Optional[float] = None
    center_ndvi: Optional[float] = None

class Statistics(BaseModel):
    mean_ndvi: float
    std_ndvi: float
    min_ndvi: float
    max_ndvi: float
    total_pixels: int
    total_area_hectares: Optional[float] = None

class AnalysisResponse(BaseModel):
    status: str
    zones: List[ZoneInfo]
    statistics: Statistics
    request: Optional[Dict[str, Any]] = None