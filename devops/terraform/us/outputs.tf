output "log_groups" {
  value = [aws_cloudwatch_log_group.log-group-lambda.name]
}

output "topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}

output "sqs_url" {
  value = aws_sqs_queue.queue.url
}

output "sqs_arn" {
  value = aws_sqs_queue.queue.arn
}

output "user-service-lambda-arn" {
  value   = aws_lambda_function.service.arn
}
