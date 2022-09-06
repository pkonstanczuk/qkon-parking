variable "is_production" {
  type        = bool
  description = "Implements any security measures required for production environment"
  default     = true
}

variable "code_version" {
  type        = string
  description = "deployed version"
}

variable "m2m_password" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "api-domain-name" {
  type    = string
  default = "api.dev.parkq.co"
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
  service_name       = "user-service"
  service_short_name = "us"
  tags               = {
    environment : terraform.workspace, service : local.service_name, vizyah : true, module : "parkq"
  }
}
