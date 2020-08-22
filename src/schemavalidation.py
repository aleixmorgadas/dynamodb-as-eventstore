import json
from decimal import Decimal

import jsonschema

schema = {
    'type': 'object',
    'properties': {
        'Timestamp': {'type': 'number'},
        'EventType': {'type': 'string'},
        'ID': {'type': 'string'},
        'EmitterId': {'type': 'string'},
        'EmitterType': {'type': 'string'},
        'Data': {'type': ['object', 'null']},
    },
    'required': ['Timestamp', 'EventType', 'ID', 'EmitterId', 'EmitterType']
}


def validate(message):
    try:
        instance = json.loads(message, parse_float=Decimal)
        jsonschema.validate(instance, schema=schema)
        return True
    except Exception as e:
        print('Invalid Event Schema', e)
        return False
