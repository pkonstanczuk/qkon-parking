locals {
  contract_domain = "parkq-${terraform.workspace}-contracts.dev.vizyah.co"
}


resource "aws_s3_bucket" "cloudfront_bucket" {
  bucket        = "parkq-${terraform.workspace}-dashboard-bucket"
  tags          = local.tags
  force_destroy = !var.is_production
}

resource "aws_s3_bucket_policy" "cloudfront_bucket" {
  bucket = aws_s3_bucket.cloudfront_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_bucket.json
}

resource "aws_s3_bucket_acl" "cloudfront_bucket" {
  bucket = aws_s3_bucket.cloudfront_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "cloudfront_bucket" {
  bucket                  = aws_s3_bucket.cloudfront_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "contracts-ui" {
  bucket        = local.contract_domain
  tags          = local.tags
  force_destroy = true
}

resource "aws_s3_bucket_policy" "contracts-ui" {
  bucket = aws_s3_bucket.contracts-ui.id
  policy = data.aws_iam_policy_document.contracts-ui.json
}

resource "aws_s3_bucket_acl" "contracts-ui" {
  bucket = aws_s3_bucket.contracts-ui.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "contracts-ui" {
  bucket                  = aws_s3_bucket.contracts-ui.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "contracts-ui" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.parkq.id}"]
    }

    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.contracts-ui.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "cloudfront_bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.parkq.id}"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.cloudfront_bucket.arn}/*"
    ]
  }
}