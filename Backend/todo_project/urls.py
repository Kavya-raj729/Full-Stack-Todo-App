from django.contrib import admin

from django.urls import path, include

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [

    path('admin/', admin.site.urls),

    path('tasks/', include('tasks.urls')),

    path('users/', include('users.urls')),
    path('github/',include('github_api.urls')),
    path('', include('django_prometheus.urls')),  
    path('ai/', include('ai_portfolio.urls')),  
    # path("auth/github/", include("github_auth.urls")),
    # JWT Routes
    path(
        'api/token/',
        TokenObtainPairView.as_view(),
        name='token_obtain_pair'
    ),

    path(
        'api/token/refresh/',
        TokenRefreshView.as_view(),
        name='token_refresh'
    ),
]