from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
import os
import uuid
import shutil
from typing import List

from .db import models, database
from .schemas import diagnosis as schemas
from .core import security

# Create tables on startup
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="AgriSmart Crop Health Service",
    description="Microservice managing AI diagnosis history & images",
    version="1.0.0"
)

# Directory to store uploaded images
UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

# Serve images as static files so the Flutter app can display them via URL
app.mount("/api/v1/crop_health/images", StaticFiles(directory=UPLOAD_DIR), name="images")

@app.post("/api/v1/crop_health/diagnoses", response_model=schemas.DiagnosisResponse)
async def create_diagnosis(
    plant_name: str = Form(...),
    disease_name: str = Form(...),
    confidence: float = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(database.get_db),
    user_id: str = Depends(security.get_current_user_id)
):
    """
    Saves a new diagnosis. 
    1. Saves the image file to the server.
    2. Creates a database record linked to the authenticated user.
    """
    # 1. Save Image
    file_extension = image.filename.split(".")[-1]
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)
    
    # URL to access the image (Relative to the gateway)
    image_url = f"/api/v1/crop_health/images/{unique_filename}"
    
    # 2. Save DB Record
    db_diagnosis = models.Diagnosis(
        user_id=user_id,
        plant_name=plant_name,
        disease_name=disease_name,
        confidence=confidence,
        image_url=image_url
    )
    db.add(db_diagnosis)
    db.commit()
    db.refresh(db_diagnosis)
    
    return db_diagnosis

@app.get("/api/v1/crop_health/diagnoses", response_model=List[schemas.DiagnosisResponse])
def get_diagnoses(
    db: Session = Depends(database.get_db),
    user_id: str = Depends(security.get_current_user_id)
):
    """
    Returns only the diagnoses belonging to the currently logged-in user.
    """
    return db.query(models.Diagnosis).filter(models.Diagnosis.user_id == user_id).order_by(models.Diagnosis.created_at.desc()).all()

@app.delete("/api/v1/crop_health/diagnoses/{diagnosis_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_diagnosis(
    diagnosis_id: int,
    db: Session = Depends(database.get_db),
    user_id: str = Depends(security.get_current_user_id)
):
    """
    Deletes a diagnosis record and its file.
    Only allows deletion if the record belongs to the authenticated user.
    """
    db_diagnosis = db.query(models.Diagnosis).filter(
        models.Diagnosis.id == diagnosis_id,
        models.Diagnosis.user_id == user_id
    ).first()
    
    if not db_diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found or unauthorized")
    
    # Delete image file
    file_name = db_diagnosis.image_url.split("/")[-1]
    file_path = os.path.join(UPLOAD_DIR, file_name)
    if os.path.exists(file_path):
        os.remove(file_path)
        
    db.delete(db_diagnosis)
    db.commit()
    
    return None

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "crop_health_service"}
