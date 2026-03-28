from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class DiagnosisBase(BaseModel):
    """
    Standard fields for a diagnosis.
    """
    plant_name: str
    disease_name: str
    confidence: float

class DiagnosisCreate(DiagnosisBase):
    """
    Fields needed to create a new diagnosis record.
    The 'image_url' and 'user_id' will be added in the backend.
    """
    pass

class DiagnosisResponse(DiagnosisBase):
    """
    Standard format for returning records to the Flutter app.
    """
    id: int
    user_id: str
    image_url: str
    created_at: datetime

    class Config:
        from_attributes = True
