locals {
  environment = "production"

  bucket_name = var.site_domain
  common_tags = {
    Project     = var.project_name
    Owner       = var.owner
    Environment = local.environment
    ManagedBy   = "terraform"
    Workload    = "static-website"
  }

  # Calculate full CloudFront domain
  cloudfront_domain = "https://${module.static_site.cdn_domain}"
}
