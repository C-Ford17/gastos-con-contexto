from rest_framework import serializers

class CategoryCreateSerializer(serializers.Serializer):
    name = serializers.CharField(min_length=1, max_length=60)
    type = serializers.ChoiceField(choices=["expense", "income"])
    emoji = serializers.CharField(required=False, allow_blank=True, max_length=8)
    color = serializers.CharField(required=False, allow_blank=True, max_length=16)
    order = serializers.IntegerField(required=False)

class CategoryUpdateSerializer(serializers.Serializer):
    name = serializers.CharField(required=False, min_length=1, max_length=60)
    emoji = serializers.CharField(required=False, allow_blank=True, max_length=8)
    color = serializers.CharField(required=False, allow_blank=True, max_length=16)
    order = serializers.IntegerField(required=False)
