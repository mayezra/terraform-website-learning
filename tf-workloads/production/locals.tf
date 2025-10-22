locals {
  # Add environment prefix
  bucket_name = var.site_domain
  
  # Useful tags that can be reused
  common_tags = {
    Project     = "terraform-website-learning"
    Owner       = "mayezra"
    Environment = "production"
    ManagedBy   = "terraform"
  }
  
  # Calculate full CloudFront domain
  cloudfront_domain = "https://${module.static_site.cdn_domain}"
}
