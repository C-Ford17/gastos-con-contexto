from rest_framework import serializers

class BudgetUpsertSerializer(serializers.Serializer):
    month = serializers.RegexField(regex=r"^\d{4}-\d{2}$")  # YYYY-MM
    categoryId = serializers.CharField()
    limitAmount = serializers.FloatField(min_value=0)
    alertThreshold = serializers.IntegerField(min_value=1, max_value=100, required=False, default=80)
