from django.urls import path
from api import views_auth
from api import views_categories
from api import views_expenses

urlpatterns = [
    path("auth/register", views_auth.register),
    path("auth/login", views_auth.login),
    path("auth/me", views_auth.me),
    path("categories", views_categories.categories),
    path("categories/<str:category_id>", views_categories.category_detail),
    path("expenses", views_expenses.expenses),
    path("expenses/<str:expense_id>", views_expenses.expense_detail),   
]
