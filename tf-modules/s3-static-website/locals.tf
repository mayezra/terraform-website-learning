# tf-modules/s3-static-website/locals.tf

locals {
  # ============================================
  # Computed Resource Names
  # ============================================
  # These avoid repetition and ensure consistency
  bucket_arn            = aws_s3_bucket.this.arn
  bucket_regional_domain = aws_s3_bucket.this.bucket_regional_domain_name
  
  # Origin Access Control name (more descriptive)
  oac_name = "${var.bucket_name}-oac"
  
  # Origin ID for CloudFront (currently hardcoded as "s3-origin" in main.tf)
  origin_id = "s3-${var.bucket_name}"
  
  # ============================================
  # Lifecycle Configuration
  # ============================================
  # Centralize these magic numbers for easier tuning
  noncurrent_glacier_days = 30  # Days before moving to Glacier
  noncurrent_expiry_days  = 90  # Days before deleting old versions
  release_expiry_days     = 100 # Days before deleting old releases
  
  # ============================================
  # Cache Behavior Settings
  # ============================================
  # Make these configurable if you want different settings per environment
  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]
  
  # ============================================
  # Tags - Merge Module Defaults with User Tags
  # ============================================
  # This allows the workload to add/override tags
  tags = merge(
    {
      ManagedBy = "Terraform"
      Module    = "s3-static-website"
    },
    var.tags  # User-provided tags from the workload
  )
}
