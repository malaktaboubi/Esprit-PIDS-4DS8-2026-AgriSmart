import sys
import os

from app.db.database import SessionLocal
from app.db import models
from app.core import security

db = SessionLocal()
existing_admin = db.query(models.User).filter(models.User.email == "admin@agrismart.com").first()

if existing_admin:
    print(f"Admin exists! ID: {existing_admin.id}, Role: {existing_admin.role}, Hashed pass looks like: {existing_admin.hashed_password[:10]}...")
    is_valid = security.verify_password("Admin@12345", existing_admin.hashed_password)
    print(f"Does the default password match? {is_valid}")
else:
    print("Admin DOES NOT exist!")
