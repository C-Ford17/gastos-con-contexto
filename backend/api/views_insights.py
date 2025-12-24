from datetime import datetime, timezone, timedelta
from rest_framework.decorators import api_view
from rest_framework.response import Response

from api.services.insights_service import summary

def _parse_iso(dt: str | None):
    if not dt:
        return None
    return datetime.fromisoformat(dt.replace("Z", "+00:00"))

@api_view(["GET"])
def insights_summary(request):
    user_id = request.user.id

    # defaults: últimos 30 días
    now = datetime.now(timezone.utc)
    date_from = _parse_iso(request.query_params.get("from")) or (now - timedelta(days=30))
    date_to = _parse_iso(request.query_params.get("to")) or now

    return Response(summary(user_id, date_from, date_to))
