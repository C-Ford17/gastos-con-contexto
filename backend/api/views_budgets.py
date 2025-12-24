from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from api.repositories.budgets_repo import upsert_budget, list_budgets, delete_budget
from api.services.budgets_service import spent_by_category_for_month
from api.serializers_budgets import BudgetUpsertSerializer

def _dto(doc: dict):
    return {
        "id": str(doc["_id"]),
        "month": doc.get("month"),
        "categoryId": str(doc.get("categoryId")),
        "limitAmount": doc.get("limitAmount"),
        "alertThreshold": doc.get("alertThreshold", 80),
        "createdAt": doc.get("createdAt"),
        "updatedAt": doc.get("updatedAt"),
    }

@api_view(["GET", "POST"])
def budgets(request):
    user_id = request.user.id

    if request.method == "GET":
        month = request.query_params.get("month")
        docs = list_budgets(user_id, month=month)
        return Response([_dto(d) for d in docs])

    serializer = BudgetUpsertSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    doc = upsert_budget(
        user_id=user_id,
        month=serializer.validated_data["month"],
        category_id=serializer.validated_data["categoryId"],
        limit_amount=serializer.validated_data["limitAmount"],
        alert_threshold=serializer.validated_data.get("alertThreshold", 80),
    )
    return Response(_dto(doc), status=status.HTTP_201_CREATED)

@api_view(["DELETE"])
def budget_detail(request, budget_id: str):
    user_id = request.user.id
    ok = delete_budget(user_id, budget_id)
    return Response(status=204 if ok else 404)

@api_view(["GET"])
def budget_alerts(request):
    user_id = request.user.id
    month = request.query_params.get("month")
    if not month:
        return Response({"error": "month is required (YYYY-MM)"}, status=400)

    budgets_docs = list_budgets(user_id, month=month)
    spent_map = spent_by_category_for_month(user_id, month)

    alerts = []
    for b in budgets_docs:
        category_id = str(b["categoryId"])
        spent = float(spent_map.get(category_id, 0.0))
        limit_amount = float(b.get("limitAmount", 0.0))
        pct = (spent / limit_amount * 100.0) if limit_amount > 0 else 0.0

        level = None
        if pct >= 100:
            level = "red"
        elif pct >= float(b.get("alertThreshold", 80)):
            level = "yellow"

        alerts.append({
            "categoryId": category_id,
            "month": month,
            "limitAmount": limit_amount,
            "spent": spent,
            "percentage": round(pct, 1),
            "alertLevel": level,
        })

    return Response({
        "month": month,
        "alerts": [a for a in alerts if a["alertLevel"] is not None],
    })
