import requests
import os
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import JsonResponse
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from decouple import config

from django.core.cache import cache
# GITHUB_CLIENT_ID = os.environ.get('CLIENT_ID')
# GITHUB_CLIENT_SECRET = os.environ.get('CLIENT_SECRET')

# def github_login(request):
#     github_auth_url = (
#         f"https://github.com/login/oauth/authorize"
#         f"?client_id={GITHUB_CLIENT_ID}"
#         f"&scope=repo user"
#     )

#     return JsonResponse({
#         "auth_url": github_auth_url
#     })


# def github_callback(request):
#     code = request.GET.get("code")

#     token_url = "https://github.com/login/oauth/access_token"

#     response = requests.post(
#         token_url,
#         headers={"Accept": "application/json"},
#         data={
#             "client_id": GITHUB_CLIENT_ID,
#             "client_secret": GITHUB_CLIENT_SECRET,
#             "code": code,
#         },
#     )

#     token_json = response.json()

#     access_token = token_json.get("access_token")

#     user_response = requests.get(
#         "https://api.github.com/user",
#         headers={
#             "Authorization": f"Bearer {access_token}"
#         },
#     )

#     user_data = user_response.json()

#     return JsonResponse({
#         "token": access_token,
#         "user": user_data,
#     })






GITHUB_TOKEN = config('GITHUB_TOKEN')

print("GITHUB_TOKEN:", GITHUB_TOKEN)





HEADERS = {
    "Authorization": f"Bearer {GITHUB_TOKEN}"
}

session = requests.Session()

session.headers.update(HEADERS)






















# =========================
# GITHUB PROFILE API
# =========================

@api_view(['GET'])
def github_profile(request, username):

    url = f'https://api.github.com/users/{username}'

    response = requests.get(url)

    data = response.json()

    formatted = {

        'avatar': data.get('avatar_url'),

        'name': data.get('name'),

        'username': data.get('login'),

        'bio': data.get('bio'),

        'company': data.get('company'),

        'blog': data.get('blog'),

        'location': data.get('location'),

        'email': data.get('email'),

        'twitter':
            data.get('twitter_username'),

        'followers':
            data.get('followers'),

        'following':
            data.get('following'),

        'public_repos':
            data.get('public_repos'),

        'public_gists':
            data.get('public_gists'),

        'created_at':
            data.get('created_at'),

        'updated_at':
            data.get('updated_at'),

        'hireable':
            data.get('hireable'),
    }

    return Response(formatted)


# =========================
# GITHUB REPO API
# =========================

@api_view(['GET'])
def github_repo(
    request,
    owner,
    repo
):

    url = (
        f'https://api.github.com/repos/'
        f'{owner}/{repo}'
    )

    response = requests.get(url)

    data = response.json()

    formatted = {

        'name':
            data.get('name'),

        'description':
            data.get('description'),

        'stars':
            data.get('stargazers_count'),

        'forks':
            data.get('forks_count'),

        'watchers':
            data.get('watchers_count'),

        'issues':
            data.get('open_issues_count'),

        'language':
            data.get('language'),

        'size':
            data.get('size'),

        'topics':
            data.get('topics'),

        'license':
            data.get('license'),

        'homepage':
            data.get('homepage'),

        'default_branch':
            data.get('default_branch'),

        'created_at':
            data.get('created_at'),

        'updated_at':
            data.get('updated_at'),

        'visibility':
            data.get('visibility'),

        'open_issues':
            data.get('open_issues'),

        'network_count':
            data.get('network_count'),

        'subscribers_count':
            data.get('subscribers_count'),
    }

    return Response(formatted)



@api_view(['GET'])
def github_languages(
    request,
    owner,
    repo
):

    url = (
        f'https://api.github.com/repos/'
        f'{owner}/{repo}/languages'
    )

    response = requests.get(url)

    if response.status_code == 200:

        return Response(response.json())

    return Response(
        {
            'error':
                'Unable to fetch languages'
        },
        status=response.status_code
    )

# =========================
# USER REPOSITORIES
# =========================
# =========================
# FETCH USER REPOSITORIES
# =========================

@api_view(['GET'])
def github_repositories(
    request,
    username
):

    try:

        url = (
            f'https://api.github.com/users/'
            f'{username}/repos'
        )

        headers = {
            "Accept":
                "application/vnd.github+json"
        }

        response = requests.get(
            url,
            headers=headers
        )

        data = response.json()

        repos = []

        for repo in data:

            repos.append({

                'name':
                    repo.get('name'),

                'description':
                    repo.get('description'),

                'language':
                    repo.get('language'),

                'stars':
                    repo.get(
                        'stargazers_count'
                    ),

                'forks':
                    repo.get(
                        'forks_count'
                    ),

                'watchers':
                    repo.get(
                        'watchers_count'
                    ),
            })

        return Response(repos)

    except Exception as e:

        return Response(
            {
                'error': str(e)
            },
            status=500
        )



def fetch_languages(url):

    try:

        response = session.get(
            url,
            timeout=5
        )

        if response.status_code == 200:
            return response.json()

    except Exception:
        return {}

    return {}


def github_combined_languages(request, username):

    repos_url = (
        f"https://api.github.com/users/{username}/repos"
        "?per_page=100"
    )
    cache_key = f"github_languages_{username}"
    

    cached_data = cache.get(cache_key)
   

    if cached_data:

       return JsonResponse(cached_data)
    repos_response = session.get(
        repos_url,
        timeout=5
    )

    if repos_response.status_code != 200:

        return JsonResponse({

            "github_status":
                repos_response.status_code,

            "github_response":
                repos_response.json(),

        })

    repos = repos_response.json()

    language_urls = []

    for repo in repos:
        if repo["fork"]:
            continue
        language_urls.append(
            repo["languages_url"]
        )

    combined_languages = {}

    total_bytes = 0
    worker_count = min(10, len(language_urls))
    with ThreadPoolExecutor(
        max_workers=worker_count
    ) as executor:

        results = executor.map(
            fetch_languages,
            language_urls
        )

        for languages in results:

            for language, bytes_count in languages.items():

                if language in combined_languages:

                    combined_languages[language] += bytes_count

                else:

                    combined_languages[language] = bytes_count

                total_bytes += bytes_count

    if total_bytes == 0:

        return JsonResponse({

            "username": username,

            "languages": {},

            "total_bytes": 0

        })

    percentage_languages = {}

    for language in combined_languages:

        percentage = (
        combined_languages[language]
        / total_bytes
        ) * 100

        if percentage >= 0.0001:

            percentage_languages[language] = round(
            percentage,
            4
        )

    sorted_languages = dict(

        sorted(
            percentage_languages.items(),
            key=lambda item: item[1],
            reverse=True
        )

    )

    response_data = ({

        "username": username,

        "repo_count": len(repos),

        "total_bytes": total_bytes,

        "languages": sorted_languages

    })
    
    cache.set(cache_key, response_data, timeout=60 * 60)

    return JsonResponse(response_data)