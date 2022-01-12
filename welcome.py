import json
import boto3
import dateutil.tz
import os
from base64 import b64decode

kms_client=boto3.client('kms')
encrypted_snow_creds = os.environ['cred']

creds = kms_client.decrypt(
    CiphertextBlob=b64decode(encrypted_snow_creds),
    EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
)['Plaintext'].decode('utf-8')
print(creds)
cred = json.loads(creds)
client_id = cred['client_id']
print(client_id)
password = cred['password']
print(password)
def handler(event, context):
    print("hello from lambda")
    return{
        'Statuscode': '200'
    }
