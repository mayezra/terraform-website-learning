output "bucket_name" { value = aws_s3_bucket.this.bucket }                   # raw bucket name from resource
output "cdn_domain" { value = aws_cloudfront_distribution.this.domain_name } # raw CDN domain (d123.cloudfront.net)

