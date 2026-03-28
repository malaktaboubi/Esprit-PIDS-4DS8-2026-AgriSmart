from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
import os

# The key used must match exactly across ALL services
# We'll rely on the environment variable 'SECRET_KEY'
SECRET_KEY = os.getenv("SECRET_KEY", "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7")
ALGORITHM = "HS256"

# This looks for the token in the 'Authorization: Bearer <token>' header
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def get_current_user_id(token: str = Depends(oauth2_scheme)) -> str:
    """
    Decodes the JWT token and returns the user's unique ID.
    If the token is invalid, we raise an Unauthorized error.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # 1. Decode the token using our shared SECRET_KEY
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # 2. Extract the 'sub' claim containing the user ID
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        
        return user_id
    except JWTError as e:
        print(f"JWT Decode Error: {e}, SECRET_KEY is {SECRET_KEY[:5]}...")
        raise credentials_exception
