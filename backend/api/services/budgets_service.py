from datetime import datetime, timezone
from api.db import get_db
from bson import ObjectId

def _month_range(month: str):
    # month: "YYYY-MM"
    start = datetime.strptime(month, "%Y-%m").replace(tzinfo=timezone.utc)
    if start.month == 12:
        end = start.replace(year=start.year + 1, month=1)
    else:
        end = start.replace(month=start.month + 1)
    return start, end

def spent_by_category_for_month(user_id: str, month: str):
    db = get_db()
    start, end = _month_range(month)

    pipeline = [
        {"$match": {
            "userId": ObjectId(user_id),
            "type": "expense",
            "date": {"$gte": start, "$lt": end},
        }},
        {"$group": {
            "_id": "$categoryId",
            "spent": {"$sum": "$amount"},
        }}
    ]

    rows = list(db["expenses"].aggregate(pipeline))
    # dict: categoryId(str) -> spent(float)
    return {str(r["_id"]): float(r["spent"]) for r in rows}
