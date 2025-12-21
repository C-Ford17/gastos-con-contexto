from django.urls import path
from api import views_auth

urlpatterns = [
    path("auth/register", views_auth.register),
    path("auth/login", views_auth.login),
    path("auth/me", views_auth.me),
]
