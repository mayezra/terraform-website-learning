# tf-modules/s3-static-website/variables.tf

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be valid DNS name (lowercase, numbers, hyphens, dots)."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
