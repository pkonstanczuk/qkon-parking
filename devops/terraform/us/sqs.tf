locals {
  queue-name = "${terraform.workspace}-US.fifo"
}
resource "aws_sqs_queue" "queue" {
  name                        = local.queue-name
  fifo_queue                  = true
  delay_seconds               = 0
  content_based_deduplication = false
  message_retention_seconds   = 300
  visibility_timeout_seconds  = 300
  policy                      = data.aws_iam_policy_document.bs-sqs-queue-policy.json
  tags                        = local.tags
}

data "aws_iam_policy_document" "bs-sqs-queue-policy" {
  policy_id = "sqs-queue-policy-${local.queue-name}/SQSDefaultPolicy"

  statement {
    sid    = "sns-topic-send"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.queue-name}"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [
        "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*${terraform.workspace}*"
      ]
    }
  }
}

