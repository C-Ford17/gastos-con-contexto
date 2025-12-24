from datetime import datetime, timezone
from bson import ObjectId
from api.db import get_db

def col():
    return get_db()["budgets"]

def upsert_budget(user_id: str, month: str, category_id: str, limit_amount: float, alert_threshold: int = 80):
    now = datetime.now(timezone.utc)
    q = {
        "userId": ObjectId(user_id),
        "month": month,
        "categoryId": ObjectId(category_id),
    }
    update = {
        "$set": {
            "limitAmount": float(limit_amount),
            "alertThreshold": int(alert_threshold),
            "updatedAt": now,
        },
        "$setOnInsert": {
            "createdAt": now,
        }
    }
    col().update_one(q, update, upsert=True)
    return col().find_one(q)

def list_budgets(user_id: str, month: str | None = None):
    q = {"userId": ObjectId(user_id)}
    if month:
        q["month"] = month
    return list(col().find(q).sort("month", -1))

def delete_budget(user_id: str, budget_id: str) -> bool:
    res = col().delete_one({"_id": ObjectId(budget_id), "userId": ObjectId(user_id)})
    return res.deleted_count == 1
