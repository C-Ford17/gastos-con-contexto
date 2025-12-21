from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from api.repositories.users_repo import find_by_email, create_user
from api.security.passwords import hash_password, verify_password

def _tokens_for_user_id(user_id: str):
    # Creamos refresh token “vacío” y metemos claim user_id.
    refresh = RefreshToken()
    refresh["user_id"] = user_id
    return {"refresh": str(refresh), "access": str(refresh.access_token)}

@api_view(["POST"])
@permission_classes([AllowAny])
def register(request):
    email = (request.data.get("email") or "").strip().lower()
    password = request.data.get("password") or ""
    username = (request.data.get("username") or "").strip()

    if not email or not password:
        return Response({"error": "email and password required"}, status=400)

    if find_by_email(email):
        return Response({"error": "email already exists"}, status=400)

    user = create_user(email=email, password_hash=hash_password(password), username=username or None)
    tokens = _tokens_for_user_id(str(user["_id"]))

    return Response({
        "user": {"id": str(user["_id"]), "email": user["email"], "username": user["username"]},
        **tokens
    }, status=status.HTTP_201_CREATED)

@api_view(["POST"])
@permission_classes([AllowAny])
def login(request):
    email = (request.data.get("email") or "").strip().lower()
    password = request.data.get("password") or ""

    user = find_by_email(email)
    if not user or not verify_password(password, user["passwordHash"]):
        return Response({"error": "invalid credentials"}, status=401)

    tokens = _tokens_for_user_id(str(user["_id"]))
    return Response({
        "user": {"id": str(user["_id"]), "email": user["email"], "username": user["username"]},
        **tokens
    })

@api_view(["GET"])
def me(request):
    # request.user viene del MongoJWTAuthentication
    return Response({
        "id": request.user.id,
        "email": request.user.email,
        "username": request.user.username,
    })
