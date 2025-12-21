from datetime import datetime
from bson import ObjectId
from api.db import get_db

def users_col():
    return get_db()["users"]

def find_by_email(email: str):
    return users_col().find_one({"email": email.lower().strip()})

def find_by_id(user_id: str):
    return users_col().find_one({"_id": ObjectId(user_id)})

def create_user(email: str, password_hash: str, username: str | None = None):
    doc = {
        "email": email.lower().strip(),
        "username": (username or email.split("@")[0]).strip(),
        "passwordHash": password_hash,
        "createdAt": datetime.utcnow(),
        "updatedAt": datetime.utcnow(),
        "currency": "COP",
        "timezone": "America/Bogota",
    }
    res = users_col().insert_one(doc)
    doc["_id"] = res.inserted_id
    return doc
