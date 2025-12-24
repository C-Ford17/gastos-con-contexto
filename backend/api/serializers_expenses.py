from rest_framework import serializers

class ExpenseCreateSerializer(serializers.Serializer):
    type = serializers.ChoiceField(choices=["expense", "income"])
    amount = serializers.FloatField(min_value=0.01)
    currency = serializers.CharField(required=False, default="COP")
    date = serializers.DateTimeField()  # ISO datetime

    categoryId = serializers.CharField()
    mood = serializers.IntegerField(min_value=1, max_value=10, required=False)
    reason = serializers.ChoiceField(choices=["need", "craving", "impulse", "other"], required=False)
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)
    tags = serializers.ListField(child=serializers.CharField(max_length=30), required=False)
    receiptImageUrl = serializers.URLField(required=False, allow_null=True)

class ExpenseUpdateSerializer(serializers.Serializer):
    amount = serializers.FloatField(min_value=0.01, required=False)
    date = serializers.DateTimeField(required=False)

    mood = serializers.IntegerField(min_value=1, max_value=10, required=False)
    reason = serializers.ChoiceField(choices=["need", "craving", "impulse", "other"], required=False)
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)
    tags = serializers.ListField(child=serializers.CharField(max_length=30), required=False)
    receiptImageUrl = serializers.URLField(required=False, allow_null=True)
