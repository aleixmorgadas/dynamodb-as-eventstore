resource "aws_sqs_queue" "deadletter_queue" {
  name                        = "deadletter-queue"
}

resource "aws_sqs_queue" "event-store-queue" {
  name                        = "event-store-queue"
  max_message_size            = 2048
  message_retention_seconds   = 86400
  receive_wait_time_seconds   = 10
  redrive_policy              = jsonencode({
    deadLetterTargetArn       = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount           = 4
  })
  kms_master_key_id           = aws_kms_alias.event-store-queue_key_alias.id

  tags = {
    Name = "event-store-queue"
  }
}

resource "aws_sqs_queue_policy" "event-store-queue_policy" {
  queue_url = aws_sqs_queue.event-store-queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "event-store-queue-policy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "sqs:*"
      ],
      "Resource": "${aws_sqs_queue.event-store-queue.id}"
    }
  ]
}
POLICY
}

resource "aws_kms_key" "event-store-queue_key" {
  description = "encryption key for Event store SQS"
  policy = data.aws_iam_policy_document.event-store-queue_key_policy.json
  tags = {
    Name = "event-store-queue-key"
  }
}

resource "aws_kms_alias" "event-store-queue_key_alias" {
  target_key_id = aws_kms_key.event-store-queue_key.id
  name = "alias/event-store-queue-key"
}

data "aws_iam_policy_document" "event-store-queue_key_policy" {
  policy_id = "event-store-queue-key-policy"

  statement {
    sid = "Enable IAM User Permissions"
    actions = ["kms:*"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account}:root"]
    }
    resources = ["*"]
    effect = "Allow"
  }

  statement {
    sid = "lambda decrypt permission"
    actions = ["kms:*"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    resources = ["*"]
    effect = "Allow"
  }
}