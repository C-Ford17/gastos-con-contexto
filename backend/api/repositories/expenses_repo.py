from datetime import datetime, timezone
from bson import ObjectId
from api.db import get_db

def col():
    return get_db()["expenses"]

def _day_floor_utc(dt: datetime) -> datetime:
    # Normaliza a 00:00 UTC para agrupar por día sin líos
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    dt_utc = dt.astimezone(timezone.utc)
    return dt_utc.replace(hour=0, minute=0, second=0, microsecond=0)

def create_expense(user_id: str, doc: dict) -> dict:
    now = datetime.now(timezone.utc)

    # Normalización de fechas
    date = doc["date"]
    date_day = _day_floor_utc(date)

    expense = {
        "userId": ObjectId(user_id),
        "type": doc["type"],  # expense | income
        "amount": float(doc["amount"]),
        "currency": doc.get("currency", "COP"),
        "date": date,
        "dateDay": date_day,

        "categoryId": ObjectId(doc["categoryId"]),
        "categoryNameSnapshot": doc.get("categoryNameSnapshot", ""),

        "mood": doc.get("mood"),
        "reason": doc.get("reason"),
        "note": doc.get("note", ""),
        "tags": doc.get("tags", []),

        "receiptImageUrl": doc.get("receiptImageUrl"),

        "createdAt": now,
        "updatedAt": now,
    }

    res = col().insert_one(expense)
    expense["_id"] = res.inserted_id
    return expense

def get_expense(user_id: str, expense_id: str):
    return col().find_one({"_id": ObjectId(expense_id), "userId": ObjectId(user_id)})

def update_expense(user_id: str, expense_id: str, patch: dict):
    patch["updatedAt"] = datetime.now(timezone.utc)

    # Si cambian date, recalculamos dateDay
    if "date" in patch and isinstance(patch["date"], datetime):
        patch["dateDay"] = _day_floor_utc(patch["date"])

    col().update_one(
        {"_id": ObjectId(expense_id), "userId": ObjectId(user_id)},
        {"$set": patch},
    )
    return get_expense(user_id, expense_id)

def delete_expense(user_id: str, expense_id: str) -> bool:
    res = col().delete_one({"_id": ObjectId(expense_id), "userId": ObjectId(user_id)})
    return res.deleted_count == 1

def list_expenses(user_id: str, filters: dict, limit: int, offset: int):
    q = {"userId": ObjectId(user_id)}

    # rango fechas
    if filters.get("from"):
        q["date"] = q.get("date", {})
        q["date"]["$gte"] = filters["from"]
    if filters.get("to"):
        q["date"] = q.get("date", {})
        q["date"]["$lte"] = filters["to"]

    # filtros directos
    if filters.get("categoryId"):
        q["categoryId"] = ObjectId(filters["categoryId"])
    if filters.get("type"):
        q["type"] = filters["type"]
    if filters.get("reason"):
        q["reason"] = filters["reason"]

    # búsqueda simple por note (regex)
    if filters.get("q"):
        q["note"] = {"$regex": filters["q"], "$options": "i"}

    cursor = col().find(q).sort("date", -1).skip(offset).limit(limit)
    items = list(cursor)
    total = col().count_documents(q)
    return items, total
