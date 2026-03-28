# services/clustering.py
import numpy as np
import joblib
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


scaler_path = os.path.join(BASE_DIR, "models", "scaler.pkl")
# Load models
try:
        scaler = joblib.load(scaler_path)
        print("✅ Scaler loaded successfully")
except:
        scaler = None
        print("⚠️ Scaler not loaded")
        

def analyze_zones(ndvi_array):
    """
    Analyze NDVI array and return zone information
    """
    try:
        
        # Flatten and remove NaN
        ndvi_flat = ndvi_array.flatten()
        mask = ~np.isnan(ndvi_flat)
        ndvi_clean = ndvi_flat[mask].reshape(-1, 1)
        
        if len(ndvi_clean) == 0:
            return {
                "status": "error",
                "message": "No valid NDVI pixels found"
            }
        
        # Scale if available
        if scaler is not None:
            ndvi_scaled = scaler.transform(ndvi_clean)
        else:
            ndvi_scaled = ndvi_clean
        
        # --- CRITICAL FIX: Match the buffer type expected by the model ---
        # We use ascontiguousarray to ensure memory is linear and force float32
        ndvi_scaled = np.ascontiguousarray(ndvi_scaled, dtype=np.float32)
        
        # Predict clusters
        from sklearn.cluster import KMeans

        model_test = KMeans(n_clusters=5, random_state=42)
        clusters = model_test.fit_predict(ndvi_scaled)

        # Get centers to determine order
        centers = model_test.cluster_centers_.flatten()
        
        # Create a mapping: Sort indices of centers from lowest to highest NDVI
        # e.g., if centers are [0.8, 0.2, 0.5], sorted_indices are [1, 2, 0]
        sorted_indices = np.argsort(centers)
        
        # Create a rank mapping: {old_label: new_label}
        # new_label 0 will be the lowest NDVI center
        rank_map = {old_id: new_rank for new_rank, old_id in enumerate(sorted_indices)}
        
        # Re-assign clusters based on rank
        sorted_clusters = np.array([rank_map[label] for label in clusters])
        
        # Replace original clusters with sorted ones for the rest of the logic
        clusters = sorted_clusters
        
        # Calculate statistics
        unique, counts = np.unique(clusters, return_counts=True)
        total_pixels = len(clusters)
        percentages = (counts / total_pixels) * 100
        
        # Get cluster centers
        if scaler is not None and hasattr(model_test, 'cluster_centers_'):
            centers_scaled = model_test.cluster_centers_
            centers_original = scaler.inverse_transform(centers_scaled).flatten()
        else:
            centers_original = [0.25, 0.55, 0.85][:len(unique)]
        
        # Build zone information
        zones = []
        for zone_id, count, percentage in zip(unique, counts, percentages):
            area_hectares = (count * 10 * 10) / 10000
            
            zones.append({
                "zone_id": int(zone_id),
                "pixel_count": int(count),
                "percentage": round(float(percentage), 2),
                "area_hectares": round(area_hectares, 2),
                "center_ndvi": round(float(centers_original[int(zone_id)]), 3) if int(zone_id) < len(centers_original) else 0.0
            })
        
        # Calculate overall statistics
        stats = {
            "mean_ndvi": round(float(np.nanmean(ndvi_array)), 3),
            "std_ndvi": round(float(np.nanstd(ndvi_array)), 3),
            "min_ndvi": round(float(np.nanmin(ndvi_array)), 3),
            "max_ndvi": round(float(np.nanmax(ndvi_array)), 3),
            "total_pixels": int(total_pixels),
            "total_area_hectares": round((total_pixels * 10 * 10) / 10000, 2)
        }
        
        return {
            "status": "success",
            "zones": zones,
            "statistics": stats,
            # ADD THESE TWO LINES:
            "cluster_labels": clusters.tolist(), # Convert numpy to list for JSON compatibility
            "original_shape": ndvi_array.shape
        }
        
    except Exception as e:
        print(f"❌ Error in analyze_zones: {e}")
        import traceback
        traceback.print_exc()
        return {
            "status": "error",
            "message": str(e)
        }