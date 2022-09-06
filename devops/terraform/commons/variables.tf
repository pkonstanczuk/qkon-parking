variable "vpc_id" {
  type = string
}

variable "code_version" {
  type        = string
  description = "deployed version"
}

variable "is_production" {
  type        = bool
  description = "Implements any security measures required for production environment"
}
variable "zone_id" {
  type = string
}

locals {
  service_name = "commons"
  tags         = {
    environment : terraform.workspace, service : local.service_name, vizyah : true, module : "parkq"
  }
}