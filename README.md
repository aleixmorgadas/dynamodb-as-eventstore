# dynamodb-as-eventstore

Using DynamoDB as EventStore with SQS and Lambda.

[![practical-dev](.github/assets/infrastructure.png)](https://dev.to/aleixmorgadas/dynamodb-as-eventstore-4o71-temp-slug-7165395)

Article at https://dev.to/aleixmorgadas/dynamodb-as-eventstore-4o71-temp-slug-7165395

## Setup local environment

I assume you have:

- [Terraform installed](https://www.terraform.io/)
- [AWS Account](https://aws.amazon.com/)
- Python Environment

__Install Python Dependencies__

:information_source: I used Linux/Debian for this project, you might need to adapt the commands to your operating system.

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

You might need `python3-venv` as OS dependency installed.

## Deployment

:warning: __The provided solution will incur in your billing as some services are not part of the AWS Free Tier__ 

Before Deployment, you should check:

- `infrastructure/main.tf`. The region
- `infrastructure/variables.tf`. Set the read and write capacity of DynamoDB that you need. Default read-capacity 1, write-capacity 1.

At `infrastructure` folder, execute `./run.sh`.

## Event Base

All events received by the lambda __must__ follow the next schema:

| Field     | Type      | Required  | Description   |
| ---       | ----      | ---       | ---           |
| Timestamp | Date      | true      | Time when event was created |
| EventType | String    | true      | Event identifier. Format `EVENT_EXAMPLE` |
| ID        | String    | true      | Id of the entity  |
| EmitterId | String    | true      | Id of the user or system that caused the event |
| EmitterType | String    | true      | `SYSTEM` or `USER` |
| Data      | Object | null    | true      | fields of the event |

In case of not following the schema, the event will be rejected.

Example:

```json
{
	"Timestamp"	: 1596719980,
	"EventType"	: "EVENT_TEST",
	"ID"		: "test_id",
	"EmitterId"	: "me",
    "EmitterType": "human",
	"Data"		: {
		"foo": "bar"
	}
}
```

## Technical Debt

The different AWS Roles have too much permissions in their policies. It will be convenient that you restricted those to what's really required.