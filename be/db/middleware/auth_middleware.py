from fastapi import HTTPException, Cookie
import boto3
from secrets_keys import Secrets
cognito_client = boto3.client('cognito-idp', region_name=Secrets().REGION_NAME)

def _get_user_from_cognito(access_token: str):
    try:
        user_res = cognito_client.get_user(AccessToken=access_token)

        return {
            attr["Name"]: attr["Value"]
            for attr in user_res.get("UserAttributes", [])
        }
    except Exception as e:
        raise HTTPException(500, "Error fetching user")

def get_current_user(access_token: str = Cookie(None)):
    if not access_token:
        raise HTTPException(401, "Not authenticated")
    print(access_token)
    
    return _get_user_from_cognito(access_token)
