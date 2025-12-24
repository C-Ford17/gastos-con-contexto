from datetime import datetime, timezone
from bson import ObjectId
from api.db import get_db

def summary(user_id: str, date_from: datetime, date_to: datetime):
    db = get_db()

    pipeline = [
        {"$match": {
            "userId": ObjectId(user_id),
            "date": {"$gte": date_from, "$lte": date_to},
        }},
        {"$facet": {
            "totalsByType": [
                {"$group": {"_id": "$type", "total": {"$sum": "$amount"}}}
            ],
            "topCategories": [
                {"$match": {"type": "expense"}},
                {"$group": {"_id": "$categoryNameSnapshot", "total": {"$sum": "$amount"}}},
                {"$sort": {"total": -1}},
                {"$limit": 5},
            ],
            "expenseByDay": [
                {"$match": {"type": "expense"}},
                {"$group": {
                    "_id": {
                        "$dateToString": {"format": "%Y-%m-%d", "date": "$date"}
                    },
                    "total": {"$sum": "$amount"},
                }},
                {"$sort": {"_id": 1}},
            ],
        }},
    ]

    out = list(db["expenses"].aggregate(pipeline))
    data = out[0] if out else {"totalsByType": [], "topCategories": [], "expenseByDay": []}

    total_income = 0.0
    total_expense = 0.0
    for row in data["totalsByType"]:
        if row["_id"] == "income":
            total_income = float(row["total"])
        elif row["_id"] == "expense":
            total_expense = float(row["total"])

    return {
        "from": date_from.isoformat(),
        "to": date_to.isoformat(),
        "totalIncome": round(total_income, 2),
        "totalExpense": round(total_expense, 2),
        "balance": round(total_income - total_expense, 2),
        "topCategories": [
            {"name": r["_id"], "amount": round(float(r["total"]), 2)}
            for r in data["topCategories"]
        ],
        "expenseByDay": [
            {"date": r["_id"], "amount": round(float(r["total"]), 2)}
            for r in data["expenseByDay"]
        ],
    }
