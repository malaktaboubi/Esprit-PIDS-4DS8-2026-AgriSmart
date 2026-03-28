from pydantic import BaseModel
from typing import Optional

# 1. Schema for the Token response sent back to Flutter
class Token(BaseModel):
    access_token: str
    token_type: str
    role: str  # Extra helpful field so the frontend knows the role immediately 

# 2. Schema for the data we extract from the JWT token
class TokenData(BaseModel):
    email: Optional[str] = None
    role: Optional[str] = None
