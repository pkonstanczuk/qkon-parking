locals {
  api_definition = templatefile(
    "${path.module}/../../../devops/contracts-ui/contracts/${local.service_name}-contract.yaml",
    {
      lambda_arn           = aws_lambda_function.service.invoke_arn
      environment          = terraform.workspace
      cognito_user_pool_id = var.cognito_user_pool_id
      cognito_client_id    = var.cognito_client_id
    }
  )
}

resource "local_file" "filled_contract" {
  content  = local.api_definition
  filename = "${path.module}/../contracts/${local.service_name}-contract.yaml"
}


resource "aws_apigatewayv2_api" "service-gateway" {
  name          = "${local.service_name}-api-${terraform.workspace}"
  protocol_type = "HTTP"
  tags          = local.tags
  body          = local.api_definition
  cors_configuration {
    allow_headers     = ["*"]
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    expose_headers    = ["*"]
    max_age           = 0
    allow_credentials = false

  }
}
resource "aws_apigatewayv2_stage" "service-gateway" {
  api_id      = aws_apigatewayv2_api.service-gateway.id
  name        = "default"
  auto_deploy = true
  tags        = local.tags
}

resource "aws_apigatewayv2_api_mapping" "domain-mapping" {
  api_id          = aws_apigatewayv2_api.service-gateway.id
  domain_name     = var.api-domain-name
  stage           = aws_apigatewayv2_stage.service-gateway.id
  api_mapping_key = local.service_short_name
}

resource "aws_apigatewayv2_api_mapping" "domain-mapping-full" {
  api_id          = aws_apigatewayv2_api.service-gateway.id
  domain_name     = var.api-domain-name
  stage           = aws_apigatewayv2_stage.service-gateway.id
  api_mapping_key = local.service_name
}
