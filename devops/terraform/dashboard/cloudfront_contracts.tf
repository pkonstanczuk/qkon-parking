resource "aws_cloudfront_distribution" "contracts_s3_distribution" {
  origin {
    domain_name         = aws_s3_bucket.contracts-ui.bucket_regional_domain_name
    origin_id           = local.contracts_s3_origin_id
    connection_attempts = 3
    connection_timeout  = 10
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.parkq.cloudfront_access_identity_path
    }
  }
  custom_error_response {
    error_code         = 404
    response_page_path = "/index.html"
    response_code      = 200
  }
  custom_error_response {
    error_code         = 400
    response_page_path = "/index.html"
    response_code      = 200
  }
  custom_error_response {
    error_code         = 403
    response_page_path = "/index.html"
    response_code      = 200
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Parkq contracts for env ${terraform.workspace}"
  default_root_object = "index.html"

  aliases = [local.contract_domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.contracts_s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 30
    max_ttl                = 30
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["US", "CA", "GB", "CN", "IN"]
    }
  }

  tags = local.tags

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
  }
}

resource "aws_route53_record" "contract_www" {
  count   = 1
  zone_id = var.zone_id
  name    = local.contract_domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.contracts_s3_distribution.domain_name]
}