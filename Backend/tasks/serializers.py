from rest_framework import serializers
from .models import Task


class TaskSerializer(serializers.ModelSerializer):

    class Meta:
        model = Task
        fields = ['id', 'title', 'completed', 'created_at']
        read_only_fields = ['id', 'created_at']

    def validate_title(self, value):

        if not value.strip():
            raise serializers.ValidationError(
                "Title cannot be empty"
            )

        if len(value.strip()) < 3:
            raise serializers.ValidationError(
                "Title must be at least 3 characters long"
            )

        return value