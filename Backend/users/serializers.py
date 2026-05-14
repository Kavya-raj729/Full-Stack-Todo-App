from django.contrib.auth.models import User
from rest_framework import serializers


class RegisterSerializer(serializers.ModelSerializer):

    confirm_password = serializers.CharField(
        write_only=True
    )

    class Meta:

        model = User

        fields = [
            'id',
            'username',
            'password',
            'confirm_password'
        ]

        extra_kwargs = {
            'password': {
                'write_only': True
            }
        }

    def validate_username(self, value):

        if User.objects.filter(
            username=value
        ).exists():

            raise serializers.ValidationError(
                "Username already exists"
            )

        return value

    def validate(self, attrs):

        if attrs['password'] != attrs['confirm_password']:

            raise serializers.ValidationError(
                {
                    'password': 'Passwords do not match'
                }
            )

        return attrs

    def create(self, validated_data):

        validated_data.pop('confirm_password')

        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password']
        )

        return user