variable "site_domain" {
  description = "Bucket + CloudFront name (must be unique)"
  type        = string
  default     = "my-terraform.example.com"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}
