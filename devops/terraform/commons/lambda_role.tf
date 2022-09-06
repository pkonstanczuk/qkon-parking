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
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]
    effect    = "Allow"
    resources = [
      "*"
    ]
    sid = "DynamoDbListPolicy"
  }
  statement {
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${upper(terraform.workspace)}*"
    ]
    sid = "DynamoDbTablePolicy"
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
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${terraform.workspace}-*"
    ]
    sid = "LambdaPermissions"
  }
  statement {
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
    effect    = "Allow"
    resources = [
      "*"
    ]
    sid = "LambdaVPCPermissions"
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:s3:::parkq-${terraform.workspace}-*"
    ]
    sid = "S3Permissions"
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*${terraform.workspace}*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda-insights:*"

    ]
    sid = "LogPermissions"
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name                = "parkq-${terraform.workspace}-lambda-role"
  tags                = local.tags
  inline_policy {
    name   = "${terraform.workspace}_resources_access"
    policy = data.aws_iam_policy_document.lambda_policy.json
  }
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}
