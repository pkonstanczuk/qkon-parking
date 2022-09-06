data "aws_region" "current" {}

resource "aws_cloudwatch_dashboard" "basic-logs" {
  dashboard_name = "parkq-dashboard-${terraform.workspace}"

  dashboard_body = templatefile(
    "${path.module}/basicDashboardTemplate.json",
    {
      environment = terraform.workspace
      aws_region      = data.aws_region.current.name
    }
  )
}

resource "aws_cloudwatch_dashboard" "error-logs" {
  dashboard_name = "parkq-dashboard-${terraform.workspace}-errors"

  dashboard_body = templatefile(
    "${path.module}/errorDashboardTemplate.json",
    {
      environment = terraform.workspace
      aws_region      = data.aws_region.current.name
    }
  )
}