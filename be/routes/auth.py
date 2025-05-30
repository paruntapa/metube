from fastapi import APIRouter, Depends, HTTPException, Response, Cookie
import boto3
from pydantic_models.auth_models import SignupRequest, LoginRequest, ConfirmSignupRequest
from secrets_keys import Secrets
from helper.auth_helper import get_secret_hash
from sqlalchemy.orm import Session
from db.db import get_db
from db.models.users import User
from db.middleware.auth_middleware import get_current_user

router = APIRouter()
secrets_keys = Secrets()

COGNITO_CLIENT_ID = secrets_keys.COGNITO_CLIENT_ID
COGNITO_CLIENT_SECRET = secrets_keys.COGNITO_CLIENT_SECRET

cognito_client = boto3.client('cognito-idp', region_name=secrets_keys.REGION_NAME)

@router.post("/signup")
def signup_user(data: SignupRequest, db: Session = Depends(get_db)):
    print(data)

    try:
        secret_hash = get_secret_hash(data.email, COGNITO_CLIENT_ID, COGNITO_CLIENT_SECRET)
        cognito_response = cognito_client.sign_up(
            ClientId=COGNITO_CLIENT_ID,
            Username=data.email,
            Password=data.password,
            SecretHash=secret_hash,
            UserAttributes=[
                {'Name': "email", "Value": data.email},
                {'Name': "name", "Value": data.name}
            ]
        )

        cognito_sub = cognito_response.get("UserSub")

        if not cognito_sub: 
            raise HTTPException(400, "Cognito sub not found")
        
        new_user = User(name=data.name, email=data.email, cognito_sub=cognito_sub)
        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        return {"Message": "Signed up successfully. Please verify your email"}
    except Exception as e:
        raise HTTPException(400, f'Cognito signup failed: {e}')
    
@router.post("/login")
def login_user(data: LoginRequest, response: Response):

    try:
        secret_hash = get_secret_hash(data.email, COGNITO_CLIENT_ID, COGNITO_CLIENT_SECRET)

        cognito_response = cognito_client.initiate_auth(
            ClientId=COGNITO_CLIENT_ID,
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': data.email,
                'PASSWORD': data.password,
                'SECRET_HASH': secret_hash
            }
        )

        auth_result = cognito_response.get("AuthenticationResult")

        if not auth_result:
            raise HTTPException(400, "Invalid credentials")

        access_token = auth_result.get("AccessToken")
        refresh_token = auth_result.get("RefreshToken")

        response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True)
        response.set_cookie(key="refresh_token", value=refresh_token, httponly=True, secure=True)

        return {"Message": "Logged in successfully"}
    except Exception as e:
        raise HTTPException(400, f'Cognito signup failed: {e}')

@router.post("/confirm-signup")
def confirm_signup(data: ConfirmSignupRequest):

    try:
        secret_hash = get_secret_hash(data.email, COGNITO_CLIENT_ID, COGNITO_CLIENT_SECRET)

        cognito_response = cognito_client.confirm_sign_up(
            ClientId=COGNITO_CLIENT_ID,
            Username=data.email,
            ConfirmationCode=data.otp,
            SecretHash=secret_hash
        )

        return {"Message": "OTP Verified"}
    except Exception as e:
        raise HTTPException(400, f'Cognito signup failed: {e}')
    
@router.post("/refresh")
def refresh_token(refresh_token: str = Cookie(None), user_cognito_sub: str = Cookie(None), response: Response = None):

    try:
        secret_hash = get_secret_hash(user_cognito_sub, COGNITO_CLIENT_ID, COGNITO_CLIENT_SECRET)

        cognito_response = cognito_client.initiate_auth(
            ClientId=COGNITO_CLIENT_ID,
            AuthFlow='REFRESH_TOKEN_AUTH',
            AuthParameters={
                'REFRESH_TOKEN': refresh_token,
                'SECRET_HASH': secret_hash
            },
        )

        auth_result = cognito_response.get("AuthenticationResult")

        if not auth_result:
            raise HTTPException(400, "Invalid credentials")

        access_token = auth_result.get("AccessToken")

        response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True)

        return {"Message": "Access Token refreshed"}
    except Exception as e:
        raise HTTPException(400, f'Cognito signup failed: {e}')
    
@router.get('/me')
def protected_route(user = Depends(get_current_user)):
    return user;
