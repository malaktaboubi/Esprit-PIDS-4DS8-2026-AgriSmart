# app/routes.py
from fastapi import APIRouter, HTTPException
from app.schemas import FieldRequest
from app.services.gee_client import get_ndvi_array, get_mock_ndvi_array
from app.services.clustering import analyze_zones
import traceback
from app.services.visualization import generate_zone_map

router = APIRouter()

@router.post("/analyze")
async def analyze_field(data: FieldRequest):
    """
    Analyze a field polygon and return NDVI zones
    """
    try:
        print(f"\n🔍 Analyzing field...")
        
        # Try real GEE first, fallback to mock if it fails
        try:
            ndvi_array = get_ndvi_array(
                polygon=data.polygon,
                start_date=data.start_date,
                end_date=data.end_date
            )
        except Exception as e:
            print(f"⚠️ GEE failed, using mock data: {e}")
            ndvi_array = get_mock_ndvi_array(
                polygon=data.polygon,
                start_date=data.start_date,
                end_date=data.end_date
            )
        
        # Analyze zones
        results = analyze_zones(ndvi_array)

        
        
        if results["status"] == "error":
            raise HTTPException(status_code=400, detail=results["message"])
        
        # Add request metadata
        results["request"] = {
            "start_date": data.start_date,
            "end_date": data.end_date,
            "polygon": data.polygon
        }



        if results["status"] == "success":
         # Generate the map using the data returned by the model
            map_path = generate_zone_map(
                ndvi_array=ndvi_array, 
                cluster_labels=results["cluster_labels"]
            )
            results["map_url"] = map_path # Add the path to your response

        
        
        return results
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/analyze-mock")
async def analyze_field_mock(data: FieldRequest):
    """
    Test endpoint that always uses mock data
    """
    try:
        ndvi_array = get_mock_ndvi_array(
            polygon=data.polygon,
            start_date=data.start_date,
            end_date=data.end_date
        )
        
        results = analyze_zones(ndvi_array)
        results["request"] = {
            "start_date": data.start_date,
            "end_date": data.end_date,
            "note": "This is mock data for testing"
        }
        
        return results
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))