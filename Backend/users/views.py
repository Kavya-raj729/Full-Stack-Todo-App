from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import RegisterSerializer

from django.contrib.auth.models import User
from django.contrib.auth import authenticate


# =========================
# GENERATE JWT TOKENS
# =========================

def get_tokens_for_user(user):

    refresh = RefreshToken.for_user(user)

    return {

        'refresh': str(refresh),

        'access': str(refresh.access_token),
    }


# =========================
# REGISTER API
# =========================

@api_view(['POST'])
def register_api(request):

    serializer = RegisterSerializer(
        data=request.data
    )

    if serializer.is_valid():

        user = serializer.save()

        tokens = get_tokens_for_user(user)

        return Response(
            {
                'message': 'User Registered Successfully',
                'tokens': tokens
            },
            status=status.HTTP_201_CREATED
        )

    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )


# =========================
# LOGIN API
# =========================

@api_view(['POST'])
def login_api(request):

    username = request.data.get('username')

    password = request.data.get('password')

    user = authenticate(
        username=username,
        password=password
    )

    if user is not None:

        tokens = get_tokens_for_user(user)

        return Response(
            {
                'message': 'Login Successful',
                'tokens': tokens
            },
            status=status.HTTP_200_OK
        )

    return Response(
        {
            'error': 'Invalid Credentials'
        },
        status=status.HTTP_401_UNAUTHORIZED
    )


# =========================
# LOGOUT API
# =========================

@api_view(['POST'])
def logout_api(request):

    print("REQUEST DATA:")
    print(request.data)

    try:

        refresh_token = request.data.get(
            'refresh'
        )

        print("REFRESH TOKEN:")
        print(refresh_token)

        token = RefreshToken(
            refresh_token
        )

        token.blacklist()

        print(
            "USER LOGGED OUT SUCCESSFULLY"
        )

        return Response(
            {
                'message':
                    'Logout Successful'
            },
            status=status.HTTP_205_RESET_CONTENT
        )

    except Exception as e:

        print("LOGOUT ERROR:")
        print(str(e))

        return Response(
            {
                'error': str(e)
            },
            status=status.HTTP_400_BAD_REQUEST
        )