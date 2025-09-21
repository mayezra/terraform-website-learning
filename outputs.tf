output "cloudfront_url" {
  description = "Your HTTPS site URL"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

