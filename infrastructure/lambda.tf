resource "aws_lambda_function" "event-handler" {
  function_name   = "event-handler"
  handler         = "eventhandler.handler"
  role            = aws_iam_role.event-store-lambda-role.arn
  runtime         = "python3.8"
  filename        = "../build/lambda.zip"
  source_code_hash = filesha256("../build/lambda.zip")
}

resource "aws_lambda_event_source_mapping" "queue-to-lambda" {
  event_source_arn = aws_sqs_queue.event-store-queue.arn
  function_name    = aws_lambda_function.event-handler.arn
  enabled = true
}

resource "aws_iam_role" "event-store-lambda-role" {
  name        = "event-store-lambda-role"
  path        = "/"
  description = "Allows Lambda Function to call AWS services on your behalf."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "event_handler_policy" {
  name        = "event_handler_policy"
  path        = "/"
  description = "IAM policy for event-handler lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ],
      "Resource": "arn:aws:sqs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "kms:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "event-handler-lambda-logs" {
  name              = "/aws/lambda/${aws_lambda_function.event-handler.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "event_handler_policy" {
  role       = aws_iam_role.event-store-lambda-role.name
  policy_arn = aws_iam_policy.event_handler_policy.arn

  depends_on = [aws_iam_role.event-store-lambda-role, aws_iam_policy.event_handler_policy]
}

data "aws_kms_alias" "queue-key" {
  name = "alias/event-store-queue-key"
}