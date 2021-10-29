import json
import boto3
import dateutil.tz
import os
from base64 import b64decode

kms_client=boto3.client('kms')
encrypted_snow_creds = os.environ['SNOW_CREDS']

cred = kms_client.decrypt(
    CiphertextBlob=b64decode(encrypted_snow_creds),
    EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
)['Plaintext'].decode('utf-8')

cred = json.loads(cred)
client_id = cred['CLIENT_ID']
client_secret = cred['CLIENT_SECRET']
user_name = cred['USERNAME']
password = cred['PASSWORD']


def lambda_handler(event, context):
    print("hello from lambda")
    return{
        'Statuscode': '200'
    }