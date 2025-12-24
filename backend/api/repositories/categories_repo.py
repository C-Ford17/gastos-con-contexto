from datetime import datetime
from bson import ObjectId
from api.db import get_db

def col():
    return get_db()["categories"]

def list_categories(user_id: str, type_: str | None = None):
    q = {"userId": ObjectId(user_id)}
    if type_:
        q["type"] = type_
    return list(col().find(q).sort("order", 1).sort("name", 1))

def create_category(user_id: str, name: str, type_: str, emoji: str | None, color: str | None, order: int | None):
    doc = {
        "userId": ObjectId(user_id),
        "name": name.strip(),
        "type": type_,  # "expense" | "income"
        "emoji": emoji or "",
        "color": color or "#6200EE",
        "order": int(order or 0),
        "createdAt": datetime.utcnow(),
        "updatedAt": datetime.utcnow(),
    }
    res = col().insert_one(doc)
    doc["_id"] = res.inserted_id
    return doc

def get_category(user_id: str, category_id: str):
    return col().find_one({"_id": ObjectId(category_id), "userId": ObjectId(user_id)})

def update_category(user_id: str, category_id: str, patch: dict):
    patch["updatedAt"] = datetime.utcnow()
    col().update_one(
        {"_id": ObjectId(category_id), "userId": ObjectId(user_id)},
        {"$set": patch},
    )
    return get_category(user_id, category_id)

def delete_category(user_id: str, category_id: str) -> bool:
    res = col().delete_one({"_id": ObjectId(category_id), "userId": ObjectId(user_id)})
    return res.deleted_count == 1
