from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from typing import Any, List

from app.db.database import get_db
from app.db import models
from app.schemas import user as user_schemas
from app.schemas import token as token_schemas
from app.core import security

router = APIRouter()
bearer_scheme = HTTPBearer()
ALLOWED_ROLES = {"admin", "consultant", "farmer"}


def _validate_role(role: str) -> str:
    normalized_role = role.strip().lower()
    if normalized_role not in ALLOWED_ROLES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid role. Allowed roles: admin, consultant, farmer.",
        )
    return normalized_role


def _get_current_admin(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> models.User:
    if not security.SECRET_KEY:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="SECRET_KEY is not configured.",
        )

    token = credentials.credentials
    try:
        payload = jwt.decode(token, security.SECRET_KEY, algorithms=[security.ALGORITHM])
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_id = payload.get("sub")
    role = payload.get("role")

    if not user_id or role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required.",
        )

    admin_user = db.query(models.User).filter(models.User.id == int(user_id)).first()
    if not admin_user or not admin_user.is_active or admin_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin account is not authorized.",
        )

    return admin_user

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
    requested_role = _validate_role(user_in.role or "farmer")
    if requested_role == "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin accounts can only be created by an existing admin.",
        )

    db_user = models.User(
        email=user_in.email,
        full_name=user_in.full_name,
        phone_number=user_in.phone_number,
        region=user_in.region,
        hashed_password=hashed_pass,
        role=requested_role,
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


@router.get("/admin/users", response_model=List[user_schemas.UserResponse])
def list_users(
    _: models.User = Depends(_get_current_admin),
    db: Session = Depends(get_db),
) -> Any:
    """Admin endpoint: list all users for management."""
    users = db.query(models.User).order_by(models.User.created_at.desc()).all()
    return users


@router.post("/admin/users", response_model=user_schemas.UserResponse, status_code=status.HTTP_201_CREATED)
def create_user_as_admin(
    user_in: user_schemas.UserCreate,
    _: models.User = Depends(_get_current_admin),
    db: Session = Depends(get_db),
) -> Any:
    """Admin endpoint: create a user with an explicit role and active status."""
    existing_user = db.query(models.User).filter(models.User.email == user_in.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists.",
        )

    db_user = models.User(
        email=user_in.email,
        full_name=user_in.full_name,
        phone_number=user_in.phone_number,
        region=user_in.region,
        hashed_password=security.get_password_hash(user_in.password),
        role=_validate_role(user_in.role or "farmer"),
        is_active=True,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.patch("/admin/users/{user_id}", response_model=user_schemas.UserResponse)
def update_user_role_or_access(
    user_id: int,
    payload: user_schemas.UserRoleAccessUpdate,
    admin_user: models.User = Depends(_get_current_admin),
    db: Session = Depends(get_db),
) -> Any:
    """Admin endpoint: update user role and/or access status."""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")

    if user.id == admin_user.id and payload.is_active is False:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot disable your own admin account.",
        )

    if payload.role is not None:
        user.role = _validate_role(payload.role)
    if payload.is_active is not None:
        user.is_active = payload.is_active

    db.commit()
    db.refresh(user)
    return user
