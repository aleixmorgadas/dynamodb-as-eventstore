import json
from decimal import Decimal

from schemavalidation import validate
import boto3
import os

dynamodb = boto3.resource('dynamodb')

def handler(event, context):
    table = dynamodb.Table('event-store)

    for record in event['Records']:
        payload=record["body"]
        is_valid = validate(payload)
        event = json.loads(payload, parse_float=Decimal)
        if not is_valid:
            raise Exception("schema is not valid")

        table.put_item(
            Item=event
        )

        print('Stored Event', event)

