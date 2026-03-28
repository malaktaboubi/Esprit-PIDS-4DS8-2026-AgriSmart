# services/gee_client.py
import ee
import numpy as np
import os
import requests
import io
import traceback

# Initialize Earth Engine
try:
    service_account = "agrismart@agrismart-487712.iam.gserviceaccount.com"
    key_path = os.path.expanduser(r"~\AgriSmart\backend\satellite_service\Google.Earth.Engine\agrismart-487712-8538d73bcbb6.json")
    
    if not os.path.exists(key_path):
        raise FileNotFoundError(f"Service account key not found at: {key_path}")
    
    credentials = ee.ServiceAccountCredentials(service_account, key_path)
    ee.Initialize(credentials)
    print("✅ Earth Engine initialized successfully")
    
except Exception as e:
    print(f"❌ Earth Engine initialization failed: {e}")
    raise

def extract_coordinates(polygon):
    """
    Extract coordinates from various polygon formats for GEE
    """
    if isinstance(polygon, dict):
        if 'coordinates' in polygon:
            coords = polygon['coordinates']
            if polygon.get('type') == 'Polygon':
                return coords
            return coords
        return polygon
    elif isinstance(polygon, list):
        if polygon and isinstance(polygon[0], list):
            if len(polygon[0]) == 2 and isinstance(polygon[0][0], (int, float)):
                return [polygon]
            return polygon
        return [polygon]
    return polygon

def get_ndvi_array(polygon, start_date, end_date):
    """
    Get NDVI array from Google Earth Engine for a given polygon and date range
    """
    try:
        print(f"\n🔍 Starting GEE processing...")
        print(f"📅 Date range: {start_date} to {end_date}")
        
        # Extract coordinates
        coords = extract_coordinates(polygon)
        farm = ee.Geometry.Polygon(coords)
        
        # Get area
        area = farm.area().divide(10000).getInfo()
        print(f"📍 Polygon area: {area:.2f} hectares")
        
        # Get imagery
        print(f"🛰️ Fetching Sentinel-2 imagery...")
        dataset = (
            ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
            .filterBounds(farm)
            .filterDate(start_date, end_date)
            .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 40))
        )
        
        count = dataset.size().getInfo()
        print(f"📸 Found {count} images")
        
        if count == 0:
            # Try without cloud filter
            dataset = (
                ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                .filterBounds(farm)
                .filterDate(start_date, end_date)
            )
            count = dataset.size().getInfo()
            print(f"📸 Found {count} images (no cloud filter)")
        
        if count == 0:
            raise ValueError(f"No Sentinel-2 images found")
        
        # Get median composite
        image = dataset.median()
        ndvi = image.normalizedDifference(['B8', 'B4']).rename('NDVI')
        
        # Download data
        print(f"📥 Downloading NDVI data...")
        url = ndvi.getDownloadURL({
            'scale': 10,
            'region': farm,
            'format': 'NPY'
        })
        
        response = requests.get(url)
        if response.status_code != 200:
            raise Exception(f"Download failed with status {response.status_code}")
        
        # Load numpy array and ensure it's float
        np_data = np.load(io.BytesIO(response.content))
        
        # Convert to float32 and handle different shapes
        if len(np_data.shape) == 3:
            ndvi_array = np_data[0].astype(np.float32)
        elif len(np_data.shape) == 2:
            ndvi_array = np_data.astype(np.float32)
        else:
            ndvi_array = np_data.astype(np.float32)
        
        # Handle any non-numeric values
        ndvi_array = np.where(np.isfinite(ndvi_array), ndvi_array, np.nan)
        
        # Clip to valid NDVI range
        ndvi_array = np.clip(ndvi_array, -1, 1)
        
        print(f"✅ NDVI array shape: {ndvi_array.shape}")
        print(f"📊 NDVI range: [{np.nanmin(ndvi_array):.3f}, {np.nanmax(ndvi_array):.3f}]")
        print(f"🔢 Valid pixels: {np.sum(~np.isnan(ndvi_array))} / {ndvi_array.size}")
        
        return ndvi_array
        
    except Exception as e:
        print(f"❌ Error in get_ndvi_array: {e}")
        print(traceback.format_exc())
        raise

# Create a mock version for testing without GEE
# In gee_client.py, update the mock function to return float32
def get_mock_ndvi_array(polygon, start_date, end_date):
    """
    Generate mock NDVI data for testing
    """
    print(f"\n🔍 Generating MOCK NDVI data...")
    
    # Create a 100x100 mock NDVI array
    height, width = 100, 100
    
    # Create a pattern with different zones
    x = np.linspace(0, 1, width)
    y = np.linspace(0, 1, height)
    X, Y = np.meshgrid(x, y)
    
    # Create zones:
    # Zone 0: Low NDVI (0.1-0.3)
    # Zone 1: Medium NDVI (0.3-0.6)
    # Zone 2: High NDVI (0.6-0.9)
    
    mock_ndvi = 0.3 + 0.5 * Y + 0.2 * np.sin(5 * X)
    
    # CRITICAL: Ensure float32 dtype
    mock_ndvi = mock_ndvi.astype(np.float32)
    
    # Add some noise
    mock_ndvi += np.random.randn(height, width).astype(np.float32) * 0.05
    
    # Clip to valid range
    mock_ndvi = np.clip(mock_ndvi, 0.1, 0.9)
    
    # Add some NaN values (clouds)
    mask = np.random.random(mock_ndvi.shape) > 0.95
    mock_ndvi[mask] = np.nan
    
    print(f"✅ Mock NDVI array shape: {mock_ndvi.shape}, dtype: {mock_ndvi.dtype}")
    print(f"📊 NDVI range: [{np.nanmin(mock_ndvi):.3f}, {np.nanmax(mock_ndvi):.3f}]")
    
    return mock_ndvi