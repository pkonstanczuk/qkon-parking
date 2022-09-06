output "lambda_role_arn" {
  value = aws_iam_role.iam_for_lambda.arn
}

output "api-domain-name" {
  value = aws_apigatewayv2_domain_name.api-domain.domain_name
}

output "mysql8_parameter_group_name" {
  value = aws_db_parameter_group.mysql-8-db-param-group.name
}

output "db_access_externally_security_group" {
  value = aws_security_group.allow_access_to_db_externally.id
}