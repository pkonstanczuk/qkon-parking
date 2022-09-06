resource "aws_cloudwatch_query_definition" "last_version_logs" {
  name = "${terraform.workspace}-last-version-logs"

  log_group_names = var.log_groups

  query_string = <<EOF
fields  @message
| parse @message "[*][Build:*][Service:*][*]*" as messageTime, buildVersion, serviceName, logType,messageContent
| filter buildVersion = "${var.code_version}"
| filter logType !="metric"
| display logType,messageContent, serviceName
EOF
}
#Split to two groups as there is a limit in one fropu
resource "aws_cloudwatch_query_definition" "all_services_errors" {
  name = "${terraform.workspace}-not-provider-errors"

  log_group_names = var.log_groups

  query_string = <<EOF
filter @message like /(?i)Error/ or @message like /(?i)Exception/
| fields @log as Service,@timestamp as Timestamp, @requestId as RequestID, @message as Message, @duration as DurationInMS
| sort Timestamp desc
EOF
}

resource "aws_cloudwatch_query_definition" "providers_errors" {
  name = "${terraform.workspace}-provider-errors"

  log_group_names = var.log_groups_providers

  query_string = <<EOF
filter @message like /(?i)Error/ or @message like /(?i)Exception/
| fields @log as Service,@timestamp as Timestamp, @requestId as RequestID, @message as Message, @duration as DurationInMS
| sort Timestamp desc
EOF
}
