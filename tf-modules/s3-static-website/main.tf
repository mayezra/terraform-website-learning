# Create a private S3 bucket
resource "aws_s3_bucket" "this" {             # define an S3 bucket resource; label "this" by convention
  bucket = var.bucket_name                     # bucket name comes from module input (set by workload)
  tags   = local.tags                          # apply standard tags defined in locals.tf
}

# enable versioning (keeps old copies of objects)
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce “no public access” at the account or bucket, nobody on the public internet can read my bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id   # attach to the bucket above
  block_public_acls       = true                    # block ACLs that make things public
  block_public_policy     = true                    # block bucket policies that are public
  ignore_public_acls      = true                    # ignore any public ACLs
  restrict_public_buckets = true                    # prevent public bucket-wide policies
}

# enforce bucket-owner ownership, regardless of who uploads, the bucket owner still own the objects and won’t be blocked by ACLs.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Allow CloudFront to sign requests to S3 (modern OAC mechanism)- CloudFront uses an Origin Access Control to sign requests.
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.bucket_name}-oac"   # readable name
  origin_access_control_origin_type = "s3"                       # origin is S3
  signing_behavior                  = "always"                   # always sign requests
  signing_protocol                  = "sigv4"                    # AWS Signature v4
}

# Create the CDN distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = true                   # activate distribution
  default_root_object = "index.html"           # serve index.html by default

  origin {                                     # where CloudFront fetches content
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name  # S3 origin DNS
    origin_id                = "s3-origin"                                     # internal ID
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id     # tie to OAC above
    s3_origin_config { origin_access_identity = "" }                            # required empty field when using OAC
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"          # reference the origin block
    viewer_protocol_policy = "redirect-to-https"  # force HTTPS for users
    allowed_methods        = ["GET","HEAD"]       # static site: read only
    cached_methods         = ["GET","HEAD"]       # cache read methods
    compress               = true                 # enable gzip/brotli compression

    forwarded_values {
      query_string = false                        # don’t vary cache on query strings
      cookies { forward = "none" }                # don’t forward cookies (better caching)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true         # free HTTPS on *.cloudfront.net
  }
}

# Build an IAM policy document that allows ONLY THIS CloudFront to read objects from S3
data "aws_iam_policy_document" "allow_cf" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

# Attach the generated policy to the S3 bucket
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_cf.json

  # optional but helpful to avoid first-apply race conditions:
  depends_on = [
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_ownership_controls.this
  ]
}


# Lifecycle policy for old releases cleanup
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  # Rule 1: Delete old releases after 90 days
  rule {
    id     = "delete-old-releases"
    status = "Enabled"

    filter {
      prefix = "releases/"
    }

    expiration {
      days = 90
    }
  }

  # Rule 2: Archive old versions to cheaper storage
  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}
