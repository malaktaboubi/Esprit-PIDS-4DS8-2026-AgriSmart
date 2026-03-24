from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from typing import Any

from app.db.database import get_db
from app.db import models
from app.schemas import user as user_schemas
from app.schemas import token as token_schemas
from app.core import security

router = APIRouter()

@router.post("/register", response_model=user_schemas.UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(
    user_in: user_schemas.UserCreate, 
    db: Session = Depends(get_db)
) -> Any:
    """
    Register a new user.
    """
    # 1. Check if user already exists
    user = db.query(models.User).filter(models.User.email == user_in.email).first()
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists."
        )
    
    # 2. Hash the password before saving
    hashed_pass = security.get_password_hash(user_in.password)
    
    # 3. Create the database record. Notice we map `role` carefully!
    db_user = models.User(
        email=user_in.email,
        full_name=user_in.full_name,
        phone_number=user_in.phone_number,
        region=user_in.region,
        hashed_password=hashed_pass,
        role=user_in.role
    )
    
    # 4. Save to the database
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user

@router.post("/login", response_model=token_schemas.Token)
def login_access_token(
    # OAuth2PasswordRequestForm expects data to be sent as Form Data, not raw JSON
    # This is the standard for OAuth2
    form_data: OAuth2PasswordRequestForm = Depends(), 
    db: Session = Depends(get_db)
) -> Any:
    """
    OAuth2 compatible token login, getting an access token for future requests.
    """
    # 1. Find the user by their email (which OAuth2 calls 'username')
    user = db.query(models.User).filter(models.User.email == form_data.username).first()
    
    # 2. Authenticate the user
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")

    # 3. Create the JWT Token containing the user's ID and ROLE!
    access_token = security.create_access_token(
        data={"sub": str(user.id), "role": user.role}
    )
    
    # 4. Return the token directly to the Flutter App
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "role": user.role  # Sent nakedly alongside the token for easy front-end routing
    }
