locals {
  main_domain_name     = "${terraform.workspace}.parkq.co"
  contract_domain_name = "api.${terraform.workspace}.parkq.co"
}

resource "aws_cloudfront_origin_access_identity" "parkq" {
  comment = "Parkq access identity for env ${terraform.workspace}"
}

