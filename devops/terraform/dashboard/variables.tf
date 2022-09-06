variable "acm_certificate_arn" {
  type = string
}

variable "api_url" {
  type = string
}

variable "zone_id" {
  type = string
}
variable "is_production" {
  type        = bool
  description = "Implements any security measures required for production environment"
  default     = true
}

variable "code_version" {
  type        = string
  description = "deployed version"
}

variable "cognito_client_id" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_environment" {
  type = string
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  service_name           = "vizyah-dashboard"
  service_short_name     = "dashboard"
  s3_origin_id           = "dashboard-bucket-origin-${terraform.workspace}"
  contracts_s3_origin_id = "contracts-bucket-origin-${terraform.workspace}"
  tags                   = {
    environment : terraform.workspace, service : local.service_name, vizyah : true, module : "vizyah"
  }
}
