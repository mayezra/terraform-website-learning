variable "region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for website hosting"
  type        = string
}

