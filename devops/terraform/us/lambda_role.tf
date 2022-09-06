data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
    sid    = "AllowToAssumeRoleByLambda"
  }
}


data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${terraform.workspace}-*"
    ]
    sid = "LambdaPermissions"
  }
  statement {
    actions = [
      "cognito-idp:*"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
    sid = "CognitoPermissions"
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*${terraform.workspace}*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda-insights:*"

    ]
    sid = "LogPermissions"
  }
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:TagQueue",
      "sqs:UntagQueue",
      "sqs:PurgeQueue"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${terraform.workspace}-*.fifo"
    ]
    sid = "SQSPermissions"
  }
  statement {
    actions = [
      "sns:Publish",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${terraform.workspace}-*"
    ]
    sid = "SNSPermissions"
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name = "parkq-${local.service_name}-${terraform.workspace}-lambda-role"
  tags = local.tags
  inline_policy {
    name   = "${terraform.workspace}_resources_access"
    policy = data.aws_iam_policy_document.lambda_policy.json
  }
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}
