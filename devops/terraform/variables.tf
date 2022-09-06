variable "code_version" {
  type = string
}

variable "ss_db_instance_class" {
  default = "db.t3.micro"
  type    = string
}

variable "ss_reserved_concurrent_executions_async" {
  default = 10
  type    = number
}

variable "ss_reserved_concurrent_executions_sync" {
  default = 5
  type    = number
}
variable "log_retention_days" {
  default = 1
  type    = number
}

variable "ztm_reserved_concurrent_executions_async" {
  default = 1
  type    = number
}

variable "ztm_reserved_concurrent_executions_sync" {
  default = 5
  type    = number
}

variable "dashboard_acm_certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:139620956858:certificate/91fcb6d0-bda7-44bb-9506-ec19255832a3"
}

variable "is_production" {
  type        = bool
  default     = true
  description = "Implements any security measures required for production environment"
}

variable "s3_vpc_address" {
  type = string
}

variable "cognito_client_id" {
  type    = string
  default = "1c6tnv36hslllcu6lh94q10pjb"
}

variable "cognito_user_pool_id" {
  type    = string
  default = "eu-central-1_ZqrkVVDHe"
}

variable "cognito_environment" {
  type        = string
  description = "We share Cognito among all dev environments to avoid redundant work with user craeting for tests"
  default     = "dev"
}


locals {
  vpc_id                 = "vpc-852397ef"
  default_security_group = "sg-6a706a17"
  default_subnet_ids     = ["subnet-24914968", "subnet-d95a90a5", "subnet-ef920d85"]
  zone_id                = "Z05065703RC2A4UXV1OYL"
  #Password used for direct communication between services with full admin privileges
  m2m_password = "44b1112d-2934-4a73-96ef-e9fab4eb5019"
}
