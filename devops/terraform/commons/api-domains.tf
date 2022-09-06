data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_apigatewayv2_domain_name" "api-domain" {
  domain_name = "api.${terraform.workspace}.parq.co"
  tags        = local.tags


  domain_name_configuration {
    certificate_arn = "arn:aws:acm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:certificate/df6c8f3d-ac46-4c56-b05c-4d0c174ccbab"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}


resource "aws_route53_record" "api-domain-registration" {
  name    = aws_apigatewayv2_domain_name.api-domain.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api-domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api-domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}



