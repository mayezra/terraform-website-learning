# tf-workloads/production/variables.tf

variable "site_domain" {
  description = "Bucket + CloudFront name (must be globally unique)"
  type        = string
  default     = "my-terraform.example.com"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name for tagging and identification"
  type        = string
  default     = "terraform-website-learning"
}

variable "owner" {
  description = "Owner/team responsible for this infrastructure"
  type        = string
  default     = "mayezra"
}

