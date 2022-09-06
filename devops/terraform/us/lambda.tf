locals {
  lambda_environment_variables = {
    #    service will look for user pool vizyah-pool-{COGNITO_ENVIRONMENT}
    COGNITO_ENVIRONMENT = "dev"
    DEBUG_ENABLED       = !var.is_production
    SERVICE_NAME        = local.service_name
    AWS_REGION_NAME     = data.aws_region.current.name
    ENVIRONMENT         = terraform.workspace
    NOTIFIER_SNS_ARN    = aws_sns_topic.sns_topic.arn
    M2M_PASSWORD        = var.m2m_password
  }
  lambda_name           = "${terraform.workspace}-${local.service_name}"
  artifacts_bucket_name = "parkq-artifacts"
}

resource "aws_lambda_event_source_mapping" "async-sqs-mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.service.arn
  batch_size       = 1
  enabled          = true
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "${local.service_name}-${terraform.workspace}-lambda-layer"
  compatible_runtimes = ["python3.9"]
  s3_bucket           = local.artifacts_bucket_name
  s3_key              = "${local.service_name}/${local.service_name}-layer-${var.code_version}.zip"
}


resource "aws_lambda_function" "service" {
  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  handler       = "main.${local.service_short_name}_entrypoint"
  memory_size   = 128
  timeout       = 50
  depends_on    = [aws_cloudwatch_log_group.log-group-lambda]

  description = "Runs ${local.service_name} related sync tasks"
  layers      = [aws_lambda_layer_version.lambda_layer.arn]
  s3_bucket   = local.artifacts_bucket_name
  s3_key      = "${local.service_name}/${local.service_name}-${var.code_version}.zip"
  environment {
    variables = local.lambda_environment_variables
  }
  tags = local.tags
}

resource "aws_lambda_permission" "allow-api-gateway" {
  statement_id  = "AllowApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_stage.service-gateway.api_id}/**"
}

resource "aws_lambda_permission" "allow-cognito" {
  statement_id  = "AllowCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.service.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/*"
}

resource "aws_cloudwatch_log_group" "log-group-lambda" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = var.log_retention_days
}
