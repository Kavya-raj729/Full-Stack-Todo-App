from django.urls import path
from .views import register_api, login_api

urlpatterns = [

    path(
        'api/register/',
        register_api,
        name='register-api'
    ),

    path(
        'api/login/',
        login_api,
        name='login-api'
    ),
]