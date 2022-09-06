output "bucket_name" {
  value = aws_s3_bucket.cloudfront_bucket.bucket
}

output "contracts_ui_bucket_name" {
  value = aws_s3_bucket.contracts-ui.bucket
}

output "contracts_ui_address" {
  value = aws_route53_record.contract_www[0].name
}

output "www_main_address" {
  value = aws_route53_record.www[0].name
}
