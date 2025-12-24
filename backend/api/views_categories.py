from bson import ObjectId
from pymongo.errors import DuplicateKeyError
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from api.repositories.categories_repo import (
    list_categories, create_category, get_category, update_category, delete_category
)
from api.serializers_categories import CategoryCreateSerializer, CategoryUpdateSerializer

def _to_dto(doc: dict):
    return {
        "id": str(doc["_id"]),
        "name": doc.get("name", ""),
        "type": doc.get("type", ""),
        "emoji": doc.get("emoji", ""),
        "color": doc.get("color", ""),
        "order": doc.get("order", 0),
        "createdAt": doc.get("createdAt"),
        "updatedAt": doc.get("updatedAt"),
    }

@api_view(["GET", "POST"])
def categories(request):
    user_id = request.user.id

    if request.method == "GET":
        type_ = request.query_params.get("type")
        docs = list_categories(user_id, type_=type_)
        return Response([_to_dto(d) for d in docs])

    serializer = CategoryCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    try:
        doc = create_category(
            user_id=user_id,
            name=serializer.validated_data["name"],
            type_=serializer.validated_data["type"],
            emoji=serializer.validated_data.get("emoji"),
            color=serializer.validated_data.get("color"),
            order=serializer.validated_data.get("order"),
        )
        return Response(_to_dto(doc), status=status.HTTP_201_CREATED)
    except DuplicateKeyError:
        return Response({"error": "Category already exists (same name/type)."}, status=400)

@api_view(["PATCH", "DELETE", "GET"])
def category_detail(request, category_id: str):
    user_id = request.user.id

    doc = get_category(user_id, category_id)
    if not doc:
        return Response({"error": "Category not found"}, status=404)

    if request.method == "GET":
        return Response(_to_dto(doc))

    if request.method == "DELETE":
        ok = delete_category(user_id, category_id)
        return Response(status=204 if ok else 404)

    serializer = CategoryUpdateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    patch = dict(serializer.validated_data)
    updated = update_category(user_id, category_id, patch)
    return Response(_to_dto(updated))
