from dataclasses import dataclass
from bson import ObjectId
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication
from api.repositories.users_repo import find_by_id

@dataclass
class MongoUser:
    id: str
    email: str
    username: str

    @property
    def is_authenticated(self):
        return True

class MongoJWTAuthentication(BaseAuthentication):
    """
    1) Valida el token con SimpleJWT.
    2) Lee claim user_id.
    3) Busca usuario en Mongo y lo expone como request.user.
    """
    def __init__(self):
        self._jwt = JWTAuthentication()

    def authenticate(self, request):
        header = self._jwt.get_header(request)
        if header is None:
            return None

        raw_token = self._jwt.get_raw_token(header)
        if raw_token is None:
            return None

        validated_token = self._jwt.get_validated_token(raw_token)
        user_id = validated_token.get("user_id")
        if not user_id:
            raise AuthenticationFailed("Token missing user_id")

        user_doc = find_by_id(user_id)
        if not user_doc:
            raise AuthenticationFailed("User not found")

        user = MongoUser(
            id=str(user_doc["_id"]),
            email=user_doc.get("email", ""),
            username=user_doc.get("username", ""),
        )
        return (user, validated_token)
