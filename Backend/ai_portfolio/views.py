from rest_framework.decorators import api_view
from rest_framework.response import Response
from .services.github_service import fetch_complete_profile
from .services.groq_service import generate_ai_resume


@api_view(['POST'])
def generate_portfolio(request):

    username = request.data.get("username")

    github_data = fetch_complete_profile(username)

    ai_response = generate_ai_resume(
        username,
        github_data
    )

    return Response(ai_response)