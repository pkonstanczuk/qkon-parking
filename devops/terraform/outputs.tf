output "dashboard_bucket_name" {
  value = module.dashboard.bucket_name
}

output "contracts_ui_bucket_name" {
  value = module.dashboard.contracts_ui_bucket_name
}

output "contracts_url" {
  value = module.dashboard.contracts_ui_address
}

output "dashboard_url" {
  value = module.dashboard.www_main_address
}
