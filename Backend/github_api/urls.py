from django.urls import path

from .views import (
    github_profile,
    github_repo,
    github_languages,
    github_repositories,
    github_combined_languages,
    # github_login,
    # github_callback,
)

urlpatterns = [

    path(
        'profile/<str:username>/',
        github_profile,
    ),

    path(
        'repo/<str:owner>/<str:repo>/',
        github_repo,
    ),
    path(
        'languages/<str:owner>/<str:repo>/',
        github_languages,
    ),
    path(
        'repos/<str:username>/',
        github_repositories,
    ),
      path(
        'combined-languages/<str:username>/',
        github_combined_languages,
    ),
    # path("login/", github_login, name="github_login"),
    # path("callback/", github_callback, name="github_callback"),
]