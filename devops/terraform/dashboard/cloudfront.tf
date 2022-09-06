resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name         = aws_s3_bucket.cloudfront_bucket.bucket_regional_domain_name
    origin_id           = local.s3_origin_id
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
  comment             = "Parkq dashboard for env ${terraform.workspace}"
  default_root_object = "index.html"

  aliases = [local.main_domain_name]

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = local.s3_origin_id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.parkq-api.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 30
    max_ttl                = 300
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

resource "aws_route53_record" "www" {
  count   = 1
  zone_id = var.zone_id
  name    = local.main_domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.s3_distribution.domain_name]
}

resource "aws_cloudfront_response_headers_policy" "parkq-api" {
  name = "parkq-api-${terraform.workspace}"

  custom_headers_config {
    items {
      header   = "code_version"
      override = true
      value    = var.code_version
    }
    items {
      header   = "cognito_user_pool_id"
      override = true
      value    = var.cognito_user_pool_id
    }
    items {
      header   = "cognito_environment"
      override = true
      value    = var.cognito_environment
    }
    items {
      header   = "cognito_client_id"
      override = true
      value    = var.cognito_client_id
    }
  }
}