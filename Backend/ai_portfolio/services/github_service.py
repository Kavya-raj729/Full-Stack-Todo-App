import requests


def fetch_complete_profile(username):

    profile_url = f"https://api.github.com/users/{username}"

    profile = requests.get(profile_url).json()

    repos_url = f"https://api.github.com/users/{username}/repos"

    repos = requests.get(repos_url).json()

    repo_data = []

    for repo in repos:

        languages = requests.get(
            repo["languages_url"]
        ).json()

        repo_data.append({
            "name": repo.get("name"),
            "description": repo.get("description"),
            "topics": repo.get("topics", []),
            "stars": repo.get("stargazers_count"),
            "forks": repo.get("forks_count"),
            "language": repo.get("language"),
            "languages": list(languages.keys()),
            "created_at": repo.get("created_at"),
            "updated_at": repo.get("updated_at"),
        })

    return {
        "profile": {
            "name": profile.get("name"),
            "bio": profile.get("bio"),
            "followers": profile.get("followers"),
            "following": profile.get("following"),
            "public_repos": profile.get("public_repos"),
            "location": profile.get("location"),
        },
        "repositories": repo_data
    }