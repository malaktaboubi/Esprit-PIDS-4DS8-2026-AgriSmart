from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from .database import Base

class Diagnosis(Base):
    """
    Representation of a single crop health diagnosis in the database.
    """
    __tablename__ = "diagnoses"

    id = Column(Integer, primary_key=True, index=True)
    
    # Store the user_id from the JWT 'sub' claim to filter results
    user_id = Column(String, index=True, nullable=False)
    
    plant_name = Column(String, nullable=False)
    disease_name = Column(String, nullable=False)
    confidence = Column(Float, nullable=False)
    
    # Path to the image file stored in the container's persistent volume
    image_url = Column(String, nullable=False)
    
    # Automatic timestamping
    created_at = Column(DateTime(timezone=True), server_default=func.now())
