module "commons" {
  source        = "./commons"
  code_version  = var.code_version
  vpc_id        = local.vpc_id
  is_production = var.is_production
  zone_id       = local.zone_id
}

module "user_service" {
  source               = "./us"
  is_production        = var.is_production
  code_version         = var.code_version
  log_retention_days   = var.log_retention_days
  api-domain-name      = module.commons.api-domain-name
  cognito_client_id    = var.cognito_client_id
  cognito_user_pool_id = var.cognito_user_pool_id
  cognito_environment  = var.cognito_environment
  m2m_password         = local.m2m_password
}

module "dashboard" {
  source               = "./dashboard"
  acm_certificate_arn  = var.dashboard_acm_certificate_arn
  api_url              = module.commons.api-domain-name
  is_production        = var.is_production
  zone_id              = local.zone_id
  code_version         = var.code_version
  cognito_client_id    = var.cognito_client_id
  cognito_environment  = var.cognito_environment
  cognito_user_pool_id = var.cognito_user_pool_id
}

module "logging" {
  source       = "./logging"
  code_version = var.code_version
  log_groups = concat(
    module.user_service.log_groups
  )
  log_groups_providers = []
}
