import unittest
import json

import schemavalidation


class SchemaValidationTestCase(unittest.TestCase):
    def test_event_schema_is_valid(self):
        message = json.dumps({
            'Timestamp': 1596717736,
            'EventType': 'EVENT_TEST',
            'ID': 'random-id',
            'EmitterId': 'random-emitter-id',
            'EmitterType': 'SYSTEM',
            'Data': {
                'field': 'value'
            }
        })

        is_valid = schemavalidation.validate(message)

        self.assertTrue(is_valid)

    def test_event_schema_is_invalid(self):
        # data field is missing
        message = json.dumps({
            'Timestamp': 1596717736,
            'EventType': 'EVENT_TEST',
            'ID': 'random-id',
            'EmitterId': 'random-emitter-id',
        })

        is_valid = schemavalidation.validate(message)

        self.assertFalse(is_valid)

    def test_event_schema_is_valid_when_data_is_none(self):
        message = json.dumps({
            'Timestamp': 1596717736,
            'EventType': 'EVENT_TEST',
            'ID': 'random-id',
            'EmitterId': 'random-emitter-id',
            'EmitterType': 'SYSTEM',
            'Data': None
        })

        is_valid = schemavalidation.validate(message)

        self.assertTrue(is_valid)

if __name__ == '__main__':
    unittest.main()
