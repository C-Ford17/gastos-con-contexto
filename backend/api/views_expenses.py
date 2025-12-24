from datetime import datetime
from bson import ObjectId
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from api.serializers_expenses import ExpenseCreateSerializer, ExpenseUpdateSerializer
from api.repositories.expenses_repo import (
    create_expense, list_expenses, get_expense, update_expense, delete_expense
)
from api.repositories.categories_repo import get_category

def _dto(doc: dict):
    return {
        "id": str(doc["_id"]),
        "type": doc.get("type"),
        "amount": doc.get("amount"),
        "currency": doc.get("currency", "COP"),
        "date": doc.get("date"),
        "categoryId": str(doc.get("categoryId")),
        "categoryNameSnapshot": doc.get("categoryNameSnapshot", ""),
        "mood": doc.get("mood"),
        "reason": doc.get("reason"),
        "note": doc.get("note", ""),
        "tags": doc.get("tags", []),
        "receiptImageUrl": doc.get("receiptImageUrl"),
        "createdAt": doc.get("createdAt"),
        "updatedAt": doc.get("updatedAt"),
    }

def _parse_int(value: str | None, default: int):
    try:
        return int(value)
    except:
        return default

@api_view(["GET", "POST"])
def expenses(request):
    user_id = request.user.id

    if request.method == "GET":
        # filtros
        from_s = request.query_params.get("from")
        to_s = request.query_params.get("to")

        filters = {
            "categoryId": request.query_params.get("categoryId"),
            "type": request.query_params.get("type"),
            "reason": request.query_params.get("reason"),
            "q": request.query_params.get("q"),
        }

        if from_s:
            filters["from"] = datetime.fromisoformat(from_s.replace("Z", "+00:00"))
        if to_s:
            filters["to"] = datetime.fromisoformat(to_s.replace("Z", "+00:00"))

        limit = max(1, min(200, _parse_int(request.query_params.get("limit"), 50)))
        offset = max(0, _parse_int(request.query_params.get("offset"), 0))

        items, total = list_expenses(user_id, filters, limit=limit, offset=offset)
        return Response({
            "count": total,
            "limit": limit,
            "offset": offset,
            "results": [_dto(x) for x in items],
        })

    # POST
    serializer = ExpenseCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    # category snapshot
    category_doc = get_category(user_id, data["categoryId"])
    if not category_doc:
        return Response({"error": "Category not found"}, status=400)

    doc = {
        **data,
        "categoryNameSnapshot": category_doc.get("name", ""),
    }

    created = create_expense(user_id, doc)
    return Response(_dto(created), status=status.HTTP_201_CREATED)

@api_view(["GET", "PATCH", "DELETE"])
def expense_detail(request, expense_id: str):
    user_id = request.user.id

    doc = get_expense(user_id, expense_id)
    if not doc:
        return Response({"error": "Expense not found"}, status=404)

    if request.method == "GET":
        return Response(_dto(doc))

    if request.method == "DELETE":
        ok = delete_expense(user_id, expense_id)
        return Response(status=204 if ok else 404)

    serializer = ExpenseUpdateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    updated = update_expense(user_id, expense_id, dict(serializer.validated_data))
    return Response(_dto(updated))
