import joblib
import numpy as np
from sklearn.preprocessing import StandardScaler
import os

# Ensure directory exists
os.makedirs("app/models", exist_ok=True)

# Create a dummy scaler
scaler = StandardScaler()

# Fit on representative NDVI distribution - explicitly float32
dummy_data = (np.random.randn(1000, 1) * 0.2 + 0.5).astype(np.float32)
scaler.fit(dummy_data)

# Save to the correct location
joblib.dump(scaler, 'app/models/scaler.pkl')
print(f"✅ Dummy scaler (dtype: {dummy_data.dtype}) saved to app/models/scaler.pkl")