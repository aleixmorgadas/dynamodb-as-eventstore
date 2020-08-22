resource "aws_dynamodb_table" "event-store" {
  name = "event-store"
  billing_mode = "PROVISIONED"
  read_capacity = var.dynamo-db-read_capacitydynamo-db-read_capacity
  write_capacity = var.dynamo-db-write_capacity
  hash_key = "ID"
  range_key = "Timestamp"

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.dynamodb_event_store_key.arn
  }

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "EventType"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  tags = {
    Name = "event-store"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_kms_key" "dynamodb_event_store_key" {
  description = "encryption key for Event Store DynamoDB"
  tags = {
    Name = "dynamodb_event_store-key"
  }
}

resource "aws_kms_alias" "dynamodb_event_store_key_alias" {
  target_key_id = aws_kms_key.dynamodb_event_store_key.id
  name = "alias/dynamodb-event-store-key"
}